{ stdenv
, fetchurl

, libffi
, libtasn1
}:

let
  version = "0.23.20";

  tarballUrls = version: [
    "https://github.com/p11-glue/p11-kit/releases/download/${version}/p11-kit-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "p11-kit-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "14d86024c3dfd6b967d9bc0b4ec7b2973014fe7423481f4d230a1a63b8aa6104";
  };

  buildInputs = [
    libffi
    libtasn1
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--without-trust-paths"
  ];

  preInstall = ''
    installFlagsArray+=("exampledir=$out/etc/pkcs11")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.23.20";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprints = [
          "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30"
          "4622 25C3 B46F 3487 9FC8  496C D605 848E D7E6 9871"
        ];
      };
      inherit (src) outputHashAlgo;
      outputHash = "14d86024c3dfd6b967d9bc0b4ec7b2973014fe7423481f4d230a1a63b8aa6104";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://p11-glue.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
