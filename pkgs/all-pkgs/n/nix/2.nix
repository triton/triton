{ stdenv
, config
, fetchTritonPatch
, fetchurl
, lib

, aws-sdk-cpp
, busybox
, boehm-gc
, brotli
, bzip2
, curl
, libseccomp
, libsodium
, openssl
, sqlite
, xz

, storeDir ? config.nix.storeDir or "/nix/store"
}:

stdenv.mkDerivation rec {
  name = "nix-2.0.4";

  src = fetchurl {
    url = "https://nixos.org/releases/nix/${name}/${name}.tar.xz";
    multihash = "Qmdf1xu1r8ifDjVkq5gNbxUBS2c3JpJ8XxqBe1BvVacN15";
    sha256 = "166540ff7b8bb41449586b67e5fc6ab9e25525f6724b6c6bcbfb0648fbd6496b";
  };

  buildInputs = [
    #aws-sdk-cpp
    boehm-gc
    brotli
    bzip2
    curl
    libseccomp
    libsodium
    openssl
    sqlite
    xz
  ];

  patches = [
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0001-Configurable-fixed-output-paths.patch";
      sha256 = "89694ae966850d5c926ca11fb7a19fcc63b8f517b752fa4f0e4384257573f17f";
    })
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0002-Remove-hardcoded-nixos.org-references.patch";
      sha256 = "4b8409841f5a5dc37590ed0623ca0af468ab477837bfcf27726bd7e0fa375727";
    })
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0003-Remove-nixpkgs-references.patch";
      sha256 = "d45ca713fb8dd3f0446823d404bc1d0703f1b147c96dd08e8fd1ac3ae837dd7f";
    })
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0004-Build-dir-should-be-unique.patch";
      sha256 = "42fdc7e4725b3258525f6d9ca0a6e894e151dd93893cad369ffc6fe75fcf3ce5";
    })
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0005-Always-verify-TLS.patch";
      sha256 = "cfce63abb5f90e11260bc3f91c25a78488893286d3198300c276bbebf74fec28";
    })
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0006-SSL_CERT_FILE-for-fixed-output.patch";
      sha256 = "30e696b2d12859213843f6b1a70eba0d19c435e8eb7b856e110765681acc20e9";
    })
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0007-Output-base64-by-default.patch";
      sha256 = "cb7c47fb97f9a3a7a1163a0f4a25799f328065ec94545fbb765673b1dce58838";
    })
    (fetchTritonPatch {
      rev = "1e9615b6dbafda8140c68c3a16c72c5d41f9c1bd";
      file = "n/nix/0008-Make-fixed-ouput-message-nicer.patch";
      sha256 = "1c84f6431342fa9c73db64250aeca3db58185f5d750a94b4ea5ef4a95a1119a1";
    })
  ];

  postPatch = ''
    # Make sure we have a working busybox sh
    '${busybox}'/bin/busybox sh --help 2>&1 | grep -q 'Usage: sh'
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    # Ideally this would be /var but this is standard
    # If we change this now we break the nix-daemon severely and
    # we can't use upstream binaries
    "--localstatedir=/nix/var"
    "--enable-gc"
    "--disable-init-state"
    "--with-store-dir=${storeDir}"
    "--with-sandbox-shell=${busybox}/bin/busybox"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = map (x: "${x}.sha256") src.urls;
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Package manager that makes packages reproducible";
    homepage = https://nixos.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
