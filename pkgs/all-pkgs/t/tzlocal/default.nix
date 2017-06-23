{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
}:

let
  version = "1.4";
in
buildPythonPackage rec {
  name = "tzlocal-${version}";

  src = fetchPyPi {
    package = "tzlocal";
    inherit version;
    sha256 = "05a2908f7fb1ba8843f03b2360d6ad314dbf2bce4644feb702ccd38527e13059";
  };

  buildInputs = [
    pytz
  ];

  doCheck = true;

  meta = with lib; {
    description = "tzinfo object for the local timezone";
    homepage = https://github.com/regebro/tzlocal;
    license = licenses.free; # CC0 1.0 Universal
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
