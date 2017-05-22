{ stdenv
, fetchurl

, glib
}:

let
  version = "3.15.3";
in
stdenv.mkDerivation rec {
  name = "nbd-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/nbd/nbd/${version}/${name}.tar.xz";
    sha256 = "6888cd01efbd8e2377634c83c29c8a096b485f90f1185854651ed6b50f1c0056";
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
