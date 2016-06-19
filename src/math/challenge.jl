#=
   Rump challenge, setprecision(ArbFloat, prec) where prec >= 122
   correct -0.82729605994682136... not 1.172604...

   tst2=RumpChallenge()
   Float64(tst2.val) == -0.8273960599468214
=#   

function RumpChallenge(NumType, prec)
    setprecision(NumType,prec)
    k77617 = convert(NumType, 77617)
    k33096 = convert(NumType, 33096)
    k33375 = convert(NumType, 333) + convert(NumType, 0.75)
    k11 = convert(NumType, 11)
    k121 = convert(NumType, 121)
    k2 = convert(NumType, 2)
    k55 = convert(NumType, 5) + convert(NumType, 0.5)
    
    x = k77617; y = k33096
    x2 = x*x
    y2 = y*y; y3 = y2*y; y4 = y2*y2; y6 = y3*y3; y8 = y4*y4
    a=k33375*y6
    b=x2 * (k11*x2*y2 - y6 - k121*y4 - k2)
    c=k55*y8;  d=x/(y+y)
    b=x2 * (k11*x2*y2 - y6 - k121*y4 - k2)
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

