[![builds.sr.ht status](https://builds.sr.ht/~fd/rsscombine.svg)](https://builds.sr.ht/~fd/rsscombine)

Forked from [rsscombine](https://github.com/chase-seibert/rsscombine) by [Chase Seibert](https://github.com/chase-seibert).

# RSS Combine

Combine multiple RSS feeds into a single feed, as a service.

## Quick Start

Here is how you run the service locally.
You may need to `brew install golang`, first.

```bash
git clone git@github.com:chase-seibert/rsscombine.git
cd rsscombine
go mod download
go run rsscombine.go
```

## Configuration

You can specify configuration options as either a YAML file, or as environment
variables. Environment variable names should be in all caps, prefixed by
`RSSCOMBINE_` with underscored included.

### Options

See the "Example YAML File" section for example defaults.

| YAML Name              | Environment Variable              | Description                                                                        |
| ---------------------- | --------------------------------- | ---------------------------------------------------------------------------------- |
| title                  | RSSCOMBINE_TITLE                  | Title of the new RSS feed.                                                         |
| link                   | RSSCOMBINE_LINK                   | Link to the new RSS feed. Can be a webpage or the feed URL.                        |
| description            | RSSCOMBINE_DESCRIPTION            | Description of your new feed, shows in RSS readers.                                |
| author_name            | RSSCOMBINE_AUTHOR_NAME            | Your full name, shows in RSS readers.                                              |
| author_email           | RSSCOMBINE_AUTHOR_EMAIL           | Your email, shows in RSS readers.                                                  |
| client_timeout_seconds | RSSCOMBINE_CLIENT_TIMEOUT_SECONDS | Seconds to timeout call from the server to the individual RSS feeds.               |
| feeds                  |                                   | List of feeds to combine. Cannot be specified via environment variable.            |
| feed_urls              | RSSCOMBINE_FEED_URLS              | Optional: URL to parse feed URLs from. If set, this overrides the feeds setting.   |
| feed_exclude_prefixes  | RSSCOMBINE_FEED_EXCLUDE_PREFIXES  | Optional: list of URL prefixes to exclude from feed_urls parsing.                  |
| feed_limit_per_feed    | RSSCOMBINE_FEED_LIMIT_PER_FEED    | Optional: how many items you want to pull from each sub-feed.                      |
| feed_limit             | RSSCOMBINE_FEED_LIMIT             | Optional: how many total entries should appear in the final feed (defaults to 20). |

## Example YAML File

You can create a local `rsscombine.yml` file in this format:

```yaml
title: exozy.me RSS Feed
link: https://feeds.exozy.me/rss.xml
description: exozyme members' RSS feeds
author_name: Ersei
author_email: contact+exozyme@ersei.net
feed_limit: 10
feeds:
  - https://ersei.net/en/blog.atom
  - https://a.exozy.me/index.xml
  - https://aryak.me/rss.xml
  - https://www.1a-insec.net/all.atom.xml
  - https://karawale.in/index.xml
```
