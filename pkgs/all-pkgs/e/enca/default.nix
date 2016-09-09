{ stdenv
, fetchurl
, gettext

, recode
}:

stdenv.mkDerivation rec {
  name = "enca-1.19";

  src = fetchurl {
    url = "https://dl.cihar.com/enca/${name}.tar.xz";
    multihash = "QmeByvryGNDd9ysbSk4omYmNAvuGvueKMRn22EWZ1pCiRY";
    sha256 = "3a487eca40b41021e2e4b7a6440b97d822e6532db5464471f572ecf77295e8b8";
  };

  postPatch = ''
    # too old, automake will update it
    rm -v missing
  '';

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    recode
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-external"
    "--disable-gtk-doc"
    "--enable-rpath"
    "--without-gcov"
  ];

  meta = with stdenv.lib; {
    description = "Detects encoding of text files and can convert them";
    homepage = http://???;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
