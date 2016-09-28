{ stdenv
, fetchTritonPatch
, fetchurl

, openssl
}:

let
  version = "0.3.13";
in
stdenv.mkDerivation rec {
  name = "trousers-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/project/trousers/trousers/${version}/${name}.tar.gz";
    sha256 = "bb908e4a3c88a17b247a4fc8e0fff3419d8a13170fe7bdfbe0e2c5c082a276d3";
  };

  buildInputs = [
    openssl
  ];

  patches = [
    (fetchTritonPatch {
      rev = "35e456a096e677dc4ee1453c76c52821423f7405";
      file = "t/trousers/trousers-0.3-allow-non-tss-config-file-owner.patch";
      sha256 = "891938eb62275871cafd5c279d677662e89620c59265cd8b4605f630f97afb87";
    })
  ];

  configureFlags = [
    "--disable-usercheck"
  ];

  # Attempt to remove -std=gnu89 when updating w/ gcc5+
  NIX_CFLAGS_COMPILE = "-std=gnu89 -DALLOW_NON_TSS_CONFIG_FILE";
  NIX_LDFLAGS = "-lgcc_s";

  meta = with stdenv.lib; {
    description = "Trusted computing software stack";
    homepage = http://trousers.sourceforge.net/;
    license = licenses.cpl10;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

