{ stdenv
, fetchurl
, lib
, ninja
, python

, c-ares
, http-parser
, icu
, libuv
, nghttp2_lib
, openssl_1-0-2
, openssl_1-1-0
, zlib

, channel
}:

let
  inherit (lib)
    optionals
    optionalString
    versionAtLeast
    versionOlder;

  sources = {
    "6" = {
      version = "6.14.2";
      sha256 = "b3a534b2ad5e96c6ff67f3a1356b94f7a28ef118eb1d420b314fe5aafe6d62d1";
    };
    "8" = {
      version = "8.11.1";
      sha256 = "40a6eb51ea37fafcf0cfb58786b15b99152bec672cccf861c14d1cca0ad4758a";
    };
    "10" = {
      version = "10.1.0";
      sha256 = "a6671055b4085795f5427f42349eae14c5dfe7692c923dffb7635b9f62cc7902";
    };
  };

  source = sources."${channel}";

  dirUrls = [
    "https://nodejs.org/dist/v${source.version}"
  ];
in
stdenv.mkDerivation rec {
  name = "nodejs-${source.version}";

  src = fetchurl {
    urls = map (n: "${n}/node-v${source.version}.tar.xz") dirUrls;
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = optionals (versionAtLeast source.version "7.0.0") [
    ninja
  ] ++ [
    python
  ];

  buildInputs = [
    c-ares
    http-parser
    icu
    libuv
  ] ++ optionals (versionAtLeast source.version "8.0.0") [
    nghttp2_lib
  ] ++ (
    if versionAtLeast source.version "10.0.0" then [
      openssl_1-1-0
    ] else [
      openssl_1-0-2
    ]
  ) ++ [
    zlib
  ];

  postPatch = ''
    patchShebangs configure
  '' + optionalString ((versionOlder source.version "10.0.0") &&
       (versionAtLeast source.version "7.0.0"))
    /* Fix compat with ICU 61+, Remove if fixed upstream
       https://github.com/nodejs/node/commit/b8f47b27571f8d763f811f017be3fb37d466c4fc */ ''
    sed -i src/inspector_io.cc \
      -e 's/UnicodeString/icu::UnicodeString/g' \
      -e 's/CheckedArrayByteSink/icu::CheckedArrayByteSink/g' \
      -e 's/StringPiece/icu::StringPiece/g'
    sed -i src/node_i18n.cc \
      -e 's/TimeZone::getTZDataVersion/icu::TimeZone::getTZDataVersion/g'
    sed -i tools/icu/iculslocs.cc \
      -e 's/CharString/icu::CharString/g' \
      -e 's/LocalUResourceBundlePointer/icu::LocalUResourceBundlePointer/g'
  '';

  configureFlags = optionals (versionAtLeast source.version "7.0.0") [
    "--ninja"
  ] ++ [
    "--shared-http-parser"
    "--shared-libuv"
  ] ++ optionals (versionAtLeast source.version "8.0.0") [
    "--shared-nghttp2"
  ] ++ [
    "--shared-openssl"
    "--shared-zlib"
    "--shared-cares"
    "--with-intl=system-icu"
  ];

  disableStatic = false;

  setupHook = ./setup-hook.sh;

  preBuild = optionalString (versionAtLeast source.version "7.0.0") ''
    # Ninja build directory
    makeFlagsArray+=('-C' 'out/Release/')
  '';

  installPhase = ''
    # Install must be run manually when using ninja setup hook
    sed -i tools/install.py \
      -e "s,/usr/local,$out,"
    ${python.interpreter} tools/install.py

    # Fix scripts like npm that depend on node
    export PATH="$out/bin:$PATH"
    command -v node
    while read file; do
      patchShebangs "$file"
    done < <(grep -r '#!/usr/bin/env' $out | awk -F: '{print $1}')
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      sha256Urls = map (n: "${n}/SHASUMS256.txt.asc") dirUrls;
      #pgpsigSha256Urls = map (n: "${n}.asc") sha256Urls;
      # https://github.com/nodejs/node#release-team
      pgpKeyFingerprints = [
        # Colin Ihrig
        "94AE 3667 5C46 4D64 BAFA  68DD 7434 390B DBE9 B9C5"
        # Evan Lucas
        "B9AE 9905 FFD7 803F 2571  4661 B63B 535A 4C20 6CA9"
        # Gibson Fahnestock
        "7798 4A98 6EBC 2AA7 86BC  0F66 B01F BB92 821C 587A"
        # Italo A. Casas
        "5673 0D54 0102 8683 275B  D23C 23EF EFE9 3C4C FFFE"
        # James M Snell
        "71DC FD28 4A79 C3B3 8668  286B C97E C7A0 7EDE 3FC1"
        # Jeremiah Senkpiel
        "FD3A 5288 F042 B685 0C66  B31F 09FE 4473 4EB7 990E"
        # Myles Borins
        "C4F0 DFFF 4E8C 1A82 3640  9D08 E73B C641 CC11 F4C8"
        # Rod Vagg
        "DD8F 2338 BAE7 501E 3DD5  AC78 C273 792F 7D83 545D"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
