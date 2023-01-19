const _CONFIG_NAMES = ["JLAssistant.toml", ".JLAssistant.toml", ".JLAssistant", ".JLAssistant"]

# global
function _load_global_config()
    for name in _CONFIG_NAMES
        path = joinpath(homedir(), name)
        isfile(path) || continue
        return TOML.parsefile(path)
    end
    return Dict()
end

# local
function _load_local_config(dir)
    for name in _CONFIG_NAMES
        path = joinpath(dir, name)
        isfile(path) || continue
        return TOML.parsefile(path)
    end
    return Dict()
end

# All
function _load_config(dir = pwd())
    config0 = _load_global_config()
    config1 = _load_local_config(dir)
    return merge!(config0, config1)
end