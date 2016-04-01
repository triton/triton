{ stdenv, fetchurl, alsa-lib, gettext, ncurses, libsamplerate, fftw_double, pciutils }:

stdenv.mkDerivation rec {
  name = "alsa-utils-${version}";
  version = "1.1.1";

  src = fetchurl {
    urls = [
      "ftp://ftp.alsa-project.org/pub/utils/${name}.tar.bz2"
      "http://alsa.cybermirror.org/utils/${name}.tar.bz2"
    ];
    sha256 = "89757c9abaf420831b088fce354d492acc170bd02bb50eb7392c175f594b8041";
  };

  buildInputs = [ gettext alsa-lib ncurses libsamplerate fftw_double ];

  patchPhase = ''
    substituteInPlace alsa-info/alsa-info.sh \
      --replace "which" "type -p" \
      --replace "lspci" "${pciutils}/bin/lspci"
  '';

  configureFlags = [
    "--disable-xmlto"
    "--with-udev-rules-dir=$(out)/lib/udev/rules.d"
  ];

  installFlags = [
    "ASOUND_STATE_DIR=$(TMPDIR)/dummy"
  ];

  meta = {
    homepage = http://www.alsa-project.org/;
    description = "ALSA, the Advanced Linux Sound Architecture utils";

    longDescription = ''
      The Advanced Linux Sound Architecture (ALSA) provides audio and
      MIDI functionality to the Linux-based operating system.
    '';

    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.AndersonTorres ];
  };
}
