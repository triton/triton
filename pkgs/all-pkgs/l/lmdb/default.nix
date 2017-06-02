{ stdenv
, fetchFromGitHub
}:

let
  version = "0.9.21";
in
stdenv.mkDerivation rec {
  name = "lmdb-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "LMDB";
    repo = "lmdb";
    rev = "LMDB_${version}";
    sha256 = "c8a2892fcc50e5991bbdca77fca87d75f9f953f9156d2149aeedcb35b64121c4";
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
