function show{P}(io::IO, x::ArbFloat{P})
    s = string(x)
    print(io, s)
end

function showall{P}(io::IO, x::ArbFloat{P})
    s = string(midpoint(x)," ± ", convert(Float64,radius(x)))
    print(io, s)
end

#=
function showall{P,N}(io::IO, x::NTuple{N,ArbFloat{P}})
    for z in x
      s = string(midpoint(z)," ± ", convert(Float64,radius(z)))
      print(io, s);print(io,"\n")
    end
end
=#

function showall{P,N}(io::IO, x::NTuple{N,ArbFloat{P}})
    if N==0
       print(io,"()")
       return nothing
    elseif N==1
       print(io,string("(",midpoint(x[1])," ± ", convert(Float64,radius(x[1])),")"))
    end
    
    ss = Vector{String}(N)
    for i in 1:N
      z = x[i]
      ss[i] = string(midpoint(z)," ± ", convert(Float64,radius(z)))
    end
    
    println(io,string("( ", ss[1], ","));
    for s in ss[2:end-1]
      println(io, string("  ", s, ","))
    end  
    println(io,string("  ", ss[end], ")"))
end

function showall{P}(io::IO, x::Vector{ArbFloat{P}})
    n = length(x)
    ss = Vector{String}(n)
    for i in 1:n
      z = x[i]
      ss[i] = string(midpoint(z)," ± ", convert(Float64,radius(z)))
    end
    print(io, ss)
end

function showcompact{P}(io::IO, x::ArbFloat{P})
    showcompact(io, Float64(midpoint(x)))
end

function showsmart{P}(io::IO, x::ArbFloat{P})
    s = smartstring(x)
    print(io, s)
end

function showsmart{P}(x::ArbFloat{P})
    s = smartstring(x)
    print(s)
end
