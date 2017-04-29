{ stdenv
, fetchzip
}:

let
  date = "2017-04-29";
  rev = "f9973ab5540a56ee89888799a6d7a12c9aa603cf";
in
stdenv.mkDerivation {
  name = "gnulib-${date}";

  src = fetchzip {
    version = 3;
    url = "https://git.savannah.gnu.org/cgit/gnulib.git/snapshot/gnulib-${rev}.tar.xz";
    multihash = "Qmd3PwjvZKUSG8n8SgcaBHfmD9ULRQHZ39g1qmKzJCR58K";
    sha256 = "73b60abb56e6026d4ec09e56a68785c2165f1cf50345e16f99827b70493d4c8f";
  };

  installPhase = ''
    mkdir -p $out
  '';

  meta = with stdenv.lib; {
    homepage = "http://www.gnu.org/software/gnulib/";
    description = "central location for code to be shared among GNU packages";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
