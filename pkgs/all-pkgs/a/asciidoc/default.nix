{ stdenv
, fetchurl

, pythonPackages
}:

let
  version = "8.6.9";
in
stdenv.mkDerivation rec {
  name = "asciidoc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/asciidoc/asciidoc/${version}/${name}.tar.gz";
    sha256 = "78db9d0567c8ab6570a6eff7ffdf84eadd91f2dfc0a92a2d0105d323cab4e1f0";
  };

  buildInputs = [
    pythonPackages.python
  ];

  parallelBuild = false;
  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "A plain text human readable/writable document format";
    homepage = http://asciidoc.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
