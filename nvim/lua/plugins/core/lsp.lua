-- 作用: 统一语言服务器与诊断体验
-- 包含: neovim/nvim-lspconfig, mason-org/mason-lspconfig.nvim
local function add_unique(list, items)
  local seen = {}
  for _, v in ipairs(list) do
    seen[v] = true
  end
  for _, v in ipairs(items) do
    if not seen[v] then
      table.insert(list, v)
      seen[v] = true
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      },
      inlay_hints = { enabled = true },
      -- Codelens 会在部分语言里于 BufEnter/InsertLeave 等时机刷新，
      -- 从文件树打开文件时容易带来明显卡顿，先默认关闭。
      codelens = { enabled = false },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        pyright = {},
        ruff = {},
        html = {},
        cssls = {},
        tailwindcss = {
          settings = {
            tailwindCSS = {
              emmetCompletions = true,
              classAttributes = {
                "class",
                "className",
                "class:list",
                "ngClass",
              },
              experimental = {
                classRegex = {
                  { "tw`([^`]*)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "tw=\"([^\"]*)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "tw={(.-)}", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "twMerge\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "tv\\(([^)]*)\\)", "['\"]([^\"]*)['\"]" },
                  { "clsx\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                },
              },
            },
          },
        },
        vtsls = {
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = { completeFunctionCalls = true },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              format = { enable = true },
              validate = true,
            },
          },
        },
        marksman = {},
        jsonls = {},
        clangd = {},
        texlab = {},
        cmake = {},
      },
      setup = {
        ruff = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            client.server_capabilities.hoverProvider = false
          end)
        end,
        vtsls = function(_, opts)
          opts.settings.javascript = vim.tbl_deep_extend(
            "force",
            {},
            opts.settings.typescript or {},
            opts.settings.javascript or {}
          )
        end,
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      add_unique(opts.ensure_installed, {
        "lua_ls",
        "pyright",
        "ruff",
        "html",
        "cssls",
        "tailwindcss",
        "vtsls",
        "gopls",
        "yamlls",
        "marksman",
        "jsonls",
        "clangd",
        "texlab",
        "cmake",
      })
    end,
  },
}
