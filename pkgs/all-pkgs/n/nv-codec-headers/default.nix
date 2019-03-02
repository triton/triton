{ stdenv
, fetchurl
, lib
}:

let
  version = "9.0.18.0";
in
stdenv.mkDerivation rec {
  name = "nv-codec-headers-${version}";

  src = fetchurl {
    url = "https://github.com/FFmpeg/nv-codec-headers/releases/download/"
      + "n${version}/${name}.tar.gz";
    sha256 = "6292aa41233d5c6e7cb917610de9aff8764f194116780c5b3aad753bf8868d4d";
  };

  preBuild = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    description = "Headers required to interface with Nvidias codec APIs";
    homepage = https://git.videolan.org/?p=ffmpeg/nv-codec-headers.git;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
