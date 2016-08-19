{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "yasm-1.3.0";

  src = fetchurl {
    url = "https://www.tortall.net/projects/yasm/releases/${name}.tar.gz";
    multihash = "QmeFZY6fWZsBgDu2BvPADAzabKSKS6j9VB2xrjN1jn7uHR";
    sha256 = "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-warnerror"
    "--disable-profiling"
    "--disable-gcov"
    "--disable-python"
    "--disable-python-bindings"
    "--enable-nls"
    "--enable-rpath"
  ];

  meta = with stdenv.lib; {
    description = "An assembler for x86 and x86_64 instruction sets";
    homepage = http://www.tortall.net/projects/yasm/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
