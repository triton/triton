{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "fcgi-2.4.0";

  src = fetchurl {
    url = "mirror://gentoo/distfiles/${name}.tar.gz";
    multihash = "QmZwNnd51t9napXnf8KPGhJh47sr3QvHGtY5Breyo58yTj";
    sha256 = "1f857wnl1d6jfrgfgfpz3zdaj8fch3vr13mnpcpvy8bang34bz36";
  };

  patches = [
    ./gcc-4.4.diff
  ];

  postInstall = ''
    ln -s . $out/include/fastcgi
  '';

  # Fails for 2.4.0
  buildParallel = false;

  meta = with stdenv.lib; {
    description = "A language independent, scalable, open extension to CG";
    homepage = http://www.fastcgi.com/;
    license = "FastCGI see LICENSE.TERMS";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
