{ stdenv
, autoconf
, automake
, fetchFromGitHub
, intltool
, lib
, wrapPython

, dbus-python
, libnotify
, mutagen
, pygobject
, python-mpd2
}:

let
  date = "2019-05-03";
in
stdenv.mkDerivation rec {
  name = "mpdris2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "eonpatapon";
    repo = "mpDris2";
    rev = "1653e15fb9446d5be5bff1dd64dacf70992ab1ef";
    sha256 = "0ea7b97744eea65e6a7a1187151eeab632a351ecb38e84f82ffa71ad3d280acf";
  };

  nativeBuildInputs = [
    autoconf
    automake
    intltool
    wrapPython
  ];

  pythonPath = [
    dbus-python
    libnotify
    mutagen
    pygobject
    python-mpd2
  ];

  # wrapPythonPrograms does not correctly replace shebangs leaving the version.
  postPatch = ''
    sed -i src/mpDris2.in.py \
      -e 's,env python3,env python,'
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  postInstall = ''
    wrapPythonPrograms
  '';

  meta = with lib; {
    description = "MPRIS 2 support for mpd";
    homepage = https://github.com/eonpatapon/mpDris2/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
