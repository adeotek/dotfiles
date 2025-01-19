local M = {}

function M.setup()
    -- Get configuration from environment variable or use default
    local selected_config = os.getenv("NVIM_CONFIG") or "adeotek_v2"
    
    -- Load the selected configuration
    require("configs." .. selected_config)
end

return M