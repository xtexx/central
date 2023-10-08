---
title: 'Search Engines Indexation'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/abe8fe352711601fbcd24bf4505f7e0b81a93c5d/docs/content/administration/search-engines-indexation.en-us.md'
---

## Search engines indexation of your Forgejo installation

By default your Forgejo installation will be indexed by search engines.
If you don't want your repository to be visible for search engines read further.

### Block search engines indexation using robots.txt

To make Forgejo serve a custom `robots.txt` (default: empty 404) for top level installations,
create a file called `robots.txt` at the root of the `CustomPath` as displayed in the `/admin` page.

Examples on how to configure the `robots.txt` can be found at [https://moz.com/learn/seo/robotstxt](https://moz.com/learn/seo/robotstxt).

```txt
User-agent: *
Disallow: /
```

If you installed Forgejo in a subdirectory, you will need to create or edit the `robots.txt` in the top level directory.

```txt
User-agent: *
Disallow: /forgejo/
```

### Disallow crawling archives to save disk space

If the archive files are crawled, they will be generated dynamically
and kept around which can amount to a lot of disk. To prevent that
from happening, add the following to the `robots.txt` file:

```txt
User-agent: *
Disallow: /*/*/archive/
```

See also a more complete example [at Codeberg](https://codeberg.org/robots.txt).
