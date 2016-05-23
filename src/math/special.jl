for (op,cfunc) in ((:factorial,:arb_fac_ui), (:doublefactorial,:arb_doublefac_ui), (:risingfactorial, :arb_rising_ui))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::Int)
      yy = UInt(y)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, UInt, Int), &z, &x, &yy, P)
      z
    end
  end
end

for (op,cfunc) in ((:agm, :arb_agm), (:polylog, :arb_polylog))
  @eval beg
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P}, prec::Int=P)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
  end  
end
