
log2o10{P}(::Type{ArbFloat{P}}) = log(ArbFloat{P}(2))/log(ArbFloat{P}(10))
log10o2{P}(::Type{ArbFloat{P}}) = log(ArbFloat{P}(10))/log(ArbFloat{P}(2))

exp1{P}(::Type{ArbFloat{P}})    = exp(ArbFloat{P}(1))

fourpi{P}(::Type{ArbFloat{P}})  = ArbFloat{P}(16)*atan(ArbFloat{P}(1))
twopi{P}(::Type{ArbFloat{P}})   = ArbFloat{P}(8)*atan(ArbFloat{P}(1))
onepi{P}(::Type{ArbFloat{P}})   = ArbFloat{P}(4)*atan(ArbFloat{P}(1))
halfpi{P}(::Type{ArbFloat{P}})  = ArbFloat{P}(2)*atan(ArbFloat{P}(1))
qrtrpi{P}(::Type{ArbFloat{P}})  = atan(ArbFloat{P}(1))


golden{P}(::Type{ArbFloat{P}})  = (1+sqrt(ArbFloat{P}(4)))/ArbFloat{P}(2)



log2o10(::Type{ArbFloat}) = log2o10{precision(ArbFloat)}
log10o2(::Type{ArbFloat}) = log10o2{precision(ArbFloat)}

exp1(::Type{ArbFloat}) = exp1{precision(ArbFloat)}

fourpi(::Type{ArbFloat}) = fourpi{precision(ArbFloat)}
twopi(::Type{ArbFloat}) = twopi{precision(ArbFloat)}
onepi(::Type{ArbFloat}) = onepi{precision(ArbFloat)}
halfpi(::Type{ArbFloat}) = halfpi{precision(ArbFloat)}
qrtrpi(::Type{ArbFloat}) = qrtrpi{precision(ArbFloat)}

