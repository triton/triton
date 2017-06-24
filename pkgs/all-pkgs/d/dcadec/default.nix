{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "dcadec-2016-06-03";

  src = fetchFromGitHub {
    version = 3;
    owner = "foo86";
    repo = "dcadec";
    rev = "b93deed1a231dd6dd7e39b9fe7d2abe05aa00158";
    sha256 = "46fcd95f31dc98e9ae581130e3a3a5994c632f73c2b70361b9d17bdc7d374b53";
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
