{ stdenv
, fetchurl
, makeWrapper

, perl
, procps
}:

stdenv.mkDerivation rec {
  name = "parallel-20171222";

  src = fetchurl {
    url = "mirror://gnu/parallel/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "9bc8c7fd2420ee9c6f4eeaf11d08c77682dbb02dc64d64881f38110f693379dc";
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
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "CDA0 1A42 08C4 F745 0610  7E7B D1AB 4516 8888 8888";
      inherit (src) urls outputHash outputHashAlgo;
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
