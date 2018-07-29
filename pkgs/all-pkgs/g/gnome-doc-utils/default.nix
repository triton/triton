{ stdenv
, fetchurl
, gettext
, intltool
, perl

, libxml2
, libxslt
, python2Packages
}:

let
  major = "0.20";
  version = "${major}.10";
in
stdenv.mkDerivation rec {
  name = "gnome-doc-utils-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-doc-utils/${major}/${name}.tar.xz";
    sha256 = "19n4x25ndzngaciiyd8dd6s2mf9gv6nv3wv27ggns2smm7zkj1nb";
  };

  nativeBuildInputs = [
    gettext
    intltool
    perl
    python2Packages.wrapPython
  ];

  buildInputs = [
    libxml2
    libxslt
    python2Packages.python
    python2Packages.libxml2
  ];

  pythonPath = [
    python2Packages.libxml2
  ];

  configureFlags = [
    "--disable-documentation"
    "--disable-scrollkeeper"
  ];
  
  postInstall = ''
    wrapPythonPrograms
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
