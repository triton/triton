{ stdenv
, fetchurl
, intltool
, lib
, meson
, ninja
, vala

, argyllcms
, bash-completion
, glib
, gobject-introspection
, libgusb
, lcms2
, libgudev
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
  name = "colord-1.4.3";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/colord/releases/${name}.tar.xz";
    multihash = "QmY9zG5iSirN9LfHFapxbvHY6RWXomXBRUmieLDFgDppRT";
    hashOutput = false;
    sha256 = "9a8e669ee1ea31632bee636cc57353f703c2ea9b64cd6e02bbaabe9a1e549df7";
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
    glib
    gobject-introspection
    lcms2
    libgudev
    libgusb
    polkit
    sqlite
    systemd_lib
    systemd-dummy
  ];

  postPatch = ''
    # Install systemd files to the current prefix
    sed -i contrib/session-helper/meson.build \
      -e "s|systemd.get_pkgconfig_variable.*|'$out/lib/systemd/user',|g"
    sed -i data/meson.build \
      -e "s|systemd.get_pkgconfig_variable('tmpfilesdir')|'$out/lib/tmpfiles.d'|" \
      -e "s|systemd.get_pkgconfig_variable('systemdsystemunitdir')|'$out/lib/systemd/system'|" \
      -e "s|bash_completion.get_pkgconfig_variable('completionsdir')|'$out/share/bash-completion/completions'|"
  '';

  mesonFlags = [
    "-Dsession_example=false"
    "-Dlibcolordcompat=true"
    "-Dvapi=true"
    "-Dtests=false"
    "-Ddaemon_user=colord"
    "-Dman=false"
    "-Ddocs=false"
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
