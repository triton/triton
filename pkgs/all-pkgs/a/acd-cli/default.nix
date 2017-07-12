{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, isPy36
, lib

, appdirs
, colorama
, fuse_2
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

  makeWrapperArgs = [
    "--prefix LIBFUSE_PATH : ${fuse_2}/lib/libfuse.so"
  ];

  preFixup = /* Remove __pycache__ directory in bin output directory*/ ''
    rm -rvf $out/bin/__pycache__
  '' + /* Fix wrapper argv0 by replacing acd_cli's aliases with symlinks  */ ''
    rm -v $out/bin/acd{,_}cli
    ln -sv $out/bin/acd_cli.py $out/bin/acdcli
    ln -sv $out/bin/acd_cli.py $out/bin/acd_cli
  '';

  disabled = !isPy3 || isPy36;

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
