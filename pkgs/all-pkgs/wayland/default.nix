{ stdenv
, docbook_xsl
, doxygen
, fetchurl
, graphviz
, libxslt
, xmlto

, expat
, libffi
, libxml2

, enableDocumentation ? false
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

stdenv.mkDerivation rec {
  name = "wayland-${version}";
  version = "1.10.0";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "1p307ly1yyqjnzn9dbv78yffql2qszn84qk74lwanl3gma8fgxjb";
  };

  nativeBuildInputs = [ ]
    ++ optionals enableDocumentation [
      docbook_xsl
      doxygen
      graphviz
      libxslt
      xmlto
    ];

  buildInputs = [
    expat
    libffi
    libxml2
  ];

  configureFlags = [
    "--enable-libraries"
    (enFlag "documentation" enableDocumentation null)
  ];

  passthru = {
    inherit version;
  };

  meta = with stdenv.lib; {
    description = "Reference implementation of the wayland protocol";
    homepage = http://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
