{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "bc-1.06.95";

  src = fetchurl {
    url = "http://alpha.gnu.org/gnu/bc/${name}.tar.bz2";
    sha256 = "1k2yf9bhjxjwfhz0d1c5hmmrs8rxi9al0d4a39p8lgf0zayapr3y";
  };

  patches = [
    (fetchTritonPatch {
      rev = "4eaff4fc1ef159416bd98cf46c56dafa9d755a7a";
      file = "bc/bc-1.06-mem-leak.patch";
      sha256 = "27e30d0389b79556609a74a4bb2a19f208f0e527bf08357ad79e0f453f15ac17";
    })
    (fetchTritonPatch {
      rev = "4eaff4fc1ef159416bd98cf46c56dafa9d755a7a";
      file = "bc/bc-1.06-void_uninitialized.patch";
      sha256 = "cb210e21f6a9ab5cac591259b1649120b0b74a722dc02ec17cb09bc9a19f3b8a";
    })
  ];

  configureFlags = [
    "--without-libedit"
    "--with-readline"
  ];

  postConfigure =
  /* Don't regen docs -- configure produces a small fragment
     that includes the version info which causes all pages to
     regen (newer file). */ ''
  	touch -r doc doc/*
  '';

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    ncurses
    readline
  ];

  postBuild =
  /* Simple test */ ''
    echo "quit" | ./bc/bc -l Test/checklib.b
  '';

  doCheck = true;
  enableParallelBuilding = false;

  meta = with stdenv.lib; {
    description = "GNU software calculator";
    homepage = http://www.gnu.org/software/bc/;
    license = with licenses; [
      lgpl21
      gpl2
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
