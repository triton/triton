{stdenv, fetchurl, xlibsWrapper, bison, flex, xorg}:

stdenv.mkDerivation {
  name = "Xaw3d-1.5E";
  builder = ./builder.sh;
  src = fetchurl {
    url = http://freshmeat.net/redir/xaw3d/11835/url_tgz/Xaw3d-1.5E.tar.gz;
    md5 = "29ecfdcd6bcf47f62ecfd672d31269a1";
  };
  patches = [./config.patch ./laylex.patch];
  buildInputs = [xorg.imake xorg.gccmakedep xorg.libXpm xorg.libXp bison flex];
  propagatedBuildInputs = [xlibsWrapper xorg.libXmu];

  meta = {
    description = "3D widget set based on the Athena Widget set";
  };
}
