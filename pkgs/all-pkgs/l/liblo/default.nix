{ stdenv
, fetchurl
, lib
}:

let
  version = "0.29";
in
stdenv.mkDerivation rec {
  name = "liblo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/liblo/liblo/${version}/${name}.tar.gz";
    sha256 = "ace1b4e234091425c150261d1ca7070cece48ee3c228a5612d048116d864c06a";
  };

  configureFlags = [
    "--disable-tools"
    "--disable-examples"
  ];

  meta = with lib; {
    description = "Implementation of the Open Sound Control protocol";
    homepage = http://liblo.sourceforge.net/;
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
