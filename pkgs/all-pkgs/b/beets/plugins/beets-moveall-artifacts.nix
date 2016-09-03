{ stdenv
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  name = "beets-moveall-artifacts-2016-08-28";

  src = fetchFromGitHub {
    version = 1;
    owner = "chlorm";
    repo = "beets-moveall-artifacts";
    rev = "9a193d2a149fc40e3dea0e6e26b57001589e2d02";
    sha256 = "6420bd62987607396517d0087294ec69036b50b8ce42a63a0f75b983807089fd";
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
