{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "adns-1.5.1";

  src = fetchurl {
    urls = [
      "mirror://gnu/adns/${name}.tar.gz"
      "http://www.chiark.greenend.org.uk/~ian/adns/ftp/${name}.tar.gz"
      "ftp://ftp.chiark.greenend.org.uk/users/ian/adns/${name}.tar.gz"
    ];
    multihash = "QmWhYWVbbwVF9u7ueanFab3qKucWMojanSEgCokqCyksvv";
    sha256 = "5b1026f18b8274be869245ed63427bf8ddac0739c67be12c4a769ac948824eeb";
  };

  meta = with lib; {
    description = "Asynchronous DNS Resolver Library";
    homepage = "http://www.chiark.greenend.org.uk/~ian/adns/";
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
