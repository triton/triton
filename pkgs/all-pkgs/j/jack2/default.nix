{ stdenv
, fetchFromGitHub
, lib
, makeWrapper
, waf

, bash
, expat
, libsamplerate
, libsndfile
, readline

# Optional Dependencies
, alsa-lib
, celt
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
  libBool = if libOnly then "no" else "yes";

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
    makeWrapper
    waf
  ];

  buildInputs = [
    expat
    libsamplerate
    libsndfile
    readline

    celt
    dbus
    opus
  ] ++ optionals (!libOnly) [
    alsa-lib
    ffado_lib
    pythonPackages.python
    pythonPackages.dbus-python
  ];

  postPatch = ''
    sed -i svnversion_regenerate.sh \
      -e 's,/bin/bash,${bash}/bin/bash,'
  '' + /* Remove vendored WAF */ ''
    rm -rfv waflib/
    sed -i wscript -e '/xcode/d'
  '';

  wafFlags = [
    "--classic"
    "--dbus"
    "--autostart=dbus"
    "--doxygen=no"
    "--alsa=${libBool}"
    "--firewire=${libBool}"
    #"--freebob=${libBool}"  # TODO
    #"--iio=${libBool}"  # TODO
    "--winmme=no"  # Windows?
    "--celt=yes"
    "--opus=yes"
    "--samplerate=yes"
    "--sndfile=yes"
    "--readline=yes"
  ];

  installPhase = ''
    python waf install
  '' + (
    if libOnly then ''
      rm -rfv $out/{bin,share}
      rm -rfv $out/lib/{jack,libjacknet*,libjackserver*}
    '' else ''
      wrapProgram $out/bin/jack_control \
        --set 'PYTHONPATH' "$PYTHONPATH"
    ''
  );

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
