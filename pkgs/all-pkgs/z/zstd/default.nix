{ stdenv
, fetchFromGitHub
}:

let
  version = "1.0.0";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "d69340e794c30a20497e54de78e04f1c1951b64c3d65fc76f66b906c305ff115";
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
