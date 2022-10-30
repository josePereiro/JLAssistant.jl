## ---------------------------------------------------------
# CLI
function run_generate_pkg(argv=ARGS)

    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "pkgname"
            help="The package name"
            required = true    
        "--code", "-c"
            help = "Will open the project after creation"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgname = parsed_args["pkgname"]
    code = parsed_args["code"]

    ## ---------------------------------------------------------
    _print_options(;pkgname, code)

    ## ---------------------------------------------------------
    pkgdir = _generate(pkgname)
    
    ## ---------------------------------------------------------
    if code
        run(Cmd(["code", pkgdir]); wait=true)
    end

end