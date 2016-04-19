## ArbFloats.jl
```               Arb available as an extended precision floating point context.          ```
```ruby
                                                         Jeffrey Sarnoff © 2016˗May˗26  New_York
```
#####This is for Julia v0.5
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
