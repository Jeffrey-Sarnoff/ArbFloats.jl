function show{P}(io::IO, x::ArbFloat{P})
    s = string(x)
    print(io, s)
end

function showcompact{P}(io::IO, x::ArbFloat{P})
    showcompact(io, Float64(midpoint(x)))
end

function showall{P}(io::IO, x::ArbFloat{P})
    s = string(midpoint(x)," ± ", convert(Float64,radius(x)))
    print(io, s)
end


function showsmart{P}(io::IO, x::ArbFloat{P})
    s = smartstring(x)
    print(io, s)
end

function showmany{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}, stringformer::Function)
    if N==0
       print(io,"()")
       return nothing
    elseif N==1
       print(io,string("( ",stringformer(x[1]),", )"))
       return nothing
    end
    
    ss = Vector{String}(N)
    for i in 1:N
      ss[i] = stringformer(x[i])
    end
    
    println(io,string("( ", ss[1], ","));
    for s in ss[2:end-1]
      println(io, string("  ", s, ","))
    end  
    println(io,string("  ", ss[end], " )"))
end

showmany{P,N}(x::NTuple{N,ArbFloat{P}}, stringformer::Function) = 
   showmany{P,N}(Base.STDOUT,x,stringformer)


function showmany{P}(io::IO, x::Vector{ArbFloat{P}}, stringformer::Function)
    n = length(x)

    if n==0
       print(io,"[]")
       return nothing
    elseif n==1
       print(io,string("[ ",stringformer(x[1])," ]"))
       return nothing
    end
    
    ss = Vector{String}(n)
    for i in 1:n
      ss[i] = stringformer(x[i])
    end
    
    println(io,string("[ ", ss[1], ","));
    for s in ss[2:end-1]
      println(io, string("  ", s, ","))
    end  
    println(io,string("  ", ss[end], " ]"))
end

showmany{P}(x::Vector{ArbFloat{P}}, stringformer::Function) = 
    showmany{P}(Base.STDOUT,x,stringformer)


show{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany(io, x, string)
showsmart{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany{P,N}(io, x, smartstring)
showall{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany{P,N}(io, x, stringAll)
showcompact{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany{P,N}(io, x, stringCompact)

show{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, string)
showsmart{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany{P}(io, x, smartstring)
showall{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, stringAll)
showcompact{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany{P}(io, x, stringCompact)


