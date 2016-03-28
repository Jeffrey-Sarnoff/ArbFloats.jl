#=
    ref: https://github.com/wbhart/Nemo.jl/blob/master/src/arb/arb.jl
=#

@doc"""
    ArbSpan
"""

"""ArbSpan ↦  Float64 """

function convert(::Type{Float64}, x::ArbValue)
    t = ArfStruct()
    t.exp  = x.internal.mid_exp
    t.size = x.internal.mid_size
    t.d1   = x.internal.mid_d1
    t.d2   = x.internal.mid_d2
    #                          (the rounding mode number 4 rounds to nearest)
    return ccall((:arf_get_d, :libarb), Float64, (Ptr{ArfStruct}, Int), &t, 4)
end


function convert(::Type{ArbValue}, x::Float64)
    t = ArfStruct()
    #                          (the rounding mode number 4 rounds to nearest)
    return ccall((:arf_set_d, :libarb), Float64, (Ptr{ArfStruct}, Int), &t, 4)

    t.exp  = x.internal.mid_exp
    t.size = x.internal.mid_size
    t.d1   = x.internal.mid_d1
    t.d2   = x.internal.mid_d2

end






function convert{T<:Float64}}(::Type{ArbSpan}, x::T)
    ccall((:arb_set_d, :libarb), Void, (Ref{arbInside}, Float64), arbInsideVal, x)
    #ccall((:arb_set_d, :libarb), Void, (Ptr{arbInside}, Float64), arbInsideVal, x)
    convert(ArbSpan, convert(Float64, x))
end

function convert{T<:SmallerNumbers}}(::Type{ArbSpan}, x::T)
    convert(ArbSpan, convert(Float64, x))
end

function convert{T<:SmallerNumbers}(::Type{T}, x::ArbSpan)
    convert(T, convert(Float64, x))
end

function convert{T<:AbstractString}(::Type{ArbSpan}, x::T)
end

function convert{T<:AbstractString}(::Type{T}, x::ArbSpan})
end

function convert(::Type{ArbSpan}, x::BigFloat)
end

function convert(::Type{BigFloat}, x::ArbSpan)
end
