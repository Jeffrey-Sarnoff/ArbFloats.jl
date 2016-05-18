
# fractionalPart(x), wholePart(x) = modf(x)
#
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
