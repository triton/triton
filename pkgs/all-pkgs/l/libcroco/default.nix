{ stdenv
, fetchurl
, lib

, glib
, libxml2
}:

let
  versionMajor = "0.6";
  versionMinor = "13";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "libcroco-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libcroco/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "767ec234ae7aa684695b3a735548224888132e063f92db585759b422570621d4";
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
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/libcroco/${versionMajor}/"
          + "${name}.sha256sum";
      };
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
