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

  buildInputs = [
    cairo
    libsigcxx
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-documentation"
    "--enable-warnings"
    "--disable-tests"
    "--enable-api-exceptions"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-boost"
    "--without-boost-unit-test-framework"
  ];

  meta = with stdenv.lib; {
    description = "C++ bindings for the Cairo vector graphics library";
    homepage = http://cairographics.org/cairomm;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
