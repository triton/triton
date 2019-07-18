{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.4.0";
in
buildPythonPackage rec {
  name = "typed-ast";

  src = fetchPyPi {
    package = "typed_ast";
    inherit version;
    sha256 = "66480f95b8167c9c5c5c87f32cf437d585937970f3fc24386f313a4c97b44e34";
  };

  meta = with lib; {
    description = "ast module that parses `# type:` comments";
    homepage = https://github.com/python/typed_ast;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
