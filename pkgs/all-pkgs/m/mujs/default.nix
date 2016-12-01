{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "mujs-2016-10-31";

  src = fetchFromGitHub {
    version = 2;
    owner = "ccxvii";
    repo = "mujs";
    rev = "a0ceaf5050faf419401fe1b83acfa950ec8a8a89";
    sha256 = "023a927441a75e335c4899d44a64a0fd62117564dcbe45b112cd661df9e9f6c3";
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
