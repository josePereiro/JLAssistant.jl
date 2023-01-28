const _DEV_ENV_PATH_KEY = "DEV_PATH"

## --------------------------------------------------------
function _walk_devpath(f::Function)

    config = _load_config()
    devpaths = get(config, _DEV_ENV_PATH_KEY, [Pkg.devdir()])

    # precompile pkgs
    keepout(dir) = basename(dir) == ".git"
    for rootdir in devpaths
        !isdir(rootdir) && error(rootdir, " is not a valid dir")
        _break = false
        walkdown(rootdir; keepout) do path 
            _break = f(path) === true 
            _break && return true
            return nothing
        end
        _break && break
    end

end

## --------------------------------------------------------
function _show_dev_workspaces()
    
    founds = String[]
    _walk_devpath() do path
        endswith(path, ".code-workspace") && push!(founds, path)
        return nothing
    end
    
    # Print
    for file in founds
        name = replace(basename(file), ".code-workspace" => "")
        @info(name, file)
    end

    return nothing
end

## --------------------------------------------------------
function _find_dev_workspace(name)

    # name.code-workspace
    name = replace(name, ".code-workspace" => "")
    name = string(name, ".code-workspace")

    found = ""
    _walk_devpath() do path
        if name == basename(path)
            found = path
            return true
        end
        return nothing
    end
    return found
end