{ stdenv, fetchurl, pkgconfig, perl, python, libffi, nspr, zlib, readline, icu }:

stdenv.mkDerivation rec {
  version = "38.2.1.rc0";
  name = "spidermonkey-${version}";

  src = fetchurl {
    url = "https://people.mozilla.org/~sstangl/mozjs-${version}.tar.bz2";
    sha256 = "0p4bmbpgkfsj54xschcny0a118jdrdgg0q29rwxigg3lh5slr681";
  };

  preConfigure = ''
    cd js/src
  '';

  nativeBuildInputs = [ pkgconfig perl python ];
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

  doCheck = false;

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
}
