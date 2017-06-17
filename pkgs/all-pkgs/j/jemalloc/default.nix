{ stdenv
, fetchTritonPatch
, fetchurl
}:

let
  version = "5.0.0";
in
stdenv.mkDerivation rec {
  name = "jemalloc-${version}";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "9e4a9efba7dc4a7696f247c90c3fe89696de5f910f7deacf7e22ec521b1fa810";
  };

  patches = [
    (fetchTritonPatch {
      rev = "892789aa67ad1b2ce0a5a8d226cd3bab6a82d80b";
      file = "j/jemalloc/0001-only-abort-on-dlsym-when-necessary.patch";
      sha256 = "ef8b3afd9f7e8ee871bf6b228b0f9288881f6cc0243478bab727ba02eb2776e0";
    })
  ];

  dontDisableStatic = true;

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
