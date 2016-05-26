{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.27";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "Qma4LVc63BjFA4dSDoQVnZCMrc9MVV2uUgC5MZcuRtNdsU";
    sha256 = "19x16kxg0klks7v8v65z92ijkli4x5z2bk8yj0aljz0nn44xbry2";
  };

  buildInputs = [
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = "http://darwinsys.com/file";
    description = "A program that shows the type of files";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
