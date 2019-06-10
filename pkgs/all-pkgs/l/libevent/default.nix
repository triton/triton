{ stdenv
, fetchurl

, openssl
, python3
}:

let
  version = "2.1.10";
  channel = "stable";

  tarballUrls = version: [
    "https://github.com/libevent/libevent/releases/download/release-${version}/libevent-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libevent-${version}";

  src = fetchurl {
    urls = tarballUrls "${version}-${channel}";
    hashOutput = false;
    sha256 = "e864af41a336bb11dab1a23f32993afe963c1f69618bd9292b89ecf6904845b0";
  };

  buildInputs = [
    openssl
    python3  # For event_rpcgen.py
  ];

  preConfigure = ''
    prefix="$dev"
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
  '';

  configureFlags = [
    "--enable-gcc-hardening"
    "--disable-samples"
  ];

  disableStatic = false;

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib/*.so* "$lib"/lib

    mkdir -p "$dev"/nix-support
    echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
  '';

  outputs = [
    "dev"
    "lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.1.10-stable";
      inherit (src)
        outputHashAlgo;
      outputHash = "e864af41a336bb11dab1a23f32993afe963c1f69618bd9292b89ecf6904845b0";
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
