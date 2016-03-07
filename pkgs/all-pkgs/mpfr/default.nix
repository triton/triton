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
  version = "3.1.4";

  src = fetchurl {
    url = "mirror://gnu/mpfr/mpfr-${version}.tar.bz2";
    sha256 = "0xbpgwwwqqnnx9jilxygs690qknhpv21hdhzb3nhf95drn03l46k";
  };

  patches = flip mapAttrsToList patchSha256s (n: sha256: fetchurl {
    name = "mpfr-${version}-${n}";
    url = "http://www.mpfr.org/mpfr-${version}/${n}";
    inherit sha256;
  });

  buildInputs = [
    gmp
  ];

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
