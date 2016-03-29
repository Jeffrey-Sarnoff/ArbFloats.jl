
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


