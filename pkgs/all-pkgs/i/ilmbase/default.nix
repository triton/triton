{ stdenv
, fetchurl
}:

let
  version = "2.3.0";
in
stdenv.mkDerivation rec {
  name = "ilmbase-${version}";

  src = fetchurl {
    url = "https://github.com/openexr/openexr/releases/download/v${version}/${name}.tar.gz";
    sha256 = "456978d1a978a5f823c7c675f3f36b0ae14dba36638aeaa3c4b0e784f12a3862";
  };

  meta = with stdenv.lib; {
    homepage = http://www.openexr.com/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
