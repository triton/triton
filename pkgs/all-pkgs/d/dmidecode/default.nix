{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "dmidecode-3.2";

  src = fetchurl {
    url = "mirror://savannah/dmidecode/${name}.tar.xz";
    hashOutput = false;
    sha256 = "077006fa2da0d06d6383728112f2edef9684e9c8da56752e97cd45a11f838edd";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "90DF D652 3C57 373D 81F6  3D19 8656 88D0 38F0 2FC8";
      };
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
