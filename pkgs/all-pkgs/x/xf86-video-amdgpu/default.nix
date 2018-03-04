{ stdenv
, fetchurl
, lib
, util-macros

#, glamoregl
, libdrm
, opengl-dummy
, systemd_lib
, xorg-server
, xorg
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xf86-video-amdgpu-18.0.0";

  src = fetchurl {
    url = "mirror://xorg/individual/driver/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "e909b9707d2562dfc36d8075a8cbddbc93901aaa8f2522d9a429c3fc5ad66d94";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    xorg.glamoregl
    libdrm
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
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Michel Daenzer
        "B09F AF35 BE91 4521 9809  5114 5A81 AF8E 6ADB B200"
      ];
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
