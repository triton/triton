{ stdenv
, buildEnv
, fetchTritonPatch
, fetchzip
, jam
, unzip

, libjpeg
, libpng
, libtiff
, openssl
, writeText
, xorg
, zlib
}:

let
  inputEnv = buildEnv {
    name = "argyllcms-inputs";
    paths = [
      libjpeg
      libpng
      libtiff
      openssl
      xorg.libX11
      xorg.libXau
      xorg.libXdmcp
      xorg.libXext
      xorg.libXinerama
      xorg.libXrandr
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXxf86vm
      xorg.randrproto
      xorg.renderproto
      xorg.scrnsaverproto
      xorg.xextproto
      xorg.xf86vidmodeproto
      xorg.xproto
      zlib
    ];
  };
in

stdenv.mkDerivation rec {
  name = "argyllcms-${version}";
  version = "1.8.3";

  src = fetchzip {
    version = 1;
    url = "http://www.argyllcms.com/Argyll_V${version}_src.zip";
    multihash = "QmQjL1Bejc5pXDNgoQzj9VUS2jZ8aMRKngGKNzMok8GtUV";
    purgeTimestamps = true;
    sha256 = "653503de46188a3d4f197c3844f11a68923c674bb2d826c5c505eaf5a4b790df";
    # The argyllcms web server doesn't like curl ...
    curlOpts = "--user-agent 'Mozilla/5.0'";
  };

  nativeBuildInputs = [
    jam
  ];

  buildInputs = [
    inputEnv
  ];

  patches = [
    (fetchTritonPatch {
      rev = "b664680703ddf56e54f54264001e13e39e6127f7";
      file = "argyllcms/argyllcms-1.8.3-gcc5.patch";
      sha256 = "de9b8a90e249070d457291c29ae3c732f89c51bc6f6296cb6aa7e800ba31a0e5";
    })
  ];

  preConfigure = ''
    # Remove bundled packages
    find . -name configure | grep -v xml | xargs -n 1 dirname | xargs rm -rf

    # Fix all of the usr references
    sed -i 's,/usr,${inputEnv},g' Jamtop
  '';

  NIX_LDFLAGS = "-L${inputEnv}";

  postInstall = /* Remove invalid file in bin/ */ ''
    rm -v $out/bin/License.txt
  '' + /* Install udev rule */ ''
    mkdir -pv $out/etc/udev/rules.d
    sed -i '/udev-acl/d' usb/55-Argyll.rules
    cp -v usb/55-Argyll.rules $out/etc/udev/rules.d/
  '' + /* Fix output directory */ ''
    mkdir -pv $out/share/
    mv -v $out/ref $out/share/argyllcms
  '';

  passthru = {
    srcVerification = fetchzip {
    version = 1;
      inherit (src)
        curlOpts
        outputHash
        outputHashAlgo
        purgeTimestamps
        urls;
      insecureHashOutput = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Color management system (compatible with ICC)";
    homepage = http://www.argyllcms.com;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
