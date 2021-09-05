module JLAssistant

    import TOML
    import LocalRegistry
    import ArgParse
    import MyPkgTemplate
    import Pkg
    
    using FilesTreeTools

    include("create_pkg_version.jl")
    include("commit_to_registry.jl")
    include("_project_toml_utils.jl")
    include("precompile_projects.jl")
    include("generate_pkg.jl")
    include("utils.jl")
    include("_walk_pkgs.jl")
    include("import_pkgs.jl")
    include("update_manifests.jl")

end
