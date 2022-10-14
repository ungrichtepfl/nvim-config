local M = {}

-- TODO: backfill this to template
M.setup = function()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		-- disable virtual text
		virtual_text = false,
		-- show signs
		signs = {
			active = signs,
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

local function lsp_highlight_document(client)
	-- Set autocommands conditional on server_capabilities
	if client.server_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

local function lsp_keymaps(bufnr)
	local function opts(desc)
		return { noremap = true, silent = true, buffer = bufnr, desc = "Lsp: " .. desc }
	end

	vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts("Go to declaration"))
	vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts("Go to definition"))
	vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts("Hover info"))
	vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts("Go to implementation"))
	vim.keymap.set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts("Signature help"))
	--[[ vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts("Rename variable")) ]]
	vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts("Go to references"))
	-- vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts("Code actions"))
	-- vim.keymap.set("n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts("Open diagnostics"))
	vim.keymap.set(
		"n",
		"[d",
		'<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>',
		opts("Go to previous diagnostics")
	)
	vim.keymap.set(
		"n",
		"gl",
		'<cmd>lua vim.diagnostic.open_float({ border = "rounded" })<CR>',
		opts("Show diagnostics")
	)
	vim.keymap.set(
		"n",
		"]d",
		'<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>',
		opts("Go to next diagnostics")
	)
	--[[ vim.keymap.set("n", "<leader>ld", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts("Set location list")) ]]
	vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format{async = true}' ]])
end

M.on_attach = function(client, bufnr)
	if client.name == "tsserver" then
		client.resolved_capabilities.document_formatting = false
	end
	lsp_keymaps(bufnr)
	lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
	vim.notify("'cmp_nvim_lsp' plugin not found!")
	return M
end

M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M
