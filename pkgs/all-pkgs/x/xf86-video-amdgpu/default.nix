{ stdenv
, fetchurl
, lib
, util-macros

, libdrm
, libpciaccess
, opengl-dummy
, systemd_lib
, xorg-server
, xorg
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xf86-video-amdgpu-19.0.0";

  src = fetchurl {
    url = "mirror://xorg/individual/driver/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "8836147d4755908ec9e192b7cc485fbc2ce7706de33f7bea515294d3ba4c4f51";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libdrm
    libpciaccess
    opengl-dummy
    systemd_lib
    xorg-server
    xorgproto
  ];

  configureFlags = [
    "--enable-udev"
    "--enable-glamor"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Michel Daenzer
          "B09F AF35 BE91 4521 9809  5114 5A81 AF8E 6ADB B200"
        ];
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "AMD Xorg video driver";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
