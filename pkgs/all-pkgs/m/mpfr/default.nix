{ stdenv
, fetchurl
, gmp
}:

let
  patchSha256s = import ./patches.nix;

  tarballUrls = version: [
    "mirror://gnu/mpfr/mpfr-${version}.tar.xz"
  ];

  version = "4.0.0";

  inherit (stdenv.lib)
    flip
    length
    mapAttrsToList;
in
stdenv.mkDerivation rec {
  name = "mpfr-${version}-p${toString (length patches)}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "fbe2cd1418b321f5c899ce4f0f0f4e73f5ecc7d02145b0e1fd096f5c3afb8a1d";
  };

  patches = flip mapAttrsToList patchSha256s (n: { multihash, sha256 }: fetchurl {
    name = "mpfr-${version}-${n}";
    url = "http://www.mpfr.org/mpfr-${version}/${n}";
    inherit multihash sha256;
  });

  buildInputs = [
    gmp
  ];

  configureFlags = [
    "--with-pic"
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.0.0";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "07F3 DBBE CC1A 3960 5078  094D 980C 1976 98C3 739D";
      inherit (src) outputHashAlgo;
      outputHash = "fbe2cd1418b321f5c899ce4f0f0f4e73f5ecc7d02145b0e1fd096f5c3afb8a1d";
    };
  };

  meta = with stdenv.lib; {
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
