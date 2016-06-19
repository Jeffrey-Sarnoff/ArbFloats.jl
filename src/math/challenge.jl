#=
    J-M Muller's "Kahan Challenge"
=#


# zero{P}(::Type{ArbFloat{P}}) = ArbFloat{P}(0)
#  one{P}(::Type{ArbFloat{P}}) = ArbFloat{P}(1)

function E(x)
    if iszero(x)
        ArbFloat{precision(ArbFloat)}(1)
    else
        expm1(x) / x
    end
end
function Q(x)
    af1 = one(ArbFloat{precision(ArbFloat)})
    a = abs(x - sqrt(x*x+af1))
    b = af1 / (x+sqrt(x*x + af1))
    a - b
end
function H(x)
    z=Q(x)
    E(z*z)
end

#=
   compute H(x) for x = 15,16,17,9999; repeat with more precision
   correct answer is 1 wrong answer is 0
       setprecision(ArbFloat,prec) where prec >= 23, 62 for 999999999

   Float64(midpoint(H(ArbFloat("9999"))).val) == 1.0
=#       

function MullerKahanChallenge{P}(x::Int, ::Type{Val{P}})
    prec = Int(string(P))
    a = ArbFloat{P}(x)
    H(a)
end    
    
    
