{ stdenv
, fetchurl
, gettext

, zlib
}:

stdenv.mkDerivation rec {
  name = "cracklib-2.9.6";

  src = fetchurl {
    url = "https://github.com/cracklib/cracklib/releases/download/${name}/${name}.tar.gz";
    multihash = "QmPNkPiCXBPy7SY9xwvvYa7WxmeMnCnyXteTuvHcntJGgr";
    sha256 = "0hrkb0prf7n92w6rxgq0ilzkk6rkhpys2cfqkrbzswp27na7dkqp";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    zlib
  ];

  meta = with stdenv.lib; {
    description = "A library for checking the strength of passwords";
    homepage = https://github.com/cracklib/cracklib;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
