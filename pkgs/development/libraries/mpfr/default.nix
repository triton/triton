{ stdenv, fetchurl, gmp }:

let
  patchSha256s = {
    "patch01" = "1hhpl0wg3gmv5m5kxc5r3n7vzvjnil4jx6rvk99gmfwylsjqx8lf";
    "patch02" = "19gvq283yspz7yajm4q2ys03hpxj0m5l8ahrkmccjzaqd07jwq53";
    "patch03" = "0p1y7mwbnshbj81hg5nfprzwh4aakxszf7n8bn4kh66jka4cw79c";
    "patch04" = "0vp2ywg8p0a2g8wai4fw29mbx1nq5yjzd361h2mr4cn6vac4a3sz";
    "patch05" = "1y0izl4y17xrdjidl2p1m1vapmgci5qv6shk0aqd187nvrs72jgw";
  };
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "mpfr-${version}-p${toString (length patches)}";
  version = "3.1.3";

  src = fetchurl {
    url = "mirror://gnu/mpfr/mpfr-${version}.tar.bz2";
    sha256 = "1z8akfw9wbmq91vrx04bw86mmnxw2sw5qm5cr8ix5b3w2mcv8fzn";
  };

  patches = flip mapAttrsToList patchSha256s (n: sha256: fetchurl {
    name = "mpfr-${version}-${n}";
    url = "http://www.mpfr.org/mpfr-${version}/${n}";
    inherit sha256;
  });

  # mpfr.h requires gmp.h
  propagatedBuildInputs = [ gmp ];

  configureFlags =
    optional stdenv.isSunOS "--disable-thread-safe" ++
    optional stdenv.is64bit "--with-pic";

  doCheck = true;

  enableParallelBuilding = true;

  meta = {
    homepage = http://www.mpfr.org/;
    description = "Library for multiple-precision floating-point arithmetic";

    longDescription = ''
      The GNU MPFR library is a C library for multiple-precision
      floating-point computations with correct rounding.  MPFR is
      based on the GMP multiple-precision library.

      The main goal of MPFR is to provide a library for
      multiple-precision floating-point computation which is both
      efficient and has a well-defined semantics.  It copies the good
      ideas from the ANSI/IEEE-754 standard for double-precision
      floating-point arithmetic (53-bit mantissa).
    '';

    license = licenses.lgpl2Plus;

    maintainers = [ ];
    platforms = platforms.all;
  };
}
