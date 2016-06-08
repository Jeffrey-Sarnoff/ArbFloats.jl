## ArbFloats.jl
###### Arb available as an extended precision floating point context.

```ruby
                                                         Jeffrey Sarnoff © 2016˗May˗26 in New York City
```
#####This is for Julia v0.5
####About
Arb is software by Fredrik Johansson with contributions from others including William Hart, Tommy Hofmann, Sebastian Pancratz `get other names`.
Dr. Johansson has allowed Julia to use Arb under the MIT License.  
  
An Arb value is an interval given by its midpoint and a radius of _inclusion_ about the midpoint.  
An ArbFloat is a floating point value that is represented internally as an Arb (interval) value.  

It is a useful fiction to think of ArbFloats as Arb values with a zero radius -- and sometimes they are.  
When an ArbFloat has a nonzero radius, the user sees only those digits that _don`t care_:  
the digits which remain after rounding the ArbFloat so that the radius is subsumed (as if 0.0).



####Use
```julia
using ArbFloats

five = ArbFloat(5)
5

e = exp(ArbFloat(1))
2.7182_8182_8459_0452_3536_0287_4713_5266_2 ± 4.8148250e-35

lowerbound(e)
2.7182_8182_8459_0452_3536_0287_4713_5266_2
upperbound(e)
2.7182_8182_8459_0452_3536_0287_4713_5266_3

smartbound(e)
2.7182_8182_8459_0452_3536_0287_4713_5266₊


fuzzed_e = tan(atanh(tanh(atan(e))))
2.7182_8182_8459_0452_3536_0287_4713_52662 ± 7.8836806e-33

round(Int, Float64(radius(fuzzed_e)/radius(e)))
162

`setprecision(ArbFloat, 53)`

exactFloat = ArbExact(0.125)
0.125
approxFloat = ArbFloat(0.125)
0.125±0.1388e-17
showall(approxFloat)
0.125±0.138877788f-17
midpoint(approxFloat)
0.125
radius(approxFloat)
0.138877788f-17
```
