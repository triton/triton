{ stdenv
, buildPythonPackage
, fetchFromGitHub
#, fetchPyPi
, lib

, libyaml
}:

let

  version = "2017-09-11";
in
buildPythonPackage {
  name = "PyYAML-${version}";

  # src = fetchPyPi {
  #   package = "PyYAML";
  #   inherit version;
  #   sha256 = "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab";
  # };

  # Temporary until >3.12 is released, needed for python 3.7 compatibility.
  src = fetchFromGitHub {
    version = 5;
    owner = "yaml";
    repo = "pyyaml";
    rev = "298e07907ae526594069f6fdf31f2f1278cc1ae3";
    sha256 = "39eb24b73f96c9ed5b082f9179019e5a117187bd15b0025f71eab8ffba3b54e8";
  };

  buildInputs = [
    libyaml
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
