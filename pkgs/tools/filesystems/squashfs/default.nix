{ stdenv
, fetchFromGitHub

, lz4
, lzo
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "squashfs-4.4dev";

  src = fetchFromGitHub {
    owner = "plougher";
    repo = "squashfs-tools";
    rev = "9c1db6d13a51a2e009f0027ef336ce03624eac0d";
    sha256 = "83979bacb8272301d6b157314a9d04a3bcf4119872e3e0a6d0dd1a681a5b2f7c";
  };

  buildInputs = [
    lz4
    lzo
    xz
    zlib
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
