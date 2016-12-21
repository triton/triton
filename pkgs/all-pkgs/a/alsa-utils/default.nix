{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, gettext
, lib
, libxslt
, xmlto

, alsa-lib
, fftw_single
, libsamplerate
, ncurses
}:

stdenv.mkDerivation rec {
  name = "alsa-utils-1.1.3";

  src = fetchurl {
    url = "mirror://alsa/utils/${name}.tar.bz2";
    multihash = "QmZ2iyPWGzod3MdnUpgFju76q9y64TaWRonTT7KRa1txW9";
    sha256 = "127217a54eea0f9a49700a2f239a2d4f5384aa094d68df04a8eb80132eb6167c";
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

  meta = with lib; {
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
