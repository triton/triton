{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, libjpeg
, libpng
, libx11
, portmidi
, sdl
, sdl-image
, sdl-mixer
, sdl-ttf
, smpeg
}:

let
  version = "1.9.3";
in
buildPythonPackage rec {
  name = "pygame-${version}";

  src = fetchPyPi {
    package = "Pygame";
    inherit version;
    sha256 = "0cyl0ww4fjlx289pjxa53q4klyn55ajvkgymw0qrdgp4593raq52";
  };

  buildInputs = [
    libjpeg
    libpng
    libx11
    portmidi
    sdl
    sdl-image
    sdl-mixer
    sdl-ttf
    smpeg
  ];

  patches = [
    ./pygame-v4l.patch
  ];

  preConfigure = ''
    for i in \
      ${sdl-image} \
      ${sdl-mixer} \
      ${sdp-ttf} \
      ${libpng} \
      ${libjpeg} \
      ${portmidi} \
      ${libx11}; do
      sed -i config_unix.py \
        -e "/origincdirs =/a'$i/include',"
      sed -i config_unix.py \
        -e "/origlibdirs =/aoriglibdirs += '$i/lib',"
    done

    LOCALBASE=/ python config.py
  '';

  disabled = isPy3;

  meta = with lib; {
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
