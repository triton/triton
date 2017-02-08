{ stdenv
, fetchFromGitHub
}:

let
  version = "1.1.3";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "416f6ac0510b9547e2334bc753d7e35b5c1679188f6f575c6184c00dc3b73122";
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
