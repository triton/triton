{ stdenv
, fetchurl
, ncurses
}:

let
  patchSha256s = import ./patches.nix;

  version = "7.0";

  inherit (stdenv.lib)
    attrNames
    flip
    length
    mapAttrsToList;
in
stdenv.mkDerivation rec {
  name = "readline-${version}-p${toString (length (attrNames patchSha256s))}";

  src = fetchurl {
    url = "mirror://gnu/readline/readline-${version}.tar.gz";
    sha256 = "750d437185286f40a369e1e4f4764eda932b9459b5ec9a731628393dd3d32334";
  };

  buildInputs = [
    ncurses
  ];

  patchFlags = [
    "-p0"
  ];

  patches = [
    ./link-against-ncurses.patch
  ] ++ flip mapAttrsToList patchSha256s (name: sha256: fetchurl {
    inherit name sha256;
    url = "mirror://gnu/readline/readline-${version}-patches/${name}";
  });

  meta = with stdenv.lib; {
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
