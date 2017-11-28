{ stdenv
, fetchurl
, lib
# , meson
# , ninja

, xz
}:

stdenv.mkDerivation rec {
  name = "orc-0.4.28";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/orc/${name}.tar.xz";
    hashOutput = false;
    sha256 = "bfcd7c6563b05672386c4eedfc4c0d4a0a12b4b4775b74ec6deb88fc2bcd83ce";
  };

  # nativeBuildInputs = [
  #   meson
  #   ninja
  # ];

  buildInputs = [
    xz
  ];

  # mesonFlags = [
  #   "-Denable-backend=all"
  #   "-Ddisable_gtkdoc=true"
  #   "-Ddisable_tests=true"
  # ];

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
        # Edward Hervey
        "D78B C13E 3280 CB8A FDE2  78EA 032D 3D83 3A0B A62A"
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
