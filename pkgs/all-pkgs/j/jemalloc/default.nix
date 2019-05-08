{ stdenv
, fetchurl
, lib

, functionPrefix ? null
}:

let
  version = "5.2.0";

  inherit (lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "jemalloc-${version}";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "74be9f44a60d2a99398e706baa921e4efde82bf8fd16e5c0643c375c5851e3b4";
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
