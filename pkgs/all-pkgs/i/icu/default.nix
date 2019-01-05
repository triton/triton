{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;

  tarballUrls = v: [
    "http://download.icu-project.org/files/icu4c/${v}/icu4c-${replaceChars ["."] ["_"] v}-src.tgz"
  ];

  version = "63.1";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmcwUadnqKHdhksCRvvgsV4WK4nqM18X3gKnGY5oPJ75nS";
    hashOutput = false;
    sha256 = "05c490b69454fce5860b7e8e2821231674af0a11d7ef2febea9a32512998cb9d";
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
      urls = tarballUrls "63.1";
      inherit (src) outputHashAlgo;
      outputHash = "05c490b69454fce5860b7e8e2821231674af0a11d7ef2febea9a32512998cb9d";
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
