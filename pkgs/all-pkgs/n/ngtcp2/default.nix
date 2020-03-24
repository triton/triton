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

  rev = "61de9068057e5cb22f843a8c601422383dcf520c";
  date = "2020-03-23";
in
stdenv.mkDerivation rec {
  name = "${prefix}ngtcp2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ngtcp2";
    repo = "ngtcp2";
    inherit rev;
    sha256 = "3219ac52881b7c39c29adfdf9ded9442e726f02b3383fecfbdfcb7fa7151c39b";
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
