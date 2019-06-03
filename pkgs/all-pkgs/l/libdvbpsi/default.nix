{ stdenv
, autoreconfHook
, fetchFromGitLab
, lib
}:

let
  date = "2018-12-07";
  rev = "be3ae3225f5270d259d4e434898946cb95ca3217";
in
stdenv.mkDerivation rec {
  name = "libdvbpsi-${date}";

  src = fetchFromGitLab {
    version = 6;
    host = "https://code.videolan.org";
    owner = "videolan";
    repo = "libdvbpsi";
    inherit rev;
    sha256 = "4d678d5aceba86718d5e31cbdde27926b44755ee3490f4fa30a19b65034045e8";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    description = "Decoding and generation of MPEG TS and DVB PSI tables";
    homepage = http://www.videolan.org/developers/libdvbpsi.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
