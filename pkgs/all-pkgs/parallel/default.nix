{ stdenv
, fetchurl
, makeWrapper

, perl
, procps
}:

stdenv.mkDerivation rec {
  name = "parallel-20160122";

  src = fetchurl {
    url = "mirror://gnu/parallel/${name}.tar.bz2";
    sha256 = "1xs8y8jh7wyjs27079xz0ja7xfi4dywz8d6hbkl44mafdnnfjfiy";
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

  meta = with stdenv.lib; {
    description = "Shell tool for executing jobs in parallel";
    homepage = http://www.gnu.org/software/parallel/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
