
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

function stringTrimmed{P}(x::ArbFloat{P}, ndigitsremoved::Int)
   n = max(4,floor(Int, P*0.3010299956639811952137))-ndigitsremoved
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, UInt(2)) # round nearest
   s = bytestring(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
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
function stringInformed{P}(x::ArbFloat{P})
    ub = upperbound(x)
    lb = lowerbound(x)
    ubstr = stringTrimmed(ub,0)
    lbstr = stringTrimmed(lb,0)
    ubstrlen = length(ubstr)
    lbstrlen = length(lbstr)
    ubdelta = lbdelta = 0
    if ubstrlen > lbstrlen
       ubdelta = lbstrlen-ubstrlen
    else
       lbdelta = lbstrlen-ubstrlen
    end
    
    for i in 0:(ubstrlen+ubdelta+lbdelta-4)
        ubstr = stringTrimmed(ub,i-ubdelta)
        lbstr = stringTrimmed(lb,i-lbdelta)
        if ubstr==lbstr
           break
        end
    end
    
    sval = ArbFloat{P}(ubstr)
    if midpoint(sval) > midpoint(x)
       string(ubstr,"-")
    elseif midpoint(sval) < midpoint(x)
       string(ubstr,"+")
    else
       string(ubstr,"±")
    end
end    

function decompose{P}(x::ArbFloat{P})
    # decompose x as num * 2^pow / den
    # num, pow, den = decompose(x)
 
   num,powof2,den 
end
