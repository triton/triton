{ stdenv
, fetchTritonPatch
, fetchurl

, rarSupport ? false
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "16.02";
in
stdenv.mkDerivation rec {
  name = "p7zip-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/p7zip/p7zip_${version}_src_all.tar.bz2";
    multihash = "QmV1kWMqVpr6y6hVNS1m2jNQYXcsBDawHPpuUeEtKT6NQW";
    sha256 = "5eb20ac0e2944f6cb9c2d51dd6c4518941c185347d4089ea89087ffdd6e2341f";
  };

  patches = [
    (fetchTritonPatch {
      rev = "e1394a1eee643236924329eb1a0f17e646b2c8ac";
      file = "p/p7zip/CVE-2016-9296.patch";
      sha256 = "f9bcbf21d4aa8938861a6cba992df13dec19538286e9ed747ccec6d9a4e8f983";
    })
    (fetchTritonPatch {
      rev = "e1394a1eee643236924329eb1a0f17e646b2c8ac";
      file = "p/p7zip/CVE-2017-17969.patch";
      sha256 = "c6af5ba588b8932a5e99f3741fcf1011b7c94b533de903176c7d1d4c02a9ebef";
    })
    (fetchTritonPatch {
      rev = "e1394a1eee643236924329eb1a0f17e646b2c8ac";
      file = "p/p7zip/CVE-2018-5996.patch";
      sha256 = "9c92b9060fb0ecc3e754e6440d7773d04bc324d0f998ebcebc263264e5a520df";
    })
    (fetchTritonPatch {
      rev = "e1394a1eee643236924329eb1a0f17e646b2c8ac";
      file = "p/p7zip/CVE-2018-10115.patch";
      sha256 = "c397eb6ad60bfab8d388ea9b39c0c13ae818f86746210c6435e35b35c786607f";
    })
    (fetchTritonPatch {
      rev = "e1394a1eee643236924329eb1a0f17e646b2c8ac";
      file = "p/p7zip/gcc10.patch";
      sha256 = "f90013d66d3c9865cb56fed2fb0432057a07283d5361e2ae9e98c3d3657f42a1";
    })
  ];

  postPatch = optionalString (!rarSupport) ''
    sed -i makefile* CPP/7zip/Bundles/Format7zFree/makefile \
       -e '/Rar/d' \
       -e '/RAR/d'
    rm -frv CPP/7zip/Compress/Rar
  '';

  preConfigure = ''
    buildFlags=all3
  '';

  preBuild = ''
    makeFlagsArray+=("DEST_HOME=$out")
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
