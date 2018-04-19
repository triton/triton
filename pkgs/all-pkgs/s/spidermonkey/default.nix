{ stdenv
, autoconf_21x
, fetchurl
, fetchzip
, lib
, perl
, python2
, which

, icu
, libffi
, nspr
, readline
, zlib

, channel
}:

# >=45.0.0 should use the releases in the murcurial repo at:
# https://hg.mozilla.org/mozilla-unified, see generateDistTarball below.

let
  inherit (lib)
    optionals
    replaceStrings
    versionAtLeast;

  sources = {
    "45" = {
      version = "45.9.0";
      sha256 = "2afb02029e115fae65dbe1d9c562cbfeb761a6807338bbd30dbffba616cb2d20";
    };
    "52" = {
      version = "52.7.3";
      sha256 = "5cc68c1a7486cfbbf02aec0e9da9f87b55e7bfc68c7d5139bc1e578441aaf19f";
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
    which
  ];

  buildInputs = [
    libffi
    nspr
    zlib
    readline
    icu
  ];

  postUnpack = ''
    srcRoot="$srcRoot/js/src/"
  '';

  # They assume the autoconf binary is named `autoconf-2.13` so detection fails.
  AUTOCONF = "${autoconf_21x}/bin/autoconf";

  # Fixes an issue with gcc7 c++ strictness
  CXXFLAGS = "-fpermissive";

  preConfigure = /* configure cannot be executed in the build directory */ ''
    mkdir -pv build/
    cd build/
    configureScript='../configure'
  '';

  configureFlags = [
    "--enable-release"
    "--enable-pie"
    "--disable-debug"
    "--enable-readline"
    "--with-pthreads"
    "--enable-shared-js"
    "--with-system-nspr"
    "--with-system-zlib"
    ###"--enable-system-ffi"
    "--disable-tests"
    "--enable-optimize"
    "--enable-jemalloc"
    "--enable-strip"
    "--enable-install-strip"
    "--enable-readline"
    "--with-system-icu"
  ] ++ optionals (versionAtLeast channel "45") [
    "--enable-gold"
  ];

  postFixup = ''
    # The headers are symlinks to a directory that doesn't get put
    # into $out, so they end up broken. Fix that by just resolving the
    # symlinks.
    for i in $(find $out -type l); do
      cp --remove-destination "$(readlink "$i")" "$i";
    done
  '';

  buildParallel = versionAtLeast channel "45";
  installParallel = false;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      sha512Url = "https://archive.mozilla.org/pub/firefox/releases/"
        + "${source.version}esr/SHA512SUMS";
      pgpsigSha512Url = "${sha512Url}.asc";
      pgpKeyFingerprint = "14F2 6682 D091 6CDD 81E3  7B6D 61B7 B526 D98F 0353";
      inherit (src) urls outputHashAlgo outputHash;
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
