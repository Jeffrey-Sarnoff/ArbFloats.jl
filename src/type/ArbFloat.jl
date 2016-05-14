            # P is the precision used for this value
type ArbFloat{P}  <: Real
  mid_exp::Int # fmpz
  mid_size::UInt # mp_size_t
  mid_d1::Int # mantissa_struct
  mid_d2::Int
  rad_exp::Int # fmpz
  rad_man::UInt
end

ArbFloatPrecision = 123
function setprecision(::Type{ArbFloat}, x::Int)
    ArbFloatPrecision = abs(x)
end
precision(::Type{ArbFloat}) = ArbFloatPrecision
precision{P}(x::ArbFloat{P}) = P



@inline function clearArbFloat(x::ArbFloat)
     ccall(@libarb(arb_clear), Void, (Ptr{ArbFloat},), &x)
end

function finalizer(x::ArbFloat)
    finalizer(x, clearArbFloat)
end    

#=
function convert{P}(::Type{ArbFloat{P}}, x::ArbFloat)
    p = precision(ArbFloat)
    ArbFloat{P}(x.mid_exp, x.mid_size, x.mid_d1, x.mid_d2, x.rad_exp, x.rad_man)
end    
=#


function ArbFloat()
    p = precision(ArbFloat)
    z = ArbFloat{p}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    finalizer(z)
    z
end

function convert{P}(::Type{ArbFloat{P}}, x::UInt)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    ccall(@libarb(arb_set_ui), Void, (Ptr{ArbFloat{P}}, UInt), &z, x)
    finalizer(z)
    z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::UInt32) = convert(ArbFloat{P}, convert(UInt64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::UInt64) = convert(ArbFloat{P}, convert(UInt32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::UInt16) = convert(ArbFloat{P}, convert(UInt,x))

function convert{P}(::Type{ArbFloat{P}}, x::Int)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat{P}}, Int), &z, x)
    finalizer(z)
    z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::Int32) = convert(ArbFloat{P}, convert(Int64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::Int64) = convert(ArbFloat{P}, convert(Int32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::Int16) = convert(ArbFloat{P}, convert(Int,x))


function convert{P}(::Type{ArbFloat{P}}, x::Float64)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    ccall(@libarb(arb_set_d), Void, (Ptr{ArbFloat{P}}, Float64), &z, x)
    finalizer(z)
    z
end
convert{P}(::Type{ArbFloat{P}}, x::Float32) = convert(ArbFloat{P}, convert(Float64,x))
convert{P}(::Type{ArbFloat{P}}, x::Float16) = convert(ArbFloat{P}, convert(Float64,x))

function convert{P}(::Type{ArbFloat{P}}, x::BigFloat)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set_round_fmpz), Void, (Ptr{ArbFloat}, BigFloat, Int), &z, x, P)
    finalizer(z)
    z
end
convert{P}(::Type{ArbFloat{P}}, x::BigInt) = convert(ArbFloat{P}, convert(BigFloat,x))

function convert{P}(::Type{ArbFloat{P}}, x::String)
    b = bytestring(x)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_set_str), Void, (Ptr{ArbFloat}, Ptr{UInt8}, Int), &z, b, P)
    finalizer(z)
    z
end


convert(::Type{BigInt}, x::String) = parse(BigInt,x)
convert(::Type{BigFloat}, x::String) = parse(BigFloat,x)
convert(::Type{BigFloat}, x::Rational) = parse(BigFloat,string(x))

#=
for T in (:Int8,:Int16,:Int32,:Int64)
    @eval convert{P}(::Type{ArbFloat{P}}, x::($T)) = ArbFloat(convert(Int,x))
end
for T in (:Float16,:Float32,:Float64)
    @eval convert{P}(::Type{ArbFloat{P}}, x::($T)) = ArbFloat(convert(Float64,x))
end
for T in (:BigInt, :BigFloat, :Int128, :(Rational{Int32}), :(Rational{Int64}), :(Rational{Int128}), :(Rational{BigInt}))
    @eval convert{P}(::Type{ArbFloat{P}}, x::($T)) = ArbFloat( convert(BigFloat, string(x)) )
end
=#

#convert{P}(::Type{ArbFloat{P}}, x::Int64) = ArbFloat(x)
#convert{P}(::Type{ArbFloat{P}}, x::Int32) = ArbFloat(x)

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
