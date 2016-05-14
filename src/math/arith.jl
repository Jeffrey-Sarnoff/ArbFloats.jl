#=
   -x, abs(x), inv(x),
   floor(x), ceil(x), sqrt(x), invsqrt(x)
   x+y, x-y, x*y, x/y, hypot(x,y)
   muladd(a,b,c), fma(a,b,c)
=#

for (op,cfunc) in ((:-,:arb_neg), (:abs, :arb_abs))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      z = ArbFloat{P}(0,0,0,0,0,0)
      ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
      finalizer(z)      
      z
    end
  end
end

for (op,cfunc) in ((:inv, :arb_inv), (:floor,:arb_floor), (:ceil, :arb_ceil), 
    (:sqrt, :arb_sqrt), (:invsqrt, :arb_rsqrt))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      z = ArbFloat{P}(0,0,0,0,0,0)
      ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, P)
      finalizer(z)      
      z
    end
  end
end

for (op,cfunc) in ((:+,:arb_add), (:-, :arb_sub), (:*, :arb_mul), (:/, :arb_div), (:hypot, :arb_hypot))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P})
      z = ArbFloat{P}(0,0,0,0,0,0)
      ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      finalizer(z)      
      z
    end
    ($op){T<:AbstractFloat,P}(x::ArbFloat{P}, y::T) = ($op)(x, ArbFloat{P}(y))
    ($op){T<:AbstractFloat,P}(x::T, y::ArbFloat{P}) = ($op)(ArbFloat{P}(x), y)
  end
end

for (op,cfunc) in ((:+,:arb_add_si), (:-, :arb_sub_si), (:*, :arb_mul_si), (:/, :arb_div_si))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::Int)
      z = ArbFloat{P}(0,0,0,0,0,0)
      ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int, Int), &z, &x, y, P)
      finalizer(z)      
      z
    end
  end
end

(+){P}(x::Int, y::ArbFloat{P}) = (+)(y,x)
(-){P}(x::Int, y::ArbFloat{P}) = -((-)(y,x))
(*){P}(x::Int, y::ArbFloat{P}) = (*)(y,x)
(/){P}(x::Int, y::ArbFloat{P}) = (/)(ArbFloat{P}(x),y)

(+){P}(x::ArbFloat{P}, y::Integer) = (+)(x, ArbFloat(y))
(-){P}(x::ArbFloat{P}, y::Integer) = (-)(x, ArbFloat(y))
(*){P}(x::ArbFloat{P}, y::Integer) = (*)(x, ArbFloat(y))
(.){P}(x::ArbFloat{P}, y::Integer) = (/)(x, ArbFloat(y))

(+){P}(x::Integer, y::ArbFloat{P}) = (+)(ArbFloat(x),y)
(-){P}(x::Integer, y::ArbFloat{P}) = -((-)(y,ArbFloat(x)))
(*){P}(x::Integer, y::ArbFloat{P}) = (*)(ArbFloat(x),y)
(/){P}(x::Integer, y::ArbFloat{P}) = (/)(ArbFloat(x),y)

for (op,cfunc) in ((:addmul,:arb_addmul), (:submul, :arb_submul))
  @eval begin
    function ($op){P}(w::ArbFloat{P}, x::ArbFloat{P}, y::ArbFloat{P})
      z = ArbFloat{P}(0,0,0,0,0,0)
      ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &w, &x, &y, P)
      finalizer(z)      
      z
    end
  end
end

muladd{P}(a::ArbFloat{P}, b::ArbFloat{P}, c::ArbFloat{P}) = addmul(c,a,b)
mulsub{P}(a::ArbFloat{P}, b::ArbFloat{P}, c::ArbFloat{P}) = addmul(-c,a,b)

