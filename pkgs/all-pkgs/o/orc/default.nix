{ stdenv
, fetchurl
, lib

, xz
}:

stdenv.mkDerivation rec {
  name = "orc-0.4.27";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/orc/${name}.tar.xz";
    hashOutput = false;
    sha256 = "51e53e58fc8158e5986a1f1a49a6d970c5b16493841cf7b9de2c2bde7ce36b93";
  };

  buildInputs = [
    xz
  ];

  postPatch = /* Completely disable examples */ ''
    sed -i Makefile.{am,in} \
      -e '/SUBDIRS/ s:examples::'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    #"--enable-backend=all"
    "--enable-Bsymbolic"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256sum") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Sebastian Dröge
        "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5"
        # Tim-Philipp Müller
        "D637 032E 45B8 C658 5B94  5656 5D2E EE6F 6F34 9D7C"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "The Oil Runtime Compiler, a JIT compiler for array operations";
    homepage = http://gstreamer.freedesktop.org/;
    # The source code implementing the Marsenne Twister algorithm is licensed
    # under the 3-clause BSD license. The rest is 2-clause BSD license.
    license = with licenses; [
      bsd2
      bsd3
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
