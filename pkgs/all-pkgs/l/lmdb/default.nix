{ stdenv
, fetchFromGitHub
}:

let
  version = "0.9.19";
in
stdenv.mkDerivation rec {
  name = "lmdb-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "LMDB";
    repo = "lmdb";
    rev = "LMDB_${version}";
    sha256 = "bc4441d3607a624cf81e859edd1dbfadd1ce00396643ef9493cad94a42b0e39e";
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
