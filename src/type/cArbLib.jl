
type ArbValue <: Real

   significandExpo ::Int
   significandSize ::UInt
   significand1st  ::Int
   significand2nd  ::Int

   plusminus2Expon ::Int
   plusminusSignif ::UInt
   
   parentprecision ::Int
   
   ArbValue(significandExpo::Int, signifiandSize::UInt,
            significand1st::Int , significand2nd::Int,
            plusminus2Expon::Int, plusminusSignif::UInt, parentprecision::Int ) =
       new( significand.significandExpo, significand.signifiandSize,
            significand.significand1st , significand.significand2nd,
            plusminus.plusminus2Expon, plusminus.plusminusSignif, parentprecision )
end

parentprecision() = precision(ArbValue) # ::Int

ArbValue(significand:SignificandStruct, plusorminus::PlusOrMinusStruct, parentprecision::Int) =
   ArbValue( significand.significandExpo, significand.signifiandSize,
             significand.significand1st , significand.significand2nd,
             plusminus.plusminus2Expon, plusminus.plusminusSignif, parentprecision )

ArbValue(significand::SignificandStruc, plusorminus::PlusOrMinusStruct) =
   ArbValue( significand.significandExpo, significand.signifiandSize,
             significand.significand1st , significand.significand2nd,
             plusorminus.plusorminus2Expon, plusorminus.plusorminusSignif,
             parentprecision() )


