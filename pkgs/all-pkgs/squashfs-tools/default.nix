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
    sha256 = "fea7782f4a37c9bac657fec97426c28910903b0bb6800cd4fdaf849adce02716";
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
