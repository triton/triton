{ stdenv
, fetchTritonPatch
, fetchurl
}:

let
  version = "2.7.2";
in
stdenv.mkDerivation rec {
  name = "mcpp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mcpp/mcpp/V.${version}/${name}.tar.gz";
    sha256 = "0r48rfghjm90pkdyr4khxg783g9v98rdx2n69xn8f6c5i0hl96rv";
  };

  patches = [
    (fetchTritonPatch {
      rev = "853aa0890d644aaaf37aaa27534f091571dd936e";
      file = "m/mcpp/fs28284.patch";
      sha256 = "27e42d8cae06327370cf0f9a8118d23a2f9368b87f24b38a9cb9c0c4eaeadb4e";
    })
    (fetchTritonPatch {
      rev = "853aa0890d644aaaf37aaa27534f091571dd936e";
      file = "m/mcpp/namlen.patch";
      sha256 = "ee8bf97c42150d2424a5984baec8227a44538e15c23cec93aabfc65daf9a6081";
    })
  ];

  configureFlags = [
    "--enable-mcpplib"
  ];

  meta = with stdenv.lib; {
    homepage = "http://mcpp.sourceforge.net/";
    description = "A portable c preprocessor";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
