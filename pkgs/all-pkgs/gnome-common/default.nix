{ stdenv
, fetchurl

, which
, autoconf
, automake
}:

stdenv.mkDerivation rec {
  name = "gnome-common-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-common/${versionMajor}/${name}.tar.xz";
    sha256 = "22569e370ae755e04527b76328befc4c73b62bfd4a572499fde116b8318af8cf";
  };

  patches = [
    (fetchurl {
      name = "gnome-common-patch";
      url = "https://bug697543.bugzilla-attachments.gnome.org/attachment.cgi?id=240935";
      sha256 = "17abp7czfzirjm7qsn2czd03hdv9kbyhk3lkjxg2xsf5fky7z7jl";
    })
  ];

  propagatedBuildInputs = [
    # autogen.sh which is using gnome-common tends to require which
    which
    autoconf
    automake
  ];

  meta = with stdenv.lib; {
    description = "Common files for development of Gnome packages";
    homepage = https://git.gnome.org/browse/gnome-common;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
