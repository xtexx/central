---
title: 'Development environment'
license: 'Apache-2.0'
origin_url: 'https://github.com/go-gitea/gitea/blob/ec1feedbf582b05b6a5e8c59fb2457f25d053ba2/docs/content/development/hacking-on-gitea.en-us.md'
---

This page lists a few options to set up a productive development environment for working on Forgejo.

## VSCodium

[VSCodium](https://vscodium.com/) is an open source version of the Visual Studio Code IDE.
The [Go integration for Visual Studio Code](https://code.visualstudio.com/docs/languages/go) works
with VSCodium and is a viable tool to work on Forgejo.

First, run `cp -r contrib/ide/vscode .vscode` to create new directory `.vscode` with the contents of folder [contrib/ide/vscode](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/contrib/ide/vscode) at the root of the repository. Then, open the project directory in VSCodium.

You can now use `Ctrl`+`Shift`+`B` to build the gitea executable and `F5` to run it in debug mode.

Tests can be run by clicking on the `run test` or `debug test` button above their declaration.

Go code is formatted automatically when saved.

## Emacs

Emacs has [a Go mode](https://github.com/golang/tools/blob/master/gopls/doc/emacs.md) that can likely be used to work on Forgejo's code base.
Do you know how to configure it properly? Why not document that here?

## Vim

Vim has [a Go plugin](https://github.com/fatih/vim-go) that can likely be used to work on Forgejo's code base.
Do you know how to configure it properly? Why not document that here?

## Neovim

Here's a minimal example that configures `gopls` and `golangci_lint_ls` using
the `Lazy.nvim` plugin manager.

<details>
<summary>init.lua</summary>

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"neovim/nvim-lspconfig",
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = vim.fn.executable("make") == 1,
			},
		},
	},
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local on_attach = function(client, bufno)
	-- depricated since neovim 0.10
	-- vim.api.nvim_buf_set_option(bufno, "omnifunc", "v:lua.vim.lsp.omnifunc")
	vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufno })

	local ts = require("telescope.builtin")
	local opts = { buffer = bufno }

	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gtd", vim.lsp.buf.type_definition, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gu", ts.lsp_references, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)
	vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ async = true })
	end, opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

require("lspconfig")["gopls"].setup({
	capabilities = capabilities,
	settings = {},
	on_attach = on_attach,
})

require("lspconfig")["golangci_lint_ls"].setup({
	capabilities = capabilities,
	settings = {},
	on_attach = on_attach,
})
```

</details>
