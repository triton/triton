{ stdenv
, cc
, fetchurl
, gnum4

, cxx ? false
}:

let
  inherit (stdenv.lib)
    boolEn
    optionals
    optionalString;

  version = "6.2.0";

  tarballUrls = version: [
    "mirror://gnu/gmp/gmp-${version}.tar.xz"
    "ftp://ftp.gmplib.org/pub/gmp-${version}/gmp-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gmp${optionalString (!cxx) "-nocxx"}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "258e6cd51b3fbdfc185c716d55f82c08aff57df0c6fbd143cf6ed561267a1526";
  };

  nativeBuildInputs = [
    cc
    gnum4
  ];

  configureFlags = [
    "--with-pic"
    "--enable-fat"
    "--${boolEn cxx}-cxx"
  ];

  # Only provides some info files
  postInstall = ''
    rm -r "$dev"/share

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "6.2.0";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "343C 2FF0 FBEE 5EC2 EDBE  F399 F359 9FF8 28C6 7298";
      inherit (src) outputHashAlgo;
      outputHash = "258e6cd51b3fbdfc185c716d55f82c08aff57df0c6fbd143cf6ed561267a1526";
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://gmplib.org/";
    description = "GNU multiple precision arithmetic library";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
