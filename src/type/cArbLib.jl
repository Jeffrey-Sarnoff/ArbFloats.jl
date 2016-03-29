
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
            significandHead::Int , significandTail::Int,
            halfwidthPow2::Int, halfwidthSignif::UInt, parentprecision::Int ) =
       new( significandPow2, significandSize,
            significandHead, significandTail,
            halfwidthPow2 halfwidthSignif, parentprecision )
end

parentprecision() = precision(ArbValue) # ::Int

ArbValue(significand:SignificandStruct, plusorminus::PlusOrMinusStruct, parentprecision::Int) =
   ArbValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHead, significand.significandTail,
             halfwidthPow2, halfwidthSignif, parentprecision )

ArbValue(significand::SignificandStruc, plusorminus::PlusOrMinusStruct) =
   ArbValue( significand.significandPow2, significand.signifiandSize,
             significand.significandHead, significand.significandTail,
             halfwidthPow2, halfwidthSignif, parentprecision,
             parentprecision() )

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


function Cdouble(a::arf, rnd::Cint = 4)
  z = ccall((:arf_get_d, :libarb), Cdouble, (Ptr{arf}, Cint), a.data, rnd)
  return z
end

function BigFloat(x::arf)
  old_prec = get_bigfloat_precision()
  set_bigfloat_precision(parent(x).prec)
  z = BigFloat(0)
  r = ccall((:arf_get_mpfr, :libarb), Cint,
                (Ptr{BigFloat}, Ptr{arf}, Cint), &z, &x, Cint(0))
  set_bigfloat_precision(old_prec)
  return z
end
