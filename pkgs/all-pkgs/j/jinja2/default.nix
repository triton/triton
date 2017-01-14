{ stdenv
, buildPythonPackage
, fetchPyPi

, markupsafe
}:

let
  version = "2.9.4";
in
buildPythonPackage rec {
  name = "Jinja2-${version}";

  src = fetchPyPi {
    package = "Jinja2";
    inherit version;
    sha256 = "aab8d8ca9f45624f1e77f2844bf3c144d180e97da8824c2a6d7552ad039b5442";
  };

  propagatedBuildInputs = [
    markupsafe
  ];

  doCheck = true;

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
