{ stdenv
, fetchTritonPatch
, fetchurl

, nspr
, perl
, sqlite
, zlib
}:

let
  version = "3.50";

  baseUrl = "https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases"
    + "/NSS_${stdenv.lib.replaceStrings ["."] ["_"] version}_RTM/src";
in
stdenv.mkDerivation rec {
  name = "nss-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "185df319775243f5f5daa9d49b7f9cc5f2b389435be3247c3376579bee063ba7";
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
      rev = "8dda9bf38ae60322770160feac0b9a69f2abb2f1";
      file = "n/nss/0001-Add-pem-support.patch";
      sha256 = "9b87348be9f86cd0817469e5d20ad63c766aa4f3805b2ea2a8b7ca340da656c0";
    })
    (fetchTritonPatch {
      rev = "8dda9bf38ae60322770160feac0b9a69f2abb2f1";
      file = "n/nss/0002-Fix-sharedlib-loading.patch";
      sha256 = "cb1ea195088039ac65c9fe8c49c4f4ed94b2b81f85ffa74f8190da9a3ba7408b";
    })
    (fetchTritonPatch {
      rev = "8dda9bf38ae60322770160feac0b9a69f2abb2f1";
      file = "n/nss/0003-Add-pkgconfig-files.patch";
      sha256 = "f545241ef7ca7c384d6a6a0693838d5dc0e73a8fff294fc6dbe4f41bdec4aed7";
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
    "NSS_USE_SYSTEM_ZLIB=1"
    "NSS_DISABLE_GTESTS=1"
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

    rm -r "$out"/lib/*.a
  '';

  postFixup = ''
    for libname in freebl3 nssdbm3 softokn3
    do
      libfile="$out/lib/lib$libname.so"
      LD_LIBRARY_PATH=$out/lib $out/bin/shlibsign -v -i "$libfile"
    done
  '';

  # Throws lots of errors as of 3.23
  buildParallel = false;

  passthru = {
    inherit version;

    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha256Url = "${baseUrl}/SHA256SUMS";
      };
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
