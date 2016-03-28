using Clang.wrap_c
       context = wrap_c.init(; output_file="libarb.jl",
                             header_library=x->"libarb",
                             header_wrapped=(x,y)->contains(y, "arb.h"),
                             common_file="libarb_h.jl", clang_diagnostics=true,
                             clang_args=["-v"], clang_includes=["/cmn/julia/usr/bin/", "/home/jas/Arb/arb-master"])
       context.options.wrap_structs = true
       wrap_c.wrap_c_headers(context, ["arb.h","arf.h",acb.h"]))
       
       
