
            # P is the precision used for this value
type ArbFloat{P}  <: Real
  mid_exp::Int # fmpz
  mid_size::UInt # mp_size_t
  mid_d1::Int # mantissa_struct
  mid_d2::Int
  rad_exp::Int # fmpz
  rad_man::UInt
end

precision{P}(x::ArbFloat{P}) = P

# get and set working precision for ArbFloat

const ArbFloatPrecision = [123,]
precision(::Type{ArbFloat}) = ArbFloatPrecision[1]

function setprecision(::Type{ArbFloat}, x::Int)
    bigprecisionGTE = trunc(Int, 2.25*x)
    if precision(BigFloat) < bigprecisionGTE
        setprecision(BigFloat,bigprecisionGTE)
    end
    ArbFloatPrecision[1] = abs(x)
end


# a type specific hash function helps the type to 'just work'
const hash_arbfloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arbfloat_lo = hash(zero(UInt), hash_arbfloat_lo)
hash{P}(z::ArbFloat{P}, h::UInt) = 
    hash(reinterpret(UInt,z.mid_d1)$z.rad_man, 
         (h $ hash(reinterpret(UInt,z.mid_d2)$(~reinterpret(UInt,P)), hash_arbfloat_lo) $ hash_0_arbfloat_lo))


function clearArbFloat{P}(x::ArbFloat{P})
     ccall(@libarb(arb_clear), Void, (Ptr{ArbFloat{P}},), &x)
end

function initializer{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    finalizer(z, clearArbFloat)
    z
end


function ArbFloat()
    p = precision(ArbFloat)
    z = initializer(ArbFloat{p})
    z
end


ArbFloat(x::Real) = ArbFloat{precision(ArbFloat)}(x)


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

function round{P}(x::ArbFloat{P}; sigbits::Int=P)
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_round), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
   z
end
round{P}(x::ArbFloat{P}, prec::Int) = round(x,sigbits=prec)

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


function decompose{P}(x::ArbFloat{P})
    # decompose x as num * 2^pow / den
    # num, pow, den = decompose(x)
    bf = convert(BigFloat, x)
    decompose(bf)
end
