{ stdenv
, autoreconfHook
, fetchFromGitLab
, lib

, libaacs
, libgcrypt
, libgpg-error
}:

let
  date = "2018-11-30";
  rev = "147268028c7ab29add3ec33d53dc4a270698e1c6";
in
stdenv.mkDerivation {
  name = "libbdplus-${date}";

  src = fetchFromGitLab {
    version = 6;
    host = "https://code.videolan.org";
    owner = "videolan";
    repo = "libbdplus";
    inherit rev;
    sha256 = "75c96d087cf59d35d6dc1473b7627f7cf2308254a5672dcb574d436072d96c9b";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libaacs
    libgcrypt
    libgpg-error
  ];

  configureFlags = [
    "--with-libaacs"
  ];

  meta = with lib; {
    description = "Library to access BD+ protected Blu-Ray disks";
    homepage = http://www.videolan.org/developers/libbdplus.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

