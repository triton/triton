{ stdenv
, fetchurl

, openssl
}:

stdenv.mkDerivation rec {
  name = "ipmitool-1.8.17";

  src = fetchurl {
    url = "mirror://sourceforge/ipmitool/${name}.tar.bz2";
    multihash = "QmdofyZF3hzpf3NSwzG4NfH4qU1K6cG6qYKjnrpErXyGTZ";
    sha256 = "97fa20efd9c87111455b174858544becae7fcc03a3cb7bf5c19b09065c842d02";
  };

  buildInputs = [
    openssl
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--infodir=$out/share/info"
      "--mandir=$out/share/man"
    )
  '';

  meta = with stdenv.lib; {
    description = "Command-line interface to IPMI-enabled devices";
    homepage = http://ipmitool.sourceforge.net;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
