{ stdenv
, fetchFromGitHub

, libbsd
, libressl
}:

stdenv.mkDerivation {
  name = "acme-client-2016-09-03";

  src = fetchFromGitHub {
    version = 2;
    owner = "kristapsdz";
    repo = "acme-client-portable";
    rev = "e15995f0fcd196a8c8fd7fe376f5c30c6c463b55";
    sha256 = "78669a67d695ce1adad08082d2c42b988641d5ce435995e08bf6521406817640";
  };

  buildInputs = [
    libbsd
    libressl
  ];

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
