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

fld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = floor(x/y)
cld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = ceil(x/y)
div{P}(x::ArbFloat{P}, y::ArbFloat{P}) = trunc(x/y)

