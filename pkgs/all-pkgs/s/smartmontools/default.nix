{ stdenv
, fetchurl

, libcap-ng
}:

let
  version = "6.6";
in
stdenv.mkDerivation rec {
  name = "smartmontools-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/smartmontools/smartmontools/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "51f43d0fb064fccaf823bbe68cf0d317d0895ff895aa353b3339a3b316a53054";
  };

  buildInputs = [
    libcap-ng
  ];

  configureFlags = [
    "--with-libcap-ng"
    "--with-nvme-devicescan"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "887B 8C63 2110 4CA8 4A8E  F91B 18EC DA46 CBF6 BAC6";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tools for monitoring the health of hard drives";
    homepage = http://smartmontools.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
