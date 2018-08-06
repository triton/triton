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
      rev = "9f8cc90aa574e0259d8d44fb57ce6a0a8e299ccc";
      file = "n/nix/0001-Configurable-fixed-output-paths.patch";
      sha256 = "1e324269d592e10ae2e72d4b1efd490c82cbfdcb9d1f9cb5cec3296818fe49f8";
    })
    (fetchTritonPatch {
      rev = "9f8cc90aa574e0259d8d44fb57ce6a0a8e299ccc";
      file = "n/nix/0002-Remove-hardcoded-nixos.org-references.patch";
      sha256 = "88888e6d71c9fa07e7bdebbffb1d82c9e2ef1cc095de560ea44d20d6cca2e580";
    })
    (fetchTritonPatch {
      rev = "9f8cc90aa574e0259d8d44fb57ce6a0a8e299ccc";
      file = "n/nix/0003-Remove-nixpkgs-references.patch";
      sha256 = "1c28d29385b3dfbf840b99efba9fe90ed6842371fc112b8f3602d36f7e904852";
    })
    (fetchTritonPatch {
      rev = "9f8cc90aa574e0259d8d44fb57ce6a0a8e299ccc";
      file = "n/nix/0004-Build-dir-should-be-unique.patch";
      sha256 = "6e3ba2beaacf59ed6e2120b15bf833826596f0729c9568e0e36e24a3a73561d0";
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
