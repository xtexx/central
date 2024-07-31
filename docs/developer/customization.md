---
title: 'Interface customization'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/e865de1e9d65dc09797d165a51c8e705d2a86030/docs/content/administration/customizing-gitea.en-us.md'
---

This sections documents the Forgejo interface customization that requires an intimate knowledge of the underlying codebase. The user interface customization documented and supported for Forgejo admins to use [is found in the corresponding administrator guide section](../../admin/customization/).

Customizing Forgejo is typically done using the `CustomPath` folder - by default this is
the `custom` folder from the working directory (WorkPath), but may be different if your build has
set this differently. This is the central place to override configuration settings,
templates, etc. You can check the `CustomPath` using `forgejo help`. You can also find
the path on the _Configuration_ tab in the _Site Administration_ page. You can override
the `CustomPath` by setting either the `FORGEJO_CUSTOM` environment variable or by
using the `--custom-path` option on the `forgejo` binary. (The option will override the
environment variable.)

If Forgejo is deployed from binary, all default paths will be relative to the Forgejo
binary.

Application settings can be found in file `CustomConf` which is by default,
`$FORGEJO_CUSTOM/conf/app.ini` but may be different if your build has set this differently.

If you are having difficulty with finding the `CustomConf` directory, you can identify
the variable using `forgejo help` or in the logs. This variable can be overridden using
the `--config` option on the `forgejo` binary.

**Note:** Forgejo must perform a full restart to see configuration changes.

## Serving custom public files

To make Forgejo serve custom public files (like pages and images), use the folder
`$FORGEJO_CUSTOM/public/` as the webroot. Symbolic links will be followed.
At the moment, only the following files are served:

- `public/robots.txt`
- files in the `public/.well-known/` folder
- files in the `public/assets/` folder

For example, a file `image.png` stored in `$FORGEJO_CUSTOM/public/assets/`, can be accessed with
the url `http://forgejo.example.com/assets/image.png`.

## Changing the logo

To build a custom logo and/or favicon clone the Forgejo source repository, replace `assets/logo.svg` and/or `assets/favicon.svg` and run
`make generate-images`. `assets/favicon.svg` is used for the favicon only. This will update below output files which you can then place in `$FORGEJO_CUSTOM/public/assets/img` on your server:

- `public/assets/img/logo.svg` - Used for site icon, app icon
- `public/assets/img/logo.png` - Used for Open Graph
- `public/assets/img/avatar_default.png` - Used as the default avatar image
- `public/assets/img/apple-touch-icon.png` - Used on iOS devices for bookmarks
- `public/assets/img/favicon.svg` - Used for favicon
- `public/assets/img/favicon.png` - Used as fallback for browsers that don't support SVG favicons

## Customizing Forgejo pages and resources

Forgejo's executable contains all the resources required to run: templates, images, style-sheets
and translations. Any of them can be overridden by placing a replacement in a matching path
inside the `custom` directory. For example, to replace the default `.gitignore` provided
for C++ repositories, we want to replace `options/gitignore/C++`. To do this, a replacement
must be placed in `$FORGEJO_CUSTOM/options/gitignore/C++`.

Every single page of Forgejo can be changed. Dynamic content is generated using [go templates](https://pkg.go.dev/html/template),
which can be modified by placing replacements below the `$FORGEJO_CUSTOM/templates` directory.

To obtain any embedded file (including templates), the `forgejo embedded` CLI can be used. Alternatively, they can be found in the [`templates`](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/templates) directory of Forgejo source.

Be aware that any statement contained inside `{{` and `}}` are Forgejo's template syntax and
should **not** be touched without fully understanding these components.

Forgejo regularly makes backward incompatible changes to its own templates, which makes templates **very likely to break when upgrading Forgejo**.

Before deploying your changes to production or upgrading a modified Forgejo instance, we urge that you test your custom modifications in a testing environment first.

### Customizing startpage / homepage

Copy [`home.tmpl`](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/templates/home.tmpl) for your version of Forgejo from `templates` to `$FORGEJO_CUSTOM/templates`.
Edit as you wish.
Dont forget to restart your Forgejo to apply the changes.

### Adding links and tabs

If all you want is to add extra links to the top navigation bar or footer, or extra tabs to the repository view, you can put them in `extra_links.tmpl` (links added to the navbar), `extra_links_footer.tmpl` (links added to the left side of footer), and `extra_tabs.tmpl` inside your `$FORGEJO_CUSTOM/templates/custom/` directory.

For instance, let's say you are in Germany and must add the famously legally-required "Impressum"/about page, listing who is responsible for the site's content:
just place it under your "$FORGEJO_CUSTOM/public/assets/" directory (for instance `$FORGEJO_CUSTOM/public/assets/impressum.html`) and put a link to it in either `$FORGEJO_CUSTOM/templates/custom/extra_links.tmpl` or `$FORGEJO_CUSTOM/templates/custom/extra_links_footer.tmpl`.

To match the current style, the link should have the class name "item", and you can use `{{AppSubUrl}}` to get the base URL:
`<a class="item" href="{{AppSubUrl}}/assets/impressum.html">Impressum</a>`

You can add new tabs in the same way, putting them in `extra_tabs.tmpl`.
The exact HTML needed to match the style of other tabs is in the file
[`templates/repo/header.tmpl`](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/templates/repo/header.tmpl).

### Other additions to the page

Apart from `extra_links.tmpl` and `extra_tabs.tmpl`, there are other useful templates you can put in your `$FORGEJO_CUSTOM/templates/custom/` directory:

- `header.tmpl`, just before the end of the `<head>` tag where you can add custom CSS files for instance.
- `body_outer_pre.tmpl`, right after the start of `<body>`.
- `body_inner_pre.tmpl`, before the top navigation bar, but already inside the main container `<div class="full height">`.
- `body_inner_post.tmpl`, before the end of the main container.
- `body_outer_post.tmpl`, before the bottom `<footer>` element.
- `footer.tmpl`, right before the end of the `<body>` tag, a good place for additional JavaScript.

### Using Forgejo variables

It's possible to use various Forgejo variables in your custom templates.

First, _temporarily_ enable development mode: in your `app.ini` change from `RUN_MODE = prod` to `RUN_MODE = dev`. Then add `{{ $ | DumpVar }}` to any of your templates, restart Forgejo and refresh that page; that will dump all available variables.

Find the data that you need, and use the corresponding variable; for example, if you need the name of the repository then you'd use `{{.Repository.Name}}`.

If you need to transform that data somehow, and aren't familiar with Go, an easy workaround is to add the data to the DOM and add a small JavaScript script block to manipulate the data.

## Customizing Forgejo mails

The `$FORGEJO_CUSTOM/templates/mail` folder allows changing the body of every mail of Forgejo.
Templates to override can be found in the
[`templates/mail`](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/templates/mail)
directory of Forgejo source.
Override by making a copy of the file under `$FORGEJO_CUSTOM/templates/mail` using a
full path structure matching source.

Any statement contained inside `{{` and `}}` are Forgejo's template
syntax and shouldn't be touched without fully understanding these components.

## Customizing gitignores, labels, licenses, locales, and readmes.

Place custom files in corresponding sub-folder under `custom/options`.

**NOTE:** The files should not have a file extension, e.g. `Labels` rather than `Labels.txt`

### gitignores

To add custom .gitignore, add a file with existing [.gitignore rules](https://git-scm.com/docs/gitignore) in it to `$FORGEJO_CUSTOM/options/gitignore`

### Labels

Starting with Forgejo 1.19, you can add a file that follows the [YAML label format](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/options/label/Advanced.yaml) to `$FORGEJO_CUSTOM/options/label`:

```yaml
labels:
  - name: 'foo/bar' # name of the label that will appear in the dropdown
    exclusive: true # whether to use the exclusive namespace for scoped labels. scoped delimiter is /
    color: aabbcc # hex colour coding
    description: Some label # long description of label intent
```

The [legacy file format](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/options/label/Default) can still be used following the format below, however we strongly recommend using the newer YAML format instead.

`#hex-color label name ; label description`

### Licenses

To add a custom license, add a file with the license text to `$FORGEJO_CUSTOM/options/license`

### Readmes

To add a custom Readme, add a markdown formatted file (without an `.md` extension) to `$FORGEJO_CUSTOM/options/readme`

**NOTE:** readme templates support **variable expansion**.
currently there are `{Name}` (name of repository), `{Description}`, `{CloneURL.SSH}`, `{CloneURL.HTTPS}` and `{OwnerName}`

### Reactions

To change reaction emoji's you can set allowed reactions at app.ini

```
[ui]
REACTIONS = +1, -1, laugh, confused, heart, hooray, eyes
```

A full list of supported emoji's is at [emoji list](https://codeberg.org/forgejo/discussions/issues/82)

## Customizing fonts

Fonts can be customized using CSS variables:

```css
:root {
  --fonts-proportional:  /* custom proportional fonts * !important;
  --fonts-monospace:  /* custom monospace fonts * !important;
  --fonts-emoji:  /* custom emoji fonts * !important;
}
```
