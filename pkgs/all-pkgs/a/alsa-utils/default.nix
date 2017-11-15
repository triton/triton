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
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "alsa-utils-1.1.5";

  src = fetchurl {
    url = "mirror://alsa/utils/${name}.tar.bz2";
    multihash = "QmaKgJYXDqGWmyDmLUyqLS83j8rUXrtPL6NmwfRNVqGkrN";
    sha256 = "320bd285e91db6e7fd7db3c9ec6f55b02f35449ff273c7844780ac6a5a3de2e8";
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
