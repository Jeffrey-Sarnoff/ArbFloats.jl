## ArbFloats.jl
###### Arb available as an extended precision floating point context.

```ruby
                                                         Jeffrey Sarnoff © 2016˗May˗26  New_York
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
exactFloat = ArbFloatExact(0.125)
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
