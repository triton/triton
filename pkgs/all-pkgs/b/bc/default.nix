{ stdenv
, ed
, fetchTritonPatch
, fetchurl
, flex

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "bc-1.07";

  src = fetchurl {
    url = "mirror://gnu/bc/${name}.tar.gz";
    hashOutput = false;
    sha256 = "55cf1fc33a728d7c3d386cc7b0cb556eb5bacf8e0cb5a3fcca7f109fc61205ad";
  };

  nativeBuildInputs = [
    ed
    flex
  ];

  buildInputs = [
    flex
    ncurses
    readline
  ];

  patches = [
    (fetchTritonPatch {
      rev = "f7da28f32f73a7a392b4f4bd0fbeb90e17fdbad0";
      file = "b/bc/fix-hang.patch";
      sha256 = "64719ac2d2a1622c241f5647973122d3ca742a28649875cd29ee957bf383dc38";
    })
  ];

  configureFlags = [
    "--without-libedit"
    "--with-readline"
  ];

  # Prevent doc rebuild
  preBuild = ''
    touch doc doc/*
  '';

  doCheck =true;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "00E4 2623 2F38 4BF6 D32D  8B18 81C2 4FF1 2FB7 B14B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "GNU software calculator";
    homepage = http://www.gnu.org/software/bc/;
    license = with licenses; [
      lgpl21
      gpl2
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
