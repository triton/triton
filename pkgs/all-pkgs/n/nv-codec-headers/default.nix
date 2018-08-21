{ stdenv
, fetchgit
, lib
}:

let
  version = "8.1.24.2";
in
stdenv.mkDerivation rec {
  name = "nv-codec-headers-${version}";

  src = fetchgit {
    version = 6;
    url = https://git.videolan.org/git/ffmpeg/nv-codec-headers.git;
    rev = "refs/tags/n${version}";
    sha256 = "d48670280bf6fb7821c0721e6cb1726fcabdcfdfd1e9fef8ccc921778d32bbfa";
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
