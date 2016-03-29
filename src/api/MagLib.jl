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

type Mag <: AbstractFloat
    exponent::Int           # fmpz
    mantissa::UInt          # mp_limb_t
end

Mag() = Mag(zero(Int), zero(UInt))
Mag(mantissa::UInt) = Mag(zero(Int), mantissa)
Mag(mantissa::Int)  = Mag(reinterpret(UInt, mantissa))

function convert(::Type{Mag}, x::Float64)
    m = Mag()
    ccall( (:mag_set_d, :libarb), Void, (Ptr{Mag}, Ptr{Float64}), m, x )
end
