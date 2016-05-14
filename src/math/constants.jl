

function PI{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_pi), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
PI(::Type{ArbFloat}) = PI(ArbFloat{precision(ArbFloat)})

function SQRTPI{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_sqrtpi), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
SQRTPI(::Type{ArbFloat}) = SQRTPI(ArbFloat{precision(ArbFloat)})

function LOG2{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_log2), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
LOG2(::Type{ArbFloat}) = LOG2(ArbFloat{precision(ArbFloat)})

function LOG10{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_log10), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
LOG10(::Type{ArbFloat}) = LOG10(ArbFloat{precision(ArbFloat)})

function EXP1{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_e), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
EXP1(::Type{ArbFloat}) = EXP1(ArbFloat{precision(ArbFloat)})


function EULER{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_euler), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
EULER(::Type{ArbFloat}) = EULER(ArbFloat{precision(ArbFloat)})

function CATALAN{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_catalan), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
CATALAN(::Type{ArbFloat}) = CATALAN(ArbFloat{precision(ArbFloat)})

function KINCHIN{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_kinchin), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
KHINCHIN(::Type{ArbFloat}) = KINCHIN(ArbFloat{precision(ArbFloat)})

function GLAISHER{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_apery), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
GLAISHER(::Type{ArbFloat}) = GLAISHER(ArbFloat{precision(ArbFloat)})

function APERY{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_const_apery), Void, (Ptr{ArbFloat}, Int), &z, P)
    finalizer(z)
    z
end
APERY(::Type{ArbFloat}) = APERY(ArbFloat{precision(ArbFloat)})

