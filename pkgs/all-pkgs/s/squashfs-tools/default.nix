{ stdenv
, fetchFromGitHub

, lz4
, lzo
, xz
, zlib
, zstd
}:

let
  date = "2018-11-28";
  rev = "fb33dfc32b131a1162dcf0e35bd88254ae10e265";
in
stdenv.mkDerivation rec {
  name = "squashfs-tools-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "plougher";
    repo = "squashfs-tools";
    inherit rev;
    sha256 = "ab76ba9f30f493f245e2489bf118cdb74ee04d83ded571ab2043eccbffc6401c";
  };

  buildInputs = [
    lz4
    lzo
    xz
    zlib
    zstd
  ];

  prePatch = ''
    cd squashfs-tools
  '';

  preInstall = ''
    installFlagsArray+=("INSTALL_DIR=$out/bin")
  '';

  makeFlags = [
    "GZIP_SUPPORT=1"
    "XZ_SUPPORT=1"
    "LZO_SUPPORT=1"
    "LZ4_SUPPORT=1"
    "ZSTD_SUPPORT=1"
  ];

  meta = with stdenv.lib; {
    homepage = http://squashfs.sourceforge.net/;
    description = "Tool for creating and unpacking squashfs filesystems";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
