{ stdenv
, automake
, autoconf
, fetchurl
, libtool
, makeWrapper

, glib
, libmediainfo
, libzen
, wxGTK
, zlib

, target ? "GUI"
}:

# FIXME: allow building both cli and gui from the same build

assert target == "CLI" || target == "GUI";

let
  inherit (stdenv.lib)
    optionalString;

  version = "0.7.87";
in
stdenv.mkDerivation rec {
  name = "mediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/mediainfo_${version}.tar.xz";
    multihash = "QmdLCyZ42DqhVXWc5i8mjmmZ5TFm2EmknJq9ZyhM8mHDY9";
    sha256 = "fb86d2d8775ce6b23fe9416d006b0f62f8c2d71a1ee105ba820909ce9c8744f3";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    makeWrapper
  ];

  buildInputs = [
    glib # For setup-hook
    libmediainfo
    libzen
    wxGTK
    zlib
  ];

  sourceRoot = "./MediaInfo/Project/GNU/${target}/";

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--disable-debug"
    "--disable-gprof"
    "--disable-staticlibs"
  ];

  preFixup = optionalString (target == "GUI") ''
    wrapProgram $out/bin/mediainfo-gui \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = with stdenv.lib; {
    description = "Displays technical & tag information for multimedia files";
    homepage = http://mediaarea.net/mediainfo/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
