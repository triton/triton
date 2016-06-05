{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.0.16";
in
buildPythonPackage {
  name = "ipaddress-${version}";

  src = fetchPyPi {
    package = "ipaddress";
    inherit version;
    sha256 = "5a3182b322a706525c46282ca6f064d27a02cffbd449f9f47416f1dc96aa71b0";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
