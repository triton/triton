{ stdenv
, fetchurl
, lib

, channel
}:

let
  sources = {
    "0.7" = {
      version = "0.7.1";
      multihash = "QmeERWpDtsMdASnUwdCoXVx3FdSGBvtFztUGSE3gFm2Vab";
      sha256 = "93f0e2dfb59021b19e69dc0dee855eb89f19397db1dea0d0d6f9329cff933066";
    };
    "0.5" = {
      version = "0.5.1.3";
      multihash = "QmRSQj9eJJTiRNKvYeXcm4Dow1PRSvujBp5uKeFGofGzNy";
      sha256 = "fc2e5b68382eb436a38c3104684a6c494df9bde133c139fbba3ddb5d7eaa6a2e";
    };
  };

  inherit (lib)
    optionals
    versionAtLeast;

  inherit (sources."${channel}")
    multihash
    sha256
    version;
in
stdenv.mkDerivation rec {
  name = "celt-${version}";

  src = fetchurl {
    url = "mirror://xiph/celt/${name}.tar.gz";
    inherit
      multihash
      sha256;
  };

  configureFlags = optionals (versionAtLeast version "0.11") [
    "--enable-custom-modes"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
