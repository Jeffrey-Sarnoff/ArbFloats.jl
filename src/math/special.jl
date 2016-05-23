for (op,cfunc) in ((:factorial,:arb_fac_ui), (:doublefactorial,:arb_doublefac_ui)) 
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      signbit(x) && ErrorException("Domain Error: argument is negative")
      y = trunc(UInt, x)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, UInt, Int), &z, &yy, P)
      z
    end
  end
end

for (op,cfunc) in ((:agm, :arb_agm), (:polylog, :arb_polylog))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P}, prec::Int=P)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
  end  
end
