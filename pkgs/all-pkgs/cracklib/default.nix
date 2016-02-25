{ stdenv
, fetchurl
, gettext

, zlib
}:

stdenv.mkDerivation rec {
  name = "cracklib-2.9.6";

  src = fetchurl {
    url = "https://github.com/cracklib/cracklib/releases/download/${name}/${name}.tar.gz";
    sha256 = "0hrkb0prf7n92w6rxgq0ilzkk6rkhpys2cfqkrbzswp27na7dkqp";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = https://github.com/cracklib/cracklib;
    description = "A library for checking the strength of passwords";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
