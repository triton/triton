{ stdenv
, ed
, fetchurl
, flex
, lib

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "bc-1.07.1";

  src = fetchurl {
    url = "mirror://gnu/bc/${name}.tar.gz";
    hashOutput = false;
    sha256 = "62adfca89b0a1c0164c2cdca59ca210c1d44c3ffc46daf9931cf4942664cb02a";
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

  configureFlags = [
    "--without-libedit"
    "--with-readline"
  ];

  # Prevent doc rebuild
  preBuild = ''
    touch doc doc/*
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "00E4 2623 2F38 4BF6 D32D  8B18 81C2 4FF1 2FB7 B14B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
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
