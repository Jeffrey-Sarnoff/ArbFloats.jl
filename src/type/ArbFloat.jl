
            # P is the precision used for this value
type ArbFloat{P}  <: Real
  mid_exp::Int # fmpz
  mid_size::UInt # mp_size_t
  mid_d1::Int # mantissa_struct
  mid_d2::Int
  rad_exp::Int # fmpz
  rad_man::UInt
end

# a type specific hash function helps the type to 'just work'
const hash_arbfloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arbfloat_lo = hash(zero(UInt), hash_arbfloat_lo)
hash{P}(z::ArbFloat{P}, h::UInt) = 
    hash(reinterpret(UInt,z.mid_d1)$z.rad_man, 
         (h $ hash(reinterpret(UInt,z.mid_d2)$(~reinterpret(UInt,P)), hash_arbfloat_lo) $ hash_0_arbfloat_lo))


ArbFloatPrecision = 123
function setprecision(::Type{ArbFloat}, x::Int)
    ArbFloatPrecision = abs(x)
    bigprecisionGTE = trunc(Int, 2.25*x)
    if precision(BigFloat) < bigprecisionGTE
        precision(BigFloat,bigprecisionGTE)
    end
end
precision(::Type{ArbFloat}) = ArbFloatPrecision
precision{P}(x::ArbFloat{P}) = P

ArbFloat(x::Number) = ArbFloat{precision(ArbFloat)}(x)

@inline function clearArbFloat(x::ArbFloat)
     ccall(@libarb(arb_clear), Void, (Ptr{ArbFloat},), &x)
end
@inline function finalizer(x::ArbFloat)
    finalizer(x, clearArbFloat)
end    

function initializer{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    finalizer(z, clearArbFloat)
    z
end




function ArbFloat()
    p = precision(ArbFloat)
    z = initializer(ArbFloat{p})
    z
end

function convert{P}(::Type{ArbFloat{P}}, x::UInt)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_ui), Void, (Ptr{ArbFloat{P}}, UInt), &z, x)
    z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::UInt32) = convert(ArbFloat{P}, convert(UInt64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::UInt64) = convert(ArbFloat{P}, convert(UInt32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::UInt16) = convert(ArbFloat{P}, convert(UInt,x))

function convert{P}(::Type{ArbFloat{P}}, x::Int)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat{P}}, Int), &z, x)
    z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::Int32) = convert(ArbFloat{P}, convert(Int64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::Int64) = convert(ArbFloat{P}, convert(Int32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::Int16) = convert(ArbFloat{P}, convert(Int,x))


function convert{P}(::Type{ArbFloat{P}}, x::Float64)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_d), Void, (Ptr{ArbFloat{P}}, Float64), &z, x)
    z
end
convert{P}(::Type{ArbFloat{P}}, x::Float32) = convert(ArbFloat{P}, convert(Float64,x))
convert{P}(::Type{ArbFloat{P}}, x::Float16) = convert(ArbFloat{P}, convert(Float64,x))


function convert{P}(::Type{ArbFloat{P}}, x::String)
    b = bytestring(x)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_str), Void, (Ptr{ArbFloat}, Ptr{UInt8}, Int), &z, b, P)
    z
end


convert(::Type{BigInt}, x::String) = parse(BigInt,x)
convert(::Type{BigFloat}, x::String) = parse(BigFloat,x)

convert{P}(::Type{ArbFloat{P}}, x::BigFloat) = convert(ArbFloat{P}, string(x))
convert{P}(::Type{ArbFloat{P}}, x::BigInt)   = convert(ArbFloat{P}, convert(BigFloat,x))
convert{P}(::Type{ArbFloat{P}}, x::Rational) = convert(ArbFloat{P}, convert(BigFloat,x))
convert{P,S}(::Type{ArbFloat{P}}, x::Irrational{S}) = convert(ArbFloat{P}, convert(BigFloat,x))

#= returns 256.0 for convert(big(1.5))
function convert{P}(::Type{ArbFloat{P}}, x::BigFloat)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_round_fmpz), Void, (Ptr{ArbFloat}, Ptr{BigFloat}, Int), &z, &x, P)
    z
end
=#

function num2str{P}(x::ArbFloat{P}, n::Int)
   flags = UInt(2)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = bytestring(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function convert{P}(::Type{Float64}, x::ArbFloat{P})
    s = num2str(x,22)
    parse(Float64,s)
    #ccall(@libarb(arb_set_d), Void, (Ptr{ArbFloat{P}}, Float64), &x, z)
    #z
end
convert{P}(::Type{Float32}, x::ArbFloat{P}) = convert(Float32,convert(Float64,x))

function convert{P}(::Type{Int}, x::ArbFloat{P})
    s = num2str(x,22)
    trunc(Int,parse(Float64,s))
    #ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat{P}}, Int), &x, z)
    #z
end
if sizeof(Int)==sizeof(Int64)
    convert{P}(::Type{Int32}, x::ArbFloat{P}) = convert(Int32,convert(Int64,x))
else
    convert{P}(::Type{Int64}, x::ArbFloat{P}) = convert(Int64,convert(Int32,x))
end



function String{P}(x::ArbFloat{P}, flags::UInt)
   n = floor(Int, P*0.3010299956639811952137)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = bytestring(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function string{P}(x::ArbFloat{P})
   # n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
   s = String(x,UInt(2)) # midpoint only (within 1ulp), RoundNearest
   s 
end

function copy{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function deepcopy{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function midpoint{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_get_mid_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function radius{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_get_rad_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
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
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_trim), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function show{P}(io::IO, x::ArbFloat{P})
    s = string(x)
    print(io, s)
end

ArbFloatHalf = Dict{Int,ArbFloat}(  120 => ArbFloat{120}(0.5),
                                    122 => ArbFloat{123}(0.5),
                                    125 => ArbFloat{125}(0.5),
                                    128 => ArbFloat{128}(0.5),
                                    160 => ArbFloat{160}(0.5),
                                    185 => ArbFloat{185}(0.5),
                                    192 => ArbFloat{192}(0.5),
                                    250 => ArbFloat{250}(0.5),
                                    );
                                    
# fractionalPart(x), wholePart(x) = modf(x)
#
function informedvalue{P}(x::ArbFloat{P})
    ax = abs(x)
    md = midpoint(ax)
    rd = radius(ax)
    mdrd = md/rd      # the reliable part of x is shifted to the whole part of mdrd
    if !haskey(ArbFloatHalf, P)
       ArbFloatHalf[P] = ArbFloat{P}(0.5)
    end
    wholepart  = floor(mdrd)
    fractional = mdrd - wholepart
    nearestint = floor(mdrd + ArbFloatHalf[P])   # rounds to nearest whole
    nearestint * rd
end

function decompose{P}(x::ArbFloat{P})
    # decompose x as num * 2^pow / den
    # num, pow, den = decompose(x)
 
   num,powof2,den 
end
