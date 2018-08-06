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
      rev = "6755e747916ce40339cda63422520813d1c2ed4f";
      file = "n/nix/0001-Include-ca-certs-in-fixed-outputs.patch";
      sha256 = "30b1302bd4c32ed08f7bcf1ca7e5111bfa735cee77560a08ebd082d3245f736f";
    })
    (fetchTritonPatch {
      rev = "6755e747916ce40339cda63422520813d1c2ed4f";
      file = "n/nix/0002-Remove-hardcoded-nixos.org-references.patch";
      sha256 = "38d2d06ff311e40ce31d410565b25b871d2865e82039a1c49dd854bb3bc762cb";
    })
    (fetchTritonPatch {
      rev = "6755e747916ce40339cda63422520813d1c2ed4f";
      file = "n/nix/0003-Remove-nixpkgs-references.patch";
      sha256 = "b1906ca56a149b54297000e3ce17494950817eb939d4aa772a1f05c9e55c10f9";
    })
  ];

  postPatch = ''
    # Make sure we have a working busybox sh
    '${busybox}'/bin/busybox sh --help 2>&1 | grep -q 'Usage: sh'
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
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
