{ stdenv
, fetchurl
, lib
, ninja
, python2

, c-ares
, http-parser
, icu
, libuv
, nghttp2_lib
, openssl_1-0-2
, openssl
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
      version = "6.15.1";
      sha256 = "c3bde58a904b5000a88fbad3de630d432693bc6d9d6fec60a5a19e68498129c2";
    };
    "8" = {
      version = "8.14.0";
      sha256 = "8ce252913c9f6aaa9871f2d9661b6e54858dae2f0064bd3c624676edb09083c4";
    };
    "10" = {
      version = "10.14.1";
      sha256 = "3def67bf1679e0606af4eb3d7ce3c0a3fe4548f2d0a87320d43a30e2207ab034";
    };
    "11" = {
      version = "11.4.0";
      sha256 = "b7261dd70dcac28f208e8f444dd91dc919e7ec2f5a0aeba9416eb07165a0d684";
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
    python2
  ];

  buildInputs = [
    c-ares
    http-parser
    icu
    libuv
  ] ++ optionals (versionAtLeast source.version "8.0.0") [
    nghttp2_lib
  ] ++ (
    if versionAtLeast source.version "8.0.0" then [
      openssl
    ] else [
      openssl_1-0-2
    ]
  ) ++ [
    zlib
  ];

  postPatch = ''
    patchShebangs configure
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
    ${python2.interpreter} tools/install.py

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
      fullOpts = {
        sha256Urls = map (n: "${n}/SHASUMS256.txt.asc") dirUrls;
        # https://github.com/nodejs/node#release-team
        pgpKeyFingerprints = [
          # Beth Griggs
          "4ED7 78F5 39E3 634C 779C  87C6 D706 2848 A1AB 005C"
          # Colin Ihrig
          "94AE 3667 5C46 4D64 BAFA  68DD 7434 390B DBE9 B9C5"
          # Evan Lucas
          "B9AE 9905 FFD7 803F 2571  4661 B63B 535A 4C20 6CA9"
          # Gibson Fahnestock
          "7798 4A98 6EBC 2AA7 86BC  0F66 B01F BB92 821C 587A"
          # James M Snell
          "71DC FD28 4A79 C3B3 8668  286B C97E C7A0 7EDE 3FC1"
          # Jeremiah Senkpiel
          "FD3A 5288 F042 B685 0C66  B31F 09FE 4473 4EB7 990E"
          # Myles Borins
          "C4F0 DFFF 4E8C 1A82 3640  9D08 E73B C641 CC11 F4C8"
          # Rod Vagg
          "DD8F 2338 BAE7 501E 3DD5  AC78 C273 792F 7D83 545D"
          # Ruben Bridgewater
          "A48C 2BEE 680E 8416 32CD  4E44 F074 96B3 EB3C 1762"
        ];
      };
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
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
