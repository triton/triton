{ stdenv
, buildPythonPackage
, fetchPyPi
, fetchTritonPatch
}:

buildPythonPackage rec {
  name = "progressbar-${version}";
  version = "2.3";

  src = fetchPyPi {
    package = "progressbar";
    inherit version;
    sha256 = "b2d38a729785149e65323381d2e6fca0a5e9615a6d8bcf10bfa8adedfc481254";
  };

  patches = [
    # Remove format as a slot attribute, not compatible with python 3.3+
    (fetchTritonPatch {
      rev = "1c4e4c62aaf32cfaf7164c34c805e8d550fa8020";
      file = "progressbar/progressbar-2.3-python3.3.patch";
      sha256 = "0f414aeb9605c892472c49af588079e2cbc922f985f0d6a5dd6a3a77c4c7e837";
    })
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Text progressbar library for python";
    homepage = https://github.com/niltonvolpato/python-progressbar;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
