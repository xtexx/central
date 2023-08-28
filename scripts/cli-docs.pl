#!/usr/bin/perl

use strict;
use warnings;

# Add the frontmatter and a note at the top of the file
print <<EOM;
---
title: Forgejo CLI
license: 'CC-BY-SA-4.0'
---
<!--
This page should not be edited manually.
To update this page, run the following command from the root of the docs repo:
```
forgejo docs | perl ./scripts/cli-docs.pl > ./docs/admin/command-line.md
```
-->

_**Note**: this documentation is generated from the output of the Forgejo CLI command `forgejo docs`._

EOM

while (<>) {
	# Replace 'Gitea' with 'Forgejo'
	s/Gitea/Forgejo/g;

	# Change bold formatting to code formatting for CLI parameters at the start of the line
	s/^\*\*(\-\-[^*]+)\*\*(="")?/`$1`/g;

	# Clean up the display of default values
	s/\(default(s to|:) '?([^' )]+)'?\)/_(default: `$2`)_/g;

	# Increase the level of all markdown headings
	s/^#/##/;

	print;
}
