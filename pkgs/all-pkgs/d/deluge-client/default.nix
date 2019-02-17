{ stdenv
, buildPythonPackage
, fetchFromGitHub
, lib
}:

buildPythonPackage {
  name = "deluge-client-2019-01-07";

  src = fetchFromGitHub {
    version = 6;
    owner = "JohnDoee";
    repo = "deluge-client";
    rev = "44a32ce2f783ffa8812272bc73888d5acc207296";
    sha256 = "655ae53a039490e53b1dea68367e183edb17e47485c1144c626dd0f1c25ea221";
  };

  meta = with lib; {
    description = "A very lightweight pure-python Deluge RPC Client";
    homepage = https://github.com/JohnDoee/deluge-client;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

