{ stdenv
, fetchurl
, fetchTritonPatch

, linux-headers
, bootstrap ? false
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  current-system = "/run/current-system";

  version = "2.27";
in
stdenv.mkDerivation rec {
  name = "glibc-${version}";

  src = fetchurl {
    url = "mirror://gnu/glibc/glibc-${version}.tar.xz";
    hashOutput = false;
    sha256 = "5172de54318ec0b7f2735e5a91d908afe1c9ca291fec16b5374d9faadfc1fc72";
  };

  patches = [
    (fetchTritonPatch {
      rev = "e6a0fee9782da2e14fed014ef58451f1b47c7d61";
      file = "g/glibc/0000-upstream-fixes.patch";
      sha256 = "54b5681830a6bd48797a95a0b37bf1b22de2b025af71b927c2d9e181bd28a43e";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0001-dont-use-system-ld-so-cache.patch";
      sha256 = "521131496506a6702f5de3235b6e806849c1487e70d2516eaf9a60cefc95b529";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0002-dont-use-system-ld-so-preload.patch";
      sha256 = "01f4c42101e5e6ade87f71c830345a266e72f2ed97f1639581d4cdf6a880499f";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0003-rpcgen-use-cpp-in-path.patch";
      sha256 = "4f7f58b96098b0ae3e2945481f9007c719c5f56704724a4d36074b76e29bee81";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0004-ncsd-use-out-path-instead-of-datetime-for-versioning.patch";
      sha256 = "035c181b4b5dd9757324d1984e78c2a18adde33694ac8254692921c193ae5a87";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0005-fix-path-attribute-in-getconf.patch";
      sha256 = "22800d61e8985f5e035561405b9ae61128dea1709840b3673712c3d7867bf7c7";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0006-fix-nss-module-path.patch";
      sha256 = "5144f41274b92c6c97e59a2a0d3ff6fc311592a0064de6500fdfe7dc8283dcf9";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0007-fortify-source-error.patch";
      sha256 = "0042365c98409e74958fe3ba2590e98fe28693eabe90b88c8cb5c19374f73bbd";
    })
    (fetchTritonPatch {
      rev = "5291f29cba8415e1f58e811d77957725ddde5c11";
      file = "g/glibc/0008-nix-locale-archive.patch";
      sha256 = "079f4eb8f051c20291ea8bc133c582bf4e9c743948f5052069cb40fe776eeb79";
    })
  ];

  patchVars = {
    "NIX_LD_SO_CONF" = "${current-system}/etc/ld.so.conf";
    "NIX_LD_SO_CACHE" = "${current-system}/etc/ld.so.cache";
    "NIX_LD_SO_PRELOAD" = "${current-system}/etc/ld.so.preload";
    "NIX_SW_BIN" = "${current-system}/sw/bin";
    "NIX_NSS_LIB" = "${current-system}/runtime/${stdenv.targetSystem}/nss/lib";
  };

  prePatch = ''
    patchVars["NIX_OUT"]="$out"
  '';

  /*postPatch = ''
    # nscd needs libgcc, and we don't want it dynamically linked
    # because we don't want it to depend on bootstrap-tools libs.
    echo "LDFLAGS-nscd += -static-libgcc" >> nscd/Makefile
  '';*/

  preConfigure = ''
    configureFlagsArray+=(
      # We always want to force cross compiling since this is the first stage
      # of our system build
      "--host=${stdenv.cc.platformTuples."${stdenv.targetSystem}"}"
      "--build=$(scripts/config.guess)"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--localedir=/run/current-system/sw/share/locale"
    "--enable-shared"
    "--enable-profile"
    "--enable-timezone-tools"
    "--enable-stackguard-randomization"
    "--enable-lock-elision"
    "--enable-add-ons"
    "--enable-bind-now"
    "--enable-stack-protector=strong"
    "--enable-kernel=${linux-headers.channel}"
    "--disable-werror"
    "--enable-multi-arch"
    "--disable-nss-crypt"  # We can't depend on nss here
    "--disable-systemtap"
    "--enable-build-nscd"
    "--enable-pt_chown"
    "--without-gd"
    "--with-headers=${linux-headers}/include"
  ];

  # The build system should enable the stack protector or fortifier
  # when possible. It cannot be enabled globally without breaking the build
  ccStackProtector = false;
  ccFortifySource = false;

  # Glibc should always have static libraries
  disableStatic = false;

  # Glibc should not pull in paths from another libc
  NIX_ADD_LIBC_FLAGS = false;

  # Glibc cannot have itself in its RPATH.
  NIX_DONT_SET_RPATH = true;
  NIX_NO_SELF_RPATH = true;
  NIX_CFLAGS_LINK = false;
  NIX_LDFLAGS_BEFORE = false;
  patchELFAddRpath = false;

  # Make sure we don't use the autodetected shell from the
  # bootstrap
  BASH_SHELL = "/bin/sh";
  dontPatchShebangs = true;

  # We shouldn't ever maintain references from bootstrap tooling
  allowedReferences = [
    linux-headers
  ];

  passthru = {
    inherit version;
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
