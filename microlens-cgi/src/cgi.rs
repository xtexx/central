use std::collections::HashMap;
use std::io::{Read, Write, stdin, stdout};

use axum::body::Body;
use bytes::Bytes;
use futures::executor::block_on;
use futures::{AsyncReadExt, TryStreamExt};
use http::StatusCode;
use tower_service::Service;

use crate::CgiConfig;

pub type CgiRequest = http::Request<Body>;
pub type CgiResponse = http::Response<Body>;

pub fn handle<S>(config: CgiConfig, mut func: S)
where
	S: Service<CgiRequest, Response = CgiResponse>,
	S::Error: Into<anyhow::Error>,
{
	let env_vars: HashMap<String, String> = std::env::vars().collect();
	let mut stdin = stdin();

	let content_length: usize = env_vars
		.get("CONTENT_LENGTH")
		.and_then(|cl| cl.parse::<usize>().ok())
		.unwrap_or(0);

	let mut stdin_contents = vec![0; content_length];
	stdin.read_exact(&mut stdin_contents).unwrap();
	let request = parse_request(&config, env_vars, Bytes::from(stdin_contents));

	let response = block_on(func.call(request))
		.map_err(|err| err.into())
		.unwrap_or_else(make_error_response);

	let output = serialize_response(response);
	let mut stdout = stdout();
	stdout.write_all(&output).unwrap();
}

fn parse_request(
	config: &CgiConfig,
	env_vars: HashMap<String, String>,
	stdin: Bytes,
) -> CgiRequest {
	let mut req = http::Request::builder();

	req = req
		.method(env_vars.get("REQUEST_METHOD").map_or("GET", String::as_str));

	let mut uri = if let Some(uri_split) = &config.uri_split {
		let uri = env_vars.get("SCRIPT_URI").unwrap();
		if let Some((_, uri)) = uri.split_once(uri_split) {
			uri.to_string()
		} else {
			format!("/{}", uri)
		}
	} else {
		let mut uri = env_vars.get("SCRIPT_NAME").map_or_else(
			|| match std::env::current_exe() {
				Ok(p) => p.to_string_lossy().into_owned(),
				Err(_) => String::new(),
			},
			String::clone,
		);

		if env_vars.contains_key("QUERY_STRING") {
			uri.push_str("?");
			uri.push_str(&env_vars["QUERY_STRING"]);
		}
		uri
	};
	if uri.is_empty() {
		uri.push('/');
	}

	if let Some(uri) = uri.strip_prefix(&config.path_prefix) {
		req = req.uri(uri);
	} else {
		req = req.uri(uri.as_str());
	}

	if let Some(v) = env_vars.get("SERVER_PROTOCOL") {
		if v == "HTTP/0.9" {
			req = req.version(http::version::Version::HTTP_09);
		} else if v == "HTTP/1.0" {
			req = req.version(http::version::Version::HTTP_10);
		} else if v == "HTTP/1.1" {
			req = req.version(http::version::Version::HTTP_11);
		} else if v == "HTTP/2.0" {
			req = req.version(http::version::Version::HTTP_2);
		} else {
			unimplemented!("Unsupport HTTP SERVER_PROTOCOL {:?}", v);
		}
	}

	for key in env_vars.keys().filter(|k| k.starts_with("HTTP_")) {
		let header: String = key
			.chars()
			.skip(5)
			.map(|c| if c == '_' { '-' } else { c })
			.collect();
		req = req.header(header.as_str(), env_vars[key].as_str().trim());
	}

	req = add_header(req, &env_vars, "AUTH_TYPE", "X-CGI-Auth-Type");
	req = add_header(req, &env_vars, "CONTENT_LENGTH", "X-CGI-Content-Length");
	req = add_header(req, &env_vars, "CONTENT_TYPE", "X-CGI-Content-Type");
	req = add_header(
		req,
		&env_vars,
		"GATEWAY_INTERFACE",
		"X-CGI-Gateway-Interface",
	);
	req = add_header(req, &env_vars, "PATH_INFO", "X-CGI-Path-Info");
	req =
		add_header(req, &env_vars, "PATH_TRANSLATED", "X-CGI-Path-Translated");
	req = add_header(req, &env_vars, "QUERY_STRING", "X-CGI-Query-String");
	req = add_header(req, &env_vars, "REMOTE_ADDR", "X-CGI-Remote-Addr");
	req = add_header(req, &env_vars, "REMOTE_HOST", "X-CGI-Remote-Host");
	req = add_header(req, &env_vars, "REMOTE_IDENT", "X-CGI-Remote-Ident");
	req = add_header(req, &env_vars, "REMOTE_USER", "X-CGI-Remote-User");
	req = add_header(req, &env_vars, "REQUEST_METHOD", "X-CGI-Request-Method");
	req = add_header(req, &env_vars, "SCRIPT_NAME", "X-CGI-Script-Name");
	req = add_header(req, &env_vars, "SERVER_PORT", "X-CGI-Server-Port");
	req =
		add_header(req, &env_vars, "SERVER_PROTOCOL", "X-CGI-Server-Protocol");
	req =
		add_header(req, &env_vars, "SERVER_SOFTWARE", "X-CGI-Server-Software");

	req.body(Body::from_stream(futures::stream::once(
		futures::future::ready(Ok::<_, anyhow::Error>(stdin)),
	)))
	.unwrap()
}

fn add_header(
	req: http::request::Builder,
	env_vars: &HashMap<String, String>,
	meta_var: &str,
	target_header: &str,
) -> http::request::Builder {
	if let Some(var) = env_vars.get(meta_var) {
		req.header(target_header, var.as_str())
	} else {
		req
	}
}

fn serialize_response(response: CgiResponse) -> Vec<u8> {
	let mut output = String::new();
	output.push_str("Status: ");
	output.push_str(response.status().as_str());
	if let Some(reason) = response.status().canonical_reason() {
		output.push_str(" ");
		output.push_str(reason);
	}
	output.push_str("\n");

	{
		let headers = response.headers();
		let mut keys: Vec<&http::header::HeaderName> = headers.keys().collect();
		keys.sort_by_key(|h| h.as_str());
		let mut send_content_type = true;
		for key in keys {
			if send_content_type
				&& key.as_str().to_ascii_lowercase() == "content-type"
			{
				send_content_type = false;
			}
			output.push_str(key.as_str());
			output.push_str(": ");
			output.push_str(headers.get(key).unwrap().to_str().unwrap());
			output.push_str("\n");
		}
		if send_content_type {
			// some CGI server requires a content-type header
			output.push_str("Content-Type: text/plain\n");
			output.push_str("X-Microlens-Debug-Gen-Content-Type: 1\n");
		}
	}
	output.push_str("\n");

	let mut output = output.into_bytes();
	let (_, body) = response.into_parts();
	futures::executor::block_on(
		body.into_data_stream()
			.map_err(|err| std::io::Error::new(std::io::ErrorKind::Other, err))
			.into_async_read()
			.read_to_end(&mut output),
	)
	.unwrap();

	output
}

fn make_error_response(err: anyhow::Error) -> CgiResponse {
	let body = err.to_string().into_bytes();

	http::response::Builder::new()
		.status(StatusCode::INTERNAL_SERVER_ERROR)
		.header(
			http::header::CONTENT_LENGTH,
			format!("{}", body.len()).as_str(),
		)
		.body(Body::from_stream(futures::stream::once(
			futures::future::ready(Ok::<_, anyhow::Error>(Bytes::from(body))),
		)))
		.unwrap()
}
