{ stdenv
, fetchurl
, intltool

, appstream-glib
, glib
}:

stdenv.mkDerivation rec {
  name = "appdata-tools-0.1.8";

  src = fetchurl {
    url = "http://people.freedesktop.org/~hughsient/releases/${name}.tar.xz";
    sha256 = "0qal3rzpsagzggzk0sbxlc6v51mzskpm77z07p0bp48ggz9865a0";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    appstream-glib
    glib
  ];

  meta = with stdenv.lib; {
    homepage = "http://people.freedesktop.org/~hughsient/appdata";
    description = "CLI designed to validate AppData descriptions for standards compliance and to the style guide";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
