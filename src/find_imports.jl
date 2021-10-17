## --------------------------------------------------------
function find_imports(pkgdir; subs = ["src", "scripts"])

    SPACE = hex_escape(" ")
    TAB = hex_escape("\t")
    ENTER = hex_escape("\n")
    COMMA = hex_escape(",")
    SEMICOLON = hex_escape(";")
    DOUBLEPOINT = hex_escape(":")
    BLANK = "(?:$SPACE|$TAB)"
    PKG_NAME = "[^$SPACE$TAB$COMMA$SEMICOLON$ENTER]+"
    
    imports_pool = Dict{String, Set{String}}()
    for dirname in subs
        srcdir = joinpath(pkgdir, dirname)
        !isdir(srcdir) && continue
        imports = get!(imports_pool, dirname, Set{String}())
        
        jl_files = filtertree(srcdir) do path
            endswith(path, ".jl")
        end

        for file in jl_files
            file_str = read(file, String)

            # @info("Doing", file)

            # predigest
            _c = 
            _repeat(file_str) do
                file_str = replace(file_str, r"(?:\"\"\")[^\"]*(?:\"\"\")"=>"")
                file_str = replace(file_str, r"(?:\")[^\"]*(?:\")"=>"")
                file_str = replace(file_str, r"\#\=(.|\n)*\=\#"=>"")
                file_str = replace(file_str, r"\#[^\n\"]*\n"=>"\n")
                file_str = replace(file_str, r"\#[^\n\"]*"=>"")
                file_str = replace(file_str, r"\n\n"=>"\n")
            end

            # import/using Pkg [\n;:]
            reg_str = string(
                "(?:import|using)", "(?:$BLANK|$ENTER)+", "(?<pkg>$PKG_NAME)", "$BLANK*", "[\n;:]"
            )
            reg = Regex(reg_str)

            _repeat(file_str) do
                m = match(reg, file_str)
                isnothing(m) && return file_str
                file_str = replace(file_str, m.match => "")

                # @show m
                # clear Package name
                pkg_str = m[:pkg]
                startswith(pkg_str, ".") && return file_str
                pkg_str = first(split(pkg_str, "."))
                push!(imports, pkg_str)
                return file_str
            end

            # import/using Pkg1 [\n] , [\n] Pkg1
            reg_str = string(
                "(?:import|using)", "(?:$BLANK|$ENTER)+", "(?:$PKG_NAME)", "$BLANK*", 
                "(?:", "$BLANK*", "$COMMA", "(?:$BLANK|$ENTER)*",  "(?:$PKG_NAME)", ")*",
                "(?:$BLANK|$ENTER|$SEMICOLON)*"
            )
            reg = Regex(reg_str)
            _repeat(file_str) do
                m = match(reg, file_str)
                isnothing(m) && return file_str
                file_str = replace(file_str, m.match => "")
                
                # @show m
                # clear Package names
                imp_str = m.match
                clear_reg = Regex("import|using|$ENTER|$TAB|$SPACE|$SEMICOLON")
                _repeat(file_str) do
                    imp_str = replace(imp_str, clear_reg => "")
                end

                pkg_strs = split(imp_str, ",")
                for pkg_str in pkg_strs
                    startswith(pkg_str, ".") && continue
                    pkg_str = first(split(pkg_str, "."))
                    push!(imports, pkg_str)
                end
                return file_str
            end

        end # for file 
    end # for dirname

    imports_pool
end
