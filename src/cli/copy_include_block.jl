## ---------------------------------------------------------
# CLI
function run_copy_include_block(argv=ARGS)

    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "pkgdir"
            help = "The package dir"
            arg_type = String
            default = dirname(Base.current_project())
        "--subfolder", "-s"
            help = "The subpath inside 'src'"
            arg_type = String
            default = ""
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgdir = parsed_args["pkgdir"]
    subfolder = parsed_args["subfolder"]

    _copy_include_block(pkgdir, subfolder)
end