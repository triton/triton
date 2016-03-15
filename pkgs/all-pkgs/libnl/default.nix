{ stdenv
, bison
, fetchurl
, flex
}:

let
  version = "3.2.27";
  version' = stdenv.lib.replaceStrings ["."] ["_"] version;
in
stdenv.mkDerivation {
  name = "libnl-${version}";

  src = fetchurl {
    url = "https://github.com/thom311/libnl/releases/download/libnl${version'}/libnl-${version}.tar.gz";
    sha256 = "1ilfynang98p282lgvfcp1fvfa4s86zn0qpr7i10zabq7hmzkfsb";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  meta = with stdenv.lib; {
    homepage = "http://www.infradead.org/~tgr/libnl/";
    description = "Linux NetLink interface library";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
