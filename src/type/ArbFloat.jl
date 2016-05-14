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


@inline function clearArbFloat(x::ArbFloat)
     ccall(@libarb(arb_clear), Void, (Ptr{ArbFloat},), &x)
end

function finalizer(x::ArbFloat)
    finalizer(x, clearArbFloat)
end    

function ArbFloat()
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    finalizer(z)
    z
end

function ArbFloat(x::UInt)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set_ui), Void, (Ptr{ArbFloat}, UInt), &z, x)
    finalizer(z)
    z
end
ArbFloat{T<:Unsigned}(x::T) = ArbFloat(UInt(x))

function ArbFloat(x::Int)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat}, Int), &z, x)
    finalizer(z)
    z
end
ArbFloat{T<:Signed}(x::T) = ArbFloat(Int(x))

function ArbFloat(x::Float64)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set_d), Void, (Ptr{ArbFloat}, Float64), &z, x)
    finalizer(z)
    z
end
ArbFloat{T<:Float32}(x::T) = ArbFloat(Float64(x))

function ArbFloat(x::BigFloat)
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set_round_fmpz), Void, (Ptr{ArbFloat}, BigFloat, Int), &z, x, p)
    finalizer(z)
    z
end

function ArbFloat(x::String)
    p = precision(ArbFloat)
    b = bytestring(x)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set_str), Void, (Ptr{ArbFloat}, Ptr{UInt8}, Int), &z, b, p)
    finalizer(z)
    z
end

BigInt(x::String) = parse(BigInt,x)
BigFloat(x::String) = parse(BigFloat,x)

for T in (:Int8,:Int16,:Int32,:Int64)
    @eval convert{P}(::Type{ArbFloat{P}}, x::($T)) = ArbFloat(convert(Int,x))
end
for T in (:Float16,:Float32,:Float64)
    @eval convert{P}(::Type{ArbFloat{P}}, x::($T)) = ArbFloat(convert(Float64,x))
end
for T in (:BigInt, :BigFloat, :Int128, :(Rational{Int32}), :(Rational{Int64}), :(Rational{Int128}), :(Rational{BigInt}))
    @eval convert{P}(::Type{ArbFloat{P}}, x::($T)) = ArbFloat( convert(BigFloat, string(x)) )
end

#convert{P}(::Type{ArbFloat{P}}, x::Int64) = ArbFloat(x)
#convert{P}(::Type{ArbFloat{P}}, x::Float32) = ArbFloat(x)
#convert{P}(::Type{ArbFloat{P}}, x::Float64) = ArbFloat(x)
#convert{P}(::Type{ArbFloat{P}}, x::BigFloat) = ArbFloat(string(x))
#convert{P}(::Type{ArbFloat{P}}, x::BigInt) = ArbFloat(string(x))
##convert{P,I<:Integer}(::Type{ArbFloat{P}}, x::Rational{I}) = ArbFloat(convert(BigFloat,x))
#convert{P,I<:Integer}(::Type{ArbFloat{P}}, x::I) = ArbFloat(convert(BigInt,x))
#convert{P,F<:AbstractFloat}(::Type{ArbFloat{P}}, x::F) = ArbFloat(convert(BigFloat,x))
#convert{P,R<:Real}(::Type{ArbFloat{P}}, x::R) = ArbFloat(convert(BigFloat,x))

#ArbFloat{T<:Real}(x::T) = ArbFloat(convert(BigFloat,x))


function String{P}(x::ArbFloat{P}, flags::UInt)
   n = floor(Int, P*0.3010299956639811952137)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = bytestring(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function string(x::ArbFloat)
   String(x,UInt(2)) # midpoint only, RoundNearest
end

function copy{P}(x::ArbFloat{P})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    finalizer(z)
    z
end

function deepcopy{P}(x::ArbFloat{P})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    finalizer(z, clearArbFloat)
    z
end

function midpoint{P}(x::ArbFloat{P})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_get_mid_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    finalizer(z)
    z
end

function radius{P}(x::ArbFloat{P})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_get_rad_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    finalizer(z)
    z
end

function upperbound{P}(x::ArbFloat{P})
    midpoint(x) + radius(x)
end
function lowerbound{P}(x::ArbFloat{P})
    midpoint(x) - radius(x)
end
function minmax{P}(x::ArbFloat{P})
   m = midpoint(x)
   r = radius(x)
   m-r, m+r
end

   
function relativeError{P}(x::ArbFloat{P})
    z = P
    ccall(@libarb(arb_rel_error_bits), Void, (Ptr{Int}, Ptr{ArbFloat}), &z, &x)
    z
end

function relativeAccuracy{P}(x::ArbFloat{P})
    z = P
    ccall(@libarb(arb_rel_accuracy_bits), Void, (Ptr{Int}, Ptr{ArbFloat}), &z, &x)
    z
end

function midpointPrecision{P}(x::ArbFloat{P})
    z = P
    ccall(@libarb(arb_bits), Void, (Ptr{Int}, Ptr{ArbFloat}), &z, &x)
    z
end

function trimmedAccuracy{P}(x::ArbFloat{P})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_trim), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    finalizer(z)
    z
end

function show{P}(io::IO, x::ArbFloat{P})
    s = string(x)
    print(io, s)
end
