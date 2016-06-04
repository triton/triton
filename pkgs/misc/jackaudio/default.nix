{ stdenv, fetchFromGitHub, python, makeWrapper
, bash, libsamplerate, libsndfile, readline, expat

# Optional Dependencies
, dbus, pythonPackages, ffado_lib, alsa-lib
, libopus

# Extra options
, prefix ? ""
}:

let
  libOnly = prefix == "lib";
  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "${prefix}jack2-${version}";
  version = "1.9.10";

  src = fetchFromGitHub {
    owner = "jackaudio";
    repo = "jack2";
    rev = "v${version}";
    sha256 = "7089b4dd4bf22400cf870d97afb46679d8250376ca580da039d897887120407b";
  };

  nativeBuildInputs = [ python makeWrapper ];
  buildInputs = [
    python

    libsamplerate libsndfile readline expat

    dbus libopus
  ] ++ optionals (!libOnly) [
    alsa-lib
    ffado_lib
    pythonPackages.dbus
  ];

  prePatch = ''
    substituteInPlace svnversion_regenerate.sh --replace /bin/bash ${bash}/bin/bash
  '';

  patches = [ ./jack-gcc5.patch ];

  configurePhase = ''
    python waf configure --prefix=$out \
      --dbus \
      --classic \
      ${optionalString (!libOnly) "--firewire"} \
      ${optionalString (!libOnly) "--alsa"} \
      --autostart=dbus \
  '';

  CXXFLAGS = "-std=c++98";

  buildPhase = ''
    python waf build
  '';

  installPhase = ''
    python waf install
  '' + (if libOnly then ''
    rm -rf $out/{bin,share}
    rm -rf $out/lib/{jack,libjacknet*,libjackserver*}
  '' else ''
    wrapProgram $out/bin/jack_control --set PYTHONPATH $PYTHONPATH
  '');

  meta = with stdenv.lib; {
    description = "JACK audio connection kit, version 2 with jackdbus";
    homepage = "http://jackaudio.org";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ goibhniu wkennington ];
  };
}
