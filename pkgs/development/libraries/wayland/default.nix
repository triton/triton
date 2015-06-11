{ stdenv, fetchurl, pkgconfig

# Optional Dependencies
, libffi ? null, docbook_xsl ? null, doxygen ? null, graphviz ? null, libxslt ? null, xmlto ? null
, expat ? null # Build wayland-scanner (currently cannot be disabled as of 1.7.0)

# Extra Arguments
, enableDocumentation ? false
}:

# Require the optional to be enabled until upstream fixes or removes the configure flag
assert expat != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "wayland-${version}";
  version = "1.7.0";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "173w0pqzk2m7hjlg15bymrx7ynxgq1ciadg03hzybxwnvfi4gsmx";
  };

  configureFlags = [
    (mkEnable (expat != null)     "scanner"       null)
    (mkEnable enableDocumentation "documentation" null)
  ];

  nativeBuildInputs = [ pkgconfig ]
    ++ optionals enableDocumentation [ docbook_xsl doxygen graphviz libxslt xmlto ];

  buildInputs = [ libffi expat ];

  meta = {
    description = "Reference implementation of the wayland protocol";
    homepage    = http://wayland.freedesktop.org/;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ codyopel wkennington ];
  };

  passthru.version = version;
}
