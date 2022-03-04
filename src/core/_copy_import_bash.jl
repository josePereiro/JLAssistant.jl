function _copy_include_block(pkgdir::String, subdir::String = "")
    # upgrade_manifests
    dir = joinpath(pkgdir, "src", subdir)
    !isdir(dir) && error("dir not found: '$(dir)'")
    @show dir
    toinclude = filter(readdir(dir)) do path
        string(basename(pkgdir), ".jl") == basename(path) && return false
        isdir(path) && return false
        endswith(path, ".jl") || return false
        return true
    end
    isempty(toinclude) && return
    include_block = join(
        string.(
            ["include(\""],
            joinpath.([subdir], toinclude),
            ["\")"]
        )
    , "\n") 
    println(include_block)
    clipboard(include_block)

    return nothing
end
