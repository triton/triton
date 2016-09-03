{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lmdb-${version}";
  version = "0.9.18";

  src = fetchFromGitHub {
    version = 1;
    owner = "LMDB";
    repo = "lmdb";
    rev = "LMDB_${version}";
    sha256 = "4a0916272d70cb47d2576259fc0e72c48efb9aa86bc16f253c247479670a5123";
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
