{ stdenv
, fetchurl
, lib
}:

let
  version = "1.6.24";
in
stdenv.mkDerivation rec {
  name = "libupnp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/pupnp/pupnp/libUPnP%20${version}/${name}.tar.bz2";
    sha256 = "7d83d79af3bb4062e5c3a58bf2e90d2da5b8b99e2b2d57c23b5b6f766288cf96";
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
