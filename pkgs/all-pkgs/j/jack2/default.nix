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

  version = "2018-11-15";
in
stdenv.mkDerivation rec {
  name = "${prefix}jack2-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "jackaudio";
    repo = "jack2";
    rev = "c5a16d0ed3dbfeb2bf60717cb5aaec717a229591";
    sha256 = "d5d38af2c3f39dc88372c9ce7ff0bb8f90b1f1625454e719a0f3be21f6f02342";
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

  wafConfigureFlags = [
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

  postInstall = if libOnly then ''
    rm -rfv $out/{bin,share}
    rm -rfv $out/lib/{jack,libjacknet*,libjackserver*}
  '' else ''
    wrapProgram $out/bin/jack_control \
      --set 'PYTHONPATH' "$PYTHONPATH"
  '';

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
