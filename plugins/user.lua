return {
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim", 
      "mfussenegger/nvim-dap",
    },
    ft = {"scala", "sbt"},


    config = function()
      
      local api = vim.api
      local map = vim.keymap.set

      ----------------------------------
      -- OPTIONS -----------------------
      ----------------------------------
      -- global
      vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }

      -- LSP mappings
      map("n", "K",          vim.lsp.buf.hover)
      map("n", "<leader>uL", vim.lsp.codelens.run)
      map("n", "<leader>lr", vim.lsp.buf.rename)
      -- map("n", "<leader>uf", vim.lsp.buf.formatting)
      map("n", "<leader>la", vim.lsp.buf.code_action)
      map("n", "<leader>lh", vim.lsp.buf.signature_help)
      map("n", "<leader>ls", vim.lsp.buf.document_symbol)
      map("n", "<leader>lG", vim.lsp.buf.workspace_symbol)
      map("n", "gd",         vim.lsp.buf.definition)
      map("n", "gI",         vim.lsp.buf.implementation)
      map("n", "gr",         vim.lsp.buf.references)

      map("n", "<leader>ws", function()
        require("metals").hover_worksheet()
      end)

      -- all workspace diagnostics
      map("n", "<leader>aa", vim.diagnostic.setqflist)

      -- all workspace errors
      map("n", "<leader>ae", function()
        vim.diagnostic.setqflist({ severity = "E" })
      end)

      -- all workspace warnings
      map("n", "<leader>aw", function()
        vim.diagnostic.setqflist({ severity = "W" })
      end)

      -- buffer diagnostics only
      map("n", "<leader>d", vim.diagnostic.setloclist)

      map("n", "[c", function()
        vim.diagnostic.goto_prev({ wrap = false })
      end)

      map("n", "]c", function()
        vim.diagnostic.goto_next({ wrap = false })
      end)

      -- Example mappings for usage with nvim-dap. If you don't use that, you can
      -- skip these
      map("n", "<leader>dc", function()
        require("dap").continue()
      end)

      map("n", "<leader>dr", function()
        require("dap").repl.toggle()
      end)

      map("n", "<leader>dK", function()
        require("dap.ui.widgets").hover()
      end)

      map("n", "<leader>dt", function()
        require("dap").toggle_breakpoint()
      end)

      map("n", "<leader>dso", function()
        require("dap").step_over()
      end)

      map("n", "<leader>dsi", function()
        require("dap").step_into()
      end)

      map("n", "<leader>dl", function()
        require("dap").run_last()
      end)

      -- completion related settings
      -- This is similiar to what I use
      local cmp = require("cmp")
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
          { name = "vsnip" },
        },
        snippet = {
          expand = function(args)
            -- Comes from vsnip
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- None of this made sense to me when first looking into this since there
          -- is no vim docs, but you can't have select = true here _unless_ you are
          -- also using the snippet stuff. So keep in mind that if you remove
          -- snippets you need to remove this select
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- I use tabs... some say you should stick to ins-completion but this is just here as an example
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        }),
      })

      ----------------------------------
      -- LSP Setup ---------------------
      ----------------------------------
      local metals_config = require("metals").bare_config()

      -- Example of settings
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      }

      -- *READ THIS*
      -- I *highly* recommend setting statusBarProvider to true, however if you do,
      -- you *have* to have a setting to display this in your statusline or else
      -- you'll not see any messages from metals. There is more info in the help
      -- docs about this
      metals_config.init_options.statusBarProvider = "on"

      -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Debug settings if you're using nvim-dap
      local dap = require("dap")

      dap.configurations.scala = {
        {
          type = "scala",
          request = "launch",
          name = "RunOrTest",
          metals = {
            runType = "runOrTestFile",
            --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
          },
        },
        {
          type = "scala",
          request = "launch",
          name = "Test Target",
          metals = {
            runType = "testTarget",
          },
        },
      }

      metals_config.on_attach = function(client, bufnr)
        require("metals").setup_dap()
      end

      -- Autocmd that will actually be in charging of starting the whole thing
      local nvim_metals_group = api.nvim_create_augroup("nvim-metals", { clear = true })
      api.nvim_create_autocmd("FileType", {
        -- NOTE: You may or may not want java included here. You will need it if you
        -- want basic Java support but it may also conflict if you are using
        -- something like nvim-jdtls which also works on a java filetype autocmd.
        pattern = { "scala", "sbt", "java" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },

   {
     "simrat39/rust-tools.nvim", -- add lsp plugin
     {
       "williamboman/mason-lspconfig.nvim",
       opts = {
         ensure_installed = { "rust_analyzer" },
       },
     },
   },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
          flavour = "mocha", -- latte, frappe, macchiato, mocha
          background = { -- :h background
              light = "latte",
              dark = "mocha",
          },
          transparent_background = false, -- disables setting the background color.
          show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
          term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
          dim_inactive = {
              enabled = false, -- dims the background color of inactive window
              shade = "dark",
              percentage = 0.15, -- percentage of the shade to apply to the inactive window
          },
          no_italic = false, -- Force no italic
          no_bold = false, -- Force no bold
          no_underline = false, -- Force no underline
          styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
              comments = { "italic" }, -- Change the style of comments
              conditionals = { "italic" },
              loops = {},
              functions = {},
              keywords = {},
              strings = {},
              variables = {},
              numbers = {},
              booleans = {},
              properties = {},
              types = {},
              operators = {},
          },
          color_overrides = {},
          custom_highlights = {},
          integrations = {
              cmp = true,
              gitsigns = true,
              nvimtree = true,
              telescope = true,
              notify = false,
              mini = false,
              -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
          },
      })
    end


  },
}

