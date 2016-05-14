immutable ArbFloat{Precision}  <: Real
  mid_exp::Int # fmpz
  mid_size::UInt # mp_size_t
  mid_d1::Int # mantissa_struct
  mid_d2::Int
  rad_exp::Int # fmpz
  rad_man::UInt
end

setprecision(ArbFloat,120)

function clearArbFloat(x::ArbFloat)
     ccall((:arb_clear, :libarb), Void, (Ptr(ArbFloat),), &x)
end

function ArbFloat()
    z = ArbFloat{precision(ArbFloat)}(0,0,0,0,0,0)
    ccall((:arb_init, :libarb), Void, (Ptr{ArbFloat},), &z)
    finalizer(z, clearArbFloat)
end

function ArbFloat(x::Int)
    z = ArbFloat{precision(ArbFloat)}(0,0,0,0,0,0)
    ccall((:arb_init, :libarb), Void, (Ptr{ArbFloat},), &z)
    ccall((:arb_set_si, :libarb), Void, (Ptr{ArbFloat}, Int), &z, &x)
    finalizer(z, clearArbFloat)
    z
end


