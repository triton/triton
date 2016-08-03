{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "alsa-firmware-1.0.29";

  src = fetchurl {
    url = "mirror://alsa/firmware/${name}.tar.bz2";
    sha256 = "0gfcyj5anckjn030wcxx5v2xk2s219nyf99s9m833275b5wz2piw";
  };

  preConfigure = ''
    configureFlagsArray+=("--with-hotplug-dir=$out/lib/firmware")
  '';

  dontStrip = true;

  postInstall = ''
    # These are lifted from the Arch PKGBUILD
    # remove files which conflicts with linux-firmware
    rm -rf $out/lib/firmware/{ct{efx,speq}.bin,ess,korg,sb16,yamaha}
    # remove broken symlinks (broken upstream)
    rm -rf $out/lib/firmware/turtlebeach
    # remove empty dir
    rm -rf $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = http://www.alsa-project.org/main/index.php/Main_Page;
    description = "Soundcard firmwares from the alsa project";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
