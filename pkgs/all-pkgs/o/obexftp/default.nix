{ stdenv
, cmake
, fetchurl
, ninja

, bluez
, expat
, fuse_2
, openobex
}:

stdenv.mkDerivation rec {
  name = "obexftp-0.24.2";

  src = fetchurl {
    url = "mirror://sourceforge/openobex/${name}-Source.tar.gz";
    sha256 = "d40fb48e0a0eea997b3e582774b29f793919a625d54b87182e31a3f3d1c989a3";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    bluez
    expat
    fuse_2
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
