{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "cpio-2.13";

  src = fetchurl {
    url = "mirror://gnu/cpio/${name}.tar.bz2";
    sha256 = "eab5bdc5ae1df285c59f2a4f140a98fc33678a0bf61bdba67d9436ae26b46f6d";
  };

  configureFlags = [
    "--enable-mt"
  ];

  meta = with stdenv.lib; {
    description = "A program to create or extract from cpio archives";
    homepage = http://www.gnu.org/software/cpio/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    priority = 1; # resolves collision with gnutar's "libexec/rmt"
  };
}
