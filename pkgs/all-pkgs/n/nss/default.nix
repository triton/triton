{ stdenv
, fetchTritonPatch
, fetchurl

, nspr
, perl
, sqlite
, zlib
}:

let
  version = "3.26";

  baseUrl = "https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases"
    + "/NSS_${stdenv.lib.replaceStrings ["."] ["_"] version}_RTM/src";
in
stdenv.mkDerivation rec {
  name = "nss-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    sha256Url = "${baseUrl}/SHA256SUMS";
    sha256 = "91783a570ab953693eb977ce47c501f04c104cec287fa011c91bcc8970d1c564";
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
      rev = "c19fd3176ad33fc5e0b6c283c31bb07bf189c44a";
      file = "nss/pem-support.patch";
      sha256 = "12d887d26d437e3cb6d257f6dbf002bb1ea5941554ab8cd650845f9e8688f4ea";
    })
    (fetchTritonPatch {
      rev = "c19fd3176ad33fc5e0b6c283c31bb07bf189c44a";
      file = "nss/fix-sharedlib-loading.patch";
      sha256 = "8e18d51b76b1f0e9d074c73dce323976956ffc0fab38c8ae36a77bf95a220380";
    })
    (fetchTritonPatch {
      rev = "c19fd3176ad33fc5e0b6c283c31bb07bf189c44a";
      file = "nss/add-pkgconfig.patch";
      sha256 = "a42cfde4a40b11028527bc8c960327685b231c14dd6e2e1539804ba8b3d4dd5a";
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
