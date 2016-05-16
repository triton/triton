{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "tzlocal-${version}";
  version = "1.2.2";

  src = fetchPyPi {
    package = "tzlocal";
    inherit version;
    sha256 = "cbbaa4e9d25c36386f12af9febe315139fdd39317b91abcb42d782a5e93e525d";
  };

  buildInputs = [
    pythonPackages.pytz
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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
