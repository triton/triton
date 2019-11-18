{ stdenv
, fetchurl
}:

let
  version = "1.2.1";
in
stdenv.mkDerivation rec {
  name = "re2c-${version}";

  src = fetchurl {
    url = "https://github.com/skvadrik/re2c/releases/download/${version}/${name}.tar.xz";
    sha256 = "1a4cd706b5b966aeffd78e3cf8b24239470ded30551e813610f9cd1a4e01b817";
  };

  postFixup = ''
    rm -rv "$bin"/share
  '';

  outputs = [
    "bin"
    "man"
  ];

  meta = with stdenv.lib; {
    description = "Tool for writing very fast and very flexible scanners";
    homepage = "http://re2c.org";
    license = licenses.publicDomain;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = platforms.all;
  };
}
