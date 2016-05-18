
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


function decompose{P}(x::ArbFloat{P})
    # decompose x as num * 2^pow / den
    # num, pow, den = decompose(x)
    bf = convert(BigFloat, x)
    decompose(bf)
end

function round{P}(x::ArbFloat{P}; sigbits::Int=P)
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_round), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
   z
end
round{P}(x::ArbFloat{P}, prec::Int) = round(x,sigbits=prec)


eps{P}(::Type{ArbFloat{P}}) = ldexp(1.0,-P) # for intertype workings
eps{P}(x::ArbFloat{P}) = ldexp(1.0,-P)*x    # for intratype workings
