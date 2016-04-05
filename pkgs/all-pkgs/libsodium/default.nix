{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libsodium-${version}";
  version = "1.0.10";

  src = fetchurl {
    urls = [
      "https://download.libsodium.org/libsodium/releases/libsodium-${version}.tar.gz"
      "mirror://gentoo/distfiles/libsodium-${version}.tar.gz"
    ];
    sha256 = "71b786a96dd03693672b0ca3eb77f4fb08430df307051c0d45df5353d22bc4be";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A modern and easy-to-use crypto library";
    homepage = http://doc.libsodium.org/;
    license = licenses.isc;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
