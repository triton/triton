{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "dcadec-2016-04-07";

  src = fetchFromGitHub {
    version = 2;
    owner = "foo86";
    repo = "dcadec";
    rev = "b93deed1a231dd6dd7e39b9fe7d2abe05aa00158";
    sha256 = "451bf50181f2531dfba4d891987bc9af7c2b7a6ab774f182c50498bfb69232e4";
  };

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
    )
  '';

  makeFlags = [
    "CONFIG_SHARED=1"
  ];

  meta = with lib; {
    description = "DTS Coherent Acoustics decoder";
    homepage = https://github.com/foo86/dcadec;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
