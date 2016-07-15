{ stdenv
, buildPerlPackage
, fetchurl

, curl
}:

buildPerlPackage rec {
  name = "WWW-Curl-4.17";

  src = fetchurl {
    url = "mirror://cpan/authors/id/S/SZ/SZBALINT/${name}.tar.gz";
    sha256 = "52ffab110e32348d775f241c973eb56f96b08eedbc110d77d257cdb0a24ab7ba";
  };

  buildInputs = [
    curl
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
