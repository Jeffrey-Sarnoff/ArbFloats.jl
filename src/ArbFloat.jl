module ArbFloat

import Base: hash, convert, promote_rule, isa,
    string, show, showcompact, showall, parse,
    zero, one, ldexp, frexp, eps,
    isequal, isless, (==),(!=),(<),(<=),(>=),(>)
    min, max, minmax,
    isnan, isinf, isfinite, issubnormal,
    signbit, sign, flipsign, copysign, abs,
    (+),(-),(*),(/),(\),(%),(^),sqrt,
    trunc, round, ceil, floor,
    fld, cld, div, mod, rem, divrem, fldmod,
    

include("api/ArbLib.jl")
include("api/AcbLib.jl")

include("type/Arb.jl")
include("type/Acb.jl")




end # ArbFloat
