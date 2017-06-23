{ stdenv
, buildPythonPackage
, fetchPyPi

, dnspython
}:

let
  version = "1.6.2";
in
buildPythonPackage {
  name = "dnsdiag-${version}";

  src = fetchPyPi {
    package = "dnsdiag";
    inherit version;
    sha256 = "de455946346df2212e02f4c4138aaaa11203cbd6681970f08946e3af93c9e99c";
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
