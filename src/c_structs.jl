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
   
=#


typealias fmpz                  Int64       # Clonglong
typealias mp_limb_t             UInt64      # Culonglong
typealias mp_limb_signed_t      Int64       # Clonglong



immutable fmpr_struct
    fmpz                        man # mantissa
    fmpz                        exp # exponent
end

immutable mag_struct
    fmpz                        exp # exponent
    mp_limb_t                   man # mantissa
end


immutable mantissa_ptr_struct
    mp_size_t                   alloc
    mp_ptr                      d
end

immutable mantissa_noptr_struct
    mp_limb_t                   alloc
    mp_ptr                      d[ARF_NOPTR_LIMBS]
end




