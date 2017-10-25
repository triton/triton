{ stdenv
, autoreconfHook
, fetchgit
, fetchurl
, lib

, ffmpeg
, flac
, libexif
, libid3tag
, libjpeg
, libogg
, libvorbis
, sqlite
}:

let
  version = "1.2.0";

  inherit (lib)
    replaceStrings;
in
stdenv.mkDerivation rec {
  name = "minidlna-${version}";

  src = fetchurl {
    name = "${name}.tar.xz";
    multihash = "QmfWjHiEYTv1SckfQodoaoJhKAWXewyk3Y4nZHcyuBxZjY";
    sha256 = "c25064f9bcdfcd573b6425381c256e1d0f55c58afd0fc837c269ded9047caed8";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ffmpeg
    flac
    libexif
    libid3tag
    libjpeg
    libogg
    libvorbis
    sqlite
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-tivo"
    "--enable-netgear"
    "--enable-readynas"
  ];

  passthru = {
    srcTarball = stdenv.mkDerivation {
      name = "net-tools-tarball-${version}";

      src = fetchgit {
        version = 3;
        url = "git://git.code.sf.net/p/minidlna/git";
        rev = "refs/tags/v${replaceStrings ["."] ["_"] version}";
        sha256 = "e85ef6a90d9a521821a87e1bd4fe225244b51065f5cbadea50f2c6ad37e331f1";
      };

      buildPhase = ''
        cd ..
        tar Jcfv ${name}.tar.xz $srcRoot
      '';

      installPhase = ''
        mkdir -pv $out
        cp -v ${name}.tar.xz $out
      '';
    };
  };

  meta = with lib; {
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
