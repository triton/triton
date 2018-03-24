{ stdenv
, fetchurl
, intltool
, lib
, meson
, ninja
, vala

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
, systemd-dummy
, systemd_lib
}:

let
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "colord-1.4.2";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/colord/releases/${name}.tar.xz";
    multihash = "Qme1Y2w1Carc9UXwU7LiVibZmMDznUC9rP8CDrgeWfnVct";
    hashOutput = false;
    sha256 = "4c70d5052a9c96da51fa57e80d6dc97ca642943d5b9940a196c990dfe84beca7";
  };

  nativeBuildInputs = [
    intltool
    meson
    ninja
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
    systemd-dummy
  ];

  # preConfigure = ''
  #   configureFlagsArray+=(
  #     "--with-systemdsystemunitdir=$out/etc/systemd/system"
  #     "--with-udevrulesdir=$out/lib/udev/rules.d"
  #   )
  # '';

  postPatch = ''
    # Install systemd files to the current prefix
    sed -i contrib/session-helper/meson.build \
      -e "s|systemd.get_pkgconfig_variable.*|'$out/lib/systemd/user',|g"
    sed -i data/meson.build \
      -e "s|systemd.get_pkgconfig_variable('tmpfilesdir')|'$out/lib/tmpfiles.d'|" \
      -e "s|systemd.get_pkgconfig_variable('systemdsystemunitdir')|'$out/lib/systemd/system'|"
  '';

  mesonFlags = [
    "-Denable-bash-completion=false"
    "-Denable-libcolordcompat=true"
    "-Denable-vala=true"
    "-Denable-print-profiles=true"
    "-Denable-man=false"
    "-Denable-docs=false"
  ];

  setVapidirInstallFlag = false;

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls =  map (n: "${n}.sha256sum") urls;
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "163EB 50119 225DB 3DF8F  49EA1 7ACBA 8DFA9 70E17";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Accurately color manage input and output devices";
    homepage = http://www.freedesktop.org/software/colord/intro.html;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
