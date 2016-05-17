{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchTritonPatch
, pythonPackages
}:

buildPythonPackage rec {
  name = "beets-copyartifacts-${version}";
  version = "2015-12-12";

  src = fetchFromGitHub {
    owner = "sbarakat";
    repo = "beets-copyartifacts";
    rev = "dac4a1605111e24bb5b498aa84cead7c87480834";
    sha256 = "afb2a1fdac0aee13d512168583bd3c23310a51706637bef5c6ecc0f4d260d066";
  };

  patches = [
    # Do not move wrong files any more (PR #27)
    (fetchTritonPatch {
      rev = "ec3435fe7f003c5e2e838d4c88de51b3bbfd4d29";
      file = "beets-copyartifacts/1979e5f4ba641d800b87337712ec166895adba93.patch";
      sha256 = "5b8f72fe33eecdbf8e4be9a9c5571f37fd951e27478a1b8ec76c04e52e2728e2";
    })
  ];

  postPatch = /* Prevent recursive dependency on beets */ ''
    #sed -i setup.py \
    #  -e '/install_requires/,/\]/{/beets/d}'
    sed -i setup.py \
      -e '/install_requires/d'
  '';

  meta = with stdenv.lib; {
    description = "A plugin that moves non-music files during the import process";
    homepage = "https://github.com/sbarakat/beets-copyartifacts";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
