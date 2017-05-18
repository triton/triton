{ stdenv
, fetchFromGitHub
}:

let
  version = "0.3.5";
in
stdenv.mkDerivation {
  name = "glog-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "google";
    repo = "glog";
    rev = "v${version}";
    sha256 = "7f6f9632b1c1ca7a9fb63485c3693c41420ad5ace3e7f94a0d13d6186ba18985";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
