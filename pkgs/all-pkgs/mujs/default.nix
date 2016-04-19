{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "mujs-2016-04-19";

  src = fetchFromGitHub {
    owner = "ccxvii";
    repo = "mujs";
    rev = "4484271999bcded9ada0a76a5706235ca43b96e1";
    sha256 = "a4c285926d2efdd709a6bf566046ab2ece51e7e96db582a14175e3f9baf4745f";
  };

  preInstall = ''
    installFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    license = licenses.agpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
