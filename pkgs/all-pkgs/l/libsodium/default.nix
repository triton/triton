{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://github.com/jedisct1/libsodium/releases/download/${version}/libsodium-${version}.tar.gz"
    "https://download.libsodium.org/libsodium/releases/libsodium-${version}.tar.gz"
    "mirror://gentoo/distfiles/libsodium-${version}.tar.gz"
  ];

  version = "1.0.14";
in
stdenv.mkDerivation rec {
  name = "libsodium-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "3cfc84d097fdc891b40d291f2ac2c3f99f71a87e36b20cc755c6fa0e97a77ee7";
  };

  doCheck = true;

  postInstall = ''
    ln -sv sodium "$out"/include/nacl
    ln -sv "$(basename "$(readlink -f "$out/lib/libsodium.so")")" "$out/lib/libnacl.so"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.0.14";
      minisignUrls = map (n: "${n}.minisig") urls;
      minisignPub = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      sha256 = "3cfc84d097fdc891b40d291f2ac2c3f99f71a87e36b20cc755c6fa0e97a77ee7";
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
