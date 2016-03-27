

# Julia standard number types grouped by relative size

typealias HugeNumbers    Union{BigFloat,BigInt}
typealias LargeNumbers   Union{Int128,UInt128}
typealias LargerNumbers  Union{Float64,Int64,UInt64}
typealias MediumNumbers  Union{Float32,Int32,UInt32}
typealias SmallNumbers   Union{Float16,Int16,UInt16,Int8,UInt8}

typealias SmallerNumbers Union{Float32,Int32,UInt32,Float16,Int16,UInt16,Int8,UInt8}

const uint0  = zero(UInt)
const sint0  = zero(Int)
const float0 = zero(Float64)


# arf_struct, arb_struct
# from https://github.com/wbhart/Nemo.jl/blob/master/src/arb/ArbTypes.jl
#      "these may be used for shallow operations"

immutable ArbPrecision  # precision is the number of bits in the significand
  precision::Int        # Int32 allows > 600,000,000 digits, Arb does not use more than 16,000

  ArbPrecision(x::Integer) = new( convert(Int,x) )
end
precision(x::ArbPrecision) = x.precision

ArbPrecisions = Dict(   
    53   => ArbPrecision(  53),   60 => ArbPrecision(  60),  
    72   => ArbPrecision(  72),   75 => ArbPrecision(  75),
    120  => ArbPrecision( 120),  240 => ArbPrecision( 240), 
    250  => ArbPrecision( 250),  504 => ArbPrecision( 504), 
    1000 => ArbPrecision(1000), 3584 => ArbPrecision(3584),
)

# does not require indirect memory allocations
const FastArbPrecison = ArbPrecision( fld(480, (12-sizeof(Int))) )   


type MagStruct                           #  mag_struct (arb/master/mag.h)
  rad_xpn ::Int  #                       #  exponent    of 'radius' magnitude
  rad_sgf ::UInt # 30? significand bits  #  significand of 'radius' magnitude
end

MagStruct() = MagStruct(sint0, sint0)

type SignificandStruct                   # mantissa_struct (arb/master/arf.h)
  d1  ::Int      #                   imm mantissa value high or mantissa alloc size
  d2  ::Int      #                   imm mantissa value low     ptr2 mantissa value
end

SignificandStruct() = SignificandStruct(sint0, sint0)
SignificandStruct(d1::Int) = SignificandStruct(d1, sint0)

type ArfStruct                           #  arf_struct (arb/master/arf.h) 
  xpn ::Int      # fmpz?
  mpsz::UInt     # mp_size_t
  d1  ::Int      # SignificandStruct     # mantissa_struct
  d2  ::Int      #
end

ArfStruct() = ArfStruct(zero(Int),zero(UInt),zero(Int),zero(Int))

convert(::Type{SignificandStruct}, x::ArfStruct) = SignificandStruct(x.d1, x.d2)

convert(::Type{ArfStruct}, x::SignificandStruct, xp::Int, mpsz::UInt) = 
    ArfStruct(xp, mpsz, x.d1, x.d2)
convert(::Type{ArfStruct}, xp::Int, mpsz::UInt, x::SignificandStruct) = 
    convert(ArfStruct, x, xp, mpsz)
convert(::Type{ArfStruct}, mpsz::UInt, xp::Int, x::SignificandStruct) = 
    convert(ArfStruct, x, xp, mpsz)


type ArbStruct                           #  arb_struct (arb/master/arb.h)
  mid_xpn ::Int  # fmpz                  #    arf_struct
  mid_mpsz::UInt # mp_size_t             #
  mid_d1  ::Int  # SignificandStruct     #       mantissa_strct
  mid_d2  ::Int                          #
  rad_xpn ::Int  # fmpz?                 #       mag_struct
  rad_sgf ::UInt                         #   
end

ArbStruct() = ArbStruct(sint0,uint0,sint0,sint0,sint0,uint0)

convert(::Type{SignificandStruct}, x::ArbStruct) = SignificandStruct(x.d1, x.d2)

convert(::Type{ArbStruct}, x::SignificandStruct, mid_xpn::Int, mid_mpsz::UInt) =
    ArbStruct(mid_xpn, mid_mpsz, x.d1, x.d2, sint0, uint0)
convert(::Type{ArbStruct}, mid_xpn::Int, mid_mpsz::UInt, x::SignificandStruct) =
    convert(ArbStruct, x, mid_xpn, mid_mpsz)
convert(::Type{ArbStruct}, mid_mpsz::UInt, mid_xpn::Int, x::SignificandStruct) =
    convert(ArbStruct, x, mid_xpn, mid_mpsz)
    

convert(::Type{ArfStruct}, x::ArbStruct) = ArfStruct(x.mid_xpn, x.mid_mpsa, x.mid_d1, x.mid_d2)

convert(::Type{ArbStruct}, x::ArfStruct, rad_xpn::Int, rad_sgf::UInt) =
    ArbStruct(mid_xpn, mid_mpsz, x.d1, x.d2, sint0, uint0)
convert(::Type{ArbStruct}, rad_xpn::Int, rad_sgf::UInt, x::ArfStruct) =
    convert(ArbStruct, x, rad_xpn, rad_sgf)
convert(::Type{ArbStruct}, rad_sgf::UInt, rad_xpn::Int, x::ArfStruct) =
    convert(ArbStruct, x, rad_xpn, rad_sgf)



type ArbValue # <: FieldElem
  mid_xpn  ::Int # fmpz
  mid_mpsz ::UInt # mp_size_t
  mid_d1   ::Int # mantissa_struct
  mid_d2   ::Int
  rad_xpn  ::Int # fmpz?
  rad_sgf  ::UInt
  parent   ::ArbPrecision
end

ArbValue() = ArbValue(sint0,uint0,sint0,sint0,sint0,uint0,FastArbPrecision)

convert(::Type{ArbStruct}, x::ArbValue) =
    ArbStruct(x.mid_exp, x.mid_size, x.mid_d1, x.mid_d2, x.rad_exp, x.rad_man)

convert(::Type{ArbValue}, x::ArbStruct) =
    ArbValue( x.mid_xpn, x.mid_mpsz, x.mid_d1, x.mid_d2, x.rad_xpn, x.rad_sgf, FastArbPrecision)
    
function convert(::Type{ArbValue}, x::ArbStruct, n::Int)
    arbprec = getkey(ArbPrecisions, n, (ArbPrecisions[n] = ArbPrecision(n))  )
    ArbValue( x.mid_xpn, x.mid_mpsz, x.mid_d1, x.mid_d2, x.rad_xpn, x.rad_sgf, arbprec )
end
