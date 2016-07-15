{ stdenv
, buildPerlPackage
, fetchurl

, expat
}:

buildPerlPackage rec {
  name = "XML-Parser-2.44";

  src = fetchurl {
    url = "mirror://cpan/authors/id/T/TO/TODDR/${name}.tar.gz";
    sha256 = "1ae9d07ee9c35326b3d9aad56eae71a6730a73a116b9fe9e8a4758b7cc033216";
  };

  buildInputs = [
    expat
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
