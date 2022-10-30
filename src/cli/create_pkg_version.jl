## ---------------------------------------------------------
# CLI
function run_create_pkg_version(argv::Vector=ARGS)
    
    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "--pkgdir", "-d"
            help = "the package dir"
            arg_type = String
            default = dirname(Base.current_project())
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
        "--do-release", "-s"
            help = "Use gh cli to create a release"
            action = :store_false
        "--up-patch", "-p"
            help = "Will push a new version with the patch incremented by 1"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    new_version = parsed_args["version"]
    pkgdir = parsed_args["pkgdir"]
    registry = parsed_args["registry"]
    up_major = parsed_args["up-major"]
    up_minor = parsed_args["up-minor"]
    up_patch = parsed_args["up-patch"]
    do_release = parsed_args["do-release"]

    ## ---------------------------------------------------------
    _create_pkg_version(pkgdir;
        new_version, up_major, up_minor, up_patch, registry, do_release
    )

end