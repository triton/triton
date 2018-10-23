{ stdenv
, config
, fetchTritonPatch
, fetchurl
, lib

, aws-sdk-cpp
, busybox
, boehm-gc
, boost
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

let
  version = "2.1.3";
in
stdenv.mkDerivation rec {
  name = "nix-${version}";

  src = fetchurl {
    url = "https://nixos.org/releases/nix/${name}/${name}.tar.xz";
    multihash = "QmP8tLiMweiCRV1bPYU5MGbca3dJEn3P3x8GLHxYYgXizs";
    hashOutput = false;
    sha256 = "5d22dad058d5c800d65a115f919da22938c50dd6ba98c5e3a183172d149840a4";
  };

  buildInputs = [
    #aws-sdk-cpp
    boehm-gc
    boost
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
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0001-Configurable-fixed-output-paths.patch";
      sha256 = "887c35d5b46b61c8368d8ae66d621759ac6ece368063640db30b8f503bca21a5";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0002-Remove-hardcoded-nixos.org-references.patch";
      sha256 = "ac2e60243c32f9a273b36319726172a5bf9284e4e25a70bcd0d7c9408014ab44";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0003-Remove-nixpkgs-references.patch";
      sha256 = "a3e907634bdd727a7b425f84b05b8eee1d4557c6bb93fab44db5868cf50ec4bb";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0004-Build-dir-should-be-unique.patch";
      sha256 = "44ed78276bdc81a627c9b87462231c4638a59523f9ee7d8daf9fbf312e8de9f5";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0005-Always-verify-TLS.patch";
      sha256 = "7e4b5c383a3a441418c611e4d7d4a888f69265aafafc2a669a959f0333cb0f33";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0006-SSL_CERT_FILE-for-fixed-output.patch";
      sha256 = "43daa4a29fb7c06de423e298a2803ffd890fb7edd8d16805c4bc5408770a0cfe";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0007-Output-base16-by-default.patch";
      sha256 = "ae2e6ce7c0ac99ec805e93114904df9978fb72fb51c1b87715327d02df8cbdb7";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0008-Make-fixed-ouput-message-nicer.patch";
      sha256 = "69d9b8052afc52a0946197f2d85b98556bfba16bd77db521e1012bf17236b9c4";
    })
    (fetchTritonPatch {
      rev = "5aa406cd6b01511e34fdca6682b8f9e9375b704e";
      file = "n/nix/0009-builtin-fetchurl-Support-multiple-urls.patch";
      sha256 = "d03182cbd8623cd70596d5f0d1b317110599395e951b131650221eac1d4f1bef";
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
    "--with-store-dir=${storeDir}"
    "--with-sandbox-shell=${busybox}/bin/busybox"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  passthru = {
    inherit
      version;
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = map (x: "${x}.sha256") src.urls;
      };
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
