{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;

  tarballUrls = v: [
    "http://download.icu-project.org/files/icu4c/${v}/icu4c-${replaceChars ["."] ["_"] v}-src.tgz"
  ];

  version = "60.1";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmR4qHjWV6KGoQz5qGhaBeV6uX6A9GfnmkqcSzD5kqPTxd";
    hashOutput = false;
    sha256 = "f8f5a6c8fbf32c015a467972bdb1477dc5f5d5dfea908b6ed218715eeb5ee225";
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
      urls = tarballUrls "60.1";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "9731 166C D8E2 3A83 BEE7  C6D3 ACA5 DBE1 FD8F ABF1";
      outputHash = "f8f5a6c8fbf32c015a467972bdb1477dc5f5d5dfea908b6ed218715eeb5ee225";
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
