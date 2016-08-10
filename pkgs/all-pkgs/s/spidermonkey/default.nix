{ stdenv
, fetchurl
, perl
, python

, icu
, libffi
, nspr
, readline
, zlib

, channel ? "45"
}:

let
  inherit (stdenv.lib)
    optionals
    versionAtLeast;

  sources = {
    "17" = rec {
      version = "17.0.0";
      urls = [
        "https://ftp.mozilla.org/pub/js/mozjs${version}.tar.gz"
      ];
      sha256 = "1fig2wf4f10v43mqx67y68z6h77sy900d1w0pz9qarrqx57rc7ij";
    };
    "24" = rec {
      version = "24.2.0";
      urls = [
        "https://ftp.mozilla.org/pub/js/mozjs-${version}.tar.bz2"
      ];
      sha256 = "1n1phk8r3l8icqrrap4czplnylawa0ddc2cc4cgdz46x3lrkybz6";
    };
    "45" = rec {
      version = "45.0.2";
      urls = [
        "https://people.mozilla.org/~sfink/mozjs-${version}.tar.bz2"
      ];
      sha256 = "570530b1e551bf4a459d7cae875f33f99d5ef0c29ccc7742a1b6f588e5eadbee";
    };
  };

  inherit (sources."${channel}")
    sha256
    urls
    version;
in
stdenv.mkDerivation rec {
  name = "spidermonkey-${version}";

  src = fetchurl {
    inherit urls sha256;
  };

  nativeBuildInputs = [
    perl
    python
  ];

  buildInputs = [
    libffi
    nspr
    zlib
    readline
    icu
  ];

  prePatch = ''
    cd js/src
  '';

  postPatch = if versionAtLeast version "38.0.0" then ''
    chmod +x ../../python/mozbuild/mozbuild/milestone.py
    sed -i '1i#!${python}/bin/python' ../../python/mozbuild/mozbuild/milestone.py
  '' else ''
    # Fixes a version detection issue with perl 5.22.x
    sed -i 's/(defined\((@TEMPLATE_FILE)\))/\1/' config/milestone.pl
  '';

  configureFlags = [
    "--enable-release"
    "--enable-pie"
    "--with-pthreads"
    "--with-system-nspr"
    "--with-system-zlib"
    "--enable-system-ffi"
    "--disable-tests"
    "--enable-optimize"
    "--enable-jemalloc"
    "--enable-strip"
    "--enable-install-strip"
    "--enable-readline"
    "--with-system-icu"
  ] ++ optionals (versionAtLeast version "45.0.0") [
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

  parallelBuild = versionAtLeast version "45.0.0";
  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "Mozilla's JavaScript engine written in C/C++";
    homepage = https://developer.mozilla.org/en/SpiderMonkey;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
