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
precision(::Type{ArbFloat}) = ArbFloatPrecision
precision{Precision}(x::ArbFloat{Precision}) = Precision


function clearArbFloat(x::ArbFloat)
     ccall((:arb_clear, libarb), Void, (Ptr(ArbFloat),), &x)
end

function ArbFloat()
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@arbcall(arb_init), Void, (Ptr{ArbFloat},), &z)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::UInt)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@arbcall(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@arbcall(arb_set_ui), Void, (Ptr{ArbFloat}, UInt), &z, x)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::Int)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@arbcall(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@arbcall(arb_set_si), Void, (Ptr{ArbFloat}, Int), &z, x)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::Float64)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@arbcall(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@arbcall(arb_set_d), Void, (Ptr{ArbFloat}, Float64), &z, x)
    finalizer(z, clearArbFloat)
    z
end

function ArbFloat(x::BigFloat)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@arbcall(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@arbcall(arb_set_round_fmpz), Void, (Ptr{ArbFloat}, BigFloat, Int), &z, x, p)
    finalizer(z, clearArbFloat)
    z
end


function ArbFloat(x::String)
    p = precision(ArbFloat)
    b = bytestring(x)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@arbcall(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@arbcall(arb_set_str), Void, (Ptr{ArbFloat}, Ptr{UInt8}, Int), &z, b, p)
    finalizer(z, clearArbFloat)
    z
end

ArbFloat{T<:Real}(x::T) = ArbFloat(convert(BigFloat,x))
