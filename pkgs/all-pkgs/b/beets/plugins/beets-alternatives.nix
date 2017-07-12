{ stdenv
, buildPythonPackage
, fetchFromGitHub
, isPy2
, optionals
, pythonPackages
}:

buildPythonPackage rec {
  name = "beets-alternatives-${version}";
  version = "0.8.2";

  src = fetchFromGitHub {
    version = 1;
    owner = "geigerzaehler";
    repo = "beets-alternatives";
    rev = "v${version}";
    sha256 = "23053856372813cdd0e063f0de71dae10ac169f24cf76e747172198f99c5879e";
  };

  postPatch = /* Prevent recursive dependency on beets */ ''
    sed -i setup.py \
      -e '/install_requires/,/\]/{/beets/d}'
  '';

  propagatedBuildInputs = optionals isPy2 [
    pythonPackages.futures
  ];

  meta = with stdenv.lib; {
    description = "Beets plugin to manage external files";
    homepage = "https://github.com/geigerzaehler/beets-alternatives";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
