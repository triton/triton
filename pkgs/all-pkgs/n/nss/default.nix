{ stdenv
, fetchTritonPatch
, fetchurl

, nspr
, perl
, sqlite
, zlib
}:

let
  version = "3.47.1";

  baseUrl = "https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases"
    + "/NSS_${stdenv.lib.replaceStrings ["."] ["_"] version}_RTM/src";
in
stdenv.mkDerivation rec {
  name = "nss-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "1ae3d1cb1de345b258788f2ef6b10a460068034c3fd64f42427a183d8342a6fb";
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

  makeFlags = [
    "SOURCE_PREFIX=${placeholder "dev"}"
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

  # Throws lots of errors as of 3.23 (checked 3.47.1)
  buildParallel = false;

  postInstall = ''
    rm -rv "$dev"/private
    rm -rv "$dev"/public/dbm
    mv -v "$dev"/public "$dev"/include
    mkdir -p "$dev"/lib
    mv -v "$dev"/*.OBJ/lib/* "$dev"/lib

    mkdir -p "$bin"/bin
    mv -v "$dev"/*.OBJ/bin/* "$bin"/bin

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    rm -rv "$dev"/*.OBJ
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

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
