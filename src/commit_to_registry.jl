function commit_to_registry(pkg::String; 
        registry::String = "", verbose = false, push = true
    )

    # parse args
    pkg = isempty(pkg) ? basename(pwd()) : pkg

    # add to registry
    verbose && _info("Update registry"; pkg, registry, push)
    isempty(registry) ?
        LocalRegistry.register(pkg; push) :
        LocalRegistry.register(pkg; registry, push)

    return pkg
end

## ---------------------------------------------------
function run_commit_to_registry(argv::Vector=ARGS)
    
    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "--pkgdir", "-d"
            help = "the package dir"
            arg_type = String
            default = pwd()
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
    commit_to_registry(pkgdir;
        registry, verbose = true, push
    )

end