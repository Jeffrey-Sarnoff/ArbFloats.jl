#=

requires
https://github.com/fredrik-johansson/flint2
http://www.mpir.org/mpir-2.7.2.tar.bz2
or
https://gmplib.org/download/gmp/gmp-6.1.0.tar.lz
http://www.mpfr.org/mpfr-current/mpfr-3.1.4.tar.bz2

=#

isdir(Pkg.dir("Nemo")) || throw(ErrorException("Nemo not found")

libDir = Pkg.dir("Nemo/local/lib")
libFiles = readdir(libDir)

@linux_only begin
  libarb  = Pkg.dir("Nemo/local/lib/libarb.so")
  libflint = Pkg.dir("Nemo/local/lib/libflint.so")
  libgmp  = Pkg.dir("Nemo/local/lib/libgmp.so")
  libmpir = Pkg.dir("Nemo/local/lib/libmpir.so")
  libmpfr = Pkg.dir("Nemo/local/lib/libmpfr.so")
end

@osx_only begin
  libarb = Pkg.dir("Nemo/local/lib/libarb.dynlib")
  libflint = Pkg.dir("Nemo/local/lib/libflint.dynlib")
  libgmp  = Pkg.dir("Nemo/local/lib/libgmp.dynlib")
  libmpir = Pkg.dir("Nemo/local/lib/libmpir.dynlib")
  libmpfr = Pkg.dir("Nemo/local/lib/libmpfr.dynlib")
end

@windows_only begin
  libarb = Pkg.dir("Nemo/local/lib/libarb.dll")
  libflint = Pkg.dir("Nemo/local/lib/libflint.dll")
  libgmp  = Pkg.dir("Nemo/local/lib/libgmp.dll")
  libmpir = Pkg.dir("Nemo/local/lib/libmpir.dll")
  libmpfr = Pkg.dir("Nemo/local/lib/libmpfr.dll")
end

if isfile(libmpir) && !isfile(libgmp)
   libgmp = libmpir
end

isfile(libarb)   || throw(ErrorException("libarb not found"))
isfile(libflint) || throw(ErrorException("libflint not found"))
isfile(libgmp)   || throw(ErrorException("libgmp not found"))
isfile(libmpfr)  || throw(ErrorException("libmpfr not found"))
   
