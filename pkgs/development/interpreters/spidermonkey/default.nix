{ stdenv
, fetchurl
, perl
, python

, icu
, libffi
, nspr
, readline
, zlib
}:

let
  inherit (stdenv.lib)
    versionAtLeast;

  mkSpidermonkey = { version, urls, sha256 }: stdenv.mkDerivation rec {
    name = "spidermonkey-${version}";

    src = fetchurl {
      inherit urls sha256;
    };

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

    configureFlags = [
      "--enable-release"
      "--enable-pie"
      "--with-system-nspr"
      "--with-system-zlib"
      "--enable-system-ffi"
      "--disable-tests"
      "--enable-optimize"
      "--enable-jemalloc"
      "--enable-strip"
      "--enable-readline"
      "--with-system-icu"
    ];

    postFixup = ''
      # The headers are symlinks to a directory that doesn't get put
      # into $out, so they end up broken. Fix that by just resolving the
      # symlinks.
      for i in $(find $out -type l); do
        cp --remove-destination "$(readlink "$i")" "$i";
      done
    '';

    meta = with stdenv.lib; {
      description = "Mozilla's JavaScript engine written in C/C++";
      homepage = https://developer.mozilla.org/en/SpiderMonkey;
      maintainers = with maintainers; [
        wkennington
      ];
      platforms = with platforms;
        x86_64-linux;
    };
  };
in {
  spidermonkey_17 = mkSpidermonkey {
    version = "17.0.0";
    urls = [
      "http://ftp.mozilla.org/pub/js/mozjs17.0.0.tar.gz"
    ];
    sha256 = "1fig2wf4f10v43mqx67y68z6h77sy900d1w0pz9qarrqx57rc7ij";
  };

  spidermonkey_24 = mkSpidermonkey {
    version = "24.2.0";
    urls = [
      "http://ftp.mozilla.org/pub/js/mozjs-24.2.0.tar.bz2"
    ];
    sha256 = "1n1phk8r3l8icqrrap4czplnylawa0ddc2cc4cgdz46x3lrkybz6";
  };
}
