

# Julia standard number types grouped by relative size

typealias HugeNumbers    Union{BigFloat,BigInt}
typealias LargeNumbers   Union{Int128,UInt128}
typealias LargerNumbers  Union{Float64,Int64,UInt64}
typealias MediumNumbers  Union{Float32,Int32,UInt32}
typealias SmallNumbers   Union{Float16,Int16,UInt16,Int8,UInt8}

typealias SmallerNumbers Union{Float32,Int32,UInt32,Float16,Int16,UInt16,Int8,UInt8}



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
  rad_exp ::Int  #                       #  exponent    of 'radius' magnitude
  rad_man ::UInt # 30? significand bits  #  significand of 'radius' magnitude
end

MagStruct() = MagStruct(zero(Int), zero(UInt))

type SignificandStruc     t              # mantissa_struct (arb/master/arf.h)
  d1  ::Int      # mantissa_struct   imm mantissa value high or mantissa alloc size
  d2  ::Int      #                   imm mantissa value low     ptr2 mantissa value
end

SignificandStruct() = SignificandStruct(zero(Int), zero(Int))
SignificandStruct(d1::Int) = SignificandStruct(d1, zero(Int))

type ArfStruct                           #  arf_struct (arb/master/arf.h) 
  exp ::Int      # fmpz?
  size::UInt     # mp_size_t
  d1  ::Int      # mantissa_struct
  d2  ::Int      #
end

ArfStruct() = ArfStruct(zero(Int),zero(UInt),zero(Int),zero(Int))


type ArbStruct                           #  arf_struct (arb/master/arf.h)
  mid_exp ::Int  # fmpz                  #
  mid_size::UInt # mp_size_t             #
  mid_d1  ::Int  # mantissa_struct       #   
  mid_d2  ::Int                          #
  rad_exp ::Int  # fmpz                  #  mag_struct (arb/master/mag.h)
  rad_man ::UInt                         #  mag_struct
end

ArbStruct() = ArbStruct(zero(Int),zero(UInt),zero(Int),zero(Int),zero(Int),zero(UInt))


type ArbValue # <: FieldElem
  mid_exp  ::Int # fmpz
  mid_size::UInt # mp_size_t
  mid_d1   ::Int # mantissa_struct
  mid_d2   ::Int
  rad_exp  ::Int # fmpz
  rad_man  ::UInt
  parent   ::ArbPrecision
end

ArbValue() = ArbValue(zero(Int),zero(UInt),zero(Int),zero(Int),zero(Int),zero(UInt),FastArbPrecision)

