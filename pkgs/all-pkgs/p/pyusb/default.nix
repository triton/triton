{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, libusb
}:

let
  version = "1.0.2";
in
buildPythonPackage {
  name = "pyusb-${version}";

  src = fetchPyPi {
    package = "pyusb";
    inherit version;
    sha256 = "4e9b72cc4a4205ca64fbf1f3fff39a335512166c151ad103e55c8223ac147362";
  };

  postPatch = ''
    sed -i 's#find_library=None#find_library=lambda x: "${libusb}/lib/libusb-1.0.so"#g' \
      usb/backend/libusb1.py
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
