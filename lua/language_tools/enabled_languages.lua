-- Language tools configuration manager
local M = {}

local config_path = vim.fn.stdpath("config") .. "/lua/language_tools/enabled_languages.json"
local config_cache = nil -- Cache for the configuration

-- Get all available languages from our configuration
function M.get_all_languages()
    local languages = {
        "lua",
        "rust",
        "python",
        "javascript", -- (or typescript/typescriptreact ecc)
        "go",
        -- "haskell", -- I am not using haskell as of recently, and is a bit of a pain to set up, so is disabled
        "csharp",
        "yml"
    }

    return languages
end

-- Load the configuration from JSON file
function M.load_config()
    -- Return cached config if available
    if config_cache then
        return config_cache
    end

    -- Check if the config file exists
    if vim.fn.filereadable(config_path) == 0 then
        -- Create default config with all languages enabled
        local default_config = {}
        for _, lang in ipairs(M.get_all_languages()) do
            default_config[lang] = true
        end

        -- Create the JSON file with default configuration
        local json_str = vim.fn.json_encode(default_config)
        local file = io.open(config_path, "w")
        if file then
            file:write(json_str)
            file:close()
            print("Created default language configuration at " .. config_path)
        else
            vim.notify("Failed to create language configuration file", vim.log.levels.ERROR)
            return default_config
        end
    end

    -- Read the config file
    local file = io.open(config_path, "r")
    if not file then
        vim.notify("Failed to read language configuration file", vim.log.levels.ERROR)
        return {}
    end

    local content = file:read("*all")
    file:close()

    -- Parse the JSON content
    local success, config = pcall(vim.fn.json_decode, content)
    if not success or type(config) ~= "table" then
        vim.notify("Invalid language configuration format", vim.log.levels.WARN)
        return {}
    end

    -- Cache the configuration
    config_cache = config

    return config
end

-- Force reload the configuration (clear cache)
function M.reload_config()
    config_cache = nil
    return M.load_config()
end

-- Check if a language is enabled
function M.is_language_enabled(lang)
    local config = M.load_config()
    local all_languages = M.get_all_languages()
    local is_valid_language = false

    -- Check if the language is valid
    for _, valid_lang in ipairs(all_languages) do
        if valid_lang == lang then
            is_valid_language = true
            break
        end
    end

    if not is_valid_language then
        vim.notify("Language '" .. lang .. "' is not defined in language tools configuration", vim.log.levels.WARN)
        return false
    end

    -- Check if the language is missing from config (shouldn't happen with proper initialization)
    if config[lang] == nil then
        vim.notify("Language '" .. lang .. "' is missing in the configuration file", vim.log.levels.WARN)
        return false
    end

    return config[lang] == true
end

return M
