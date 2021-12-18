module JLAssistant

    import TOML
    import LocalRegistry
    import ArgParse
    import PkgTemplates
    import LibGit2
    import Pkg: Pkg, PackageSpec
    import Pkg: @pkg_str
    import RegexTools: hex_escape
    
    using FilesTreeTools

    include("_find_unregistered_pkgs.jl")
    include("_project_toml_utils.jl")
    include("_walk_pkgs.jl")
    include("create_pkg_version.jl")
    include("commit_to_registry.jl")
    include("precompile_projects.jl")
    include("generate_pkg.jl")
    include("utils.jl")
    include("import_pkgs.jl")
    include("update_manifests.jl")
    include("find_imports.jl")
    include("check_imports.jl")

end
