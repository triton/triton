{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "spice-protocol-0.12.13";

  src = fetchurl {
    url = "https://www.spice-space.org/download/releases/${name}.tar.bz2";
    multihash = "QmdMxn3Dj7ygCoTqvAPy5PuJW77S2DWEBVnMGNHXGPRZM4";
    hashOutput = false;
    sha256 = "89ee11b202d2268e061788e6ace114e1ff18c7620ae64d1ca3aba252ee7c9933";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") src.urls;
      pgpKeyFingerprint = "94A9 F756 61F7 7A61 6864  9B23 A9D8 C214 29AC 6C82";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Protocol headers for the SPICE protocol";
    homepage = http://www.spice-space.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
