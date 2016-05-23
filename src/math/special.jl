for (op,cfunc) in ((:agm, :arb_agm), (:polylog, :arb_polylog))
  @eval beg
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P}, prec::Int=P)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
  end  
end
