## ---------------------------------------------------------
# CLI
function run_redo_include_block(argv=ARGS)

    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "pkgdir"
            help = "The package dir"
            arg_type = String
            default = dirname(Base.current_project())
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgdir = parsed_args["pkgdir"]

    ## ---------------------------------------------------------
    _print_options(;pkgdir)

    _redo_include_blocks(pkgdir)
end 