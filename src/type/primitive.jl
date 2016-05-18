eps{P}(::Type{ArbFloat{P}}) = ldexp(1.0,-P) # for intertype workings
eps{P}(x::ArbFloat{P}) = ldexp(1.0,-P)*x    # for intratype workings
