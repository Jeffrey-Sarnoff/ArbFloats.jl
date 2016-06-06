# one parameter predicates

"""true iff midpoint(x) and radius(x) are zero"""
function iszero{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_zero), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff midpoint(x) or radius(x) are not zero"""
function ntzero{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_zero), Int, (Ptr{ArbFloat},), &x)
    z == 0
end

"""true iff zero is not within [upperbound(x), lowerbound(x)]"""
function nonzero{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_nonzero), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff midpoint(x) is one and radius(x) is zero"""
function isone{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_one), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff midpoint(x) is not one or midpoint(x) is one and radius(x) is nonzero"""
function ntone{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_one), Int, (Ptr{ArbFloat},), &x)
    z == 0
end

"""true iff radius is zero"""
function isexact{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_exact), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff radius is nonzero"""
function ntexact{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_exact), Int, (Ptr{ArbFloat},), &x)
    z == 0
end

"""true iff midpoint(x) is an integer and radius(x) is zero"""
function isinteger{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_int), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff midpoint(x) is not an integer or radius(x) is nonzero"""
function ntinteger{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_int), Int, (Ptr{ArbFloat},), &x)
    z == 0
end

"""true iff lowerbound(x) is positive"""
function ispositive{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_positive), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff upperbound(x) is negative"""
function isnegative{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_negative), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff upperbound(x) is zero or negative"""
function isnonpositive{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_nonpositive), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

"""true iff lowerbound(x) is zero or positive"""
function isnonnegative{P}(x::ArbFloat{P})
    z = ccall(@libarb(arb_is_nonnegative), Int, (Ptr{ArbFloat},), &x)
    z != 0
end

# two parameter predicates

"""true iff midpoint(x)==midpoint(y) and radius(x)==radius(y)"""
function areequal{P}(x::ArbFloat{P}, y::ArbFloat{P})
    z = ccall(@libarb(arb_equal), Int, (Ptr{ArbFloat}, Ptr{ArbFloat}), &x, &y)
    z != 0
end

"""true iff midpoint(x)!=midpoint(y) or radius(x)!=radius(y)"""
function arenotequal{P}(x::ArbFloat{P}, y::ArbFloat{P})
    z = ccall(@libarb(arb_equal), Int, (Ptr{ArbFloat}, Ptr{ArbFloat}), &x, &y)
    z == 0
end

"""true iff x and y have a common point"""
function overlap{P}(x::ArbFloat{P}, y::ArbFloat{P})
    z = ccall(@libarb(arb_overlaps), Int, (Ptr{ArbFloat}, Ptr{ArbFloat}), &x, &y)
    z != 0
end

"""true iff x and y have no common point"""
function donotoverlap{P}(x::ArbFloat{P}, y::ArbFloat{P})
    z = ccall(@libarb(arb_overlaps, Int, (Ptr{ArbFloat}, Ptr{ArbFloat}), &x, &y)
    z == 0
end

"""true iff x spans (covers) all of y"""
function contains{P}(x::ArbFloat{P}, y::ArbFloat{P})
    z = ccall(@libarb(arb_contains), Int, (Ptr{ArbFloat}, Ptr{ArbFloat}), &x, &y)
    z != 0
end

"""true iff x does not span (cover_ all of y"""
function doesnotcontain{P}(x::ArbFloat{P}, y::ArbFloat{P})
    z = ccall(@libarb(arb_contains), Int, (Ptr{ArbFloat}, Ptr{ArbFloat}), &x, &y)
    z == 0
end

