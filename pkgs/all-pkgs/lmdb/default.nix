{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lmdb-${version}";
  version = "0.9.18";

  src = fetchFromGitHub {
    owner = "LMDB";
    repo = "lmdb";
    rev = "LMDB_${version}";
    sha256 = "c0270b1a3fb0e18ab4825e0c950cbc5b7f9962f5f8c422aba45dffa94f62e9ee";
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
