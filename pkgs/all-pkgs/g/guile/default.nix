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
  version = "2.0.12";

  tarballUrls = version: [
    "mirror://gnu/guile/guile-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "guile-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "de8187736f9b260f2fa776ed39b52cb74dd389ccf7039c042f0606270196b7e9";
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
      urls = tarballUrls "2.0.12";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "FF47 8FB2 64DE 32EC 2967  25A3 DDC0 F535 8812 F8F2";
      inherit (src) outputHashAlgo;
      outputHash = "de8187736f9b260f2fa776ed39b52cb74dd389ccf7039c042f0606270196b7e9";
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
