{ stdenv
, fetchurl
, ncurses
}:

let
  patchSha256s = {
    "001" = "0vqlj22mkbn3x42qx2iqir7capx462dhagbzdw6hwxgfxavbny8s";
    "002" = "19g0l6vlfcqzwfwjj1slkmxzndjp4543hwrf26g8z216lp3h9qrr";
    "003" = "0bx53k876w8vwf4h2s6brr1i46ym87gi71bh8zl89n0gn3cbshgc";
    "004" = "1k2m8dg1awmjhmivdbx1c25866gfbpg0fy4845n8cw15zc3bjis5";
    "005" = "0jr7c28bzn882as5i54l53bhi723s1nkvzmwlh3rj6ld4bwqhxw7";
    "006" = "0mp5zgx50792gigkmjap3d0zpdv5qanii8djab7j6z69qsrpl8sw";
    "007" = "1sjv9w0mglh395i6hlq3ck7wdxvi2wyddlyb2j0jwg7cmnibayad";
    "008" = "11rpqhsxd132gc8455v51ma3a5zshznb0mh2p0zc5skcab7r7h1v";
  };
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
  ] ++ flip mapAttrsToList patchSha256s (n: sha256: fetchurl {
    name = "readline-${version}-${n}";
    url =
      let
        versionNoDecimal = concatStrings (splitString "." version);
      in
        "mirror://gnu/readline/readline-${version}-patches/"
        + "readline${versionNoDecimal}-${n}";
    inherit sha256;
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
