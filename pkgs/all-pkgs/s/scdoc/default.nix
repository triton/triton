{ stdenv
, fetchzip
}:

let
  version = "1.9.4";
in
stdenv.mkDerivation {
  name = "scdoc-${version}";

  src = fetchzip {
    version = 6;
    url = "https://git.sr.ht/~sircmpwn/scdoc/archive/${version}.tar.gz";
    sha256 = "0f58e2afb1d5b6c44615ae9b4f1c0e0fbd71622700c08c828dfdb9924ef51fd2";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
