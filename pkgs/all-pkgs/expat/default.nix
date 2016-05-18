{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "expat-2.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/expat/${name}.tar.bz2";
    sha256 = "0ryyjgvy7jq0qb7a9mhc1giy3bzn56aiwrs8dpydqngplbjq9xdg";
  };

  patches = [
    (fetchTritonPatch {
      rev = "182777a92c9373d4679204b64b72f7d2176345ec";
      file = "expat/CVE-2015-1283-refix.patch";
      sha256 = "ccbb54a31b49864316f65c3dbe5b571efd1c6e003826bdcc4f55976bebc6f5a9";
    })
    (fetchTritonPatch {
      rev = "c24fdfce944f8ff9651503fdaa267f938f546368";
      file = "expat/CVE-2016-0718.patch";
      sha256 = "3f5dab75aa8e947bcddc6ccb57ecf129341ba6aaac3511acd7842adb0c1f7ed6";
    })
	];

  patchFlags = [
    "-p2"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.libexpat.org/;
    description = "A stream-oriented XML parser library written in C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
