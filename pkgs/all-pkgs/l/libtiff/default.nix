{ stdenv
, fetchTritonPatch
, fetchurl

, jbigkit
, libjpeg
, xz
, zlib
}:

let
  version = "4.0.7";
in
stdenv.mkDerivation rec {
  name = "libtiff-${version}";

  src = fetchurl {
    url = "http://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    multihash = "Qmas7k26WaQrQyvdVfw3yHh8Gf5YMfyzLnNwGJu7TrZLda";
    sha256 = "9f43a2cfb9589e5cecaa66e16bf87f814c945f22df7ba600d63aac4632c4f019";
  };

  buildInputs = [
    jbigkit
    libjpeg
    xz
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/fix-hylafax.patch";
      sha256 = "f390882bc0fad9e6486379543e47df0f5b246843da5d442870558d24fbd7f65d";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2016-10266.patch";
      sha256 = "fa4639e3cf470021f07f3d4a6b614a56299bbefcf4f0be646848b292ed2f4a3a";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2016-10267.patch";
      sha256 = "79c6839d631d027eb51111fecebf3267fddbc03918bda5ccd5c4f027d42b5697";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2016-10268.patch";
      sha256 = "aef913defad8f42305a4f79b564ddb810cf38e028cd7f0832794d9b0089554de";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2016-10269.patch";
      sha256 = "7fd9b8cca73fc72390328951ab237fb09bd0f7aed6d45d2bd6f520c0b4812f0b";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2016-10270.patch";
      sha256 = "6325882bae9e34a2c4affed05cac874413c5cf10848873c99113a0bda5788fab";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2016-10271_10272.patch";
      sha256 = "a4b7d8d50651d6f635cc38fcc45f23ead08ce69535aeff9848f144b35bbbf572";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7592.patch";
      sha256 = "ed13722c3eb25a3f41f7497fcda959eacd2b411ba14c16c1951ab8471955e549";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7593.patch";
      sha256 = "e8e775748bf8c2d11f891b9d784ab0bdcdb69577c67c4ace44677dcb8beed827";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7594.patch";
      sha256 = "ee2db50ef741b93de70d4f2735d6ffde6c8fda6d1dcd90ba38c1a2f8499c3d04";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7595.patch";
      sha256 = "60c7caadff5fd72314ebdf46705e33341c0cab84ee2cd9508c5a315874711e07";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7596_7597_7599_7600.patch";
      sha256 = "8dae895d7eafbcc6675d4d9a4301a5da4ed314e5d677fdad23a1f5e7526a118c";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7598.patch";
      sha256 = "83e68ce99c89f8c930d8c45dc083f2dc388c84285bf68ee9e2e4d8c092e9b993";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7601.patch";
      sha256 = "83f28892b7d46056bd5eb1e2aef42d25b59dd3d814f49a28f75e1ab6e746baba";
    })
    (fetchTritonPatch {
      rev = "f3900cb3594e57c00c1693ebaec69964884d9046";
      file = "l/libtiff/libtiff-CVE-2017-7602.patch";
      sha256 = "a1e45339bf434200cdf8042fd4b7cb91f029e9121757cf8e4b927e57b908e763";
    })
  ];

  meta = with stdenv.lib; {
    description = "Library and utilities for working with the TIFF image file format";
    homepage = http://www.remotesensing.org/libtiff/;
    license = licenses.libtiff;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
