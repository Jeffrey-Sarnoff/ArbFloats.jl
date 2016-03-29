
# ArbValue := (midpoint, halfwdith)
# lobound.halfwidth.midpoint.halfwidth.hibound
#    fp      span      fp        spn     fp

type ArbValue <: Real
   # midpoint of interval value
   significandPow2 ::Int
   significandSize ::UInt
   significandHead ::Int
   significandTail ::Int
   # halfwidth of interval value, symmetric about the midpoint 
   halfwidthPow2   ::Int
   halfwidthSignif ::UInt
   
   parentprecision ::Int
   
   ArbValue(significandPow2::Int, signifiandSize::UInt,
            significandHead::Int, significandTail::Int,
            halfwidthPow2::Int, halfwidthSignif::UInt, parentprecision::Int ) =
       new( significandPow2, significandSize,
            significandHead, significandTail,
            halfwidthPow2, halfwidthSignif, parentprecision )
end

precision(x::ArbValue) = x.parentprecision # ::Int

ArbValue(significand:SignificandStruct, plusorminus::PlusOrMinusStruct, parentprecision::Int) =
   ArbValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHead, significand.significandTail,
             halfwidthPow2, halfwidthSignif, parentprecision )

ArbValue(significand::SignificandStruc, plusorminus::PlusOrMinusStruct) =
   ArbValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHead, significand.significandTail,
             halfwidthPow2, halfwidthSignif, precision()  )

#
#   ArfValue (an ArbValue without trailing precision field)
#

type ArfValue <: Real
   # midpoint of interval value
   significandPow2 ::Int
   significandSize ::UInt
   significandHead ::Int
   significandTail ::Int
   # halfwidth of interval value, symmetric about the midpoint 
   halfwidthPow2   ::Int
   halfwidthSignif ::UInt

   ArfValue(significandPow2::Int, signifiandSize::UInt,
            significandHead::Int , significandTail::Int,
            halfwidthPow2::Int, halfwidthSignif::UInt   ) =
       new( significandPow2, significandSize,
            significandHead, significandTail,
            halfwidthPow2 halfwidthSignif     )
end

ArfValue(significand::SignificandStruc, halfwidth::HalfwidthStruct) =
   ArfValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHead, significand.significandTail,
             halfwidth.halfwidthPow2, halfwidth.halfwidthSignif )

convert(::Type{ArfValue}, x::ArbValue) = 
    ArfValue( x.significandPow2, x.significandSize,
              x.significandHead, x.significandTail,
              x.halfwidthPow2, x.halfwidthSignif )

convert(::Type{ArbValue}, x::ArfValue) = 
    ArbValue( x.significandPow2, x.significandSize,
              x.significandHead, x.significandTail,
              x.halfwidthPow2, x.halfwidthSignif  ,
              parentprecision() )

promote_rule(::Type{ArbValue}, ::Type{ArfValue}) = ArbValue


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
