
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

const ArbFloatPrecision = [116,]
precision(::Type{ArbFloat}) = ArbFloatPrecision[1]

function setprecision(::Type{ArbFloat}, x::Int)
    bigprecisionGTE = trunc(Int, x*25/12)
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

upperbound{P}(x::ArbFloat{P}) = midpoint(x) + radius(x)
lowerbound{P}(x::ArbFloat{P}) = midpoint(x) - radius(x)

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

