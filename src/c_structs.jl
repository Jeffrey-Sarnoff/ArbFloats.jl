
const ARF_NOPTR_LIMBS = 2

typealias fmpz                  Int64        # Clonglong

# multiprecision typealiases, most are used in Arb's c interface
typealias mp_size_t             Int32        # a limb count, always nonnegative
typealias mp_exp_t              Int32        # gmp type
typealias mp_limb_t             UInt64       # a single limb (Culonglong)
typealias mp_limb_signed_t      Int64        # (Clonglong)
typealias mp_ptr                Ref{UInt64}  # pointer to mp_limb_t 
typealias mp_srcptr             Ref{UInt64}  # pointer to const mp_limb_t

typealias mp_noptr              NTuple{2,UInt64}

immutable fmpr_struct
    man::fmpz                   #   man # mantissa
    exp::fmpz                   #   exp # exponent
end
typealias fmpr_struct_ptr       Ref{fmpr_struct}

immutable mag_struct
    expo::fmpz                   #   exp # exponent
    mant::mp_limb_t              #   man # mantissa
end
typealias mag_struct_ptr        Ref{mag_struct}

expo(x::mag_struct) = x.expo ; exp(x::mag_struct) = x.expo
mant(x::mag_struct) = x.mant ; man(x::mag_struct) = x.mant

expo(x::mag_struct, e::fmpz) = mag_struct(e, x.mant)
mant(x::mag_struct, m::mp_limb_t) = mag_struct(x.expo, m)
(x::mag_struct)(e::fmpz) = mag_struct(e, x.mant)
(x::mag_struct)(m::mp_limb_t) = mag_struct(x.expo, m)


immutable mantissa_ptr_struct
    alloc::mp_size_t            # count of multiprecision limbs allocated
    d::mp_ptr                   #   when alloc <= 2, uses mantissa_noptr_struct
end
typealias mantissa_ptr_struct_ptr     Ref{mantissa_ptr_struct}

alloc(x::mantissa_ptr_struct) = x.alloc
d(x::mantissa_ptr_struct) = x.d

immutable mantissa_noptr_struct
    d0::mp_limb_t # UInt64[ARF_NOPTR_LIMBS] # d[2]
    d1::mp_limb_t
end
typealias mantissa_noptr_struct_ptr   Ref{mantissa_noptr_struct}

d0(x::mantissa_noptr_struct) = x.d0
d1(x::mantissa_noptr_struct) = x.d1

immutable mantissa_struct                    # in C, a Union type
  # noptr::mantissa_noprt_struct             # drop any smaller members
    ptr::mantissa_ptr_struct                 # specify one member, the largest
end
typealias mantissa_struct_ptr         Ref{mantissa_struct}

ptr(x::mantissa_struct) = x.ptr
noptr(x::mantissa_struct) = x.noptr
alloc(x::mantissa_struct) = x.ptr.alloc
d(x::mantissa_struct) = x.ptr.d
d0(x::mantissa_struct) = x.noptr.d0
d1(x::mantissa_struct) = x.noptr.d1


immutable arf_struct
    expo::fmpz                # exp
    size::mp_size_t           # size
    mant::mantissa_struct     # d
end
typealias arf_struct_ptr              Ref{arf_struct}

expo(x::arf_struct) = x.expo ; exp(x::arf_struct) = x.expo
size(x::arf_struct) = x.size
mant(x::arf_struct) = x.mant ; d(x::arf_struct) = x.mant

expo(x::arf_struct, e::fmpz) = arf_struct(e, x.size, x.mant)
size(x::arf_struct, s::mp_size_t) = arf_struct(x.expo, s, x.mant)
mant(x::arf_struct, m::mantissa_struct) = arf_struct(x.expo, x.size, m)


immutable arb_struct
    mid::arf_struct          # mid
    rad::mag_struct          # rad
end    
typealias arb_struct_ptr              Ref{arb_struct}

mid(x::arb_struct) = x.mid
rad(x::arb_struct) = x.rad
midexpo(x::arb_struct) = x.mid.expo ; exp(x::arb_struct) = x.mid.expo 
midsize(x::arb_struct) = x.mid.size
midmant(x::arb_struct) = x.mid.mant ; d(x::arb_struct) = x.mid.mant
radexpo(x::arb_struct) = x.rad.expo
radmant(x::arb_struct) = x.rad.mant

mid(x::arb_struct, m::arf_struct) = arb_struct(m, x.rad)
rad(x::arb_struct, r::mag_struct) = arb_struct(x.mid, r)

#=

   // arb.h
   typedef struct
   { 
        arf_struct              mid; 
        mag_struct              rad;
   } 
   arb_struct;
   
   
   // arf.h
   typedef struct
   {
        fmpz                    exp;
        mp_size_t               size;
        mantissa_struct         d;
   } 
   arf_struct;

   // arf.h
   typedef union                        /* UNION */
   {
        mantissa_noprt_struct   noptr;
        mantissa_ptr_struct     ptr;
   } 
   mantissa_struct;
   
   // arf.h
   typedef struct
   {
        mp_size_t               alloc;
        mp_ptr                  d;
   } 
   mantissa_ptr_struct;
   
   // arf.h
   typedef struct
   {
        mp_limb_t               d[ARF_NOPTR_LIMBS]
   } 
   mantissa_noptr_struct;
   
   // mag.h
   typedef struct
   {
        fmpz                    exp;
        mp_limb_t               man;
   } 
   mag_struct;

   // fmpr.h
   typedef struct
   {
        fmpz                    man;
        fmpz                    exp;
   }
   fmpr_struct;

   
   typedef   signed long        fmpz;
   typedef unsigned long        mp_limb_t;
   typedef   signed long        mp_limb_signed_t;
  
  
   typedef mp_limb_t *          mp_ptr;
   typedef const mp_limb_t *	  mp_srcptr;
   typedef long int             mp_size_t;
   typedef long int             mp_exp_t;
   
   #define BITS_PER_MP_LIMB (__SIZEOF_LONG__ * __CHAR_BIT__)
   #define BYTES_PER_MP_LIMB (BITS_PER_MP_LIMB / __CHAR_BIT__)

   #define ARF_NOPTR_LIMBS 2   
   
=#

