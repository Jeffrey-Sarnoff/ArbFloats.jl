#=
   Rump challenge, setprecision(ArbFloat, prec) where prec >= 122
   correct -0.82729605994682136... not 1.172604...

   tst2=RumpChallenge()
   Float64(tst2.val) == -0.8273960599468214
=#   

function RumpChallenge()
    x = ArbFloat(77617); y = ArbFloat(33096)
    x2 = x*x
    y2 = y*y; y3 = y2*y; y4 = y2*y2; y6 = y3*y3; y8 = y4*y4
    a=ArbFloat("333.75")*y6
    b=x2 * (ArbFloat("11")*x2*y2 - y6 - ArbFloat("121")*y4 - ArbFloat("2"))
    c=ArbFloat("5.5")*y8;  d=x/(y+y)
    b=x2 * (ArbFloat("11")*x2*y2 - y6 - ArbFloat("121")*y4 - ArbFloat("2"))
    a+b+c+d
end



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

function MullersKahanChallenge{P}(x::Int, ::Type{Val{P}})
    prec = parse(Int, string(P))
    a = ArbFloat{prec}(x)
    H(a)
end    
    
MullerKahanChallenge( x::Int) = MullersKahanChallenge(x, Val{precision(ArbFloat)})

