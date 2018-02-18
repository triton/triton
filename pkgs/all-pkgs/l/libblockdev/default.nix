{ stdenv
, fetchurl
, gobject-introspection
, python2

, cryptsetup
, dmraid
, glib
, kmod
, libbytesize
, lvm2
, nss
, nspr
, parted
, systemd_lib
, util-linux_lib
, volume_key
}:

let
  version = "2.16";
in
stdenv.mkDerivation rec {
  name = "libblockdev-${version}";

  src = fetchurl {
    url = "https://github.com/storaged-project/libblockdev/releases/download/${version}-1/${name}.tar.gz";
    sha256 = "d841ae446cf6dc545e4f7386e13dfd8c3e07c4b6a962536b7c0fcd20e3a4d9e4";
  };

  nativeBuildInputs = [
    gobject-introspection
    python2
  ];

  buildInputs = [
    cryptsetup
    dmraid
    glib
    kmod
    libbytesize
    lvm2
    nss
    nspr
    parted
    systemd_lib
    util-linux_lib
    volume_key
  ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${volume_key}/include/volume_key"
  
    patchShebangs scripts/boilerplate_generator.py
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-tests"
    "--without-python3"
    "--without-gtk-doc"
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
