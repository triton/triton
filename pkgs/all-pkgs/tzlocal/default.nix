{ stdenv
, buildPythonPackage
, fetchurl

, pythonPackages
}:

buildPythonPackage rec {
  name = "tzlocal-1.2.2";

  src = fetchurl {
    url = "mirror://pypi/t/tzlocal/${name}.tar.gz";
    sha256 = "cbbaa4e9d25c36386f12af9febe315139fdd39317b91abcb42d782a5e93e525d";
  };

  buildInputs = [
    pythonPackages.pytz
  ];

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
