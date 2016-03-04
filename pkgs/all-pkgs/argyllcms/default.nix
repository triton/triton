{ stdenv
, buildEnv
, fetchzip
, jam
, unzip

, libtiff
, libjpeg
, libpng
, openssl
, writeText
, xorg
, zlib
}:

let
  inputEnv = buildEnv {
    name = "argyllcms-inputs";
    paths = [
      libtiff
      libjpeg
      libpng
      openssl
      xorg.libX11
      xorg.libXxf86vm
      xorg.libXrandr
      xorg.libXinerama
      xorg.libXext
      xorg.xf86vidmodeproto
      xorg.xextproto
      xorg.randrproto
      xorg.libXrender
      xorg.scrnsaverproto
      xorg.renderproto
      xorg.libXScrnSaver
      xorg.libXdmcp
      xorg.libXau
      xorg.xproto
      zlib
    ];
  };
in

stdenv.mkDerivation rec {
  name = "argyllcms-${version}";
  version = "1.8.3";

  src = fetchzip {
    url = "http://www.argyllcms.com/Argyll_V${version}_src.zip";
    sha256 = "00ggh47qzb3xyl8rnppwxa6j113lr38aiwvsfyxwgs51aqmvq7bd";
    # The argyllcms web server doesn't like curl ...
    curlOpts = "--user-agent 'Mozilla/5.0'";
  };

  nativeBuildInputs = [
    jam
  ];

  buildInputs = [
    inputEnv
  ];

  NIX_LDFLAGS = "-L${inputEnv}";

  patches = [
    ./gcc5.patch
  ];

  preConfigure = ''
    # Remove bundled packages
    find . -name configure | grep -v xml | xargs -n 1 dirname | xargs rm -rf
    
    # Fix all of the usr references
    sed -i 's,/usr,${inputEnv},g' Jamtop
  '';

  buildPhase = ''
    jam DESTDIR="/" PREFIX="$out" -j $NIX_BUILD_CORES -q -fJambase
  '';

  installPhase = ''
    jam DESTDIR="/" PREFIX="$out" -j $NIX_BUILD_CORES -q -fJambase install
    
    rm $out/bin/License.txt
    mkdir -p $out/etc/udev/rules.d
    sed -i '/udev-acl/d' usb/55-Argyll.rules
    cp -v usb/55-Argyll.rules $out/etc/udev/rules.d/
    mkdir -p $out/share/
    mv $out/ref $out/share/argyllcms
  '';

  meta = with stdenv.lib; {
    homepage = http://www.argyllcms.com;
    description = "Color management system (compatible with ICC)";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
