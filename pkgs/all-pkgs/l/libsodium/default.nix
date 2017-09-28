{ stdenv
, autoreconfHook
, fetchTritonPatch
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

  nativeBuildInputs = [
    autoreconfHook
  ];

  patches = [
    (fetchTritonPatch {
      rev = "824339b7e47f1ea030fd411035d446c47c09061b";
      file = "l/libsodium/libsodium-1.0.10-cpuflags.patch";
      sha256 = "744230d34b59cc1a15dc82c6fd2a24baff141363b09f4220021fed901d49c97f";
    })
  ];

  configureFlags = [
    "--disable-sse4_1"
  ];

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
