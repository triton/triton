{ stdenv
, fetchurl

, cairo
, libsigcxx
}:

stdenv.mkDerivation rec {
  name = "cairomm-1.12.0";

  src = fetchurl {
    url = "http://cairographics.org/releases/${name}.tar.gz";
    sha256 = "1k3lb3jwnk5nm4s5cfm5kk8kl4b066chis4inws6k5yxdzn5lhsh";
  };

  configureFlags = [
    "--disable-documentation"
    "--disable-tests"
    "--enable-api-exceptions"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-boost"
    "--without-boost-unit-test-framework"
  ];

  buildInputs = [
    cairo
    libsigcxx
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "C++ bindings for the Cairo vector graphics library";
    homepage = http://cairographics.org/cairomm;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
