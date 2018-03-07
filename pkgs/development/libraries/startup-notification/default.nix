{ stdenv
, fetchurl

, libx11
, libxcb
, xorg
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "startup-notification-0.12";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/startup-notification/releases/${name}.tar.gz";
    sha256 = "3c391f7e930c583095045cd2d10eb73a64f085c7fde9d260f2652c7cb3cfbe4a";
  };

  buildInputs = [
    libx11
    libxcb
    xorg.xcbutil
    xorgproto
  ];

  meta = with stdenv.lib; {
    homepage = http://www.freedesktop.org/software/startup-notification;
    description = "Application startup notification and feedback library";
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
