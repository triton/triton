{ stdenv
, fetchurl
, gettext

, alsa-lib
, libsamplerate
, ncurses
}:

stdenv.mkDerivation rec {
  name = "alsa-oss-1.0.28";

  src = fetchurl {
    urls = [
      "ftp://ftp.alsa-project.org/pub/oss-lib/${name}.tar.bz2"
      "http://alsa.cybermirror.org/oss-lib/${name}.tar.bz2"
    ];
    sha256 = "1mbabiywxjjlvdh257j3a0v4vvy69mwwnvc3xlq7pg50i2m2rris";
  };

  nativeBuildInputs = [ gettext ];

  buildInputs = [
    alsa-lib
    libsamplerate
    ncurses
  ];

  configureFlags = [
    "--disable-xmlto"
  ];

  installFlags = [
    "ASOUND_STATE_DIR=$(TMPDIR)/dummy"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.alsa-project.org/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
