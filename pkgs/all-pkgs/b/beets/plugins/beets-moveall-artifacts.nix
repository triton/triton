{ stdenv
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  name = "beets-moveall-artifacts-2016-08-28";

  src = fetchFromGitHub {
    version = 6;
    owner = "chlorm";
    repo = "beets-moveall-artifacts";
    rev = "9a193d2a149fc40e3dea0e6e26b57001589e2d02";
    sha256 = "4eff767db1f08dc27af5d3345928e06eea72b1d9442fc2b5a5a49d5447dd7095";
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
