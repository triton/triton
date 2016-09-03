{ stdenv
, fetchFromGitHub

, jansson
}:

stdenv.mkDerivation {
  name = "jshon-2016-01-16";

  src = fetchFromGitHub {
    version = 1;
    owner = "keenerd";
    repo = "jshon";
    rev = "783d3bff938ebe15ce36d60a845bdc742e9555dd";
    sha256 = "84a1dea159d8d423f659e02c1ae4d1114f961545c282a6298b417530ddb42b40";
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
