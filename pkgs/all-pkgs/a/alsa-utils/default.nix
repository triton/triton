{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, gettext
, libxslt
, xmlto

, alsa-lib
, fftw_single
, libsamplerate
, ncurses
}:

stdenv.mkDerivation rec {
  name = "alsa-utils-1.1.2";

  src = fetchurl {
    url = "mirror://alsa/utils/${name}.tar.bz2";
    multihash = "QmRmwwxqHowPTrZzGWYaB9pvy2YMkAMCf312Bpp5UaT2e7";
    sha256 = "0wcha78c2sm8qqk5r3w83cvm8fp6fb1zpd35kmcm24kxhz007xks";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    gettext
    libxslt
    xmlto
  ];

  buildInputs = [
    alsa-lib
    fftw_single
    libsamplerate
    ncurses
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-udev-rules-dir=$out/lib/udev/rules.d")
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=("ASOUND_STATE_DIR=$TMPDIR")
  '';

  meta = with stdenv.lib; {
    description = "ALSA, the Advanced Linux Sound Architecture utils";
    homepage = http://www.alsa-project.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
