{ stdenv
, fetchTritonPatch
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    boolEn
    optionalAttrs
    optionalString;

  version = "1.4.18";
in
stdenv.mkDerivation (rec {
  name = "gnum4-${version}";

  src = fetchurl {
    url = "mirror://gnu/m4/m4-${version}.tar.bz2";
    hashOutput = false;
    sha256 = "6640d76b043bc658139c8903e293d5978309bf0f408107146505eca701e67cf6";
  };

  patches = [
    (fetchTritonPatch {
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "g/gnum4/glibc-2.28.patch";
      sha256 = "fc9b61654a3ba1a8d6cd78ce087e7c96366c290bc8d2c299f09828d793b853c8";
    })
  ];

  configureFlags = [
    "--${boolEn (type != "bootstrap")}-threads"
    "--${boolEn (type != "bootstrap")}-assert"
    "--${boolEn (type != "bootstrap")}-c++"
    "--enable-changeword"
    # We don't want to depend on the bootstraped shell
    "--with-syscmd-shell=/bin/sh"
  ];

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/m4/;
    description = "GNU M4, a macro processor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
} // optionalAttrs (type != "bootstrap") {
  allowedReferences = [
    "out"
    stdenv.cc.libc
    stdenv.cc.libidn2
    stdenv.cc.cc
  ];
})
