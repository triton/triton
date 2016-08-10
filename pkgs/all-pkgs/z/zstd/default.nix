{ stdenv
, fetchFromGitHub
}:

let
  version = "0.8.0";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "9ea09c5469bb2991233781dc12f3f6a01c351dbbf63dfc99a4fcb4b33688ce91";
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
