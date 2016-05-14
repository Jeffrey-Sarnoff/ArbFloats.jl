#=
   -x, abs(x), inv(x),
   floor(x), ceil(x), sqrt(x), invsqrt(x)
   x+y, x-y, x*y, x/y, hypot(x,y)
=#

for (op,cfunc) in ((:-,:arb_neg), (:abs, :arb_abs))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      z = ArbFloat{P}(0,0,0,0,0,0)
      ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
      finalizer(z, clearArbFloat)      
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
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, P)
      finalizer(z, clearArbFloat)      
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
      finalizer(z, clearArbFloat)      
      z
    end
  end
end

for (op,cfunc) in ((:addmul,:arb_addmul), (:submul, :arb_submul))
  @eval begin
    function ($op){P}(w::ArbFloat{P}, x::ArbFloat{P}, y::ArbFloat{P})
      z = ArbFloat{P}(0,0,0,0,0,0)
      ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &w, &x, &y, P)
      finalizer(z, clearArbFloat)      
      z
    end
  end
end

muladd{P}(a::ArbFloat{P}, b::ArbFloat{P}, c::ArbFloat{P}) = addmul(c,a,b)

function (fma){P}(w::ArbFloat{P}, x::ArbFloat{P}, y::ArbFloat{P})
   P3=floor(Int,P*3.25)
   z = ArbFloat{P}(0,0,0,0,0,0)
   zz = ArbFloat{P3}(0,0,0,0,0,0)
   ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
   ccall(@libarb(arb_addmul), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &zz, &w, &x, &y, P)
   ccall(@libarb(arb_set_round), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &zz, &z, P)
   finalizer(z, clearArbFloat)      
   z
end
