{ stdenv
, fetchurl
, lib
, util-macros

, damageproto
, fixesproto
, fontsproto
#, glamoregl
, libdrm
, opengl-dummy
, randrproto
, renderproto
, systemd_lib
, videoproto
, xextproto
, xf86driproto
, xorg-server
, xorg
, xproto
}:

stdenv.mkDerivation rec {
  name = "xf86-video-amdgpu-1.4.0";

  src = fetchurl {
    url = "mirror://xorg/individual/driver/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f8cac4bf3dd795b93cc337e5c0c62618026f597890a10d996f09c73eb88ba67c";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    damageproto
    fixesproto
    fontsproto
    xorg.glamoregl
    libdrm
    opengl-dummy
    randrproto
    renderproto
    systemd_lib
    videoproto
    xextproto
    xf86driproto
    xorg-server
    xproto
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
