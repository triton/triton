{ stdenv
, fetchurl

, rarSupport ? false
}:

with {
  inherit (stdenv.lib)
    optional
    optionalString;
};

stdenv.mkDerivation rec {
  name = "p7zip-${version}";
  version = "15.14.1";

  src = fetchurl {
    url = "mirror://sourceforge/p7zip/p7zip_${version}_src_all.tar.bz2";
    sha256 = "699db4da3621904113e040703220abb1148dfef477b55305e2f14a4f1f8f25d4";
  };

  postPatch = optionalString (!rarSupport) ''
    sed -i makefile* CPP/7zip/Bundles/Format7zFree/makefile \
       -e '/Rar/d' \
       -e '/RAR/d'
    rm -frv CPP/7zip/Compress/Rar
  '';

  makeFlags = [
    "DEST_HOME=$(out)"
  ];

  preConfigure = ''
    buildFlags=all3
  '';

  meta = with stdenv.lib; {
    description = "A port of the 7-zip archiver for Unix";
    homepage = http://p7zip.sourceforge.net/;
    license = with licenses; [
      lgpl21Plus
    ] ++ optional rarSupport unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
