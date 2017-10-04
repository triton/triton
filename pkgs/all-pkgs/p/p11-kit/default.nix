{ stdenv
, fetchurl

, libffi
, libtasn1
}:

let
  version = "0.23.9";

  tarballUrls = version: [
    "https://github.com/p11-glue/p11-kit/releases/download/${version}/p11-kit-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "p11-kit-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e1c1649c335107a8d33cf3762eb7f57b2d0681f0c7d8353627293a58d6b4db63";
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
      urls = tarballUrls "0.23.9";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30"
        "4622 25C3 B46F 3487 9FC8  496C D605 848E D7E6 9871"
      ];
      inherit (src) outputHashAlgo;
      outputHash = "e1c1649c335107a8d33cf3762eb7f57b2d0681f0c7d8353627293a58d6b4db63";
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
