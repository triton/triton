{ stdenv
, fetchFromGitHub
, fetchurl
, gnum4
, intel-gpu-tools
, lib
, python2

, libdrm
, libva
, libx11
, wayland
, xorgproto
}:

let
  version = "2.2.0";
in
stdenv.mkDerivation rec {
  name = "intel-vaapi-driver-${version}";

  src = fetchurl rec {
    urls = [
      ("https://github.com/intel/intel-vaapi-driver/releases/download/${version}/"
        + "${name}.tar.bz2")
      ("https://www.freedesktop.org/software/vaapi/releases/libva/"
        + "${name}.tar.bz2")
    ];
    hashOutput = false;
    sha256 = "e8a5f54694eb76aad42653b591030b8a53b1513144c09a80defb3d8d8c875c18";
  };

  nativeBuildInputs = [
    gnum4
    intel-gpu-tools
    python2
  ];

  buildInputs = [
    libdrm
    libva
    libx11
    wayland
    xorgproto
  ];

  configureFlags = [
    "--enable-x11"
    "--enable-wayland"
    "--enable-hybrid-codec"
  ];

  preInstall = ''
    installFlagsArray+=("LIBVA_DRIVERS_PATH=$out/lib/dri")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}.sha1sum") src.urls;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "VA-API user mode driver for Intel GEN Graphics family";
    homepage = https://github.com/01org/intel-vaapi-driver;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
