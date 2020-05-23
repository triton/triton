{ stdenv
, autoreconfHook
, fetchFromGitHub

, ngtcp2_lib

# Extra argument
, prefix ? ""
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optionals;
in

let
  isLib = prefix == "lib";

  rev = "05aade1b740b246ae97d1ab1f049c123bfdbf5a0";
  date = "2020-05-04";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp3-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ngtcp2";
    repo = "nghttp3";
    inherit rev;
    sha256 = "660ee5b4e4c47f038d780ac90929d08d256637bd6b4eca4a87281616707b57c6";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = optionals isLib [
    "--enable-lib-only"
  ];

  meta = with stdenv.lib; {
    description = "an implementation of QUIC in C";
    homepage = http://ngtcp2.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
