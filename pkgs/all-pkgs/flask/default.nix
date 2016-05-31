{ stdenv
, buildPythonPackage
, fetchPyPi

, click
, itsdangerous
, jinja2
, werkzeug
}:

let
  version = "0.11";
in
buildPythonPackage {
  name = "Flask-${version}";

  src = fetchPyPi {
    package = "Flask";
    inherit version;
    sha256 = "29a7405a7f0de178232fe48cd9b2a2403083bf03bd34eabe12168863d4cdb493";
  };

  propagatedBuildInputs = [
    click
    itsdangerous
    jinja2
    werkzeug
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
