#=
    J-M Muller's "Kahan Challenge"
=#    
function E(x)
    if iszero(x)
        ArbFloat(1)
    else
        (expm1(x))//x
    end
end
function Q(x)
    a = abs(x - sqrt(x*x+ArbFloat(1)))
    b = ArbFloat(1)//(x+sqrt(x*x + ArbFloat(1)))
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

function MullerKahanChallenge(x::Int)
    a = ArbFloat(x)
    H(x)
end    
    
    
