{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  inherit (lib)
    optionals;

  version = "1.3.1";
in
buildPythonPackage rec {
  name = "lazy-object-proxy-${version}";

  src = fetchPyPi {
    package = "lazy-object-proxy";
    inherit version;
    sha256 = "eb91be369f945f10d3a49f5f9be8b3d0b93a4c2be8f8a5b83b0571b8123e0a7a";
  };

  meta = with lib; {
    description = "A fast and thorough lazy object proxy";
    homepage = https://github.com/ionelmc/python-lazy-object-proxy;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
