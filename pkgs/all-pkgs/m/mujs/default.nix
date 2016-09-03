{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "mujs-2016-05-04";

  src = fetchFromGitHub {
    version = 1;
    owner = "ccxvii";
    repo = "mujs";
    rev = "1930f35933654d02234249b8c9b8c0d1c8c9fb6b";
    sha256 = "007ef0382e1f67547556afae93629a9e90e3e9df7df14591b47da65c497b2da0";
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
