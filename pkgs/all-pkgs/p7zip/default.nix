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
  version = "15.09";

  src = fetchurl {
    url = "mirror://sourceforge/p7zip/p7zip_${version}_src_all.tar.bz2";
    sha256 = "0vsdkg24qa4l47gllyy2n3vyrn2cdk01qcgpa00y04728zvsr0w7";
  };

  postPatch = optionalString (!rarSupport) ''
    sed -e '/Rar/d' -i makefile* CPP/7zip/Bundles/Format7zFree/makefile
    sed -e '/RAR/d' -i makefile* CPP/7zip/Bundles/Format7zFree/makefile
    rm -rf CPP/7zip/Compress/Rar
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
