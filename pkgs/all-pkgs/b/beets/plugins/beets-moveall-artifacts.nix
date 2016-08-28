{ stdenv
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  name = "beets-moveall-artifacts-2016-08-28";

  src = fetchFromGitHub {
    owner = "chlorm";
    repo = "beets-moveall-artifacts";
    rev = "9772a55569558903a3f14cf78600d332fdde28d6";
    sha256 = "96b8541cce2485b3a8f679f0217d2f4acb646eabf4251bf24c5f8892946cde87";
  };

  postPatch = /* Prevent recursive dependency on beets */ ''
    sed -i setup.py \
      -e '/install_requires/,/\]/{/beets/d}'
  '';

  meta = with stdenv.lib; {
    description = "Beets move untracked files plugins";
    homepage = "https://github.com/chlorm/beets-moveall-artifacts";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
