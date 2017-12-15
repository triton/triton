{ stdenv
, cython
, fetchFromGitHub
, fetchPyPi
, lib
, nasm
, unzip

, ffmpeg
, imagemagick
, libass
, sphinx
#, tesseract
, zimg

, channel ? "stable"
}:

let
  source = vapoursynth.sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "vapoursynth-${source.version}";

  src =
    if channel == "head" then
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "vapoursynth";
        repo = "vapoursynth";
        inherit (source) rev sha256;
      }
    else
      fetchPyPi {
        package = "VapourSynth";
        inherit (source) sha256 version;
        type = ".zip";
      };

  nativeBuildInputs = [
    cython
    nasm
    # sphinx
  ] ++ optionals (chanel != "head") [
    unzip
  ];

  buildInputs = [
    ffmpeg
    imagemagick
    libass
    # tesseract
    zimg
  ];

  meta = with lib; {
    description = "A video processing framework";
    homepage = https://github.com/vapoursynth/vapoursynth;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
