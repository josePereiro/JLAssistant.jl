function _check_imports(pkgdir;
        subs=["src", "scripts"]
    )
    
    ## ---------------------------------------------------
    file_imports = _find_imports(pkgdir; subs)
    proj_imports = vcat(collect.(values(file_imports))...)

    ## ---------------------------------------------------
    # Project.toml deps
    projfiles = joinpath.(pkgdir, Base.project_names)
    projis = findfirst(isfile, projfiles)
    isnothing(projis) && error("Project file not found")
    projfile = projfiles[projis]
    proj_toml = _load_project(projfile)
    proj_deps = get(proj_toml, "deps", nothing)
    proj_deps = isnothing(proj_deps) ? String[] : collect(keys(proj_deps))

    ## ---------------------------------------------------
    IGNORED = ["Base", "Core", get(proj_toml, "name", "")]

    ## ---------------------------------------------------
    # print

    ## ---------------------------------------------------
    println("\nChecking Imports")
    println("proj: ", pkgdir, "\n")
    pad_len = _max_len(proj_imports, proj_deps, "in Project.toml")
    pad_len += 3
    TAB = "  "
    
    ## ---------------------------------------------------
    missings_pool = Dict()
    for (file, imports) in file_imports
        imports = collect(imports)

        println(file, ":")
        isempty(imports) && (println(); continue)
        sort!(imports)
        println(TAB, "  ", 
            rpad("to load", pad_len), rpad("in Project.toml", pad_len)
        )
        println(TAB, "  ", 
            rpad("", pad_len, "-"), rpad("", pad_len, "-")
        )
        
        missings = String[]
        for imp in imports
            isignored = (imp in IGNORED)
            isdep = (imp in proj_deps)
            mark = (isignored || isdep) ? "  " : "* "
            label = isdep ? "present" : 
                    isignored ? "ignored" : "missing"
            color = (isignored || isdep) ? :normal : :red
            printstyled(TAB, mark, 
                rpad(imp, pad_len), 
                rpad(label, pad_len); 
                color, bold = (color == :red)
            )
            !isignored && !isdep && push!(missings, imp)
            println()
        end
        println()
        if !isempty(missings) 
            println(TAB, "Missings: ", join(missings, ", "))
            println()
        end

        missings_pool[file] = missings
    end
    println()

    ## ---------------------------------------------------
    nonloaded = filter((dep)->!(dep in proj_imports), sort!(proj_deps))
    if !isempty(nonloaded)
        println("Fake deps: ")
        println(TAB, "  ", 
            rpad("in Project.toml", pad_len), 
            rpad("loaded", pad_len)
        )
        println(TAB, "  ", 
            rpad("", pad_len, "-"), rpad("", pad_len, "-")
        )
        for dep in nonloaded
            printstyled(TAB, "* ", 
                rpad(dep, pad_len), 
                rpad("no", pad_len); 
                color = :red, bold = true
            )
            println()
        end
        println()
        println(TAB, "All fakes: ", join(nonloaded, ", "))
    end

    ## ---------------------------------------------------
    # unregistered pkgs
    # check Manifest
    unreg_pkgs = _find_unregistered_pkgs(pkgdir)
    if !isempty(unreg_pkgs) 
        println()
        println("In unregistered mode: ")
        printstyled(TAB, join(unreg_pkgs, ", "); color = :red, bold = true)
        println()
    end

    ## ---------------------------------------------------
    # fix command
    SINGLE_QUOTE = "\'"
    QUOTE = "\""
    BACK_SLASH = "\\"
    ENTER = "\n"
    COMMA = ","

    add_strs = []
    for (file, missings) in missings_pool
        isempty(missings) && continue
        add_str = string(
            "@info(", QUOTE, "Fixing ", file, QUOTE, ")", ENTER,
            "Pkg.add(",
                string("[", join(string.(QUOTE, missings, QUOTE), ", "), "]"),
            ")"

        )
        push!(add_strs, add_str)
    end
    add_str = join(add_strs, ENTER)

    rm_str = isempty(nonloaded) ? "" : 
        string(
            "@info(", QUOTE, "Removing fake deps", QUOTE, ")", ENTER,
            "Pkg.rm(",
                string("[", join(string.(QUOTE, nonloaded, QUOTE), ", "), "]"), 
            ")"
        )

    if !isempty(add_str) || !isempty(rm_str)
        fix_cmd = string(
            "julia", " --project=", pkgdir, " -e ", BACK_SLASH, ENTER,
            SINGLE_QUOTE, 
            "import Pkg;", ENTER,
            add_str, ENTER,
            rm_str, ENTER,
            "Pkg.precompile()",
            SINGLE_QUOTE
        )
        println()
        println("Fix command:")
        println()
        println(fix_cmd)
    end
    
end

