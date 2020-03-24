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

  rev = "37017cee122f54e24d9519e6b867c78c5bbcee0d";
  date = "2020-03-16";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp3-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ngtcp2";
    repo = "nghttp3";
    inherit rev;
    sha256 = "65317318c1dc96352e713f9f654ec661f9e180d67047dcee7470ee916123a22c";
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
