{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, glib
, libcap-ng
, ncurses
, numactl
, systemd_lib
}:

let
  version = "1.5.0";
in
stdenv.mkDerivation {
  name = "irqbalance-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "irqbalance";
    repo = "irqbalance";
    rev = "v${version}";
    sha256 = "88b02e4ee1fe157187bd6324623e023daf63e23a125674c2804ba7d2f1852c4f";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    glib
    libcap-ng
    ncurses
    numactl
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-numa"
    "--with-irqbalance-ui"
    "--with-systemd"
    "--with-libcap-ng"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
