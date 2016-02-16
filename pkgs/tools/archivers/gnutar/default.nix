{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gnutar-${version}";
  version = "1.28";

  src = fetchurl {
    url = "mirror://gnu/tar/tar-${version}.tar.bz2";
    sha256 = "0qkm2k9w8z91hwj8rffpjj9v1vhpiriwz4cdj36k9vrgc3hbzr30";
  };

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
