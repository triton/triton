{stdenv, fetchurl, python, libxml2, libxslt, intltool
, makeWrapper, pythonPackages }:

stdenv.mkDerivation {
  name = "gnome-doc-utils-0.20.10";

  src = fetchurl {
    url = mirror://gnome/sources/gnome-doc-utils/0.20/gnome-doc-utils-0.20.10.tar.xz;
    sha256 = "19n4x25ndzngaciiyd8dd6s2mf9gv6nv3wv27ggns2smm7zkj1nb";
  };

  configureFlags = "--disable-scrollkeeper";
  buildInputs = [ python libxml2 libxslt ];
  pythonPath = [ libxml2 ];
  postInstall = "wrapPythonPrograms";

  nativeBuildInputs = [ intltool pythonPackages.wrapPython ];
}
