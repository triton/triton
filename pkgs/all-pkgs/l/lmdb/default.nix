{ stdenv
, fetchFromGitHub
}:

let
  version = "0.9.23";
in
stdenv.mkDerivation rec {
  name = "lmdb-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "LMDB";
    repo = "lmdb";
    rev = "LMDB_${version}";
    sha256 = "d9cce319c64f020beaf88bb9f0f5d7c447de387b0b6e978b3f836d2eacf0dc83";
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
