{ stdenv
, fetchurl

, glib
}:

stdenv.mkDerivation rec {
  name = "desktop-file-utils-0.23";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/desktop-file-utils/releases/"
      + "${name}.tar.xz";
    multihash = "QmbDFiKuyfyFaNNpATsytVATCdUcRQZKuSfKvGjoaenw8J";
    sha256 = "6c094031bdec46c9f621708f919084e1cb5294e2c5b1e4c883b3e70cb8903385";
  };

  buildInputs = [
    glib
  ];

  meta = with stdenv.lib; {
    description = "Command line utilities to work with desktop menu entries";
    homepage = http://www.freedesktop.org/wiki/Software/desktop-file-utils;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
