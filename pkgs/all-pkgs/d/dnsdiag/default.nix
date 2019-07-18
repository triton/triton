{ stdenv
, buildPythonPackage
, fetchPyPi

, dnspython
}:

let
  version = "1.6.4";
in
buildPythonPackage {
  name = "dnsdiag-${version}";

  src = fetchPyPi {
    package = "dnsdiag";
    inherit version;
    sha256 = "f50495e98928afff201516fcad89e31c80d443523f02cedc61c35961ec7bf10a";
  };

  propagatedBuildInputs = [
    dnspython
  ];

  postInstall = ''
    find "$out/bin" -type f -not -name \*.py -exec rm {} \; -exec ln -sv {}.py {} \;
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
