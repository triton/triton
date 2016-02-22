{ stdenv
, fetchurl
, ncurses
}:

let
  patchSha256s = import ./patches.nix;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "readline-${version}-p${toString (length (attrNames patchSha256s))}";
  version = "6.3";

  src = fetchurl {
    url = "mirror://gnu/readline/readline-${version}.tar.gz";
    sha256 = "0hzxr9jxqqx5sxsv9vmlxdnvlr9vi4ih1avjb869hbs6p5qn1fjn";
  };

  buildInputs = [ ncurses ];

  patchFlags = [
    "-p0"
  ];

  patches = [
    ./link-against-ncurses.patch
  ] ++ flip mapAttrsToList patchSha256s (name: sha256: fetchurl {
    inherit name sha256;
    url = "mirror://gnu/readline/readline-${version}-patches/${name}";
  });

  meta = {
    description = "Library for interactive line editing";
    homepage = http://savannah.gnu.org/projects/readline/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
