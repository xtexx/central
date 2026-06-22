use std::{
    env::args,
    net::SocketAddr,
    str::FromStr,
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
    },
    time::Duration,
};

use anyhow::{Result, bail};
use serde::{Deserialize, Serialize};
use tokio::{
    io::AsyncWriteExt,
    net::{TcpListener, TcpStream},
    spawn,
    sync::{Notify, mpsc},
    task::JoinSet,
    time::sleep,
};
use wechatbot::{BotOptions, ContentType, IncomingMessage, WeChatBot};

static SWITCH_STATE: AtomicBool = AtomicBool::new(false);
static NOTIFY: Notify = Notify::const_new();

#[tokio::main]
async fn main() -> Result<()> {
    let mut bots = Vec::new();
    let mut listen_addrs = Vec::new();

    for (arg_i, arg) in args().enumerate() {
        if arg_i == 0 {
            continue;
        }
        if let Some(cred_path) = arg.strip_prefix("--cred=") {
            println!("Logging in: {}", cred_path);
            let bot = WeChatBot::new(BotOptions {
                cred_path: Some(cred_path.to_string()),
                on_qr_url: Some(Box::new(|url| println!("QR Code: {}", url))),
                on_error: Some(Box::new(|err| eprintln!("Error: {}", err))),
                ..Default::default()
            });
            let creds = bot.login(false).await?;
            println!("Loaded account: {}", creds.account_id);
            bots.push(Arc::new(bot));
        } else if let Some(listen_addr) = arg.strip_prefix("--listen=") {
            listen_addrs.push(SocketAddr::from_str(listen_addr)?);
        } else {
            bail!("unknown argument: {arg}")
        }
    }

    let mut tasks = JoinSet::new();
    let (msgs_tx, msgs_rx) = mpsc::unbounded_channel();

    for listen_addr in &listen_addrs {
        let listener = TcpListener::bind(listen_addr).await?;
        tasks.spawn(async move {
            loop {
                match listener.accept().await {
                    Ok((socket, addr)) => {
                        spawn(serve_inbound_conn(socket, addr));
                    }
                    Err(err) => println!("cannot accept inbound conn: {:?}", err),
                }
            }
        });
    }

    for bot in bots.clone() {
        let handler = {
            let bot = bot.clone();
            let msgs_tx = msgs_tx.clone();
            Box::new(move |msg: &IncomingMessage| msgs_tx.send((bot.clone(), msg.clone())).unwrap())
        };
        bot.on_message(handler).await;

        let bot = bot.clone();
        tasks.spawn(async move { bot.run().await.map_err(anyhow::Error::from) });
    }
    tasks.spawn(async move {
        let mut msgs_rx = msgs_rx;
        while let Some((bot, msg)) = msgs_rx.recv().await {
            if let Err(err) = handle_message(&bot, &msg).await {
                println!("Failed to process message: {err:?}");
            }
        }
        Ok(())
    });
    tasks.spawn(async {
        loop {
            sleep(Duration::from_secs(20)).await;
            NOTIFY.notify_waiters();
        }
    });

    tasks.join_next().await.unwrap()??;
    Ok(())
}

async fn handle_message(bot: &WeChatBot, msg: &IncomingMessage) -> Result<()> {
    match msg.content_type {
        ContentType::Text => {
            println!("Recv: {}", msg.text);
            if msg.text == "开" || msg.text == "ON" {
                println!("Turning ON the switch");
                SWITCH_STATE.store(true, Ordering::SeqCst);
                NOTIFY.notify_waiters();
                bot.reply(&msg, "已开启").await?;
            } else if msg.text == "关" || msg.text == "OFF" {
                println!("Turning OFF the switch");
                SWITCH_STATE.store(false, Ordering::SeqCst);
                NOTIFY.notify_waiters();
                bot.reply(&msg, "已关闭").await?;
            } else {
                println!("Turning OFF the switch");
                SWITCH_STATE.store(false, Ordering::SeqCst);
                NOTIFY.notify_waiters();
                bot.reply(&msg, "未知指令，已关闭开关").await?;
            }
        }
        _ => {
            bot.reply(&msg, "未知指令").await?;
        }
    }
    Ok(())
}

async fn serve_inbound_conn(conn: TcpStream, addr: SocketAddr) {
    println!("new TCP client: {:?}", addr);
    match serve_inbound_conn_impl(conn, addr).await {
        Ok(_) => println!("TCP client disconnected: {addr:?}"),
        Err(err) => println!("TCP connection error: {err:?}"),
    }
}

async fn serve_inbound_conn_impl(mut conn: TcpStream, addr: SocketAddr) -> Result<()> {
    send_msg(&mut conn, &addr, TcpMessage::Version(1)).await?;
    loop {
        let state = SWITCH_STATE.load(Ordering::SeqCst);
        send_msg(&mut conn, &addr, TcpMessage::Update(state)).await?;
        NOTIFY.notified().await;
    }
}

async fn send_msg(conn: &mut TcpStream, addr: &SocketAddr, msg: TcpMessage) -> Result<()> {
    let msg = serde_json::to_string(&msg)?;
    println!("Send: {addr:?}: {msg}");
    conn.write_all(msg.as_bytes()).await?;
    conn.write_all(b"\n").await?;
    conn.flush().await?;
    Ok(())
}

#[derive(Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
enum TcpMessage {
    Version(u32),
    Update(bool),
}
