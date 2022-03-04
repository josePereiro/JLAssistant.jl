## ---------------------------------------------------------
# CLI
function run_commit_to_registry(argv::Vector=ARGS)
    
    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "--pkgdir", "-d"
            help = "the package dir"
            arg_type = String
            default = dirname(Base.current_project())
        "--registry", "-r"
            help = "-r=Name specify the register to record to"
            arg_type = String
            default = ""
        "--no-push", "-n"
            help = "If the registry will NOT be push"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgdir = parsed_args["pkgdir"]
    registry = parsed_args["registry"]
    push = !parsed_args["no-push"]
    
    ## ---------------------------------------------------------
    _commit_to_registry(pkgdir;
        registry, verbose = true, push
    )

end