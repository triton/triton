{ stdenv
, cmake
, fetchurl
, ninja

, bluez
, fuse
, openobex
}:

stdenv.mkDerivation rec {
  name = "obexftp-0.24";

  src = fetchurl {
    url = "mirror://sourceforge/openobex/${name}-Source.tar.gz";
    sha256 = "0szy7p3y75bd5h4af0j5kf0fpzx2w560fpy4kg3603mz11b9c1xr";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    bluez
    fuse
    openobex
  ];

  preFixup = ''
    sed -i  $out/lib*/pkgconfig/obexftp.pc \
      -e '/Requires/ s,bluetooth,bluez,g'
  '';

  meta = with stdenv.lib; {
    description = "File transfer over OBEX for mobile phones";
    homepage = http://dev.zuckschwerdt.org/openobex/wiki/ObexFtp;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
