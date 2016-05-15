{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "Jinja2-${version}";
  version = "2.8";

  src = fetchPyPi {
    package = "Jinja2";
    inherit version;
    sha256 = "1x0v41lp5m1pjix3l46zx02b7lqp2hflgpnxwkywxynvi3zz47xw";
  };

  buildInputs = [
    pythonPackages.markupsafe
  ];

  meta = with stdenv.lib; {
    description = "Jinja2 is a template engine written in pure Python";
    homepage = http://jinja.pocoo.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
