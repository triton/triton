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
, editline
, libseccomp
, libsodium
, openssl
, sqlite
, xz

, storeDir ? config.nix.storeDir or "/nix/store"
}:

let
  version = "2.2.1";
in
stdenv.mkDerivation rec {
  name = "nix-${version}";

  src = fetchurl {
    url = "https://nixos.org/releases/nix/${name}/${name}.tar.xz";
    multihash = "Qmc9q3Kiu1L9MQfpe5yboBDXjTov3Y6g91wUmVuFvDyYwC";
    hashOutput = false;
    sha256 = "85f8d3518060803e44e51b1a9ada1a39cea904b36a632ba1844043a0b63be515";
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
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0001-Configurable-fixed-output-paths.patch";
      sha256 = "e7b9455a8e8eff20780c253f0d126af83230c18b1afd54ef9daa28b0695ac803";
    })
    (fetchTritonPatch {
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0002-Remove-hardcoded-nixos.org-references.patch";
      sha256 = "a6848f3879d2f4d03e19c535929e56e2104fe151bc43c35663e1dd63315b4336";
    })
    (fetchTritonPatch {
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0003-Remove-nixpkgs-references.patch";
      sha256 = "34dc2c8f6abd4dbf4d649379b072a91a76f04ad828718be6abbde3c9caa9f1f2";
    })
    (fetchTritonPatch {
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0004-Build-dir-should-be-unique.patch";
      sha256 = "a0ce713b8a9b9d6ae74164ff2433e9b968ea3aca6cadbdd4dffdc28369b450c2";
    })
    (fetchTritonPatch {
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0005-Always-verify-TLS.patch";
      sha256 = "ae097620b84909d4b23d4930e67aa977ed9def87b4d056f723ea98d485c75422";
    })
    (fetchTritonPatch {
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0006-SSL_CERT_FILE-for-fixed-output.patch";
      sha256 = "e68e51d6a86db365545b3bd57327e80e19a6213f5b1077784e3db24a52876d18";
    })
    (fetchTritonPatch {
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0007-Output-base16-by-default.patch";
      sha256 = "a03c492a24dcf8e19896e2a841a3e18cc986dd80b8423f6ccb3fd504332e4d48";
    })
    (fetchTritonPatch {
      rev = "63a0d0dcce69a14141613a47670c857480332677";
      file = "n/nix/0008-builtin-fetchurl-Support-multiple-urls.patch";
      sha256 = "57b82b2673d93c4ed4a1436e62b22b25d6f976848198834f357475317f76afee";
    })
    (fetchTritonPatch {
      rev = "1d634638656d4da132a505a8f9d3a402c2cc1092";
      file = "n/nix/0009-hash-Default-to-base16-for-better-tool-support.patch";
      sha256 = "74a6e9652136083581a4a23ce6fd41c1c2f3996ee34e7b4d61853d594431e5ef";
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
