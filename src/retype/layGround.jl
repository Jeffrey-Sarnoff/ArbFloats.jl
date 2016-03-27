

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
immutable Arb_field
  prec::Int32   # Int32 allows > 600,000,000 digits
end

type Arf_struct
  exp ::Int  # fmpz
  size::UInt # mp_size_t
  d1  ::Int  # mantissa_struct
  d2  ::Int
end

type Arb_struct
  mid_exp ::Int  # fmpz
  mid_size::UInt # mp_size_t
  mid_d1  ::Int  # mantissa_struct
  mid_d2  ::Int
  rad_exp ::Int  # fmpz
  rad_man ::UInt
end

type Arb_element # <: FieldElem
  mid_exp  ::Int # fmpz
  mid_size::UInt # mp_size_t
  mid_d1   ::Int # mantissa_struct
  mid_d2   ::Int
  rad_exp  ::Int # fmpz
  rad_man  ::UInt
  parent   ::Arb_field
end
