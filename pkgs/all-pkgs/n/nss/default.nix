{ stdenv
, fetchTritonPatch
, fetchurl

, nspr
, perl
, sqlite
, zlib
}:

let
  version = "3.27.2";

  baseUrl = "https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases"
    + "/NSS_${stdenv.lib.replaceStrings ["."] ["_"] version}_RTM/src";
in
stdenv.mkDerivation rec {
  name = "nss-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    sha256Url = "${baseUrl}/SHA256SUMS";
    sha256 = "dc8ac8524469d0230274fd13a53fdcd74efe4aa67205dde1a4a92be87dc28524";
  };

  buildInputs = [
    nspr
    perl
    sqlite
    zlib
  ];

  prePatch = ''
    cd nss
  '';

  patches = [
    (fetchTritonPatch {
      rev = "95043ea498ca0e8d0c5b7d2101263c5131814428";
      file = "n/nss/0001-Add-pem-support.patch";
      sha256 = "a2c64c308eef8885e731cdb5cca5e00ab00fcde5e12c0b234e2e125fa9ed162c";
    })
    (fetchTritonPatch {
      rev = "95043ea498ca0e8d0c5b7d2101263c5131814428";
      file = "n/nss/0002-Fix-sharedlib-loading.patch";
      sha256 = "a7e9547fc47736997e129f997af77582335d1d7b59f8fae11ab4caa153740257";
    })
    (fetchTritonPatch {
      rev = "95043ea498ca0e8d0c5b7d2101263c5131814428";
      file = "n/nss/0003-Add-pkgconfig-files.patch";
      sha256 = "0f8aea9c9a50561e3e704259883984a55d9eaade34a1fd589abb143ed9a20e72";
    })
  ];

  preBuild = ''
    makeFlagsArray+=("SOURCE_PREFIX=$out")
  '';

  makeFlags = [
    "NSPR_INCLUDE_DIR=${nspr}/include/nspr"
    "NSPR_LIB_DIR=${nspr}/lib"
    "NSDISTMODE=copy"
    "BUILD_OPT=1"
    "NSS_ENABLE_WERROR=0"
    "NSS_USE_SYSTEM_SQLITE=1"
  ] ++ stdenv.lib.optionals (stdenv.lib.elem stdenv.targetSystem stdenv.lib.platforms.bit64) [
    "USE_64=1"
  ];

  postInstall = ''
    rm -r $out/private
    mv $out/public $out/include
    mkdir -p $out/{bin,lib}
    mv $out/*.OBJ/bin/* $out/bin
    mv $out/*.OBJ/lib/* $out/lib
    rm -r $out/*.OBJ
  '';

  postFixup = ''
    for libname in freebl3 nssdbm3 softokn3
    do
      libfile="$out/lib/lib$libname.so"
      LD_LIBRARY_PATH=$out/lib $out/bin/shlibsign -v -i "$libfile"
    done
  '';

  # Throws lots of errors as of 3.23
  parallelBuild = false;

  passthru = {
    inherit version;
  };

  meta = with stdenv.lib; {
    homepage = https://developer.mozilla.org/en-US/docs/NSS;
    description = "A set of libraries for development of security-enabled client and server applications";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
