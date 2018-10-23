{ stdenv
, autoconf_21x
, fetchTritonPatch
, fetchurl
, lib
, perl
, python2

, icu
, libffi
, nspr
, readline
, zlib

, channel
, ctypes ? true
}:

# >=45.0.0 should use the releases in the murcurial repo at:
# https://hg.mozilla.org/mozilla-unified, see generateDistTarball below.

let
  inherit (lib)
    optionals
    optionalString
    replaceStrings
    versionAtLeast;

  sources = {
    "45" = {
      version = "45.9.0";
      sha256 = "2afb02029e115fae65dbe1d9c562cbfeb761a6807338bbd30dbffba616cb2d20";
    };
    "52" = {
      version = "52.9.0";
      sha256 = "c01d09658c53c1b3a496e353a24dad03b26b81d3b1d099abc26a06f81c199dd6";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "spidermonkey-${source.version}";

  src = fetchurl {
    url = "https://archive.mozilla.org/pub/firefox/releases/"
      + "${source.version}esr/source/"
      + "firefox-${source.version}esr.source.tar.xz";
    name = "spidermonkey-${source.version}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoconf_21x
    perl
    python2
  ];

  buildInputs = [
    icu
    readline
    zlib
  ] ++ optionals (ctypes) [
    libffi
    nspr
  ];

  # They assume the autoconf binary is named `autoconf-2.13` so detection fails.
  AUTOCONF = "${autoconf_21x}/bin/autoconf";

  # Fixes an issue with gcc7 c++ strictness
  CXXFLAGS = "-fpermissive";

  patches = optionals (channel == "52") [
    (fetchTritonPatch {
      rev = "b87ef54138a1e54298f50eb298b45475d0d0ba0e";
      file = "s/spidermonkey/52-fix-linking-mozglue.patch";
      sha256 = "5a84f02521f37de873991dd360a4c4bfdbdd2fb4a218e11be73f9cbbf02050e8";
    })
  ];

  # Make sure we don't get spurius regeneration warnings
  postPatch = optionalString (channel == "52") ''
    touch js/src/configure
  '';

  preConfigure = /* configure cannot be executed in the build directory */ ''
    mkdir -pv build/
    cd build/
    configureScript=../js/src/configure
  '';

  configureFlags = [
    "--disable-tests"
    "--disable-debug-symbols"
    "--enable-readline"
    "--with-intl-api"
    "--with-system-icu"
    "--with-system-zlib"
  ] ++ optionals (ctypes) [
    "--enable-ctypes"
    "--with-system-ffi"
    "--with-system-nspr"
  ];

  postFixup = ''
    # The headers are symlinks to a directory that doesn't get put
    # into $out, so they end up broken. Fix that by just resolving the
    # symlinks.
    for i in $(find $out -type l); do
      cp --remove-destination "$(readlink "$i")" "$i";
    done
  '';

  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHashAlgo
        outputHash;
      fullOpts = rec {
        sha512Url = "https://archive.mozilla.org/pub/firefox/releases/"
          + "${source.version}esr/SHA512SUMS";
        pgpsigSha512Url = "${sha512Url}.asc";
        pgpKeyFingerprint = "14F2 6682 D091 6CDD 81E3  7B6D 61B7 B526 D98F 0353";
      };
    };
  };

  meta = with lib; {
    description = "Mozilla's JavaScript engine written in C/C++";
    homepage = https://developer.mozilla.org/en/SpiderMonkey;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
