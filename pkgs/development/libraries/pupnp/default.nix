{ stdenv
, fetchurl
, lib
}:

let
  version = "1.6.22";
in
stdenv.mkDerivation rec {
  name = "libupnp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/pupnp/pupnp/libUPnP%20${version}/${name}.tar.bz2";
    sha256 = "0bdfacb7fa8d99b78343b550800ff193264f92c66ef67852f87f042fd1a1ebbc";
  };

  # Fortify Source breaks compilation
  optimize = false;
  fortifySource = false;

  meta = with lib; {
    description = "UPnP development kit for Linux";
    homepage = http://pupnp.sourceforge.net/;
    license = "BSD-style";
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
