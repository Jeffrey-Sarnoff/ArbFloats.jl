function show{P}(io::IO, x::ArbFloat{P})
    s = string(x)
    print(io, s)
end

function showall{P}(io::IO, x::ArbFloat{P})
    s = string(midpoint(x)," ± ", convert(Float64,radius(x)))
    print(io, s)
end


function stringall{P}(x::ArbFloat{P})
    string(midpoint(x)," ± ", convert(Float64,radius(x)))
end

function showall{P,N}(io::IO, x::NTuple{N,ArbFloat{P}})
    if N==0
       print(io,"()")
       return nothing
    elseif N==1
       print(io,string("( ",stringall(x[1]),", )"))
       return nothing
    end
    
    ss = Vector{String}(N)
    for i in 1:N
      ss[i] = stringall(x[i])
    end
    
    println(io,string("( ", ss[1], ","));
    for s in ss[2:end-1]
      println(io, string("  ", s, ","))
    end  
    println(io,string("  ", ss[end], " )"))
end

function showall{P}(io::IO, x::Vector{ArbFloat{P}})
    n = length(x)

    if n==0
       print(io,"[]")
       return nothing
    elseif n==1
       print(io,string("[ ",stringall(x[1])," ]"))
       return nothing
    end
    
    ss = Vector{String}(n)
    for i in 1:n
      ss[i] = stringall(x[i])
    end
    
    println(io,string("[ ", ss[1], ","));
    for s in ss[2:end-1]
      println(io, string("  ", s, ","))
    end  
    println(io,string("  ", ss[end], " ]"))
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
