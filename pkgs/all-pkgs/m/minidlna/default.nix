{ stdenv
, autoreconfHook
, fetchgit
, fetchurl

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
  version = "1.1.6";

  inherit (stdenv.lib)
    replaceStrings;
in
stdenv.mkDerivation rec {
  name = "minidlna-${version}";

  src = fetchurl {
    name = "${name}.tar.xz";
    multihash = "Qmbm8MHTmvxYGw433bmNGSMGb583vQrkZXAit4Cvk9nubV";
    sha256 = "5964d568246cead8e3d4eb6a28ea2477710bd4598a7129df30dc5db304f6f428";
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
        version = 2;
        url = "git://git.code.sf.net/p/minidlna/git";
        rev = "refs/tags/v${replaceStrings ["."] ["_"] version}";
        sha256 = "c63d03df0aa14b8115080dfb93ac828a674a65524ab88bef9559c2e0848f032a";
      };

      buildPhase = ''
        cd ..
        tar Jcfv ${name}.tar.xz $sourceRoot
      '';

      installPhase = ''
        mkdir -pv $out
        cp -v ${name}.tar.xz $out
      '';
    };
  };

  meta = with stdenv.lib; {
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
