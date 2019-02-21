{ stdenv
, fetchurl
, lib
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

  postInstall = ''
    # Remove files which conflict with linux-firmware
    rm -rf $out/lib/firmware/{ct{efx,speq}.bin,ess,korg,sb16,yamaha}
    # Remove broken symlinks (broken upstream)
    rm -rf $out/lib/firmware/turtlebeach
    # Remove empty dir
    rm -rf $out/bin
  '';

  dontStrip = true;

  meta = with lib; {
    description = "Soundcard firmwares from the alsa project";
    homepage = http://www.alsa-project.org/main/index.php/Main_Page;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
