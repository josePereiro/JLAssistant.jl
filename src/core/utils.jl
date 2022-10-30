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

## ---------------------------------------------------------
function _max_len(pad_len::Int, col::Vector{String})
    isempty(col) && return pad_len
    return max(pad_len, maximum(length.(col)))
end

_max_len(pad_len::Int, col::String) = _max_len(pad_len, [col])

function _max_len(col, cols...) 
    pad = _max_len(0, col)
    for coli in cols
        pad = _max_len(pad, coli)
    end
    return pad
end

## ---------------------------------------------------------
# filesys
function _cp(src_, dst_; kwargs...)
    mkpath(dirname(src_))
    mkpath(dirname(dst_))
    cp(src_, dst_; kwargs...)
end

## ---------------------------------------------------------
function _print_options(;kwargs...)
    println("."^60)
    println("OPTIONS")
    for (k, v) in kwargs
        println(k, ": ", v)
    end
    println("\n")
end