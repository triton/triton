{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;

  tarballUrls = v: [
    "http://download.icu-project.org/files/icu4c/${v}/icu4c-${replaceChars ["."] ["_"] v}-src.tgz"
  ];

  version = "62.1";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmVYj1nbFT2pGp7WPvPGd9XryaBLuHLTf3RERsorXdH37Q";
    hashOutput = false;
    sha256 = "3dd9868d666350dda66a6e305eecde9d479fb70b30d5b55d78a1deffb97d5aa3";
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
      urls = tarballUrls "62.1";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprints = [
        "9731 166C D8E2 3A83 BEE7  C6D3 ACA5 DBE1 FD8F ABF1"
        # Fredrik Roubert <fredrik@roubert.name>
        "FFA9 129A 180D 765B 7A5B  EA1C 9B43 2B27 D1BA 20D7"
      ];
      outputHash = "3dd9868d666350dda66a6e305eecde9d479fb70b30d5b55d78a1deffb97d5aa3";
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
