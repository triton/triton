{ stdenv
, fetchurl
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "asciidoc-8.6.9";

  src = fetchurl {
    url = "mirror://sourceforge/asciidoc/${name}.tar.gz";
    sha256 = "78db9d0567c8ab6570a6eff7ffdf84eadd91f2dfc0a92a2d0105d323cab4e1f0";
  };

  buildInputs = [
    pythonPackages.python
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
