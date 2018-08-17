{ stdenv
, fetchurl
, gobject-introspection

, cryptsetup
, dmraid
, glib
, kmod
, libbytesize
, libyaml
, lvm2
, ndctl
, nspr
, nss
, parted
, python3
, systemd_lib
, util-linux_lib
, volume_key
}:

let
  version = "2.19";
in
stdenv.mkDerivation rec {
  name = "libblockdev-${version}";

  src = fetchurl {
    url = "https://github.com/storaged-project/libblockdev/releases/download/${version}-1/${name}.tar.gz";
    sha256 = "245dd1a93faced2e923c266e3ea3b79c4740f457ea21027a978957f9918758c0";
  };

  nativeBuildInputs = [
    gobject-introspection
  ];

  buildInputs = [
    cryptsetup
    dmraid
    glib
    kmod
    libbytesize
    libyaml
    lvm2
    ndctl
    nspr
    nss
    parted
    python3
    systemd_lib
    util-linux_lib
    volume_key
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-tests"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
