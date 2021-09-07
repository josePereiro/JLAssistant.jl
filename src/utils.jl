_add_versions(v1::VersionNumber, v2::VersionNumber) = 
    VersionNumber(v1.major + v2.major, v1.minor + v2.minor, v1.patch + v2.patch)

function _info(msg; kwargs...)
    println()
    @info(msg, kwargs...)
    println()
end

function _warn(msg; kwargs...)
    println()
    @warn(msg, kwargs...)
    println()
end

_Cmd(cmdsv::Vector{String}; kwargs...) = Cmd(Cmd(cmdsv); kwargs...)

function _repeat(f::Function, str)
    len = -1
    while len != length(str)
        len = length(str)
        str = f()
    end
    str
end

## ---------------------------------------------------------
function _split_arglist(arg_str)
    isempty(arg_str) && return String[]
    arg_str = _repeat(arg_str) do
        replace(arg_str, " " => "")
    end
    split(arg_str, ",")
end