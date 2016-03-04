{ stdenv
, fetchurl
, which
, perl

, gmp
, guile
, libxml2
}:

stdenv.mkDerivation rec {
  name = "autogen-${version}";
  version = "5.18.7";

  src = fetchurl {
    url = "mirror://gnu/autogen/autogen-${version}.tar.xz";
    sha256 = "01d4m8ckww12sy50vgyxlnz83z9dxqpyqp153cscncc9w6jq19d7";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  buildInputs = [
    guile
    libxml2
    gmp
  ];

  # Fix a broken sed expression used for detecting the minor
  # version of guile we are using
  postPatch = ''
    sed -i "s,sed '.*-I.*',sed 's/\\\(^\\\| \\\)-I/\\\1/g',g" configure
  '';

  meta = with stdenv.lib; {
    description = "Automated text and program generation tool";
    license = with licenses; [ gpl3Plus lgpl3Plus ];
    homepage = http://www.gnu.org/software/autogen/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
