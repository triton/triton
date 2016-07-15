{ stdenv
, buildPerlPackage
, fetchurl

, URI
}:

buildPerlPackage rec {
  name = "HTTP-Message-6.11";

  src = fetchurl {
    url = "mirror://cpan/authors/id/E/ET/ETHER/${name}.tar.gz";
    sha256 = "e7b368077ae6a188d99920411d8f52a8e5acfb39574d4f5c24f46fd22533d81b";
  };

  propagatedBuildInputs = [
    URI
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
