{ stdenv
, fetchurl
, m4

, bzip2
, xz
, zlib

, static ? false
, shared ? true
}:

stdenv.mkDerivation rec {
  name = "elfutils-${version}";
  version = "0.165";

  src = fetchurl {
    urls = [
      "http://fedorahosted.org/releases/e/l/elfutils/${version}/${name}.tar.bz2"
      "mirror://gentoo/${name}.tar.bz2"
      ];
    sha256 = "0wp91hlh9n0ismikljf63558rzdwim8w1s271grsbaic35vr5z57";
  };

  nativeBuildInputs = [
    m4
  ];

  buildInputs = [
    bzip2
    xz
    zlib
  ];

  configureFlags = [
    "--enable-deterministic-archives"
  ];

  preFixup = stdenv.lib.optionalString (!shared) ''
    rm $out/lib/*.so*
  '' + stdenv.lib.optionalString (!static) ''
    rm $out/lib/*.a*
  '';

  meta = with stdenv.lib; {
    homepage = https://fedorahosted.org/elfutils/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
