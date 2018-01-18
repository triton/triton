{ stdenv
, fetchurl
, lib

, boost
, gdk-pixbuf
, glib
, libjpeg
, libxml2
}:

let
  version = "0.1.2";
in
stdenv.mkDerivation rec {
  name = "libopenraw-${version}";

  src = fetchurl {
    url = "https://libopenraw.freedesktop.org/download/${name}.tar.bz2";
    multihash = "QmXSnWJQFb5cLNYiSqYH9GhFf8TCVY3VmYbQRDAtBZifoq";
    hashOutput = false;
    sha256 = "d15e86141add6a652f316ab8884895d8399d37c17510b34f61e266f906a99683";
  };

  nativeBuildInputs = [

  ];

  buildInputs = [
    boost
    gdk-pixbuf
    glib
    libjpeg
    libxml2
  ];

  postPatch = /* Fix loader hardcoded install path to not use gdk-pixbuf prefix */ ''
    sed -i configure{,.ac} \
      -e "s,GDK_PIXBUF_DIR=.*,GDK_PIXBUF_DIR=$out/${gdk-pixbuf.loadersCachePath}/loaders,"
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-static-boost"
    "--enable-gnome"
    #"--enable-asan"  # Clang
    "--without-darwinports"  # Darwin
    "--without-fink"  # Darwin
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      # Hubert Figuiere
      pgpKeyFingerprint = "6C44 DB3E 0BF3 EAF5 B433  239A 5FEE 05E6 A56E 15A3";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "RAW camerafile decoding library";
    homepage = https://libopenraw.freedesktop.org;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
