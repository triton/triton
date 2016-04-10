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
    sha256 = "426f28d580dc0ad56a81a8ae1885ab49ce253d75702cc77e7e9c433a8448c8b8";
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
