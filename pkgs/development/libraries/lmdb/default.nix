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
    sha256 = "01j384kxg36kym060pybr5p6mjw0xv33bqbb8arncdkdq57xk8wg";
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
    maintainers = with maintainers; [ jb55 ];
    license = licenses.openldap;
    platforms = platforms.all;
  };
}
