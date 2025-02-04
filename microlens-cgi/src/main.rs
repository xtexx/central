use std::{fs, path::PathBuf};

use microlens_api::{
	core::{Microlens, MicrolensConfig},
	create_router,
};
use serde::{Deserialize, Serialize};

mod cgi;

fn main() {
	let config_path = find_config();
	let config =
		toml::from_str::<Config>(&fs::read_to_string(config_path).unwrap())
			.unwrap();

	let service = Microlens::from_config(config.core).unwrap();
	let router = create_router(service);
	let server = router.into_service();
	cgi::handle(config.cgi, server);
}

fn find_config() -> PathBuf {
	let path = std::env::current_exe().unwrap().canonicalize().unwrap();
	let mut path = path.as_path();
	while let Some(parent) = path.parent() {
		let file = parent.join("microlens.toml");
		if file.is_file() {
			return file;
		}
		path = parent;
	}
	panic!("failed to find microlens configuration.")
}

#[derive(Debug, PartialEq, Eq, Serialize, Deserialize)]
struct Config {
	pub core: MicrolensConfig,
	#[serde(default)]
	pub cgi: CgiConfig,
}

#[derive(Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub(crate) struct CgiConfig {
	#[serde(default)]
	pub path_prefix: String,
	#[serde(default)]
	pub uri_split: Option<String>,
}
