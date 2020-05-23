{ stdenv
, autoreconfHook
, fetchFromGitHub

, openssl

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

  rev = "016508872f81dfd7f705c5db8fda1086f02ca744";
  date = "2020-05-09";
in
stdenv.mkDerivation rec {
  name = "${prefix}ngtcp2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ngtcp2";
    repo = "ngtcp2";
    inherit rev;
    sha256 = "c0a119c1bd7da7bd338d0ce18f541026f25a20398babf6cd4728e85d85ff7ee7";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    openssl
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
