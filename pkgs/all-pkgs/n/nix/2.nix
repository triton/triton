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
      rev = "87c8a7e6ef87849eb89909dce74e0c83de571408";
      file = "n/nix/0001-Include-ca-certs-in-fixed-outputs.patch";
      sha256 = "30b1302bd4c32ed08f7bcf1ca7e5111bfa735cee77560a08ebd082d3245f736f";
    })
    (fetchTritonPatch {
      rev = "87c8a7e6ef87849eb89909dce74e0c83de571408";
      file = "n/nix/0002-Remove-nixpkgs-references.patch";
      sha256 = "00dc9899fb324924529245ab7ae37deb1528f45592b7364626cac5ee68d4deab";
    })
    (fetchTritonPatch {
      rev = "87c8a7e6ef87849eb89909dce74e0c83de571408";
      file = "n/nix/0003-Remove-hardcoded-nixos.org-references.patch";
      sha256 = "af0134f875ed431637184e58468072e1238d59a7aee87af6a437d53bc9a740de";
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
