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
        "--do-release", "-R"
            help = "Use gh cli to create a release"
            action = :store_true
        "--check-dev", "-D"
            help = "Check if there is any dep in dev mode"
            action = :store_true
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
    pkgdir = parsed_args["pkgdir"]
    registry = parsed_args["registry"]
    do_release = parsed_args["do-release"]
    check_dev = parsed_args["check-dev"]
    up_major = parsed_args["up-major"]
    up_minor = parsed_args["up-minor"]
    up_patch = parsed_args["up-patch"]

    ## ---------------------------------------------------------
    _print_options(;
        new_version, pkgdir, registry, do_release, 
        check_dev, up_major, up_minor, up_patch
    )

    ## ---------------------------------------------------------
    _create_pkg_version(pkgdir;
        new_version, 
        do_release, check_dev,
        up_major, up_minor, up_patch, registry
    )

end