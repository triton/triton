{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.2.3";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "738c4ebd88a718e700ee35c8d129acce2286542daa80a82823a7073644f706ad";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
