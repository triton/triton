{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;

  tarballUrls = v: [
    "http://download.icu-project.org/files/icu4c/${v}/icu4c-${replaceChars ["."] ["_"] v}-src.tgz"
  ];

  version = "59.1";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmbipSVYKdxUiT9hexbKw4FkJSCJhtoVmT2h979VP2WjKE";
    hashOutput = false;
    sha256 = "7132fdaf9379429d004005217f10e00b7d2319d0fea22bdfddef8991c45b75fe";
  };

  postUnpack = ''
    srcRoot="$sourceRoot/source"
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
      urls = tarballUrls "59.1";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprints = [
        # Steven R. Loomis
        "4C95 9C0F 547B D2D8 B783  5B17 AAA9 AE9C 0F0D E47D"
        "BA90 283A 60D6 7BA0 DD91  0A89 3932 080F 4FB4 19E3"
      ];
      outputHash = "7132fdaf9379429d004005217f10e00b7d2319d0fea22bdfddef8991c45b75fe";
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
