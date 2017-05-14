{ stdenv
, fetchFromGitHub
, lib
, makeWrapper
, python

, bash
, expat
, libsamplerate
, libsndfile
, readline

# Optional Dependencies
, alsa-lib
, dbus
, ffado_lib
, opus
, pythonPackages

# Extra options
, prefix ? ""
}:

let
  inherit (lib)
    optionals
    optionalString;

  libOnly = prefix == "lib";

  version = "1.9.10";
in
stdenv.mkDerivation rec {
  name = "${prefix}jack2-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "jackaudio";
    repo = "jack2";
    rev = "v${version}";
    sha256 = "c012e28cc2d6687bf34a9f2a87a507f0d3b46670428e1553634f29de82451b22";
  };

  nativeBuildInputs = [
    python
    makeWrapper
  ];

  buildInputs = [
    python

    expat
    libsamplerate
    libsndfile
    readline

    dbus
    opus
  ] ++ optionals (!libOnly) [
    alsa-lib
    ffado_lib
    pythonPackages.dbus
  ];

  prePatch = ''
    sed -i svnversion_regenerate.sh \
      -e 's,/bin/bash,${bash}/bin/bash,'
  '';

  patches = [
    ./jack-gcc5.patch
  ];

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

  meta = with lib; {
    description = "JACK audio connection kit, version 2 with jackdbus";
    homepage = "http://jackaudio.org";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
