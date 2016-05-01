{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gnutar-${version}";
  version = "1.28";

  src = fetchurl {
    url = "mirror://gnu/tar/tar-${version}.tar.bz2";
    sha256 = "0qkm2k9w8z91hwj8rffpjj9v1vhpiriwz4cdj36k9vrgc3hbzr30";
  };

  patches = [
    (fetchTritonPatch {
      rev = "58bea0bf6cf5a05014ad13bb8c914b137f87422f";
      file = "gnutar/add-clamp-mtime.patch";
      sha256 = "6bcde813d36fed0a0d5cfffb2d715d53b85d4876c050aae672cda2e190c25c87";
    })
  ];

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/tar/;
    description = "GNU implementation of the `tar' archiver";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}
