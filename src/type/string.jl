
function String{P}(x::ArbFloat{P}, flags::UInt)
   n = floor(Int, P*0.3010299956639811952137)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = bytestring(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function string{P}(x::ArbFloat{P})
   # n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
   s = String(x,UInt(2)) # midpoint only (within 1ulp), RoundNearest
   s 
end


function stringInformed{P}(x::ArbFloat{P})
    ub = upperbound(x)
    lb = lowerbound(x)
    
    if (ub==lb)
       if ub.rad_man==0
          if ub.mid_d2==0
              return string(Float64(ub))
          else
              return string(ub)
          end
       else
           return string(ub,"~")
       end
    end
    
    ubstr = stringTrimmed(ub,0)
    lbstr = stringTrimmed(lb,0)
    ubstrlen = length(ubstr)
    lbstrlen = length(lbstr)
    ubdelta = lbdelta = 0
    if ubstrlen > lbstrlen
       ubdelta = lbstrlen-ubstrlen
    else
       lbdelta = lbstrlen-ubstrlen
    end
    
    for i in 0:(ubstrlen+ubdelta+lbdelta-4)
        ubstr = stringTrimmed(ub,i-ubdelta)
        lbstr = stringTrimmed(lb,i-lbdelta)
        if ubstr==lbstr
           break
        end
    end
    
    sval = ArbFloat{P}(ubstr)
    if midpoint(sval) > midpoint(x)
       string(ubstr,"₋")
    elseif midpoint(sval) < midpoint(x)
       string(ubstr,"₊")
    else
       string(ubstr,"~")
    end
end    