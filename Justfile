dev-server:
	tortuga -v serve dev --port 8000 --hostname 127.0.0.1

build-x86:
	cargo build --release --target x86_64-unknown-linux-musl
