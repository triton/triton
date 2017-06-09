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

  version = "2017-05-18";
in
stdenv.mkDerivation rec {
  name = "${prefix}jack2-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "jackaudio";
    repo = "jack2";
    rev = "31d4ae97f296fe1c954cbb51e50d5e60578260b8";
    sha256 = "c357e5e8384231dab58e8070c9fc7515e6975f1fa61c98e7231bd3dbb3964cf5";
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

  postPatch = ''
    sed -i svnversion_regenerate.sh \
      -e 's,/bin/bash,${bash}/bin/bash,'

    # FIXME: disable tests to work around bug with gcc7
    ## if not bld.env['IS_WINDOWS']:
    ##   bld.recurse('tests')
    sed -i wscript \
      -e 's/not bld.env/bld.env/'
  '';

  configurePhase = ''
    python waf configure --prefix=$out \
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
