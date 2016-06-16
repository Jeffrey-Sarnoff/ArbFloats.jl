function String{P}(x::ArbFloat{P}, ndigits::Int, flags::UInt)
   n = max(1,min(abs(ndigits), floor(Int, P*0.3010299956639811952137)))
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function String{P}(x::ArbFloat{P}, flags::UInt)
   n = floor(Int, P*0.3010299956639811952137)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function string{P}(x::ArbFloat{P}, ndigits::Int)
   # n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
   s = String(x, ndigits, UInt(2)) # midpoint only (within 1ulp), RoundNearest
   s 
end

function string{P}(x::ArbFloat{P})
   # n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
   s = String(x,UInt(2)) # midpoint only (within 1ulp), RoundNearest
   s 
end

function stringTrimmed{P}(x::ArbFloat{P}, ndigitsremoved::Int)
   n = max(0, ndigitsremoved)
   n = max(1, floor(Int, P*0.3010299956639811952137) - n)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, UInt(2))
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

#=
     find the smallest N such that stringTrimmed(lowerbound(x), N) == stringTrimmed(upperbound(x), N)

     digits = floor(Int, precision(x)*0.3010299956639811952137)-1
     lb, ub = bounds(x)
     lbs = String(lb, digits, UInt(2))
     ubs = String(ub, digits, UInt(2))
     for i in (digits-1):-1:4
         if lbs[end]==ubs[end]
            if lbs == ubs
               break
            end
         end
         lbs = String(lb, i, UInt(2))
         ubs = String(ub, i, UInt(2))
     end
     if lbs != ubs
        ubs = String(x, 3, UInt(2))
     end
     ubs
     
=#

function smartarbstring{P}(x::ArbFloat{P})
     digits = floor(Int, precision(x)*0.3010299956639811952137)

     if isexact(x)
        return String(x, digits, UInt(2))
     end
     
     lb, ub = bounds(x)
     lbs = String(lb, digits, UInt(2))
     ubs = String(ub, digits, UInt(2))
     if lbs[end]==ubs[end] && lbs==ubs
         return ubs
     end
     for i in (digits-2):-2:4 
         lbs = String(lb, i, UInt(2))
         ubs = String(ub, i, UInt(2))
         if lbs[end]==ubs[end] && lbs==ubs # tests rounding to every other digit position
            us = String(ub, i+1, UInt(2))
            ls = String(lb, i+1, UInt(2))
            if us[end] == ls[end] && us==ls # tests rounding to every digit position
               ubs = lbs = us
            end
            break
         end
     end
     if lbs != ubs
        ubs = String(x, 3, UInt(2))
     end
     ubs
end


#=
function stringRoundNearest{P}(x::ArbFloat{P})
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, P, UInt(2)) # round nearest
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end
function stringRoundFromZeroWithRadius{P}(x::ArbFloat{P})
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, P, UInt(1)) # round up
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end
function stringRoundToZeroWithRadius{P}(x::ArbFloat{P})
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, P, UInt(0)) # round down
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end
function stringRoundFromZero{P}(x::ArbFloat{P})
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, P, UInt(3)) # round ceil
   s = String(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end
=#


#=
function smartarbstring{P}(x::ArbFloat{P})
    if midpoint(x)==0 && notexact(x)
       s = string(radius(x))
       if contains(s, "e")
          s1,s2 = split(s,"e")
          if length(s2)>0
             return string("±", rstrip(s1,'0'),"e",s2)
          else
             return string("±", rstrip(s1,'0'))
          end   
       else
          return string("±", rstrip(s,'0'))
       end
    end

    
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
           return string(ub)
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
    
    ubstr
end    
=#

function smartstring{P}(x::ArbFloat{P})
    if midpoint(x)==0 && notexact(x)
       s = string(radius(x))
       if contains(s, "e")
          s1,s2 = split(s,"e")
          if length(s2)>0
             return string("±", rstrip(s1,'0'),"e",s2)
          else
             return string("±", rstrip(s1,'0'))
          end   
       else
          return string("±", rstrip(s,'0'))
       end
    end

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
    
    bfprec=precision(BigFloat)
    setprecision(BigFloat,P+64)
    sval = round(parse(BigFloat,ubstr),P,2)
    mval = round(BigFloat(midpoint(x)),P,2)
    if sval > mval
       ubstr = string(ubstr,"₋")
    elseif sval < mval
       ubstr = string(ubstr,"₊")
    else
       ubstr = string(ubstr,"~")
    end
    setprecision(BigFloat,bfprec)
    ubstr
end    

function stringAll{P}(x::ArbFloat{P})
    string(midpoint(x)," ± ", string(radius(x),17))
end

function stringCompact{P}(x::ArbFloat{P})
    string(x,8)
end

function stringAllCompact{P}(x::ArbFloat{P})
    string(string(midpoint(x),8)," ± ", string(radius(x),5))
end

