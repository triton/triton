{ stdenv
, fetchurl

, nspr
, perl
, sqlite
, zlib
}:

let
  nssPEM = fetchurl {
    url = http://dev.gentoo.org/~polynomial-c/mozilla/nss-3.15.4-pem-support-20140109.patch.xz;
    sha256 = "10ibz6y0hknac15zr6dw4gv9nb5r5z9ym6gq18j3xqx7v7n3vpdw";
  };
in
stdenv.mkDerivation rec {
  name = "nss-${version}";
  version = "3.23";

  src = fetchurl {
    url = "http://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_${stdenv.lib.replaceStrings ["."] ["_"] version}_RTM/src/${name}.tar.gz";
    sha256 = "94b383e31c9671e9dfcca81084a8a813817e8f05a57f54533509b318d26e11cf";
  };

  buildInputs = [
    nspr
    perl
    sqlite
    zlib
  ];

  prePatch = ''
    xz -d < ${nssPEM} | patch -p1
    cd nss
  '';

  patches = [
    ./add-pkgconfig.patch
    ./fix-sharedlib-loading.patch
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
