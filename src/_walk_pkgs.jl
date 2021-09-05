function _walk_pkgs(f::Function; rootdir::String)
    
    !isdir(rootdir) && error(rootdir, " is not a valid dir")
    @info("rootdir", rootdir); println()

    # precompile pkgs
    keepout(dir) = basename(dir) == ".git"
    walkdown(rootdir; keepout) do path
        name = basename(path)
        !(name in Base.project_names) && return false

        proj = _load_project(path)
        ispackage = haskey(proj, "name")
        name = get(proj, "name", "")
        version = get(proj, "version", "")

        println("\n\n", "-"^50)
        println("Project       : ", path)
        println("ispackage     : ", ispackage)
        println("name          : ", name)
        println("proj version  : ", version)
        println()

        f(path, proj)

        return nothing
    end
end