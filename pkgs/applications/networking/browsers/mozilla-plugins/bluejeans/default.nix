{ stdenv, fetchurl, xorg, gtk2, glib, gdk-pixbuf, dpkg
, libuuid, libpulseaudio
}:

with stdenv.lib;

let

  rpathInstaller = makeLibraryPath
    [gtk glib stdenv.cc.cc];

  rpathPlugin = makeLibraryPath
    ([ stdenv.cc.cc gtk2 glib xorg.libX11 gdk-pixbuf xorg.libXext
      xorg.libXfixes xorg.libXrender xorg.libXrandr xorg.libXcomposite libpulseaudio ] ++ optional (libuuid != null) libuuid);

in

stdenv.mkDerivation rec {
  name = "bluejeans-${version}";

  version = "2.125.24.5";

  src = fetchurl {
    url = "https://swdl.bluejeans.com/skinny/bjnplugin_${version}-1_amd64.deb";
    sha256 = "0lxxd7icfqcpg5rb4njkk4ybxmisv4c509yisznxspi49qfxirwq";
  };

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  unpackPhase = "${dpkg}/bin/dpkg-deb -x $src .";

  installPhase =
    ''
      mkdir -p $out
      cp -R usr/lib $out/

      plugins=$out/lib/mozilla/plugins
      patchelf \
        --set-rpath "${rpathPlugin}" \
        $plugins/npbjnplugin_${version}.so

      patchelf \
        --set-rpath "${rpathInstaller}" \
        $plugins/npbjninstallplugin_${version}.so
    '';

  dontStrip = true;
  dontPatchELF = true;

  passthru.mozillaPlugin = "/lib/mozilla/plugins";

  meta = {
    homepage = http://bluejeans.com;
    license = stdenv.lib.licenses.unfree;
    maintainers = with maintainers; [ ocharles kamilchm ];
    platforms = stdenv.lib.platforms.linux;
  };
}
