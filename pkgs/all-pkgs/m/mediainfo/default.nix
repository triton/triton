{ stdenv
, automake
, autoconf
, fetchurl
, lib
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
  inherit (lib)
    optionalString;

  version = "0.7.94";
in
stdenv.mkDerivation rec {
  name = "mediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/source/mediainfo/${version}/"
      + "mediainfo_${version}.tar.xz";
    sha256 = "2cfdf11efe10bee34a87a41a84db10c184bb0cc68f0c26a8ca635e5a56a06db9";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    makeWrapper
  ];

  buildInputs = [
    glib  # For setup-hook
    libmediainfo
    libzen
    wxGTK
    zlib
  ];

  srcRoot = "./MediaInfo/Project/GNU/${target}/";

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

  meta = with lib; {
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
