{ stdenv
, buildPythonPackage
, fetchPyPi

, zope-event
, zope-interface
}:

let
  version = "4.3.0";
in
buildPythonPackage rec {
  name = "zope.component-${version}";

  src = fetchPyPi {
    package = "zope.component";
    inherit version;
    sha256 = "bb4136c7443610f8c2d2d357cad247c3e90bb5e6f0b7a02b0edfb11924ff9bc2";
  };

  propagatedBuildInputs = [
    zope-event
    zope-interface
  ];

  meta = with stdenv.lib; {
    description = "Zope Component Architecture";
    homepage = https://github.com/zopefoundation/zope.component;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
