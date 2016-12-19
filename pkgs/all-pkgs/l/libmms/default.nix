{ stdenv
, fetchurl
, lib

, glib
}:

let
  version = "0.6.4";
in
stdenv.mkDerivation rec {
  name = "libmms-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libmms/libmms/${version}/${name}.tar.gz";
    sha256 = "0kvhxr5hkabj9v7ah2rzkbirndfqdijd9hp8v52c1z6bxddf019w";
  };

  buildInputs = [
    glib
  ];

  meta = with lib; {
    description = "Microsoft Media Server (MMS) media streaming protocol";
    homepage = http://libmms.sourceforge.net;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
