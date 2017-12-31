{ stdenv
, fetchFromGitHub
, lib
, makeWrapper

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

  version = "2017-12-20";
in
stdenv.mkDerivation rec {
  name = "${prefix}jack2-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "jackaudio";
    repo = "jack2";
    rev = "f6f7f11b387c49973d8637fa51a4e16eaa12ffb9";
    sha256 = "dd17461b52ad140ffe866e6b1b174bd50a0d2e5597bd176f681f12eb867cfe4d";
  };

  nativeBuildInputs = [
    pythonPackages.python
    makeWrapper
  ];

  buildInputs = [
    expat
    libsamplerate
    libsndfile
    readline

    dbus
    opus
  ] ++ optionals (!libOnly) [
    alsa-lib
    ffado_lib
    pythonPackages.python
    pythonPackages.dbus
  ];

  postPatch = ''
    sed -i svnversion_regenerate.sh \
      -e 's,/bin/bash,${bash}/bin/bash,'
  '';

  configurePhase = ''
    ${pythonPackages.python.interpreter} waf configure --prefix=$out \
      --dbus \
      --classic \
      ${optionalString (!libOnly) "--firewire"} \
      ${optionalString (!libOnly) "--alsa"} \
      --autostart=dbus \
  '';

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
