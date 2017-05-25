{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "dmidecode-3.1";

  src = fetchurl {
    url = "mirror://savannah/dmidecode/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d766ce9b25548c59b1e7e930505b4cad9a7bb0b904a1a391fbb604d529781ac0";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "90DF D652 3C57 373D 81F6  3D19 8656 88D0 38F0 2FC8";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };
  meta = with stdenv.lib; {
    description = "Gathers hardware information from the BIOS via the SMBIOS/DMI standard";
    homepage = http://www.nongnu.org/dmidecode/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
