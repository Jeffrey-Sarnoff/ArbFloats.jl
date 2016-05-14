#=
   -x, abs(x), inv(x)
   x+y, x-y, x*y, x/y
   x^y
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

function inv{P}(x::ArbFloat{P})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat},), &z)
    ccall(@libarb(arb_inv), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), Int), &z, &x, P)
    finalizer(z, clearArbFloat)      
    z
end

for (op,cfunc) in ((:+,:arb_add), (:-, :arb_sub), (:*, :arb_mul), (:/, :arb_div), (:^, :arb_pow))
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
