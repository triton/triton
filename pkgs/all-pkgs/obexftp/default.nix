{ stdenv
, fetchurl
, cmake
, ninja
, openobex
, bluez
, fuse
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
    openobex
    bluez
    fuse
  ];

  preFixup = ''
    sed -i '/Requires/ s,bluetooth,bluez,g' $out/lib*/pkgconfig/obexftp.pc
  '';

  meta = {
    homepage = http://dev.zuckschwerdt.org/openobex/wiki/ObexFtp;
    description = "A library and tool to access files on OBEX-based devices (such as Bluetooth phones)";
    platforms = stdenv.lib.platforms.linux;
  };
}
