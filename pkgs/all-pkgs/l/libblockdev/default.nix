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
  version = "2.21";
in
stdenv.mkDerivation rec {
  name = "libblockdev-${version}";

  src = fetchurl {
    url = "https://github.com/storaged-project/libblockdev/releases/download/${version}-1/${name}.tar.gz";
    sha256 = "317225f0d6cbc99d90481b0f8a30be8c325f5b5aebe82f9adf409214081de10a";
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
