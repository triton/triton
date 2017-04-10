{ stdenv
, fetchurl
, lib

, libpthread-stubs
, xorg
}:

stdenv.mkDerivation rec {
  name = "libdrm-2.4.79";

  src = fetchurl {
    url = "https://dri.freedesktop.org/libdrm/${name}.tar.bz2";
    multihash = "QmbWfoozsJmRVZTBcogrNSyfnej46tAMqL7K9RbGZzTS4V";
    hashOutput = false;
    sha256 = "c6aaf319293bce38023e9a637471b0f45c93c807d2a279060d741fc7a2e5b197";
  };

  buildInputs = [
    libpthread-stubs
    xorg.libpciaccess
  ];

  configureFlags = [
    "--enable-largefile"
    "--disable-udev"  # Udev is only used by tests.
    "--enable-libkms"
    "--enable-intel"
    "--enable-radeon"
    "--enable-amdgpu"
    "--enable-nouveau"
    "--enable-omap-experimental-api"
    "--enable-exynos-experimental-api"
    "--enable-freedreno"
    "--disable-freedreno-kgsl"
    "--enable-tegra-experimental-api"
    "--disable-install-test-programs"
    "--disable-cairo-tests"
    "--disable-manpages"
    "--disable-valgrind"
    #"--with-xsltproc"
    #"--with-kernel-source"
  ];

  # This breaks libraries talking to the dri interfaces
  bindnow = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Emil Velikov
        "8703 B670 0E7E E06D 7A39  B8D6 EDAE 37B0 2CEB 490D"
        # Kenneth Graunke
        "E8EB 5B34 081C E1EE A26E  FE19 5B5B DA07 1D49 CC38"
        # Eric Anholt
        "FC9B AE14 35A9 F7F6 64B8  2057 B5D6 2936 D1FC 9EE8"
        # Rob Clark
        "D628 5B5E 8992 99F3 DA74  6184 191C 9B90 5522 B045"
        # Robert Bragg
        "C20F 5C44 90D7 D64B 4C9A  0999 8CD1 DF55 2975 297B"
        # David Airlie
        "10A6 D91D A1B0 5BD2 9F6D  EBAC 0C74 F359 79C4 86BE"
        # Marek Olšák
        "CD47 C534 1A37 5F33 BEF7  BAFA FDD1 5D5A CEF0 F2B1"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Library for accessing the kernel's Direct Rendering Manager";
    homepage = http://dri.freedesktop.org/libdrm/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
