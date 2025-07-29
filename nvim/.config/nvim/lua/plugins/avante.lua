return {
    {
        'yetone/avante.nvim',
        event = 'VeryLazy',
        lazy = false,
        version = false, -- set this if you want to always pull the latest change
        opts = vim.g.copilotEnabled and {
            provider = 'copilot',
        } or {
            provider = 'ollama',
            ollama = {
                --model = 'qwq:32b',
                --model = 'qwen2.5-coder:14b',
                model = 'qwen2.5-coder:14b',
            },
            web_search_engine = {
                provider = 'brave', -- tavily, serpapi, searchapi, google or kagi
            },
            rag_service = {
                enabled = false, -- Enables the RAG service
                host_mount = os.getenv 'HOME', -- Host mount path for the rag service
                provider = 'ollama', -- The provider to use for RAG service (e.g. openai or ollama)
                llm_model = '', -- The LLM model to use for RAG service
                embed_model = '', -- The embedding model to use for RAG service
                endpoint = 'http://localhost:11434', -- The API endpoint for RAG service
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = 'make',
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'stevearc/dressing.nvim',
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            --- The below dependencies are optional,
            'echasnovski/mini.pick', -- for file_selector provider mini.pick
            'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
            'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
            'ibhagwan/fzf-lua',
            'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
            vim.g.copilotEnabled and 'zbirenbaum/copilot.lua',
            {
                -- support for image pasting
                'HakonHarnes/img-clip.nvim',
                event = 'VeryLazy',
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { 'markdown', 'Avante' },
                },
                ft = { 'markdown', 'Avante' },
            },
        },
    },
}
