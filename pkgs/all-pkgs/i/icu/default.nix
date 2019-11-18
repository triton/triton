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

  version = "65.1";
in
stdenv.mkDerivation rec {
  name = "icu4c-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "53e37466b3d6d6d01ead029e3567d873a43a5d1c668ed2278e253b683136d948";
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

  postInstall = ''
    mkdir -p "$lib"/lib "$libicudata"/lib
    mv -v "$dev"/lib*/libicudata.so* "$libicudata"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$libicudata"/lib/* "$lib"/lib/* "$dev"/lib

    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"
    mv -v "$dev"/sbin/* "$bin"/bin
    rmdir "$dev"/sbin
    mkdir -p "$dev"/bin
    mv -v "$bin"/bin/icu-config "$dev"/bin
  '';

  postFixup = ''
    rm -rf "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "libicudata"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "65.1";
      inherit (src) outputHashAlgo;
      outputHash = "53e37466b3d6d6d01ead029e3567d873a43a5d1c668ed2278e253b683136d948";
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
