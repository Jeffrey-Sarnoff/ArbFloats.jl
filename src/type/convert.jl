macro ArbFloat(x)
    convert(ArbFloat, string(:($x)))
end
macro ArbFloat(p,x)
    convert(ArbFloat{:($p)}, string(:($x)))
end

# interconvert Arb with Arf

function convert{P}(::Type{ArbFloat{P}}, x::ArfFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}), &z, &x)
    z
end

function convert{P}(::Type{ArfFloat{P}}, x::ArbFloat{P})
    z = initializer(ArfFloat{P})
    z.mid_exp  = x.mid_exp
    z.mid_size = x.mid_size
    z.mid_d1   = x.mid_d1
    z.mid_d2   = x.mid_d2
    z
end


function convert{P}(::Type{ArbFloat{P}}, x::UInt)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_ui), Void, (Ptr{ArbFloat{P}}, UInt), &z, x)
    z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::UInt32) = convert(ArbFloat{P}, convert(UInt64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::UInt64) = convert(ArbFloat{P}, convert(UInt32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::UInt16) = convert(ArbFloat{P}, convert(UInt,x))

function convert{P}(::Type{ArbFloat{P}}, x::Int)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat{P}}, Int), &z, x)
    z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::Int32) = convert(ArbFloat{P}, convert(Int64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::Int64) = convert(ArbFloat{P}, convert(Int32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::Int16) = convert(ArbFloat{P}, convert(Int,x))


function convert{P}(::Type{ArbFloat{P}}, x::Float64)
    z = initializer(ArbFloat{P})
    fp=copy(x)
    ccall(@libarb(arb_set_d), Void, (Ptr{ArbFloat{P}}, Float64), &z, fp)
    z
end
convert{P}(::Type{ArbFloat{P}}, x::Float32) = convert(ArbFloat{P}, convert(Float64,x))
convert{P}(::Type{ArbFloat{P}}, x::Float16) = convert(ArbFloat{P}, convert(Float64,x))


function convert{P}(::Type{ArbFloat{P}}, x::String)
    s = String(x)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_str), Void, (Ptr{ArbFloat}, Ptr{UInt8}, Int), &z, s, P)
    z
end


convert(::Type{BigInt}, x::String) = parse(BigInt,x)
convert(::Type{BigFloat}, x::String) = parse(BigFloat,x)

function convert{P}(::Type{ArbFloat{P}}, x::BigFloat)
     x = round(x,P,2)
     s = string(x)
     ArbFloat{P}(s)
end

function convert{P}(::Type{BigFloat}, x::ArbFloat{P})
     s = string(midpoint(x))
     round(parse(BigFloat, s),P,2)
end

function convert{I<:Integer,P}(::Type{Rational{I}}, x::ArbFloat{P})
    bf = convert(BigFloat, x)
    convert(Rational{I}, bf)
end

convert{P}(::Type{ArbFloat{P}}, x::BigInt)   = convert(ArbFloat{P}, convert(BigFloat,x))
convert{P}(::Type{ArbFloat{P}}, x::Rational) = convert(ArbFloat{P}, convert(BigFloat,x))
convert{P,S}(::Type{ArbFloat{P}}, x::Irrational{S}) = convert(ArbFloat{P}, convert(BigFloat,x))


#= returns 256.0 for convert(big(1.5))
function convert{P}(::Type{ArbFloat{P}}, x::BigFloat)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_round_fmpz), Void, (Ptr{ArbFloat}, Ptr{BigFloat}, Int), &z, &x, P)
    z
end
=#

function num2str{P}(x::ArbFloat{P}, n::Int)
   flags = UInt(2)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

convert{P}(::Type{ArbFloat{P}}, y::ArbFloat{P}) = y

function convert{P}(::Type{Float64}, x::ArbFloat{P})
    s = num2str(x,trunc(Int, 1+P*0.30103))
    parse(Float64,s)
    #ccall(@libarb(arb_set_d), Void, (Ptr{ArbFloat{P}}, Float64), &x, z)
    #z
end
convert{P}(::Type{Float32}, x::ArbFloat{P}) = convert(Float32,convert(Float64,x))

function convert{I<:Integer,P}(::Type{I}, x::ArbFloat{P})
    s = num2str(x, trunc(Int, 1+P*0.30103)) # P * log(2)/log(10)
    parse(I,split(s,".")[1])
end

#=
# precision(BigFloat) may be less than max(P,Q)
function convert{P,Q}(::Type{ArbFloat{Q}}, y::ArbFloat{P})
    bf = convert(BigFloat,y)
    convert(ArbFloat{Q}, bf)
end    
=#

function convert{P,Q}(::Type{ArbFloat{Q}}, x::ArbFloat{P})
    if (Q < P)
        x = round(x, Q, 2)
    end
    
    a = initializer(ArfFloat{Q})
    a.mid_exp  = x.mid_exp
    a.mid_size = x.mid_size
    a.mid_d1   = x.mid_d1
    a.mid_d2   = x.mid_d2

    z = initializer(ArbFloat{Q})
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    z.rad_exp = x.rad_exp
    z.ran_man = x.rad_man
    ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &a)
    
    z
end    


for T in (:Int128, :Int64, :Int32, :Int16, :Float64, :Float32, :Float16, 
          :(Rational{Int64}), :(Rational{Int32}), :(Rational{Int16}), 
          :String)
  @eval convert(::Type{ArbFloat}, x::$T) = convert(ArbFloat{precision(ArbFloat)}, x)
end  


# Promotion
for T in (:Int128, :Int64, :Int32, :Int16, :Float64, :Float32, :Float16, 
          :(Rational{Int64}), :(Rational{Int32}), :(Rational{Int16}), 
          :String)
  @eval promote_rule{P}(::Type{ArbFloat{P}}, ::Type{$T}) = ArbFloat{P}
end  

promote_rule{P}(::Type{ArbFloat{P}}, ::Type{BigFloat}) = BigFloat
promote_rule{P}(::Type{ArbFloat{P}}, ::Type{BigInt}) = ArbFloat{P}
promote_rule{P}(::Type{ArbFloat{P}}, ::Type{Rational{BigInt}}) = Rational{BigInt}


