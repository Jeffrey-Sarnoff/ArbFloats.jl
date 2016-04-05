#=
    ref: https://github.com/wbhart/Nemo.jl/blob/master/src/arb/arb.jl
=#

#=
@doc"""
    ArbSpan
"""

"""ArbSpan ↦  Float64 """
=#

function convert(::Type{Float64}, x::ArbValue)
    t = ArfStruct(x)
    #                          (the rounding mode number 4 rounds to nearest)
    return ccall((:arf_get_d, :libarb), Float64, (Ptr{ArfStruct}, Int), &t, 4)
end

#=
julia> function af_arb_set(x::ArfStruct, y::Float64) 
          ccall((:arf_set_d, :libarb), Void, (Ref{ArfStruct},Float64), x,y)
       end
af_arb_set (generic function with 1 method)

julia> t=ArfStruct()
ArfStruct(0,0x0000000000000000,0,0)

julia> af_arb_set(t,7.0)

julia> t
ArfStruct(3,0x0000000000000002,-2305843009213693952,0)
=#

function convert(::ArfStruct, y::Float64) 
    x = ArfStruct()
    ccall((:arf_set_d, :libarb), Void, (Ref{ArfStruct},Float64), x,y)
    x
end    




function convert(::Type{ArbValue}, x::Float64)
    t = ArfStruct()
    #                          (the rounding mode number 4 rounds to nearest)
    ccall((:arf_set_d, :libarb), Void, (Ptr{ArfStruct}, Int), &t, 4)
    convert(ArbValue,t)
end



function _arb_set(x::($typeofx), y::($t))
        ccall(($f, :libarb), Void, (($passtoc), ($t)), x, y)
      end


for (typeofx, passtoc) in ((arb, Ref{arb}), (Ptr{arb}, Ptr{arb}))
  for (f,t) in (("arb_set_si", Int), ("arb_set_ui", UInt),
                ("arb_set_d", Float64))
    @eval begin
      function _arb_set(x::($typeofx), y::($t))
        ccall(($f, :libarb), Void, (($passtoc), ($t)), x, y)
      end

      function _arb_set(x::($typeofx), y::($t), p::Int)
        _arb_set(x, y)
        ccall((:arb_set_round, :libarb), Void,
                    (($passtoc), ($passtoc), Int), x, x, p)
      end
    end
  end

  @eval begin
    function _arb_set(x::($typeofx), y::fmpz)
      ccall((:arb_set_fmpz, :libarb), Void, (($passtoc), Ptr{fmpz}), x, &y)
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

#=
function convert{T<:AbstractString}(::Type{ArbSpan}, x::T)
end

function convert{T<:AbstractString}(::Type{T}, x::ArbSpan})
end

function convert(::Type{ArbSpan}, x::BigFloat)
end

function convert(::Type{BigFloat}, x::ArbSpan)
end
=#
