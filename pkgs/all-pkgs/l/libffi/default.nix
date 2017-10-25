{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libffi-3.2.1";

  src = fetchurl {
    url = "ftp://sourceware.org/pub/libffi/${name}.tar.gz";
    sha256 = "0dya49bnhianl0r65m65xndz6ls2jn1xngyn72gd28ls3n7bnvnh";
  };

  configureFlags = [
    "--enable-pax_emutramp"
  ];

  # Install headers in the right place.
  postInstall = ''
    ln -sv "$out/lib/"libffi*/include $out/include
  '';

  disableStatic = false;

  meta = with stdenv.lib; {
    description = "A foreign function call interface library";
    homepage = http://sourceware.org/libffi/;
    # See http://github.com/atgreen/libffi/blob/master/LICENSE .
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
