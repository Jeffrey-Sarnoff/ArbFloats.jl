type ArbFloat{Precision}  <: Real
  mid_exp::Int # fmpz
  mid_size::UInt # mp_size_t
  mid_d1::Int # mantissa_struct
  mid_d2::Int
  rad_exp::Int # fmpz
  rad_man::UInt
end

ArbFloatPrecision = 120
function setprecision(::Type{ArbFloat}, x::Int)
    ArbFloatPrecision = abs(x)
end
precision(::Type{ArbFloat}) = ArbFloatPrecsion
precision{Precision}(x::ArbFloat{Precision}) = Precision


function clearArbFloat(x::ArbFloat)
     ccall((:arb_clear, :libarb), Void, (Ptr(ArbFloat),), &x)
end

function ArbFloat()
    z = ArbFloat{precision(ArbFloat)}(0,0,0,0,0,0)
    ccall((:arb_init, :libarb), Void, (Ptr{ArbFloat},), &z)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::UInt)
    z = ArbFloat{precision(ArbFloat)}(0,0,0,0,0,0)
    ccall((:arb_init, :libarb), Void, (Ptr{ArbFloat},), &z)
    ccall((:arb_set_ui, :libarb), Void, (Ptr{ArbFloat}, UInt), &z, x)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::Int)
    z = ArbFloat{precision{ArbFloat}}(0,0,0,0,0,0)
    ccall((:arb_init, :libarb), Void, (Ptr{ArbFloat},), &z)
    ccall((:arb_set_si, :libarb), Void, (Ptr{ArbFloat}, Int), &z, x)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::Float64)
    z = ArbFloat{precision(ArbFloat)}(0,0,0,0,0,0)
    ccall((:arb_init, :libarb), Void, (Ptr{ArbFloat},), &z)
    ccall((:arb_set_d, :libarb), Void, (Ptr{ArbFloat}, Float64), &z, x)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::BigFloat)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall((:arb_init, :libarb), Void, (Ptr{ArbFloat},), &z)
    ccall((:arb_set_round_fmpz, :libarb), Void, (Ptr{ArbFloat}, BigFloat, Int), &z, x, p)
    finalizer(z, clearArbFloat)
    z
end

ArbFloat{T<:Real}(x::T) = ArbFloat(convert(BigFloat,x))
