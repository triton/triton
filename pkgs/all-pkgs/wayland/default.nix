{ stdenv
, docbook_xsl
, doxygen
, fetchurl
, graphviz
, libxslt
, xmlto

, libffi
, expat

, enableDocumentation ? false
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

stdenv.mkDerivation rec {
  name = "wayland-${version}";
  version = "1.9.0";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "1yhy62vkbq8j8c9zaa6yzvn75cd99kfa8n2zfdwl80x019r711ww";
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
