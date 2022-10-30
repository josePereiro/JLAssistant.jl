## ---------------------------------------------------
function _create_pkg_version(pkgdir::AbstractString=pwd();
        new_version::String="",
        up_major = false,
        up_minor = false,
        up_patch = false,
        registry::String="",
        do_release = false, 
        check_dev = true
    )

    # find project
    !isdir(pkgdir) && error("Package directory '$pkgdir' not found")
    projfile = Base.current_project(pkgdir)
    (isnothing(projfile) || isempty(dirname(projfile)) || !isfile(projfile)) && error("Project file not found")
    projfile = abspath(projfile)
    pkgdir = dirname(projfile)

    # check Manifest
    if check_dev
        unreg_pkgs = sort!(_find_unregistered_pkgs(pkgdir))
        !isempty(unreg_pkgs) && error("Some pkgs are in an 'unregistered' mode, pkgs: $(join(unreg_pkgs, ", "))")
    end

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
    _save_project(projfile, projdict) 

    _info("Package new status"; pkg_name, pkg_uuid, new_version)

    # commit new project
    _info("Adding new Project.toml")
    run(_Cmd(["git", "add", projfile]; dir=pkgdir); wait=true)
    _info("Committing new Project.toml")
    run(_Cmd(["git", "commit", "-m", "up to $(new_version)"]; dir=pkgdir); wait=true)
    run(_Cmd(["git", "push"]; dir=pkgdir); wait=true)

    # tag and push
    _info("Tagging")
    tag = string("v", new_version)
    run(_Cmd(["git", "tag", tag]; dir=pkgdir); wait=true)
    run(_Cmd(["git", "push", "origin", tag]; dir=pkgdir); wait=true)

    # update registry
    if registry != "0"
        _info("Update registry"; registry, pkg_name, new_version)
        _commit_to_registry(pkgdir; 
            registry = registry == "1" ? "" : registry, 
            verbose = false, 
            push = true
        )
    else
        _warn("Ignoring registering"; pkg_name, new_version)
    end
    
    if do_release
        # create release
        _info("Creating release"; registry, pkg_name, new_version)
        run(_Cmd(["gh", "release", "create", tag, "--notes", #=release name=# tag]; dir=pkgdir); wait=true)
    end
    
    println()
    return pkgdir
end
