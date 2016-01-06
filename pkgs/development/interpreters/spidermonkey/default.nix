{ stdenv, fetchurl, perl, python, libffi, nspr, zlib, readline, icu }:

with stdenv.lib;
let
  mkSpidermonkey = version: sha256: stdenv.mkDerivation rec {
    name = "spidermonkey-${version}";

    src = fetchurl {
      url = "https://people.mozilla.org/~sstangl/mozjs-${version}.tar.bz2";
      inherit sha256;
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

    nativeBuildInputs = [ perl python ];
    buildInputs = [ libffi nspr zlib readline icu ];

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

    enableParallelBuilding = true;

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
      platforms = platforms.linux;
    };
  };
in {
  spidermonkey_17 = mkSpidermonkey "17.0.0" "1fig2wf4f10v43mqx67y68z6h77sy900d1w0pz9qarrqx57rc7ij";
  spidermonkey_24 = mkSpidermonkey "24.2.0" "1n1phk8r3l8icqrrap4czplnylawa0ddc2cc4cgdz46x3lrkybz6";
  spidermonkey_38 = mkSpidermonkey "38.2.1.rc0" "0p4bmbpgkfsj54xschcny0a118jdrdgg0q29rwxigg3lh5slr681";
}
