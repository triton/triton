{ stdenv
, fetchFromGitHub
}:

let
  version = "0.9.24";
in
stdenv.mkDerivation rec {
  name = "lmdb-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "LMDB";
    repo = "lmdb";
    rev = "LMDB_${version}";
    sha256 = "9e7ffb8e92987c01c8058fdedb7322ae1c4e5f53e9d3826c20472a54369b4b23";
  };

  prePatch = ''
    while ! [ -f Makefile ]; do
      cd *
    done
    makeFlagsArray+=("prefix=$out")
  '';

  doCheck = true;
  checkTarget = "test";

  meta = with stdenv.lib; {
    description = "Lightning memory-mapped database";
    homepage = http://symas.com/mdb/;
    license = licenses.openldap;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
