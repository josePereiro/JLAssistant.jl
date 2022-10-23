const _INCLUDE_TAG_REGEX = r"(?i)\A\h*\#\!\h+include\h*(?<path>(?:\S)*)\h*\Z"
const _INCLUDE_EXPR_REGEX = r"(?i)\A\h*include\h*\(\h*\"(?<path>(?:\S)*)\"\h*\)\h*\Z"
const _INDET_REGEX = r"\A(?<indet>\h*)"

function _redo_include_blocks(pkgdir::String)

    src_file = joinpath(pkgdir, "src", string(basename(pkgdir), ".jl"))

    src_dir = dirname(src_file)
    
    new_lines = String[]
    isfile(src_file) || return found
    
    for (ln, line) in enumerate(eachline(src_file))
        
        # parse tag
        rm = match(_INCLUDE_TAG_REGEX, line)
        if !isnothing(rm)
            push!(new_lines, line)
            indet = " "^length(findfirst(_INDET_REGEX, line))
            
            subpath = rm[:path]
            path = joinpath(src_dir, subpath)

            # Base
            if subpath == "."
                for fn in readdir(src_dir; join = true)
                    endswith(fn, ".jl") || continue
                    fn == src_file && continue
                    
                    rfn = relpath(fn, src_dir)
                    push!(new_lines, string(indet, "include(\"", rfn, "\")"))
                end
                continue
            end
            
            # Supdirs
            path = joinpath(src_dir, subpath)
            for (root, _, files) in walkdir(path)
                for file in files
                    fn = joinpath(root, file) # path to files
                    endswith(fn, ".jl") || continue
                    rfn = relpath(fn, src_dir)
                    push!(new_lines, string(indet, "include(\"", rfn, "\")"))
                end
            end
            continue
            
        end

        # parse expr
        rm = match(_INCLUDE_EXPR_REGEX, line)
        !isnothing(rm) && continue

        push!(new_lines, line)

    end
    
    write(src_file, join(new_lines, "\n"))

    println.(new_lines)

    return nothing
end
