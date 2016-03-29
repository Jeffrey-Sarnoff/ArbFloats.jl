#=
  mag.h - fixed-precision unsigned floating-point numbers for bounds

  The mag_t type is an unsigned floating-point type with a fixed-precision
  mantissa (30 bits) and an arbitrary-precision exponent (represented as an
  fmpz_t), suited for representing and rigorously manipulating magnitude
  bounds efficiently.

  Operations always produce a strict upper or lower bound, but for performance
  reasons, no attempt is made to compute the best possible bound (in general,
  a result may a few ulps larger/smaller than the optimal value). The special
  values zero and positive infinity  are supported (but not NaN).

  Applications requiring more flexibility (such as correct rounding, 
  or higher precision) should use the arf_t type instead.
  
  -- exerpted from http://fredrikj.net/arb/mag.html
=#

import Base: convert, promote_rule, show, showcompact

type Mag <: AbstractFloat
    exponent::Int           # fmpz
    mantissa::UInt          # mp_limb_t
    
    # provide an inner constructor to avoid AbstractFloat ambiguity
    Mag(exponent::Int, mantissa::UInt) = new(exponent, mantissa)
end

Mag() = Mag(zero(Int), zero(UInt))
Mag(mantissa::UInt) = Mag(zero(Int), mantissa)
Mag(mantissa::Int)  = Mag(reinterpret(UInt, mantissa), zero(Int))

Mag(mantissa::UInt, exponent::Int) = Mag(exponent, mantissa)
Mag{T<:Int}(mantissa::T, exponent::T)  = Mag(exponent, reinterpret(UInt, mantissa))
Mag{T<:Integer}(mantissa::T, exponent::T) = Mag(convert(Int, mantissa), convert(Int, exponent))

function show(io::IO, x::Mag) 
   s = string("Mag( ", x.mantissa, "* 2^", x.exponent, " )")
   print(io, s)
end

function showcompact(io::IO, x::Mag) 
   s = string("Mag(", Float64(x.mantissa) * ldexp(1.0, x.exponent),  )")
   print(io, s)
end

function convert(::Type{Mag}, x::Float64)
    m = Mag()
    ccall( (:mag_set_d, :libarb), Void, (Ptr{Mag}, Ptr{Float64}), &m, &x)
    m
end

convert{T<:AbstractFloat}(::Type{Mag}, x::T) = convert(Mag, convert(Float64, x))
convert{T<:Integer}(::Type{Mag}, x::T) = convert(Mag, convert(Float64, x))

promote_rule(::Type{Mag}, ::Type{Float64}) = Mag
promote_rule{I<:Integer(::Type{Mag}, ::Type{I}) = Mag

for op in (:+,:-,:*,:/)
  @eval begin
     ($op)(a::Mag, b::Float64) = ($op)(promote(a,b)...)
     ($op)(a::Float64, b::Mag) = ($op)(promote(a,b)...)
     ($op){T<:Integer}(a::Mag, b::T) = ($op)(promote(a,b)...)
     ($op){T<:Integer}(a::T, b::Mag) = ($op)(promote(a,b)...)
    end
end  

