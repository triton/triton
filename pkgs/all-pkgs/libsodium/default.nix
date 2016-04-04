{ stdenv, fetchurl }:

let
  genUrls = version: [
    "https://download.libsodium.org/libsodium/releases/libsodium-${version}.tar.gz"
    "mirror://gentoo/distfiles/libsodium-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libsodium-${version}";
  version = "1.0.9";

  src = fetchurl {
    urls = genUrls version;
    allowHashOutput = false;
    sha256 = "611418db78c36b2e20e50363d30e9c002a98dea9322f305b5bde56a26cdfe756";
  };

  doCheck = true;

  passthru = rec {
    newVersion = "1.0.9";

    sourceTarball = fetchurl rec {
      urls = genUrls newVersion;
      minisignUrls = map (n: "${n}.minisig") urls;
      minisignPub = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      sha256 = "611418db78c36b2e20e50363d30e9c002a98dea9322f305b5bde56a26cdfe756";
    };
  };

  meta = with stdenv.lib; {
    description = "A modern and easy-to-use crypto library";
    homepage = http://doc.libsodium.org/;
    license = licenses.isc;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
