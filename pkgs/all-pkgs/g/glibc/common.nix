{ fetchurl
, fetchTritonPatch
}:

rec {
  version = "2.30";

  src = fetchurl {
    url = "mirror://gnu/glibc/glibc-${version}.tar.xz";
    hashOutput = false;
    sha256 = "e2c4114e569afbe7edbc29131a43be833850ab9a459d81beb2588016d2bbb8af";
  };

  patches = [
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0001-Fix-common-header-paths.patch";
      sha256 = "df93cbd406a5dd2add2dd0d601ff9fc97fc42a1402010268ee1ee8331ec6ec72";
    })
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0002-sunrpc-Don-t-hardcode-cpp-path.patch";
      sha256 = "7a9ce7f69cd6d3426d19a8343611dc3e9c48e3374fa1cb8b93c5c98d7e79d69b";
    })
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0003-timezone-Fix-zoneinfo-path-for-triton.patch";
      sha256 = "b4b47be63c3437882a160fc8d9b8ed7119ab383b1559599e2706ce8f211a0acd";
    })
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0004-nsswitch-Try-system-paths-for-modules.patch";
      sha256 = "9cd235f0699661cbfd0b77f74c538d97514ba450dfba9a3f436adc2915ae0acf";
    })
    (fetchTritonPatch {
      rev = "b772989f030aef70b8b5fd39a3bb04738d50b383";
      file = "g/glibc/0005-locale-archive-Support-multiple-locale-archive-locat.patch";
      sha256 = "3ab23b441e573e51ee67a8e65a3c0c5a40d8d80805838a389b9abca08c45156c";
    })
    (fetchTritonPatch {
      rev = "cf6beafafc0d218cf156e3713fe62c0e53629419";
      file = "g/glibc/0006-Add-C.UTF-8-Support.patch";
      sha256 = "07f61db686dc36bc009999cb8d686581a29b13a0d2dd3f7f0b74cdfe964a0540";
    })
  ];

}
