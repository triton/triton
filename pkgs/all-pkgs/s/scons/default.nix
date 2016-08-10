{ stdenv
, fetchurl
, pythonPackages
}:

pythonPackages.buildPythonPackage rec {
  name = "scons-2.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/scons/${name}.tar.gz";
    multihash = "QmdMJFPe4BiX7T2LmQQsRs145GGihN1CEgxMfQu1qVLfCz";
    sha256 = "eb296b47f23c20aec7d87d35cfa386d3508e01d1caa3040ea6f5bbab2292ace9";
  };

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    homepage = "http://scons.org/";
    description = "An improved, cross-platform substitute for Make";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
