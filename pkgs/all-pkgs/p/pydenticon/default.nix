{ stdenv
, buildPythonPackage
, fetchPyPi

, pillow
}:

let
  version = "0.3.1";
in
buildPythonPackage {
  name = "pydenticon-${version}";

  src = fetchPyPi {
    package = "pydenticon";
    inherit version;
    sha256 = "2ef363cdd6f4f0193ce62257486027e36884570f6140bbde51de72df321b77f1";
  };

  buildInputs = [
    pillow
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
