const _JLSCRIPTS_ENV_PATH_KEY = "JLSCRIPTS_PATH"
const _LOCAL_JLSCRIPTS_ENV_PATH_KEY = "LOCAL_JLSCRIPTS_PATH"

function _resolve_jl_script(name::String)
    
    config = _load_config()

    for jlpaths in [
            get(config, _LOCAL_JLSCRIPTS_ENV_PATH_KEY, String[]), # local
            get(config, _JLSCRIPTS_ENV_PATH_KEY, String[])        # global
        ]
        for path0 in jlpaths
            paths = isdir(path0) ? readdir(path0; join = true) : [path0]
            for fn in filter(isfile, paths)
                name0 = basename(fn)
                name0 == name && return fn
                name0 = replace(name0, ".jl" => "")
                name0 == name && return fn
            end
        end
    end
    
    return ""
end

function _run_jl_script(name::String)
    
    path = _resolve_jl_script(name)
    if isempty(path) 
        _info("SCRIPT NOT FOUND"; name)
        return
    end

    _info("RUNNING"; path)

    Base.include(Main, path)

    println()
    println("."^30)
    println()
end
