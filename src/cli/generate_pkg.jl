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
        "--github-user"
            help = "github user/organization"
            arg_type = String
            default = ""
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgname = parsed_args["pkgname"]
    code = parsed_args["code"]
    github_user = parsed_args["github-user"]

    ## ---------------------------------------------------------
    _print_options(;pkgname, code)

    ## ---------------------------------------------------------
    pkgdir = _generate(pkgname; github_user)
    
    ## ---------------------------------------------------------
    if code
        run(Cmd(["code", pkgdir]); wait=true)
    end

end