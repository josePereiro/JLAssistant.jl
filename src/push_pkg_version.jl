## ---------------------------------------------------
function _key_by(key)
    _toml_order = ["name", "uuid", "authors", "version", "deps", "compat", "extras", "targets"]
    idx = findfirst(isequal(key), _toml_order)
    isnothing(idx) ? 9223372036854775807 : idx
end

function _write_project(projfile, dat) 
    open(projfile, "w") do io
        TOML.print(io, dat; sorted=true, by=_key_by)
    end
end

function _info(msg; kwargs...)
    println()
    @info(msg, kwargs...)
    println()
end

function _warn(msg; kwargs...)
    println()
    @warn(msg, kwargs...)
    println()
end

_Cmd(cmdsv::Vector{String}; kwargs...) = Cmd(Cmd(cmdsv); kwargs...)

## ---------------------------------------------------
function push_pkg_version(pkgdir::AbstractString=pwd();
        new_version::String="",
        up_major = false,
        up_minor = false,
        up_patch = false,
        registry::String=""
    )

    # find project
    !isdir(pkgdir) && error("Package directory '$pkgdir' not found")
    projfile = Base.current_project(pkgdir)
    (isnothing(projfile) || isempty(dirname(projfile)) || !isfile(projfile)) && error("Project file not found")
    projfile = abspath(projfile)
    pkgdir = dirname(projfile)

    # up version
    projdict = TOML.parsefile(projfile)
    pkg_version = VersionNumber(projdict["version"])
    pkg_name = projdict["name"]
    pkg_uuid = projdict["uuid"]
    
    if !isempty(new_version)
        new_version = replace(new_version, "v"=>"")
        new_version = VersionNumber(new_version)
        (pkg_version > new_version) && error("New version $(new_version) is 'older' than current $(pkg_version)")
    elseif up_major
        new_version = VersionNumber(pkg_version.major + 1, 0, 0)
    elseif up_minor
        new_version = VersionNumber(pkg_version.major, pkg_version.minor + 1, 0)
    elseif up_patch
        new_version = VersionNumber(pkg_version.major, pkg_version.minor, pkg_version.patch + 1)
    else
        error("Not new version specify")
    end
    (new_version == pkg_version) && error("Equal new and old versions")


    _info("Package current status"; pkg_name, pkg_uuid, pkg_version)
    
    # write back Project
    projdict["version"] = string(new_version)
    _write_project(projfile, projdict) 
    
    _info("Package new status"; pkg_name, pkg_uuid, new_version)
    
    # commit new project
    _info("Adding new Project.toml")
    run(Cmd(Cmd(["git", "add", projfile]); dir=pkgdir); wait=true)
    _info("Committing new Project.toml")
    run(_Cmd(["git", "commit", "-m", "up to $(new_version)"]; dir=pkgdir); wait=true)
    

    # tag and push
    _info("Tagging")
    tag = string("v", new_version)
    run(_Cmd(["git", "tag", tag]; dir=pkgdir); wait=true)
    run(_Cmd(["git", "push", "origin", tag]; dir=pkgdir); wait=true)

    # update registry
    if registry != "0"
        _info("Update registry"; registry, pkg_name, new_version)
        registry == "1" ?
            LocalRegistry.register(pkgdir; push=true) :
            LocalRegistry.register(pkgdir; registry, push=true)
    else
        _warn("Ignoring registering"; pkg_name, new_version)
    end

    return pkgdir
end

## ---------------------------------------------------
function run_push_pkg_version(pkgdir; argv::Vector=ARGS)
    
    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "--version", "-v"
            help = "the new version to push"
            arg_type = String
            default = ""
        "--registry", "-r"
            help = "-r=Name specify the register to push. Use -r0 to ignore registering and r1 to use installed"
            arg_type = String
            default = "0"
        "--up-major", "-M"
            help = "Will push a new version with the major incremented by 1"
            action = :store_true
        "--up-minor", "-m"
            help = "Will push a new version with the minor incremented by 1"
            action = :store_true
        "--up-patch", "-p"
            help = "Will push a new version with the patch incremented by 1"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    new_version = parsed_args["version"]
    registry = parsed_args["registry"]
    up_major = parsed_args["up-major"]
    up_minor = parsed_args["up-minor"]
    up_patch = parsed_args["up-patch"]

    ## ---------------------------------------------------------
    push_pkg_version(pkgdir;
        new_version, up_major, up_minor, up_patch, registry
    )

end