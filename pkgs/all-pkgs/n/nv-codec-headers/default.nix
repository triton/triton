{ stdenv
, fetchgit
, lib
}:

let
  version = "8.0.14.1";
in
stdenv.mkDerivation rec {
  name = "nv-codec-headers-${version}";

  src = fetchgit {
    version = 5;
    url = https://git.videolan.org/git/ffmpeg/nv-codec-headers.git;
    rev = "refs/tags/n${version}";
    sha256 = "792267e9856b3f2e91f274d071fec459589e00fdde2365ea7938eb3eedd4c65c";
  };

  preBuild = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    description = "";
    homepage = https://git.videolan.org/?p=ffmpeg/nv-codec-headers.git;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
