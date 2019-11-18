{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://github.com/jedisct1/libsodium/releases/download/${version}/libsodium-${version}.tar.gz"
    "https://download.libsodium.org/libsodium/releases/libsodium-${version}.tar.gz"
    "mirror://gentoo/distfiles/libsodium-${version}.tar.gz"
  ];

  version = "1.0.18";
in
stdenv.mkDerivation rec {
  name = "libsodium-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1";
  };

  doCheck = true;

  postInstall = ''
    ln -sv sodium "$dev"/include/nacl
    ln -sv "$(basename "$(readlink -f "$dev/lib/libsodium.so")")" "$dev/lib/libnacl.so"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.0.18";
      fullOpts = {
        minisignUrls = map (n: "${n}.minisig") urls;
        minisignPub = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      sha256 = "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1";
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
