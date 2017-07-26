{ stdenv
, fetchurl
, lib

, glib
, libxml2
}:

let
  versionMajor = "0.6";
  versionMinor = "12";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "libcroco-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libcroco/${versionMajor}/${name}.tar.xz";
    sha256 = "ddc4b5546c9fb4280a5017e2707fbd4839034ed1aba5b7d4372212f34f84f860";
  };

  buildInputs = [
    libxml2
    glib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-checks"
    "--enable-Bsymbolic"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "https://download.gnome.org/sources/libcroco/${versionMajor}/"
        + "${name}.sha256sum";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Generic Cascading Style Sheet (CSS) parsing and manipulation";
    homepage = https://git.gnome.org/browse/libcroco/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
