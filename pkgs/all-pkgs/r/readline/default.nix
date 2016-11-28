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
    sha256 = "0d13sg9ksf982rrrmv5mb6a2p4ys9rvg9r71d6il0vr8hmql63bm";
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
