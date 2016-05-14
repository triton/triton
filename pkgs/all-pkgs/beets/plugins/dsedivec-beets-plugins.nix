{ stdenv
, buildPythonPackage
, fetchFromGitHub
, python2Packages
}:

buildPythonPackage rec {
  name = "dsedivec-beets-plugins-${version}";
  version = "2015-06-22";

  src = fetchFromGitHub {
    owner = "dsedivec";
    repo = "beets-plugins";
    rev = "c67038d91bca79d9fd52ab316ad9150c1ba1a236";
    sha256 = "080bbe6ded4b04983d743eec2305666bb24a3e5596a81968b0a2d470e2ecf4ac";
  };

  postPatch = /* Prevent recursive dependency on beets */ ''
    sed -i setup.py \
      -e '/install_requires/,/\]/{/beets/d}'
  '';

  meta = with stdenv.lib; {
    description = "Beets tag editer & move untracked files plugins";
    homepage = "https://github.com/dsedivec/beets-plugins";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
