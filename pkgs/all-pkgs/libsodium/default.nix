{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libsodium-1.0.9";

  src = fetchurl {
    urls = [
      "https://download.libsodium.org/libsodium/releases/${name}.tar.gz"
      "mirror://gentoo/distfiles/${name}.tar.gz"
    ];
    sha256 = "611418db78c36b2e20e50363d30e9c002a98dea9322f305b5bde56a26cdfe756";
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
