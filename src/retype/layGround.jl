

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


type MagStruct                            #  mag_struct (arb/master/mag.h)
  rad_expn ::Int  #                       #  exponent    of 'radius' magnitude
  rad_sgnf ::UInt # 30? significand bits  #  significand of 'radius' magnitude
end

MagStruct() = MagStruct(sint0, sint0)


type SignificandStruct                   # mantissa_struct (arb/master/arf.h)
  d1  ::Int      #                   imm mantissa value high or mantissa alloc size
  d2  ::Int      #                   imm mantissa value low     ptr2 mantissa value
end

SignificandStruct() = SignificandStruct(sint0, sint0)
SignificandStruct(d1::Int) = SignificandStruct(d1, sint0)

type ArfStruct                           #  arf_struct (arb/master/arf.h) 
  expn ::Int     # MagStruct    
  mpsz::UInt     #                                  mp_size_t
  d1   ::Int     # SignificandStruct     # mantissa_struct
  d2   ::Int     #
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
                                         #    arf_struct
  expn     ::Int  # MagStruct            #       mag_struct
  mpsz     ::UInt #                      #          "
  d1       ::Int  # SignificandStruct    #       mantissa_struct
  d2       ::Int                         #               "  
  rad_expn ::Int  # fmpz?                #    mag_struct
  rad_sgnf ::UInt                        #       "
end

ArbStruct() = ArbStruct(sint0,uint0,sint0,sint0,sint0,uint0)

convert(::Type{SignificandStruct}, x::ArbStruct) = SignificandStruct(x.d1, x.d2)

convert(::Type{ArbStruct}, x::SignificandStruct, expn::Int, mpsz::UInt) =
    ArbStruct(expn, mpsz, x.d1, x.d2, sint0, uint0)
convert(::Type{ArbStruct}, expn::Int, mpsz::UInt, x::SignificandStruct) =
    convert(ArbStruct, x, expn, mpsz)
convert(::Type{ArbStruct}, mpsz::UInt, expn::Int, x::SignificandStruct) =
    convert(ArbStruct, x, expn, mpsz)
    

convert(::Type{ArfStruct}, x::ArbStruct) = ArfStruct(x.expn, x.mpsa, x.d1, x.d2)

convert(::Type{ArbStruct}, x::ArfStruct, rad_expn::Int, rad_sgnf::UInt) =
    ArbStruct(expn, mpsz, x.d1, x.d2, sint0, uint0)
convert(::Type{ArbStruct}, rad_expn::Int, rad_sgnf::UInt, x::ArfStruct) =
    convert(ArbStruct, x, rad_expn, rad_sgnf)
convert(::Type{ArbStruct}, rad_sgnf::UInt, rad_expn::Int, x::ArfStruct) =
    convert(ArbStruct, x, rad_expn, rad_sgnf)



type ArbValue # <: FieldElem
  expn      ::Int  # ArbStruct
  mpsz      ::UInt # 
  d1        ::Int  #       SignificandStruct
  d2        ::Int  #
  rad_expn  ::Int  # MagStruct
  rad_sgnf  ::UInt #
  parent    ::ArbPrecision
end

ArbValue() = ArbValue(sint0,uint0,sint0,sint0,sint0,uint0,FastArbPrecision)


convert(::Type{ArbStruct}, x::ArbValue) =
    ArbStruct(x.exp, x.mpsz, x.d1, x.d2, x.rad_expn, x.rad_sgnf)

convert(::Type{ArfStruct}, x::ArbValue) = convert(ArfStruct, convert(ArbStruct, x))
convert(::Type{ArbValue}, x::ArbStruct) =
    ArbValue( x.expn, x.mpsz, x.d1, x.d2, x.rad_expn, x.rad_sgnf, FastArbPrecision)
    
function convert(::Type{ArbValue}, x::ArbStruct, n::Int)
    arbprec = getkey(ArbPrecisions, n, (ArbPrecisions[n] = ArbPrecision(n))  )
    ArbValue( x.expn, x.mpsz, x.d1, x.d2, x.rad_expn, x.rad_sgnf, arbprec )
end



convert(::Type{SignificandStruct}, x::ArbValue) = convert(SignificandStruct, convert(ArfStruct, x))
convert(::Type{ArbValue}, x::SignificandStruct) = convert(ArbValue, convert(ArfStruct, x))

convert(::Type{MagStruct}, x::ArbStruct) = MagStruct(x.rad_expn, x.rad_sgnf)
convert(::Type{ArbStruct}, x::MagStruct) = ArbStruct(sint0,uint0,sint0,sint0, x.rad_expn, x.rad_sgnf)

convert(::Type{MagStruct}, x::ArbValue) = MagStruct(x.rad_expn, x.rad_sgnf)
convert(::Type{ArbValue}, x::MagStruct) = convert(ArbValue, convert(ArbStruct,x))



type ArfSpanStruct                       #  JAS 2016-03-27
  expn ::Int     # fmpz?
  mpsz::UInt     # mp_size_t
  d1   ::Int     # SignificandStruct     # mantissa_struct
  d2   ::Int     #
  d3   ::Int     #
  d4   ::Int     #
end

ArfSpanStruct() = ArfSpanStruct(zero(Int),zero(UInt),zero(Int),zero(Int),zero(Int),zero(Int))

type ArbSpan # <: FieldElem              #  JAS 2016-03-27
  expn      ::Int  # ArfSpanStruct 
  mpsz      ::UInt # 
  d1        ::Int  #                mantissa_struct
  d2        ::Int
  d3        ::Int
  d4        ::Int
  rad_expn  ::Int  # MagStruct
  rad_sgnf  ::UInt
  parent    ::ArbPrecision
end

ArbSpan() = ArbSpan(sint0,uint0,sint0,sint0,sint0,sint0,sint0,uint0,FastArbPrecision)



function convert(::Type{ArbSpan}, x::ArbValue)
    if x.mpsz < 3
        ArbSpan(x.expn,x.mpsz, x.d1,x.d2,sint0,sint0,x.rad_expn,x.rad_sgnf,x.parent)
    else
        NotImplemented("conversion of indirect memory into quad limbs of struct")
    end
end    

function convert(::Type{ArbValue}, x::ArbSpan)
    if x.mpsz < 3
        ArbValue(x.expn,x.mpsz, x.d1,x.d2,x.rad_expn,x.rad_sgnf,x.parent)
    else
        NotImplemented("conversion of indirect memory into quad limbs of struct")
    end
end    


convert(::Type{ArbValue} , x::ArbSpanStruct) = 
    ArbSpan(x.expn,x.mpsz, x.d1,x.d2,x.d3,x.d4,x.rad_expn,x.rad_sgnf, FastArbPrecision)


convert(::Type{ArbSpanStruct}, x::ArbSpan) =
    ArbSpanStruct(x.expn,x.mpsz, x.d1,x.d2,x.d3,x.d4,x.rad_expn,x.rad_sgnf)
convert(::Type{ArbSpan} , x::ArbSpanStruct) = 
    ArbSpan(x.expn,x.mpsz, x.d1,x.d2,x.d3,x.d4,x.rad_expn,x.rad_sgnf, FastArbPrecision)
convert(::Type{ArbSpanStruct}, x::ArbValue) =
    ArbSpanStruct(x.expn,x.mpsz, x.d1,x.d2,sint0,sint0,x.rad_expn,x.rad_sgnf)

convert(ArfStruct, convert(ArbSpanStruct, x))
convert(::Type{ArbValue}, x::ArbSpanStruct) =
    ArbValue( x.expn, x.mpsz, x.d1, x.d2, x.rad_expn, x.rad_sgnf, FastArbPrecision)
    
function convert(::Type{ArbValue}, x::ArbStruct, n::Int)
    arbprec = getkey(ArbPrecisions, n, (ArbPrecisions[n] = ArbPrecision(n))  )
    ArbValue( x.expn, x.mpsz, x.d1, x.d2, x.rad_expn, x.rad_sgnf, arbprec )
end
