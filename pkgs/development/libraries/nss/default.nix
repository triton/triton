{ stdenv, fetchurl, nspr, perl, zlib, sqlite
, includeTools ? false
}:

let

  nssPEM = fetchurl {
    url = http://dev.gentoo.org/~polynomial-c/mozilla/nss-3.15.4-pem-support-20140109.patch.xz;
    sha256 = "10ibz6y0hknac15zr6dw4gv9nb5r5z9ym6gq18j3xqx7v7n3vpdw";
  };

in stdenv.mkDerivation rec {
  name = "nss-${version}";
  version = "3.21";

  src = fetchurl {
    url = "http://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_${stdenv.lib.replaceStrings ["."] ["_"] version}_RTM/src/${name}.tar.gz";
    sha256 = "3f7a5b027d7cdd5c0e4ff7544da33fdc6f56c2f8c27fff02938fd4a6fbe87239";
  };

  buildInputs = [ nspr perl zlib sqlite ];

  prePatch = ''
    xz -d < ${nssPEM} | patch -p1
    cd nss
  '';

  patches = [
    ./add-pkgconfig.patch
    ./fix-sharedlib-loading.patch
  ];

  makeFlags = [
    "NSPR_INCLUDE_DIR=${nspr}/include/nspr"
    "NSPR_LIB_DIR=${nspr}/lib"
    "NSDISTMODE=copy"
    "BUILD_OPT=1"
    "NSS_ENABLE_WERROR=0"
    "SOURCE_PREFIX=\$(out)"
    "NSS_USE_SYSTEM_SQLITE=1"
  ] ++ stdenv.lib.optional stdenv.is64bit "USE_64=1";

  NIX_CFLAGS_COMPILE = "-Wno-error";

  postInstall = ''
    rm -rf $out/private
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
  '' + stdenv.lib.optionalString (!includeTools) ''
    find $out/bin -type f \( -name nss-config -o -delete \)
  '';

  meta = {
    homepage = https://developer.mozilla.org/en-US/docs/NSS;
    description = "A set of libraries for development of security-enabled client and server applications";
    platforms = stdenv.lib.platforms.all;
  };
}
