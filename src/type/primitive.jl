
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

function copyradius{P}(target::ArbFloat{P}, source::ArbFloat{P})
    z = deepcopy(target)
    z.rad_exp = source.rad_exp
    z.rad_man = source.rad_man
    z
end

function deepcopyradius{P}(target::ArbFloat{P}, source::ArbFloat{P})
    target.rad_exp = source.rad_exp
    target.rad_man = source.rad_man
    target
end

function copymidpoint{P}(target::ArbFloat{P}, source::ArbFloat{P})
    z = deepcopy(target)
    z.mid_exp = source.mid_exp
    z.mid_size = source.mid_size
    z.mid_d1 = source.mid_d1
    z.mid_d2 = source.mid_d2
    z
end


function decompose{P}(x::ArbFloat{P})
    # decompose x as num * 2^pow / den
    # num, pow, den = decompose(x)
    bfprec=precision(BigFloat)
    setprecision(BigFloat,P)
    bf = convert(BigFloat, x)
    n,p,d = decompose(bf)
    setprecision(BigFloat,bfprec)
    n,p,d
end

function round{P}(x::ArbFloat{P}, sig::Int=P, base::Int=2)
    nbits = base==2 ? min(sig,P) : (base==10 ? trunc(Int,sig*3.3219281) : trunc(Int,1.0e-8+sig*log(base)/log(2.0)))
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    finalizer(z, clearArbFloat)
    ccall(@libarb(arb_set_round), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, nbits)
    z
end


eps{P}(::Type{ArbFloat{P}}) = ldexp(1.0,-P) # for intertype workings
eps{P}(x::ArbFloat{P}) = ldexp(1.0,-P)*x    # for intratype workings
