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
  version = "2.2.2";

  tarballUrls = version: [
    "mirror://gnu/guile/guile-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "guile-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "1c91a46197fb1adeba4fd62a25efcf3621c6450be166d7a7062ef6ca7e11f5ab";
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

  postPatch = ''
    # Fixes for parallel building
    sed -i libguile/Makefile.in \
      -e 's,^.c.x:$,.c.x: $(BUILT_SOURCES),g' \
      -e 's,DOT_X_FILES.*: ,\0$(DOT_I_FILES) ,g'

    # Fix impurities in the generated libpath.h
    sed -i libguile/Makefile.in \
      -e '/echo.*srcdir/s@,[ ]*".*"@, "/no-such-path"@g'
  '';

  postInstall = ''
    wrapProgram $out/bin/guile-snarf --prefix PATH : "${gawk}/bin"

    # Hack to remove impurities
    # TODO: We should fix this so we have a cached version of this module
    rm "$out"/lib/guile/2.2/ccache/srfi/srfi-4/gnu.go
  '';

  # A native Guile 2.0 is needed to cross-build Guile.
  selfNativeBuildInput = true;

  setupHook = ./setup-hook-2.0.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.2.2";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        "FF47 8FB2 64DE 32EC 2967  25A3 DDC0 F535 8812 F8F2"
        "3CE4 6455 8A84 FDC6 9DB4  0CFB 090B 1199 3D9A EBB5"
      ];
      inherit (src) outputHashAlgo;
      outputHash = "1c91a46197fb1adeba4fd62a25efcf3621c6450be166d7a7062ef6ca7e11f5ab";
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
