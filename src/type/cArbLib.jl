
type ArbValue{Prec} <: Real
   significandExpo   ::Int
   significandSize   ::UInt
   significand1st    ::Int64
   significand2nd    ::Int64

   plusorminus2Expon ::Int
   plusorminusSignif ::UInt
   
   ArbValue(significand:SignificandStruct, plusorminus::PlusOrMinusStruct, precision::Int) =
       new{precision}( significand.significandExpo, significand.signifiandSize,
                       significand.significand1st , significand.significand2nd,
                       plusorminus.plusorminus2Expon, plusorminus.plusorminusSignif )
end

ArbValue(significand::SignificandStruc, plusorminus::PlusOrMinusStruct, precision::Int) =
    ArbValue{precision}(significand.significandExpo, significand.signifiandSize,
                       significand.significand1st , significand.significand2nd,
                       plusorminus.plusorminus2Expon, plusorminus.plusorminusSignif )

ArbValue(significand::SignificandStruc, plusorminus::PlusOrMinusStruct, bitsOfPrecision::Integer) =
   ArbValue( significand, plusorminus, max(10, min(bitsOfPrecison, 30_000)) )


