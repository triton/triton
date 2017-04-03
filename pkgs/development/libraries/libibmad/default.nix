{ stdenv
, fetchurl
, lib

, libibumad
}:

stdenv.mkDerivation rec {
  name = "libibmad-1.3.13";

  src = fetchurl {
    url = "https://www.openfabrics.org/downloads/management/${name}.tar.gz";
    multihash = "QmNk1FRgykiHhDMo1AuEtryRgyNvfs2uTHf4B8aJvkmb6w";
    sha256 = "17cdd721c81fecefc366601c46c55a4d44c93799980a0a34c271b12bc544520b";
  };

  buildInputs = [
    libibumad
  ];

  meta = with lib; {
    description = "Low layer IB functions for IB diagnostic/management programs";
    homepage = https://www.openfabrics.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
