{ stdenv
, fetchurl

, rarSupport ? false
}:

let
  inherit (stdenv.lib)
    optional
    optionalString;
in

stdenv.mkDerivation rec {
  name = "p7zip-${version}";
  version = "16.02";

  src = fetchurl {
    url = "mirror://sourceforge/p7zip/p7zip_${version}_src_all.tar.bz2";
    sha256 = "5eb20ac0e2944f6cb9c2d51dd6c4518941c185347d4089ea89087ffdd6e2341f";
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
