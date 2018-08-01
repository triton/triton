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
  version = "2.18";
in
stdenv.mkDerivation rec {
  name = "libblockdev-${version}";

  src = fetchurl {
    url = "https://github.com/storaged-project/libblockdev/releases/download/${version}-1/${name}.tar.gz";
    sha256 = "705d82a5a146c71a1f1159d4579648662f7e4414297eb5a2b3e7199d72bb73a8";
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
