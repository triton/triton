{ stdenv
, fetchFromGitHub
}:

let
  version = "0.3.4";
in
stdenv.mkDerivation {
  name = "glog-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "google";
    repo = "glog";
    rev = "v${version}";
    sha256 = "4b669c77148e5bbe25864069cfcd9ac3efa3cbd646a2bc50bb95f12f9dc02c2c";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
