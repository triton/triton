{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k
, lib

, appdirs
, colorama
, fusepy
, python-dateutil
, requests
, requests-toolbelt
, sqlalchemy
}:

let
  version = "0.3.2";
in
buildPythonPackage rec {
  name = "acd_cli-${version}";

  src = fetchPyPi {
    package = "acdcli";
    inherit version;
    sha256 = "9c094cb7f11c5586cfd6fbd4e7409d8ace1aaf14080847958fc69ee56fef69aa";
  };

  postPatch = ''
    sed -i setup.py \
      -e '/long_description/d'
  '';

  propagatedBuildInputs = [
    appdirs
    colorama
    fusepy
    python-dateutil
    requests
    requests-toolbelt
    sqlalchemy
  ];

  disabled = !isPy3k;

  meta = with lib; {
    description = "A CLI and FUSE filesystem for Amazon (Cloud) Drive";
    homepage = https://github.com/yadayada/acd_cli;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
