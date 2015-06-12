{ stdenv, fetchurl, pkgconfig

# Optional Dependencies
, libffi ? null, docbook_xsl ? null, doxygen ? null, graphviz ? null, libxslt ? null, xmlto ? null
, expat ? null # Build wayland-scanner (currently cannot be disabled as of 1.8.0)

# Extra Arguments
, enableDocumentation ? false
}:


let
  inherit (stdenv.lib) mkEnable optionals;
in

# Require the optional to be enabled until upstream fixes or removes the configure flag
assert expat != null;

stdenv.mkDerivation rec {
  name = "wayland-${version}";
  version = "1.8.0";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "0h61bzm9mig9ajqw2sxdr16f69qs2l5bn3g9szdhvsh8f9mk9s1i";
  };

  configureFlags = [
    (mkEnable (expat != null)     "scanner"       null)
    (mkEnable enableDocumentation "documentation" null)
  ];

  nativeBuildInputs = [ pkgconfig ]
    ++ optionals enableDocumentation [ docbook_xsl doxygen graphviz libxslt xmlto ];

  buildInputs = [ libffi expat ];

  passthru = {
    inherit version;
  };

  meta = with stdenv.lib; {
    description = "Reference implementation of the wayland protocol";
    homepage = http://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ codyopel wkennington ];
    platforms = platforms.linux;
  };
}
