{ stdenv, fetchurl, yasm, enable10bit ? false }:

stdenv.mkDerivation rec {
  name = "x264-snapshot-20151213-2245";

  src = fetchurl {
    url = "ftp://ftp.videolan.org/pub/videolan/x264/snapshots/${name}.tar.bz2";
    sha256 = "042d9hn6w0yy9k0r596lpvi73p7fk63jj6iyp3mdvlr87247j4zr";
  };

  patchPhase = ''
    sed -i s,/bin/bash,${stdenv.shell}, configure version.sh
  '';

  configureFlags = [ "--enable-shared" ]
    ++ stdenv.lib.optional (!stdenv.isi686) "--enable-pic"
    ++ stdenv.lib.optional (enable10bit) "--bit-depth=10";

  buildInputs = [ yasm ];

  meta = with stdenv.lib; {
    description = "library for encoding H264/AVC video streams";
    homepage    = http://www.videolan.org/developers/x264.html;
    license     = licenses.gpl2;
    platforms   = platforms.unix;
    maintainers = [ maintainers.spwhitt ];
  };
}
