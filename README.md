## ArbFloats.jl
###### Arb available as an extended precision floating point context.

```ruby
                                                         Jeffrey Sarnoff © 2016˗May˗26 in New York City
```
#####This is for Julia v0.5
####About
Arb is software by Fredrik Johansson with contributions from others including William Hart, Tommy Hofmann, Sebastian Pancratz.  Dr. Johansson has permitted Julia to use Arb under the MIT License.  
  
An Arb value is an interval given by its midpoint and a radius of _inclusion_ about the midpoint.  
An ArbFloat is a floating point value that is represented internally as an Arb (interval) value.  

It is a useful fiction to think of ArbFloats as Arb values with a zero radius -- and sometimes they are.  
When an ArbFloat has a nonzero radius, the user sees only those digits that _don`t care_:  
the digits which remain after rounding the ArbFloat so that the radius is subsumed (as if 0.0).



####Use
```F#
Pkg.clone("https://github.com/Jeffrey-Sarnoff/ArbFloats.jl")  # to install, requires a recent Julia v0.5.0-dev

using ArbFloats

five = ArbFloat(5)
5

e = exp(ArbFloat(1))
2.7182_8182_8459_0452_3536_0287_4713_5266_2 ± 4.8148250e-35
fuzzed_e = tan(atanh(tanh(atan(e))))
2.7182_8182_8459_0452_3536_0287_4713_52662 ± 7.8836806e-33

bounds(e)
( 2.7182_8182_8459_0452_3536_0287_4713_52663,
  2.7182_8182_8459_0452_3536_0287_4713_52664 )
smartstring(e)
2.7182_8182_8459_0452_3536_0287_4713_5266₊

bounds(fuzzed_e)
( 2.7182_8182_8459_0452_3536_0287_4713_52654,
  2.7182_8182_8459_0452_3536_0287_4713_52670 )
smartstring(fuzzed_e)
2.7182_8182_8459_0452_3536_0287_4713_527₋


# Float32 and ArbFloat32
# typealias ArbFloat32 ArbFloat{24}  # predefined
setprecision(ArbFloat, 24)


fpOneThird = 1.0f0 / 3.0f0
0.3333_334f0

afOneThird = ArbFloat(1) / ArbFloat(3)
0.3333_333 ± 2.9803_322e-8
+
# gamma(1/3) is 2.6789_3853_4707_7476_3365_5692_9409_7467_7644~

afGammaOfOneThird = gamma( afOneThird )
2.6789_380  ± 1.8211887e-6

fpGammaOfOneThird = gamma( fpOneThird )
2.6789_384

lowerbound(afGammaOfOneThird), upperbound(afGammaOfOneThird)
2.6789_360, 2.6789_400




```
