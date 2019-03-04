{ stdenv
, fetchurl

, openssl
, python3
}:

let
  version = "2.1.9";
  channel = "beta";

  tarballUrls = version: [
    "https://github.com/libevent/libevent/releases/download/release-${version}/libevent-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libevent-${version}";

  src = fetchurl {
    urls = tarballUrls "${version}-${channel}";
    hashOutput = false;
    sha256 = "eeb4c6eb2c4021e22d6278cdcd02815470243ed81077be0cbd0f233fa6fc07e8";
  };

  buildInputs = [
    openssl
  ];

  patchPhase = ''
    grep -q '^#!/usr/bin/env python$' event_rpcgen.py
    sed -i 's,^#!/usr/bin/env python$,#!${python3.interpreter},g' event_rpcgen.py
  '';

  configureFlags = [
    "--enable-gcc-hardening"
    "--disable-samples"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.1.9-beta";
      inherit (src)
        outputHashAlgo;
      outputHash = "eeb4c6eb2c4021e22d6278cdcd02815470243ed81077be0cbd0f233fa6fc07e8";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprints = [
          "9E3A C83A 2797 4B84 D1B3  401D B860 8684 8EF8 686D"
        ];
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Event notification library";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
