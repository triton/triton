{ stdenv
, autoreconfHook
, bison
, fetchFromGitLab
, flex
, lib

, libgcrypt
, libgpg-error
}:

let
  date = "2018-12-06";
  rev = "f154d7e7cc755f0ce1f817f54227815b69962380";
in
stdenv.mkDerivation rec {
  name = "libaacs-${date}";

  src = fetchFromGitLab {
    version = 6;
    host = "https://code.videolan.org";
    owner = "videolan";
    repo = "libaacs";
    inherit rev;
    sha256 = "5cebae5981d8d0df310e67ae1df7e1bec1b49fdc0beddbebb892062d6961f69b";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
  ];

  buildInputs = [
    libgcrypt
    libgpg-error
  ];

  meta = with lib; {
    description = "Library to access AACS protected Blu-Ray disks";
    homepage = https://www.videolan.org/developers/libaacs.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
