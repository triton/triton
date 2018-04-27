{ stdenv
, fetchzip
}:

let
  date = "2018-04-24";
  rev = "37efd1c53621f26d935e5fb6d8e49dbe9a4cd8df";
in
stdenv.mkDerivation {
  name = "gnulib-${date}";

  src = fetchzip {
    version = 6;
    url = "https://git.savannah.gnu.org/cgit/gnulib.git/snapshot/gnulib-${rev}.tar.xz";
    multihash = "QmYbDvkAFtT51Ruj4BHZ4TDZLBZLirGu85AyHDMKyKYpaZ";
    sha256 = "11a715698ab425f0f6a9ab90f06d7a895f257da5a931e32624f2664269167fb3";
  };

  installPhase = ''
    echo "This package does not install anything, use the source instead"
    exit 1
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
