{ stdenv
, fetchurl
, libsigsegv
, readline
}:

stdenv.mkDerivation rec {
  name = "gawk-4.1.3";

  src = fetchurl {
    url = "mirror://gnu/gawk/${name}.tar.xz";
    sha256 = "09d6pmx6h3i2glafm0jd1v1iyrs03vcyv2rkz12jisii3vlmbkz3";
  };

  buildInputs = [
    libsigsegv
    readline
  ];

  configureFlags = [
    "--with-libsigsegv-prefix=${libsigsegv}"
    "--with-readline=${readline}"
  ];

  postInstall = ''
    rm $out/bin/gawk-*
  '';

  meta = with stdenv.lib; {
    description = "GNU implementation of the Awk programming language";
    homepage = http://www.gnu.org/software/gawk/;
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
