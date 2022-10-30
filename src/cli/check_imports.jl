## ---------------------------------------------------------
# CLI
function run_check_imports(argv=ARGS)

    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "pkgdir"
            help = "The package dir"
            arg_type = String
            default = dirname(Base.current_project())
        "--subfolders", "-s"
            help = "The names (comma separated) of the subfolders to search"
            arg_type = String
            default = "src, scripts"
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgdir = parsed_args["pkgdir"]
    subs = _split_arglist(parsed_args["subfolders"])

    ## ---------------------------------------------------------
    _print_options(;pkgdir, subs) 
    
    ## ---------------------------------------------------------
    _check_imports(pkgdir; subs)
end