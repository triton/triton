{ stdenv
, fetchFromGitHub

, jansson
}:

stdenv.mkDerivation {
  name = "jshon-2016-01-16";

  src = fetchFromGitHub {
    owner = "keenerd";
    repo = "jshon";
    rev = "783d3bff938ebe15ce36d60a845bdc742e9555dd";
    sha256 = "888768c65249a0ab1f13f7620afe6723776c2dfa460fe5fe23a7b82e6fb5d99d";
  };

  buildInputs = [
    jansson
  ];

  postPatch = ''
    sed -i "s,/usr,$out,g" Makefile
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
