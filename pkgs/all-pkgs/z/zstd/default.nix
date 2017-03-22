{ stdenv
, fetchFromGitHub
}:

let
  version = "1.1.4";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "d0e2d6c6c7f02d37278c4aa8caf98f593f83633dd4e705d74110f3d1e39f1dc7";
  };

  # Makefile builds during the install phase
  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    description = "Fast real-time lossless compression algorithm";
    homepage = http://www.zstd.net/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
