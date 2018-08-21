{ stdenv
, buildEnv
, fetchTritonPatch
, fetchzip
, jam
, lib
, unzip

, libjpeg
, libpng
, libtiff
, libx11
, libxau
, libxdmcp
, libxext
, libxinerama
, libxrandr
, libxrender
, libxscrnsaver
, openssl
, writeText
, xorg
, xorgproto
, zlib
}:

let
  inputEnv = buildEnv {
    name = "argyllcms-inputs";
    paths = [
      libjpeg
      libpng
      libtiff
      libx11
      libxau
      libxdmcp
      libxext
      libxinerama
      libxrandr
      libxrender
      libxscrnsaver
      xorg.libXxf86vm
      openssl
      xorgproto
      zlib
    ];
  };
  version = "2.0.0";
in
stdenv.mkDerivation rec {
  name = "argyllcms-${version}";

  src = fetchzip {
    version = 6;
    url = "http://www.argyllcms.com/Argyll_V${version}_src.zip";
    multihash = "QmUuxRhYwfsaRrqXDfBoeYmPWfbo6XR5H5D41CNL27JFiN";
    purgeTimestamps = true;
    sha256 = "fa171e7974e195477d1447dc59cd5eeb0c923170c1cbb057f6e926c26eb0fda6";
    # The argyllcms web server doesn't like curl ...
    fullOpts = {
      curlOpts = "--user-agent 'Mozilla/5.0'";
    };
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
      inherit (src)
        version
        urls
        outputHash
        outputHashAlgo
        fullOpts
        purgeTimestamps;
      insecureHashOutput = true;
    };
  };

  meta = with lib; {
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
