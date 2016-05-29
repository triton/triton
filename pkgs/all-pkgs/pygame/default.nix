{ stdenv
, buildPythonPackage
, fetchurl

, pkgs
, pythonPackages
}:

let
  inherit (pythonPackages)
    isPy3k;
in

buildPythonPackage rec {
  name = "pygame-1.9.1";

  src = fetchurl {
    url = "http://www.pygame.org/ftp/${name}release.tar.gz";
    sha256 = "0cyl0ww4fjlx289pjxa53q4klyn55ajvkgymw0qrdgp4593raq52";
  };

  buildInputs = [
    pkgs.SDL
    pkgs.SDL_image
    pkgs.SDL_mixer
    pkgs.SDL_ttf
    pkgs.libpng
    pkgs.libjpeg
    pkgs.smpeg
    pkgs.portmidi
    pkgs.xorg.libX11
  ];

  patches = [
    ./pygame-v4l.patch
  ];

  preConfigure = ''
    for i in \
      ${pkgs.SDL_image} \
      ${pkgs.SDL_mixer} \
      ${pkgs.SDL_ttf} \
      ${pkgs.libpng} \
      ${pkgs.libjpeg} \
      ${pkgs.portmidi} \
      ${pkgs.xorg.libX11}; do

      sed -i config_unix.py \
        -e "/origincdirs =/a'$i/include',"
      sed -i config_unix.py \
        -e "/origlibdirs =/aoriglibdirs += '$i/lib',"
    done

    LOCALBASE=/ python config.py
  '';

  disabled = isPy3k;

  meta = with stdenv.lib; {
    description = "Python library for games";
    homepage = "http://www.pygame.org/";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
