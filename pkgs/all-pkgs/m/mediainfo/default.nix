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

  version = "0.7.88";
in
stdenv.mkDerivation rec {
  name = "mediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/mediainfo_${version}.tar.xz";
    multihash = "QmeRsTrvS9FBWJaVkwGr5QfmXFWoQvekJRdRGDUMdka1qJ";
    sha256 = "853839f0dce758f97ab950069c73a2ea7b601f6712bbcee36d0bc2ee9f58f373";
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
