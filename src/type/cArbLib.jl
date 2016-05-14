


type HalfwidthStruct <: Real
   # halfwidth of interval value, symmetric about the midpoint 
   halfwidthPow2   ::Int
   halfwidthSignif ::UInt

   HalfwidthStruct(significandPow2::Int, significandSignif::UInt) =
       new( significandPow2, significandSignif )
end


type MagStruct <: Real
   # like Float40 with much wider expoinent
   halfwidthPow2   ::Int
   halfwidthSignif ::UInt         # mp_limb_t

   HalfwidthStruct(significandPow2::Int, significandSignif::UInt) =
       new( significandPow2, significandSignif )
end


type SignificandStruct <: Real
   # midpoint of interval value
   significandPow2 ::Int
   significandSize ::UInt
   significandHead ::Int
   significandTail ::Int
   # halfwidth of interval value, symmetric about the midpoint 
   halfwidthPow2   ::Int
   halfwidthSignif ::UInt

   SignificandStruct(significandPow2::Int, signifiandSize::UInt,
            significandHead::Int, significandTail::Int,
            halfwidthPow2::Int, halfwidthSignif::UInt ) =
       new( significandPow2, significandSize,
            significandHead, significandTail,
            halfwidthPow2, halfwidthSignif )
end



#
#   ArfValue (an ArbValue without trailing precision field)
#

type ArfValue <: Real
   # midpoint of interval value
   significandPow2 ::Int
   significandSize ::UInt
   significandHigh ::Int
   significandLow  ::Int
   # halfwidth of interval value, symmetric about the midpoint 
   halfwidthPow2   ::Int
   halfwidthSignif ::UInt

   ArfValue(significandPow2::Int, signifiandSize::UInt,
            significandHigh::Int , significandLow::Int,
            halfwidthPow2::Int, halfwidthSignif::UInt   ) =
       new( significandPow2, significandSize,
            significandHigh, significandLow,
            halfwidthPow2, halfwidthSignif     )
end

ArfValue(significand::SignificandStruct, halfwidth::HalfwidthStruct) =
   ArfValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHigh, significand.significandLow,
             halfwidth.halfwidthPow2, halfwidth.halfwidthSignif )

convert(::Type{ArfValue}, x::ArbValue) = 
    ArfValue( x.significandPow2, x.significandSize,
              x.significandHead, x.significandTail,
              x.halfwidthPow2, x.halfwidthSignif )

convert(::Type{ArbValue}, x::ArfValue) = 
    ArbValue( x.significandPow2, x.significandSize,
              x.significandHigh, x.significandLow,
              x.halfwidthPow2, x.halfwidthSignif  ,
              parentprecision() )

promote_rule(::Type{ArbValue}, ::Type{ArfValue}) = ArbValue



# ArbValue := (midpoint, halfwdith)
# lobound.halfwidth.midpoint.halfwidth.hibound
#    fp      span      fp        spn     fp

type ArbValue <: Real
   # midpoint of interval value
   significandPow2 ::Int
   significandSize ::UInt
   significandHigh ::Int
   significandLow  ::Int
   # halfwidth of interval value, symmetric about the midpoint 
   halfwidthPow2   ::Int
   halfwidthSignif ::UInt
   
   parentprecision ::Int
   
   ArbValue(significandPow2::Int, signifiandSize::UInt,
            significandHigh::Int, significandLow::Int,
            halfwidthPow2::Int, halfwidthSignif::UInt, parentprecision::Int ) =
       new( significandPow2, significandSize,
            significandHigh, significandLow,
            halfwidthPow2, halfwidthSignif, parentprecision )
end

parent(x::ArbValue) = x.parent # ::Int
precision(x::ArbValue) = x.parentprecison # ::Int

ArbValue(significand::SignificandStruct, halfwidth::HalfwidtStruct, parentprecision::Int) =
   ArbValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHigh, significand.significandLow,
             halfwidthPow2, halfwidthSignif, parentprecision )

ArbValue(significand::SignificandStruct, halfwidth::HalfwidthStruct) =
   ArbValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHigh, significand.significandLow,
             halfwidthPow2, halfwidthSignif, precision()  )

function erase(x::ArbValue)
  ccall((:arb_clear, :libarb), Void, (Ptr{ArbValue}, ), &x)
end

function deepcopy(a::ArbValue)
  b = typeof(a)()
  ccall((:arb_set, :libarb), Void, (Ptr{ArbValue}, Ptr{ArbValue}), &b, &a)
  return b
end



function Cdouble(a::ArfValue, roundingMode::Cint = 4)
  z = ccall((:arf_get_d, :libarb), Cdouble, (Ptr{arf}, Cint), a.data, roundingMode)
  return z
end

function BigFloat(x::ArfValue)
  old_prec = precision()
  setprecision(precision(x))
  z = BigFloat(0)
  r = ccall((:arf_get_mpfr, :libarb), Cint,
                (Ptr{BigFloat}, Ptr{arf}, Cint), &z, &x, Cint(0))
  setprecision(old_prec)
  return z
end
