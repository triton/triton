{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;

  tarballName = v: "icu4c-${replaceChars ["."] ["_"] v}-src.tgz";

  tarballUrls = v: [
    "https://github.com/unicode-org/icu/releases/download/release-${replaceChars ["."] ["-"] v}/${tarballName v}"
    "http://download.icu-project.org/files/icu4c/${v}/${tarballName v}"
  ];


  version = "66.1";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "52a3f2209ab95559c1cf0a14f24338001f389615bf00e2585ef3dbc43ecf0a2e";
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
      urls = tarballUrls "66.1";
      inherit (src) outputHashAlgo;
      outputHash = "52a3f2209ab95559c1cf0a14f24338001f389615bf00e2585ef3dbc43ecf0a2e";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprints = [
          "9731 166C D8E2 3A83 BEE7  C6D3 ACA5 DBE1 FD8F ABF1"
          # Fredrik Roubert <fredrik@roubert.name>
          "FFA9 129A 180D 765B 7A5B  EA1C 9B43 2B27 D1BA 20D7"
          # Steven R. Loomis (IBM) <srloomis@us.ibm.com>
          "E409 8B78 AFC9 4394 F3F4  9AA9 0399 6C7C 83F1 2F11"
        ];
      };
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
