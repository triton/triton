{ stdenv
, fetchurl

, gtk3
, libdrm
, libpng
, pango
, systemd_full
}:

stdenv.mkDerivation rec {
  name = "plymouth-0.9.2";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/plymouth/releases/${name}.tar.bz2";
    sha256 = "2f0ce82042cf9c7eadd2517a1f74c8a85fa8699781d9f294a06eade29fbed57f";
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
    "--enable-drm"
    "--disable-documentation"
    "--disable-tracing"
    "--enable-gdm-transition"
    "--disable-upstart-monitoring"
    "--enable-systemd-integration"
    "--without-system-root-install"
  ];

  #preBuild = ''
  #  cat Makefile
  #  exit 1
  #'';

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
