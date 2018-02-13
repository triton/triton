{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, mock
, pytz
}:

let
  version = "1.5.1";
in
buildPythonPackage rec {
  name = "tzlocal-${version}";

  src = fetchPyPi {
    package = "tzlocal";
    inherit version;
    sha256 = "4ebeb848845ac898da6519b9b31879cf13b6626f7184c496037b818e238f2c4e";
  };

  buildInputs = [
    mock
    pytz
  ];

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
