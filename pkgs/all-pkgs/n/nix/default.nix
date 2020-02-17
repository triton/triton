{ stdenv
, config
, fetchTritonPatch
, fetchurl
, lib

, aws-sdk-cpp
, busybox_shell
, boehm-gc
, boost
, brotli
, bzip2
, curl
, editline
, libseccomp
, libsodium
, openssl
, sqlite
, xz

, storeDir ? config.nix.storeDir or "/nix/store"
}:

let
  version = "2.3.2";
in
stdenv.mkDerivation rec {
  name = "nix-${version}";

  src = fetchurl {
    url = "https://nixos.org/releases/nix/${name}/${name}.tar.xz";
    multihash = "QmZhaZRefjJQMibpoqPviszUNjbTQ4MuGDtGnnHyaLgP6Q";
    hashOutput = false;
    sha256 = "9fea4b52db0b296dcf05d36f7ecad9f48396af3a682bb21e31f8d04c469beef8";
  };

  buildInputs = [
    #aws-sdk-cpp
    boehm-gc
    boost
    brotli
    bzip2
    curl
    editline
    libseccomp
    libsodium
    openssl
    sqlite
    xz
  ];

  patches = [
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0001-Configurable-fixed-output-paths.patch";
      sha256 = "6a7da3cb3540555aa6ee27e44c2d66bd6dbdd34978bd577252d7c1ac0b8284e1";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0002-Remove-hardcoded-nixos.org-references.patch";
      sha256 = "e0c8426b6f4bac4db3c377bd305c704a60214adbc29720f1db4d3dfcc6fe47ab";
    })
    (fetchTritonPatch {
      rev = "a4d91a2021319a6c00d6fc8e9c8407bf3acbe160";
      file = "n/nix/0003-Remove-nixpkgs-references.patch";
      sha256 = "9a4fdc251e5d3b1ec650497e5bb125a46c7f54fafa5302df1c57cbbe354456a5";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0004-Build-dir-should-be-unique.patch";
      sha256 = "4f727034727b24762796b76d272532d00d342c051cd6d4817c5923cfafd1ff44";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0005-Always-verify-TLS.patch";
      sha256 = "2fa541bfa2817a4253a03d5a81b2ad5570f8a3f36efb8c3ba3ac006a393e0fdc";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0006-SSL_CERT_FILE-for-fixed-output.patch";
      sha256 = "96cb0797a2a7849239f9a6e081850d405a4d4899af9ed03705aecfe6eaad79b2";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0007-Output-base16-by-default.patch";
      sha256 = "f79e5e6a7528c3f7ec7b5e3377e4b73e4a37ffb9bd0c35bd43a42c0637d5296e";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0008-builtin-fetchurl-Support-multiple-urls.patch";
      sha256 = "a0ca0deba8c6a4912d67426d73a42efbf791324bf7c6d4522e06bd5ccdbf73da";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0009-hash-Default-to-base16-for-better-tool-support.patch";
      sha256 = "08e226045d69152c68599ee8ad2c24e5156eee15ea19125b2828a8739c68e19a";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0010-build-Support-for-any-system-type.patch";
      sha256 = "f8913541ed9b367f065105860805b3ee6b43a17571c0d732c52a8878d599353c";
    })
    (fetchTritonPatch {
      rev = "093c19ef10a6771b9f8f08501bbaa1bb90f5b322";
      file = "n/nix/0011-build-Support-optional-chroot-builds.patch";
      sha256 = "bec8496990ba7f5d89d25c56592063e90aef193d85311b22a3ca093069907bf8";
    })
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    # Ideally this would be /var but this is standard
    # If we change this now we break the nix-daemon severely and
    # we can't use upstream binaries
    "--localstatedir=/nix/var"
    "--enable-gc"
    "--with-store-dir=${storeDir}"
    "--with-sandbox-shell=${busybox_shell}/bin/busybox"
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
