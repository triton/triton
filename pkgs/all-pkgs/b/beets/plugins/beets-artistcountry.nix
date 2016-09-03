{ stdenv
, buildPythonPackage
, fetchFromGitHub
, pythonPackages
}:

buildPythonPackage rec {
  name = "beets-artistcountry-${version}";
  version = "0.1.1";

  src = fetchFromGitHub {
    version = 1;
    owner = "agrausem";
    repo = "beets-artistcountry";
    rev = "${version}";
    sha256 = "6ac7ea9ad5c7d40f5c9c133ca75848270f8f27a0b4c1bd5fa86f4fad0f73d50b";
  };

  postPatch = /* Prevent recursive dependency on beets */ ''
    sed -i setup.py \
      -e '/install_requires/,/\]/{/beets/d}'
  '';

  propagatedBuildInputs = [
    pythonPackages.musicbrainzngs
  ];

  meta = with stdenv.lib; {
    description = "Beets plugin to retrieve the country of an artist";
    homepage = "https://github.com/agrausem/beets-artistcountry";
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
