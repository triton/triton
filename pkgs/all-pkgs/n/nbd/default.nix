{ stdenv
, fetchurl

, glib
}:

let
  version = "3.15.2";
in
stdenv.mkDerivation rec {
  name = "nbd-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/nbd/nbd/${version}/${name}.tar.xz";
    sha256 = "cf188ebdad3d317742b874fb8669faa437ee9fab4005e71b049bc301011af344";
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
