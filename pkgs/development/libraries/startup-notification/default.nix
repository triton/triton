{ stdenv, fetchurl, xorg }:

let
  version = "0.12";
in
stdenv.mkDerivation {
  name = "libstartup-notification-${version}";
  src = fetchurl {
    url = "http://www.freedesktop.org/software/startup-notification/releases/startup-notification-${version}.tar.gz";
    sha256 = "3c391f7e930c583095045cd2d10eb73a64f085c7fde9d260f2652c7cb3cfbe4a";
  };

  buildInputs = [ xorg.libX11 xorg.libxcb xorg.xcbutil ];

  meta = {
    homepage = http://www.freedesktop.org/software/startup-notification;
    description = "Application startup notification and feedback library";
    license = stdenv.lib.licenses.lgpl2;
  };
}
