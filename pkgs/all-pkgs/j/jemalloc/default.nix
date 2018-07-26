{ stdenv
, fetchurl

, functionPrefix ? null
}:

let
  version = "5.1.0";

  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "jemalloc-${version}";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "5396e61cc6103ac393136c309fae09e44d74743c86f90e266948c50f3dbb7268";
  };

  configureFlags = optionals (functionPrefix != null) [
    "--with-jemalloc-prefix=${functionPrefix}"
  ];

  disableStatic = false;

  meta = with stdenv.lib; {
    homepage = http://www.canonware.com/jemalloc/index.html;
    description = "General purpose malloc(3) implementation";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
