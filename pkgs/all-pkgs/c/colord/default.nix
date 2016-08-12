{ stdenv
, fetchurl
, autoconf
, automake
, intltool

, argyllcms
, bash-completion
, dbus
, glib
, gobject-introspection
, libgusb
, lcms2
, libgudev
, libusb
, polkit
, sqlite
, systemd_lib
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "colord-1.3.2";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/colord/releases/${name}.tar.xz";
    sha1Url = "${url}.sha1";
    sha256 = "d4ab3f11ec5e98d1079242fda7ad0a84a51da93572405561362a6ce2c274b8f5";
  };

  nativeBuildInputs = [
    autoconf
    automake
    intltool
  ];

  buildInputs = [
    argyllcms
    bash-completion
    dbus
    glib
    gobject-introspection
    lcms2
    libgudev
    libgusb
    libusb
    polkit
    sqlite
    systemd_lib
    vala
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
      "--with-udevrulesdir=$out/lib/udev/rules.d"
    )
  '';

  configureFlags = [
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-nls"
    "--disable-strict"
    "--enable-rpath"
    (enFlag "libgusb" (libgusb != null) null)
    (enFlag "udev" (systemd_lib != null) null)
    "--disable-bash-completion"
    (enFlag "polkit" (polkit != null) null)
    "--enable-libcolordcompat"
    (enFlag "systemd-login" (systemd_lib != null) null)
    "--disable-examples"
    (enFlag "argyllcms-sensor" (argyllcms != null) null)
    "--disable-reverse"
    "--disable-sane"
    (enFlag "vala" (vala != null) null)
    "--disable-session-example"
    "--enable-print-profiles"
    "--disable-installed-tests"
    #"--with-daemon-user"
  ];

  postInstall = ''
    rm -rvf $out/var/lib/colord
    mkdir -p $out/etc/bash_completion.d
    cp -v ./data/colormgr $out/etc/bash_completion.d
  '';

  meta = with stdenv.lib; {
    description = "Accurately color manage input and output devices";
    homepage = http://www.freedesktop.org/software/colord/intro.html;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
