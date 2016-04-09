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
    sha256 = "44173b3ed9f4fe0922ce14b125988e547a3a88dca079e3ee979e536556c974f9";
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
