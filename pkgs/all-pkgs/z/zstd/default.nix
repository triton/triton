{ stdenv
, fetchFromGitHub
}:

let
  version = "0.7.5";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "f7939c3c93f223c785de5f1202527d71b6221be89f235727e46a89e4acae3bfe";
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
