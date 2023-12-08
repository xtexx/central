---
title: 'Development environment'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/ec1feedbf582b05b6a5e8c59fb2457f25d053ba2/docs/content/development/hacking-on-gitea.en-us.md'
---

This page lists a few options to set up a productive development environment for working on Forgejo.

## VS Codium

[VS Codium](https://vscodium.com/) is an open source version of the Visual Studio Code IDE.
The [Go integration for Visual Studio Code](https://code.visualstudio.com/docs/languages/go) works
with VS Codium and is a viable tool to work on Forgejo.

First, run `cp -r contrib/ide/vscode .vscode` to create new directory `.vscode` with the contents of folder [contrib/ide/vscode](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/contrib/ide/vscode) at the root of the repository. Then, open the project directory in VS Codium.

You can now use `Ctrl`+`Shift`+`B` to build the gitea executable and `F5` to run it in debug mode.

Tests can be run by clicking on the `run test` or `debug test` button above their declaration.

Go code is formatted automatically when saved.

## Emacs

Emacs has [a Go mode](https://github.com/golang/tools/blob/master/gopls/doc/emacs.md) that can likely be used to work on Forgejo's code base.
Do you know how to configure it properly? Why not document that here?

## Vim

Vim has [a Go plugin](https://github.com/fatih/vim-go) that can likely be used to work on Forgejo's code base.
Do you know how to configure it properly? Why not document that here?
