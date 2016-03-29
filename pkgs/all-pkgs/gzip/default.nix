{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gzip-1.7";

  src = fetchurl {
    url = "mirror://gnu/gzip/${name}.tar.xz";
    sha256 = "fb31c57e7ce7703596ef57329be7cc5c5fd741b4a0f659fea7ee6a54706b41ab";
  };

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  makeFlags = [
    "SHELL=/bin/sh"
    "GREP=grep"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/gzip/;
    description = "GNU zip compression program";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
