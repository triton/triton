{ stdenv
, fetchurl
, makeWrapper

, perl
, procps
}:

stdenv.mkDerivation rec {
  name = "parallel-20181022";

  src = fetchurl {
    url = "mirror://gnu/parallel/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "2e84dee3556cbb8f6a3794f5b21549faffb132db3fc68e2e95922963adcbdbec";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  preFixup = ''
    sed -i 's,#![ ]*/usr/bin/env[ ]*perl,#!${perl}/bin/perl,' $out/bin/*

    wrapProgram $out/bin/parallel \
      --prefix PATH : ${procps}/bin \
      --prefix PATH : "${perl}/bin" \
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "CDA0 1A42 08C4 F745 0610  7E7B D1AB 4516 8888 8888";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Shell tool for executing jobs in parallel";
    homepage = http://www.gnu.org/software/parallel/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
