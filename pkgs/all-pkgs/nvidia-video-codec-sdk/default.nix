{ stdenv
, fetchurl
, unzip
}:

# TODO: build tools (NvEncoder,NvEncoderPerf,NvTranscoder,NvEncoderLowLatency)

let
  inherit (stdenv.lib)
    replaceStrings;
in

stdenv.mkDerivation rec {
  name = "nvidia-video-codec-sdk-${version}";
  version = "6.0.1";

  src = fetchurl {
    url = "https://developer.nvidia.com/"
      + "video-sdk-${replaceStrings ["."] [""] version}";
    sha256 = "05227ee4015dc9bdf52b4fe8b3ba5a077d80962f35fa3b76d25288adb1dd0122";
    name = name + ".zip";
  };

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    install -D -m644 -v 'Samples/common/inc/nvEncodeAPI.h' \
      "$out/include/nvEncodeAPI.h"
  '';

  meta = with stdenv.lib; {
    description = "";
    homepage = https://developer.nvidia.com/nvidia-video-codec-sdk;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
