{ stdenv
, fetchurl
, lib
, nasm

, libsndfile
, ncurses
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    boolString
    elem
    optional
    platforms;

  sndfileFileIO =
    if libsndfile != null then
      "sndfile"
    else
      "lame";

  channel = "3.100";
  version = "${channel}";
in
stdenv.mkDerivation rec {
  name = "lame-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lame/lame/${channel}/${name}.tar.gz";
    sha256 = "ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e";
  };

  nativeBuildInputs = [
    nasm
  ];

  buildInputs = [
    ncurses
  ] ++ optional (libsndfile != null) libsndfile;

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-largefile"
    "--${boolEn (elem targetSystem platforms.x86-all)}-nasm"
    "--enable-rpath"
    "--enable-cpml"
    "--disable-gtktest"
    "--disable-efence"
    "--disable-analyzer-hooks"
    "--enable-decoder"
    "--enable-frontend"
    "--disable-mp3x"
    "--enable-mp3rtp"
    "--enable-dynamic-frontends"
    "--enable-expopt=norm"
    "--disable-debug"
    "--with-fileio=${boolString (libsndfile != null) "sndfile" "lame"}"
  ];

  meta = with lib; {
    description = "A high quality MPEG Audio Layer III (MP3) encoder";
    homepage = http://lame.sourceforge.net;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
