{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libsodium-1.0.7";

  src = fetchurl {
    url = "https://download.libsodium.org/libsodium/releases/${name}.tar.gz";
    sha256 = "0ji0aiv1vc0jpy0wb1kkz5f84skjawq161cglhy1c32icf3yglbs";
  };

  NIX_LDFLAGS = stdenv.lib.optionalString stdenv.cc.isGNU "-lssp";

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A modern and easy-to-use crypto library";
    homepage = http://doc.libsodium.org/;
    license = licenses.isc;
    maintainers = with maintainers; [ raskin viric wkennington ];
    platforms = platforms.all;
  };
}
