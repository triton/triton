{ stdenv
, fetchurl
, lib

, libbsd
}:

let
  version = "2.2.5";
in
stdenv.mkDerivation rec {
  name = "expat-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/expat/expat/${version}/${name}.tar.bz2";
    sha256 = "d9dc32efba7e74f788fcc4f212a43216fc37cf5f23f4c2339664d473353aedf6";
  };

  configureFlags = [
    "--with-libbsd"
  ];

  buildInputs = [
    libbsd
  ];

  meta = with lib; {
    description = "A stream-oriented XML parser library written in C";
    homepage = http://www.libexpat.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
