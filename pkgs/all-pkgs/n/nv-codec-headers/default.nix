{ stdenv
, fetchgit
, lib
}:

let
  version = "8.0.14.2";
in
stdenv.mkDerivation rec {
  name = "nv-codec-headers-${version}";

  src = fetchgit {
    version = 6;
    url = https://git.videolan.org/git/ffmpeg/nv-codec-headers.git;
    rev = "refs/tags/n${version}";
    sha256 = "69a0ab6c5ffad7171c63843bf7825ede935dc93a9d812210ad6c436de33bec19";
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
