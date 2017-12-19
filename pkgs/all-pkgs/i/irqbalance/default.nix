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
  version = "1.3.0";
in
stdenv.mkDerivation {
  name = "irqbalance-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "irqbalance";
    repo = "irqbalance";
    rev = "v${version}";
    sha256 = "d39fc52aa5ba498b6b280f0b6c4dbb18ac741de50cff2a238a2da207dd3c72d2";
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
