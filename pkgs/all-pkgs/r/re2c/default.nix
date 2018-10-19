{ stdenv
, fetchurl
}:

let
  version = "1.1.1";
in
stdenv.mkDerivation rec {
  name = "re2c-${version}";

  src = fetchurl {
    url = "https://github.com/skvadrik/re2c/releases/download/${version}/${name}.tar.gz";
    sha256 = "856597337ea00b24ce91f549f79e6eece1b92ba5f8b63292cad66c14ac7451cf";
  };

  meta = with stdenv.lib; {
    description = "Tool for writing very fast and very flexible scanners";
    homepage = "http://re2c.org";
    license = licenses.publicDomain;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = platforms.all;
  };
}
