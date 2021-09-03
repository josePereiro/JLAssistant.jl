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

## ---------------------------------------------------
function push_pkg_version(pkgdir=pwd();
        new_version::String="",
        up_major = false,
        up_minor = false,
        up_patch = false,
        registry::String=""
    )

    # find project
    !isdir(pkgdir) && error("pkgdir '$pkgdir' not found")
    projfile = Base.current_project(pkgdir)
    (isnothing(projfile) || isempty(dirname(projfile)) || !isfile(projfile)) && error("Project file not found")
    projfile = abspath(projfile)

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

    @info("Package current status", pkg_name, pkg_uuid, pkg_version)
    
    # write back Project
    projdict["version"] = string(new_version)
    _write_project(projfile, projdict) 
    
    println()
    @info("Package new status", pkg_name, pkg_uuid, new_version)
    
    # commit new project
    println()
    @info("Commiting updated project")
    println()
    run(Cmd(Cmd(["git", "add", projfile]); dir=pkgdir))
    println()
    run(Cmd(Cmd(["git", "commit", "-m", "up to $(new_version)"]); dir=pkgdir))

    # tag and push
    println()
    @info("Tagging")
    println()
    tag = string("v", new_version)
    run(Cmd(Cmd(["git", "tag", tag]); dir=pkgdir))
    run(Cmd(Cmd(["git", "push", "origin", tag]); dir=pkgdir))

    # update registry
    println()
    @info("Update registry", registry, pkg_name, new_version)
    println()
    isempty(registry) ? 
        LocalRegistry.register(pkgdir; push=true) :
        LocalRegistry.register(pkgdir; registry, push=true)

    return pkgdir
end