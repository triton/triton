{ stdenv
, fetchTritonPatch
, fetchurl
, lib
, nasm

, libsndfile
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

  channel = "3.99";
  version = "${channel}.5";
in
stdenv.mkDerivation rec {
  name = "lame-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lame/lame/${channel}/${name}.tar.gz";
    sha256 = "24346b4158e4af3bd9f2e194bb23eb473c75fb7377011523353196b19b9a23ff";
  };

  patches = [
    (fetchTritonPatch {
      rev = "7b4e03ea2c1aa248c38b4f55ed4892bfceaf4d32";
      file = "lame/lame-gcc-4.9.patch";
      sha256 = "9f675fa1a5ef15111bb51253b31fc88dbf9b21a5111e38ac0060b97abe42b39f";
    })
  ];

  nativeBuildInputs = [
    nasm
  ];

  buildInputs = [ ]
    ++ optional (libsndfile != null) libsndfile;

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
