module ArbFloats

import Base: hash, convert, promote_rule, isa,
    string, show, showcompact, showall, parse,
    finalizer, decompose, precision, setprecision,
    copy, deepcopy,
    zero, one, ldexp, frexp, eps,
    isequal, isless, (==),(!=),(<),(<=),(>=),(>),
    min, max, minmax,
    isnan, isinf, isfinite, issubnormal,
    signbit, sign, flipsign, copysign, abs, inv,
    (+),(-),(*),(/),(\),(%),(^), sqrt, hypot,
    trunc, round, ceil, floor,
    fld, cld, div, mod, rem, divrem, fldmod,
    muladd, fma,
    exp, expm1, log, log1p, log2, log10,
    sin, cos, tan, csc, sec, cot, asin, acos, atan, atan2,
    sinh, cosh, tanh, csch, sech, coth, asinh, acosh, atanh,
    sinc, gamma, lgamma, digamma, zeta, factorial,
    BigInt, BigFloat,
    Cint

export ArbFloat,      # co-matched decimal rounding, n | round(hi,n,10) == round(lo,n,10)
       @ArbFloat,     # converts string form of argument, precision is optional first arg in two arg form
       showsmart,
       midpoint, radius, upperbound, lowerbound, smartstring,
       two, three, four, copymidpoint, copyradius, deepcopyradius, 
       epsilon, trim, tidy, decompose,
       invsqrt, pow, root, tanpi, cotpi, logbase, sincos, sincospi, sinhcosh,
       doublefactorial, risingfactorial, rgamma, agm, polylog,
       relativeError, relativeAccuracy, midpointPrecision, trimmedAccuracy,
       PI,SQRTPI,LOG2,LOG10,EXP1,EULER,CATALAN,KHINCHIN,GLAISHER,APERY # constants

                      # Complex( ArbSpan(real), ArbSpan(imaginary) )
                      #
                      #    The real 'radius' and the imaginary 'radius' form a bounding box
                      #    in the complex plane centered on the place indicated as
                      #    Complex( midpoint(real), midpoint(imaginary) ) and oriented
                      #    by considering the 'radii' as conjugate diameters of an ellipse
                      #    < this ellipse gives the box as that in which it is inscribed >
                      #    positioned about the cartesian (or polar) location
                      #    given as Complex(real midpoint, imaginary midpoint)
                      #    and oriented with the real 'radius' centered along
                      #    the phase atan2( midpoint(imag), midpoint(real) )
                      #    and centered about Complex(midpoint(real), midpoint(imag))
                      #    with the imaginary 'radius' about the same center
                      #    oriented perpendicular to the real diameter 
                      #    atan2(-midpoint(imag), -midpoint(real) ).
                      


# ensure the requisite libraries are available

isdir(Pkg.dir("Nemo")) || throw(ErrorException("Nemo not found"))

libDir = Pkg.dir("Nemo/local/lib");
libFiles = readdir(libDir);
libarb   = joinpath(libDir,libFiles[findfirst([startswith(x,"libarb") for x in libFiles])])
libflint = joinpath(libDir,libFiles[findfirst([startswith(x,"libflint") for x in libFiles])])
isfile(libarb)   || throw(ErrorException("libarb not found"))
isfile(libflint) || throw(ErrorException("libflint not found"))

@static if is_linux() || is_bsd() || is_unix()
    libarb = String(split(libarb,".so")[1])
    libflint = String(split(libflint,".so")[1])
end
@static if is_apple()
    libarb = String(split(libarb,".dynlib")[1])
    libflint = String(split(libflint,".dynlib")[1])
end
@static if is_windows()
    libarb = String(split(libarb,".dll")[1])
    libflint = String(split(libflint,".dll")[1])
end

macro libarb(sym)
    (:($sym), libarb)
end

macro libflint(sym)
    (:($sym), libflint)
end

    
NotImplemented(info::AbstractString="") = error(string("this is not implemented\n\t",info,"\n"))

include("type/ArfFloat.jl")
include("type/ArbFloat.jl")

include("type/primitive.jl")
include("type/string.jl")
include("type/convert.jl")
include("type/compare.jl")
include("type/io.jl")

include("math/arith.jl")
include("math/round.jl")
include("math/elementary.jl")
include("math/constants.jl")
include("math/special.jl")

end # ArbFloats
