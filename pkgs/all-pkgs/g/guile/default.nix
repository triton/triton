{ stdenv
, fetchurl
, makeWrapper

, boehm-gc
, gawk
, gmp
, libffi
, libunistring
, libtool
, readline
}:

let
  version = "2.0.13";

  tarballUrls = version: [
    "mirror://gnu/guile/guile-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "guile-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "3744f2addc282a0de627aaef048f062982b44564d54ac31ff5217972529ed88b";
  };

  nativeBuildInputs = [
    makeWrapper
  ];
  
  buildInputs = [
    boehm-gc
    gmp
    libffi
    libtool
    libunistring
    readline
  ];

  # Fixes for parallel building
  postPatch = ''
    sed -i libguile/Makefile.in \
      -e 's,^.c.x:$,.c.x: $(BUILT_SOURCES),g' \
      -e 's,DOT_X_FILES.*: ,\0$(DOT_I_FILES) ,g'
  '';

  # A native Guile 2.0 is needed to cross-build Guile.
  selfNativeBuildInput = true;

  postInstall = ''
    wrapProgram $out/bin/guile-snarf --prefix PATH : "${gawk}/bin"
  '';

  setupHook = ./setup-hook-2.0.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.0.13";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        "FF47 8FB2 64DE 32EC 2967  25A3 DDC0 F535 8812 F8F2"
        "3CE4 6455 8A84 FDC6 9DB4  0CFB 090B 1199 3D9A EBB5"
      ];
      inherit (src) outputHashAlgo;
      outputHash = "3744f2addc282a0de627aaef048f062982b44564d54ac31ff5217972529ed88b";
    };
  };

  meta = with stdenv.lib; {
    description = "Embeddable Scheme implementation";
    homepage = http://www.gnu.org/software/guile/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
