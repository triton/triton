{ stdenv
, fetchurl

, gtk3
, libdrm
, libpng
, pango
, systemd_full
}:

stdenv.mkDerivation rec {
  name = "plymouth-0.9.3";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/plymouth/releases/${name}.tar.xz";
    multihash = "QmVttu23B6GoS2AcEwr7RKTZZUp3KetFa2FG32iDQCXFEa";
    sha256 = "9f8dd08a90ceaf6228dcd8c27759adf18fc9482f15b6c56dcbcced268b4e4a74";
  };

  buildInputs = [
    gtk3
    libdrm
    libpng
    pango
    systemd_full
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-pango"
    "--enable-gtk"
    "--enable-drm-renderer"
    "--disable-documentation"
    "--disable-tracing"
    "--enable-gdm-transition"
    "--disable-upstart-monitoring"
    "--enable-systemd-integration"
    "--with-udev"
    "--without-system-root-install"
  ];

  preInstall = ''
    installFlagsArray+=(
      "PLYMOUTH_CONF_DIR=$out/etc"
      "SYSTEMD_UNIT_DIR=$out/lib/systemd/system"
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
