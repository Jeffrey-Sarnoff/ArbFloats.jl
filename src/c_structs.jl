
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
    exp::fmpz                   #   exp # exponent
    man::mp_limb_t              #   man # mantissa
end
typealias mag_struct_ptr        Ref{mag_struct}

immutable mantissa_ptr_struct
    alloc::mp_size_t            # count of multiprecision limbs allocated
    d::mp_ptr                   #   when alloc <= 2, uses mantissa_noptr_struct
end
typealias mantissa_ptr_struct_ptr     Ref{mantissa_ptr_struct}

immutable mantissa_noptr_struct
    d0::mp_limb_t # UInt64[ARF_NOPTR_LIMBS] # d[2]
    d1::mp_limb_t
end
typealias mantissa_noptr_struct_ptr   Ref{mantissa_noptr_struct}

immutable mantissa_struct                    # in C, a Union type
  # mantissa_noprt_struct   noptr            # drop any smaller members
    mantissa_ptr_struct::   ptr              # specify one member, the largest
end
typealias mantissa_struct_ptr         Ref{mantissa_struct}

immutable arf_struct
    fmpz                    # exp
    mp_size_t               # size
    mantissa_struct         # d
end
typealias arf_struct_ptr              Ref{arf_struct}

immutable arb_struct
    arf_struct              # mid
    mag_struct              # rad
end    
typealias arb_struct_ptr              Ref{arb_struct}



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

