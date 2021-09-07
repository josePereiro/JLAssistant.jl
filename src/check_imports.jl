function check_imports(pkgdir;
        subs=["src", "scripts"]
    )
    
    file_imports = JLAssistant.find_imports(pkgdir; subs)
    proj_imports = vcat(collect.(values(file_imports))...)

    # Project.toml deps
    projfiles = joinpath.(pkgdir, Base.project_names)
    projfile = projfiles[findfirst(isfile, projfiles)]
    proj_toml = JLAssistant._load_project(projfile)
    proj_deps = get(proj_toml, "deps", String[""]) |> keys |> collect

    # print
    println("\nChecking Imports")
    println("proj: ", pkgdir, "\n")
    pad_len = maximum(length.(proj_imports))
    pad_len = max(pad_len, maximum(length.(proj_deps)))
    pad_len = max(pad_len, length("in Project.toml"))
    pad_len += 3 #
    TAB = "  "
    for (file, imports) in file_imports
        println(file, ":")
        isempty(imports) && (println(); continue)
        println(TAB, "  ", 
            rpad("to import", pad_len), rpad("in Project.toml", pad_len)
        )
        println(TAB, "  ", 
            rpad("", pad_len, "-"), rpad("", pad_len, "-")
        )
        
        for imp in imports
            indep = (imp in proj_deps) 
            printstyled(TAB, indep ? "  " : "* ", 
                rpad(imp, pad_len), 
                rpad(indep ? "present" : "missing", pad_len), "\n"; 
                color = indep ? :normal : :red, 
                bold = !indep
            )
        end
        println()
    end
    println()
    println("All imports:\n\t", join(string.(proj_imports), ", "))
end

## ---------------------------------------------------------
function run_check_imports(argv=ARGS)

    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "pkgdir"
            help = "The package dir"
            arg_type = String
            default = pwd()
        "--subfolders", "-s"
            help = "The names (comma separated) of the subfolders to search"
            arg_type = String
            default = "src, scripts"
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgdir = parsed_args["pkgdir"]
    subs = _split_arglist(parsed_args["subfolders"])

    check_imports(pkgdir; subs)
end