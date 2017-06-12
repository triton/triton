{ stdenv
, fetchTritonPatch
, fetchurl

, nspr
, perl
, sqlite
, zlib
}:

let
  version = "3.31";

  baseUrl = "https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases"
    + "/NSS_${stdenv.lib.replaceStrings ["."] ["_"] version}_RTM/src";
in
stdenv.mkDerivation rec {
  name = "nss-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "e90561256a3271486162c1fbe8d614d118c333d36a4455be2af8688bd420a65d";
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
      rev = "e71938b3ed2c0c7e904c57444b656e3db19bfe73";
      file = "n/nss/0001-Add-pem-support.patch";
      sha256 = "aa7c5a1a22474868d6781897b988f9e23d7958ae49c225bd7da65a3bf63fe9d1";
    })
    (fetchTritonPatch {
      rev = "e71938b3ed2c0c7e904c57444b656e3db19bfe73";
      file = "n/nss/0002-Fix-sharedlib-loading.patch";
      sha256 = "bb719d9acf4e3d984fc8885251daa7148e995a2691a040fb5c45f5dc05fc4ae0";
    })
    (fetchTritonPatch {
      rev = "e71938b3ed2c0c7e904c57444b656e3db19bfe73";
      file = "n/nss/0003-Add-pkgconfig-files.patch";
      sha256 = "f02ea2bdf7011a896c2e19bb64ea91bc8674642dc267325cba6e69b23190cbd4";
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

    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "${baseUrl}/SHA256SUMS";
      inherit (src) urls outputHash outputHashAlgo;
    };
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
