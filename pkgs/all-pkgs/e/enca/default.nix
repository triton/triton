{ stdenv
, fetchurl
, gettext

, recode
}:

stdenv.mkDerivation rec {
  name = "enca-1.18";

  src = fetchurl {
    url = "https://dl.cihar.com/enca/${name}.tar.xz";
    sha256 = "019995e9324510f0667b73e88753bc496c744f93bff48bbfb114165f8875326c";
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
