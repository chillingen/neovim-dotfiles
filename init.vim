call plug#begin()
" Vim-airline and vim-airline-themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" VScode theme
Plug 'Mofiqul/vscode.nvim'
Plug 'savq/melange'
" LuaSnip
Plug 'L3MON4D3/LuaSnip'
" friendly-snippets
Plug 'rafamadriz/friendly-snippets'
" nvim-cmp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'saadparwaiz1/cmp_luasnip'
" devicons
Plug 'kyazdani42/nvim-web-devicons'
" jdtls
Plug 'mfussenegger/nvim-jdtls'
" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
" nvim-treesitter
Plug 'nvim-treesitter/nvim-treesitter'
call plug#end()

let g:airline_theme = "raven"
let g:vscode_style = "dark"
let g:vscode_transparent = 1
let g:vscode_italic_comment = 1
let g:vscode_disable_nvimtree_bg = v:true
colorscheme vscode 

set number
set tabstop=2 softtabstop=2 shiftwidth=2
set cursorcolumn
set cursorline
set mouse=a
set clipboard=unnamed
highlight LineNr ctermfg=darkgrey

lua require("luasnip.loaders.from_vscode").lazy_load()
lua require("luasnip.loaders.from_vscode").lazy_load({ paths = {'./my_snippets'}})

nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
nnoremap <C-t> :tabnew<CR>
nnoremap <C-x> :bw<CR>

let mapleader = ","
" Telescope mappings
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" JDTLS Binds
nnoremap <A-o> <Cmd>lua require'jdtls'.organize_imports()<CR>
nnoremap crv <Cmd>lua require('jdtls').extract_variable()<CR>
vnoremap crv <Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>
nnoremap crc <Cmd>lua require('jdtls').extract_constant()<CR>
vnoremap crc <Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>
vnoremap crm <Esc><Cmd>lua require('jdtls').extract_method(true)<CR>

lua <<EOF
	
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local luasnip = require("luasnip")
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
	    ["<Tab>"] = cmp.mapping(function(fallback)
	      if cmp.visible() then
	        cmp.select_next_item()
	      elseif luasnip.expand_or_jumpable() then
	        luasnip.expand_or_jump()
	      elseif has_words_before() then
	        cmp.complete()
	      else
	        fallback()
	      end
	    end, { "i", "s" }),
	    ["<S-Tab>"] = cmp.mapping(function(fallback)
	      if cmp.visible() then
	        cmp.select_prev_item()
	      elseif luasnip.jumpable(-1) then
	        luasnip.jump(-1)
	      else
	        fallback()
	      end
	    end, { "i", "s" }),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  require('lspconfig')['tsserver'].setup {
    capabilities = capabilities
  }
	require('lspconfig').jdtls.setup{}
	require('lspconfig').rust_analyzer.setup{}

	-- Treesitter stuff
	require'nvim-treesitter.configs'.setup {
		highlight = {
			enable = true
		},
		indent = {
			enable = true
		}
	}
EOF
