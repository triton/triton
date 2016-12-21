{ stdenv
, fetchurl

, glib
}:

let
  version = "3.15.1";
in
stdenv.mkDerivation rec {
  name = "nbd-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/nbd/nbd/${version}/${name}.tar.xz";
    sha256 = "ac1108dfdaffe1cf01f5f0f34c738771184bf6ff4a503edefaf10a961f8b8745";
  };

  buildInputs = [
    glib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-syslog"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
