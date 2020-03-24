{ stdenv
, fetchurl
}:

let
  version = "1.3";
in
stdenv.mkDerivation rec {
  name = "re2c-${version}";

  src = fetchurl {
    url = "https://github.com/skvadrik/re2c/releases/download/${version}/${name}.tar.xz";
    sha256 = "f37f25ff760e90088e7d03d1232002c2c2672646d5844fdf8e0d51a5cd75a503";
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
