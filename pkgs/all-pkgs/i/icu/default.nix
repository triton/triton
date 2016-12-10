{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;

  baseUrls = v: [
    "http://download.icu-project.org/files/icu4c/${v}/icu4c"
  ];

  version = "58.2";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    url =
      map (n: "${n}-${replaceChars ["."] ["_"] version}-src.tgz")
          (baseUrls version);
    hashOutput = false;
    sha256 = "2b0a4410153a9b20de0e20c7d8b66049a72aef244b53683d0d7521371683da0c";
  };

  postUnpack = ''
    sourceRoot="$sourceRoot/source"
  '';

  configureFlags = [
    "--disable-debug"
    "--enable-release"
    "--disable-strict"
    "--enable-shared"
    #"--enable-auto-cleanup"
    "--enable-draft"
    "--enable-renaming"
    "--disable-tracing"
    #"--enable-plugins"
    #"--enable-dynload"
    "--enable-rpath"
    "--disable-weak-threads"
    "--enable-extras"
    "--enable-icuio"
    "--disable-layout"
    #"--enable-layoutex"
    "--enable-tools"
    "--disable-tests"
    "--disable-samples"
  ];

  passthru = {
    srcVerification =
      let
        version = "58.2";
      in
      fetchurl {
        inherit (src) outputHashAlgo;
        urls =
          map (n: "${n}-${replaceChars ["."] ["_"] version}-src.tgz")
              (baseUrls version);
        md5Urls =
          map (n: "${n}-src-${replaceChars ["."] ["_"] version}.md5.asc")
              (baseUrls version);
        pgpKeyFingerprints = [
          # Steven R. Loomis
          "4C95 9C0F 547B D2D8 B783  5B17 AAA9 AE9C 0F0D E47D"
        ];
        outputHash = "2b0a4410153a9b20de0e20c7d8b66049a72aef244b53683d0d7521371683da0c";
        failEarly = true;
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
