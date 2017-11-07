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
    boolEn;
in
stdenv.mkDerivation rec {
  name = "colord-1.3.5";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/colord/releases/${name}.tar.xz";
    multihash = "Qmb7gM6EEYoZ6p4zimVioFDdSrPQGZhfYGj5C8r9us68GF";
    hashOutput = false;
    sha256 = "2daa8ffd2a532d7094927cd1a4af595b8310cea66f7707edcf6ab743460feed2";
  };

  nativeBuildInputs = [
    autoconf
    automake
    intltool
    vala
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
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
      "--with-udevrulesdir=$out/lib/udev/rules.d"
    )
  '';

  configureFlags = [
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-nls"
    "--disable-strict"
    "--enable-rpath"
    "--${boolEn (libgusb != null)}-libgusb"
    "--${boolEn (systemd_lib != null)}-udev"
    "--disable-bash-completion"
    "--${boolEn (polkit != null)}-polkit"
    "--enable-libcolordcompat"
    "--${boolEn (systemd_lib != null)}-systemd-login"
    "--disable-examples"
    "--${boolEn (argyllcms != null)}-argyllcms-sensor"
    "--disable-reverse"
    "--disable-sane"
    "--${boolEn (vala != null)}-vala"
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

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha1Urls =  map (n: "${n}.sha1") urls;
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "163EB 50119 225DB 3DF8F  49EA1 7ACBA 8DFA9 70E17";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Accurately color manage input and output devices";
    homepage = http://www.freedesktop.org/software/colord/intro.html;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
