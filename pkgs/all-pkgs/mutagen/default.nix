{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "mutagen-${version}";
  version = "1.32";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "7721ded04caf36fc30661165ae311fed342f7503b048e9db3d52764108ed3ab5";
  };

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Python multimedia tagging library";
    homepage = https://github.com/quodlibet/mutagen;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
