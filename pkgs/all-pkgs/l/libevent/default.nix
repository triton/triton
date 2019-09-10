{ stdenv
, fetchurl

, openssl
, python3
}:

let
  version = "2.1.11";
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
    sha256 = "a65bac6202ea8c5609fd5c7e480e6d25de467ea1917c08290c521752f147283d";
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
    mv -v "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/*.so* "$dev"/lib

    mkdir -p "$lib"/nix-support
    touch "$lib"/nix-support/cc-wrapper-ignore
  '';

  outputs = [
    "dev"
    "lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.1.11-stable";
      inherit (src)
        outputHashAlgo;
      outputHash = "a65bac6202ea8c5609fd5c7e480e6d25de467ea1917c08290c521752f147283d";
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
