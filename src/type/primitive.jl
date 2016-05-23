
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

function round{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = ceil(Int, (sig * log(base)/log(2.0)))
    sigbits = min(P,sigbits)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    finalizer(z, clearArbFloat)
    ccall(@libarb(arb_set_round), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    z
end

function ceil{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = ceil(Int, (sig * log(base)/log(2.0)))
    sigbits = min(P,sigbits)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    finalizer(z, clearArbFloat)
    ccall(@libarb(arb_ceil), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    z
end

function floor{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = ceil(Int, (sig * log(base)/log(2.0)))
    sigbits = min(P,sigbits)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    finalizer(z, clearArbFloat)
    ccall(@libarb(arb_floor), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    z
end

function trunc{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = ceil(Int, (sig * log(base)/log(2.0)))
    sigbits = min(P,sigbits)
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    finalizer(z, clearArbFloat)
    y = abs(x)
    ccall(@libarb(arb_floor), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &y, sigbits)
    signbit(x) ? -z : z
end

function round{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = round(x, sig, base)
    convert(T, z)
end
function ceil{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = ceil(x, sig, base)
    convert(T, z)
end
function floor{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = floor(x, sig, base)
    convert(T, z)
end
function trunc{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = trunc(x, sig, base)
    convert(T, z)
end


eps{P}(::Type{ArbFloat{P}}) = ldexp(1.0,-P) # for intertype workings
eps{P}(x::ArbFloat{P}) = ldexp(1.0,-P)*x    # for intratype workings
