{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;

  tarballUrls = v: [
    "http://download.icu-project.org/files/icu4c/${v}/icu4c-${replaceChars ["."] ["_"] v}-src.tgz"
  ];

  version = "60.2";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmRH8sAQ7AW4VqSbfeoBgN71N5SW7CjRgYTAi69QrNvBo5";
    hashOutput = false;
    sha256 = "f073ea8f35b926d70bb33e6577508aa642a8b316a803f11be20af384811db418";
  };

  postUnpack = ''
    srcRoot="$srcRoot/source"
  '';

  configureFlags = [
    "--enable-auto-cleanup"
    "--enable-rpath"
    "--disable-tests"
    "--disable-samples"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "60.2";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "9731 166C D8E2 3A83 BEE7  C6D3 ACA5 DBE1 FD8F ABF1";
      outputHash = "f073ea8f35b926d70bb33e6577508aa642a8b316a803f11be20af384811db418";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Unicode and globalization support library";
    homepage = http://site.icu-project.org/;
    license = licenses.icu;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
