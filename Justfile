dev-server:
	tortuga -v serve dev --port 8000 --hostname 127.0.0.1

build-x86-gnu:
	cargo build --release --target x86_64-unknown-linux-gnu

cross-x86-musl:
	cross build --release --target x86_64-unknown-linux-musl

zig-x86-musl:
	cargo zigbuild --release --target x86_64-unknown-linux-musl
