{ stdenv
, fetchFromGitHub
}:

let
  version = "168";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "ee95bc55df7275d85698ed72b6912e3f0d8a72aa0008e67aa62fdfdf3051e5a6";
  };

  preBuild = ''
    makeFlagsArray+=(
      "etcprefix=$out"
      "prefix=$out"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
