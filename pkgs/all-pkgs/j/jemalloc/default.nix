{ stdenv
, fetchurl
, lib

, functionPrefix ? null
}:

let
  version = "5.2.1";

  inherit (lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "jemalloc-${version}";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "34330e5ce276099e2e8950d9335db5a875689a4c6a56751ef3b1d8c537f887f6";
  };

  configureFlags = optionals (functionPrefix != null) [
    "--with-jemalloc-prefix=${functionPrefix}"
  ];

  disableStatic = false;

  meta = with lib; {
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
