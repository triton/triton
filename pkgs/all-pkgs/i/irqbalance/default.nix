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
  rev = "aae4eb617d8bd913047787b50dd727d5813a7729";
  date = "2017-08-29";
in
stdenv.mkDerivation {
  name = "irqbalance-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "irqbalance";
    repo = "irqbalance";
    inherit rev;
    sha256 = "cee2621865ac7e6bf1454836b44cd4373d9d6547f19c3c3e0ce66e34ca44d12b";
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
