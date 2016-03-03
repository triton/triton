{ stdenv, fetchurl
, libjpeg
, alsa-lib ? null
, libX11 ? null
, qt4 ? null # The default is set to qt4 in all-packages.nix
, qt5 ? null
}:

# See libv4l in all-packages.nix for the libs only (overrides alsa, libX11 & QT)

assert qt4 != null -> qt5 == null;
assert qt5 != null -> qt4 == null;

let
  inherit (stdenv.lib) optional;
in

stdenv.mkDerivation rec {
  name = "v4l-utils-1.8.1";

  src = fetchurl {
    url = "http://linuxtv.org/downloads/v4l-utils/${name}.tar.bz2";
    sha256 = "0cqv8drw0z0kfmz4f50a8kzbrz6vbj6j6q78030hgshr7yq1jqig";
  };

  configureFlags = [
    "--enable-libv4l"
  ] ++ (if (alsa-lib != null && libX11 != null && (qt4 != null || qt5 != null)) then [
    "--with-udevdir=\${out}/lib/udev"
    "--enable-v4l-utils"
    "--enable-qv4l2"
  ] else [
    "--without-libudev"
    "--without-udevdir"
    "--disable-v4l-utils"
    "--disable-qv4l2"
  ]);

  postInstall = ''
    # Create symlink for V4l1 compatibility
    ln -s $out/include/libv4l1-videodev.h $out/include/videodev.h
    mkdir -p $out/include/linux
    ln -s $out/include/libv4l1-videodev.h $out/include/linux/videodev.h
  '';

  buildInputs = [ alsa-lib libX11 qt4 qt5 libjpeg ];

  # Sometimes fails
  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "V4L utils and libv4l, provide common image formats regardless of the v4l device";
    homepage = http://linuxtv.org/projects.php;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ codyopel viric ];
    platforms = platforms.linux;
  };
}
