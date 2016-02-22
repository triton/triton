{ stdenv
, fetchurl
, gmp
}:

let
  patchSha256s = import ./patches.nix;
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

  buildInputs = [ gmp ];

  configureFlags = [
    "--with-pic"
  ];

  doCheck = true;

  meta = {
    homepage = http://www.mpfr.org/;
    description = "Library for multiple-precision floating-point arithmetic";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
