{ stdenv
, fetchurl

, glib
}:

let
  version = "3.17";
in
stdenv.mkDerivation rec {
  name = "nbd-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/nbd/nbd/${version}/${name}.tar.xz";
    sha256 = "d95c6bb1a3ab33b953af99b73fb4833e123bd25433513b32d57dbeb1a0a0d189";
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
