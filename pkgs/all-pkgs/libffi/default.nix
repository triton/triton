{ stdenv
, fetchurl

, doCheck ? false, dejagnu
}:

stdenv.mkDerivation rec {
  name = "libffi-3.2.1";

  src = fetchurl {
    url = "ftp://sourceware.org/pub/libffi/${name}.tar.gz";
    sha256 = "0dya49bnhianl0r65m65xndz6ls2jn1xngyn72gd28ls3n7bnvnh";
  };

  buildInputs = stdenv.lib.optional doCheck dejagnu;

  configureFlags = [
    "--with-gcc-arch=${stdenv.cc.cc.march}"
    "--enable-pax_emutramp"
  ];

  inherit doCheck;

  # Install headers in the right place.
  postInstall = ''
    ln -sv "$out/lib/"libffi*/include $out/include
  '';

  meta = with stdenv.lib; {
    description = "A foreign function call interface library";
    homepage = http://sourceware.org/libffi/;
    # See http://github.com/atgreen/libffi/blob/master/LICENSE .
    license = licenses.free;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
