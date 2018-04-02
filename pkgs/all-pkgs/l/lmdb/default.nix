{ stdenv
, fetchFromGitHub
}:

let
  version = "0.9.22";
in
stdenv.mkDerivation rec {
  name = "lmdb-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "LMDB";
    repo = "lmdb";
    rev = "LMDB_${version}";
    sha256 = "35e22ee52ebf99059c7743f1700c91f0317e4c11bab05f5e124743bf5587dded";
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
