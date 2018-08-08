{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

let
  date = "2017-10-17";
  rev = "91ef401f4c3536c6de999ac609262691ec888c4c";
in
stdenv.mkDerivation {
  name = "rnnoise-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "xiph";
    repo = "rnnoise";
    inherit rev;
    sha256 = "bae68b0e33ac91214f9764a146e62be26ae0d6ab21220c7905686f8d728a3185";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--disable-examples"
  ];

  meta = with stdenv.lib; {
    description = "The most popular clone of the VI editor";
    homepage = http://www.vim.org;
    license = licenses.vim;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
