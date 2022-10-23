module JLAssistant

    import TOML
    import LocalRegistry
    import ArgParse
    import PkgTemplates
    import LibGit2
    import Pkg: Pkg, PackageSpec
    import RegexTools: hex_escape
    import InteractiveUtils
    import InteractiveUtils: clipboard
    
    using FilesTreeTools

    #! include .
    include("bla.jl")

    #! include core
    include("core/_check_imports.jl")
    include("core/_commit_to_registry.jl")
    include("core/_create_pkg_version.jl")
    include("core/_find_imports.jl")
    include("core/_find_unregistered_pkgs.jl")
    include("core/_generate_pkg.jl")
    include("core/_project_toml_utils.jl")
    include("core/_redo_include_block.jl")
    include("core/_walk_pkgs.jl")
    include("core/utils.jl")

    #! include cli
    include("cli/check_imports.jl")
    include("cli/commit_to_registry.jl")
    include("cli/create_pkg_version.jl")
    include("cli/generate_pkg.jl")
    include("cli/import_pkgs.jl")
    include("cli/precompile_projects.jl")
    include("cli/redo_include_block.jl")
    include("cli/update_manifests.jl")
    include("cli/upgrade_manifests.jl")

end