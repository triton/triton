{ stdenv, fetchurl }:

let
  genUrls = version: [
    "https://github.com/jedisct1/libsodium/releases/download/${version}/libsodium-${version}.tar.gz"
    "https://download.libsodium.org/libsodium/releases/libsodium-${version}.tar.gz"
    "mirror://gentoo/distfiles/libsodium-${version}.tar.gz"
  ];

  version = "1.0.11";
in

stdenv.mkDerivation rec {
  name = "libsodium-${version}";

  src = fetchurl {
    urls = genUrls version;
    allowHashOutput = false;
    sha256 = "a14549db3c49f6ae2170cbbf4664bd48ace50681045e8dbea7c8d9fb96f9c765";
  };

  doCheck = true;

  postInstall = ''
    ln -sv sodium "$out"/include/nacl
    ln -sv "$(basename "$(readlink -f "$out/lib/libsodium.so")")" "$out/lib/libnacl.so"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = genUrls "1.0.11";
      minisignUrls = map (n: "${n}.minisig") urls;
      minisignPub = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      sha256 = "a14549db3c49f6ae2170cbbf4664bd48ace50681045e8dbea7c8d9fb96f9c765";
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
