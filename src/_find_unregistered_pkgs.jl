_is_unregistered(dat::Dict) = haskey(dat, "repo-rev") || haskey(dat, "repo-url") || haskey(dat, "path")

function _find_unregistered_pkgs(pkgdir)
    manffile = filter(readdir(pkgdir; join = true)) do file
        basename(file) in Base.manifest_names
    end
    isempty(manffile) && return String[]
    manffile = first(manffile)
    devs = String[]
    manfdeps = TOML.parsefile(manffile)
    for (pkg, dat) in manfdeps
        dat = Dict(dat...)
        _is_unregistered(dat) && push!(devs, pkg)
    end
    return devs
end