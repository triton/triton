{ stdenv
, fetchurl
, lib

, which
, autoconf
, automake
}:

let
  channel = "3.18";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "gnome-common-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-common/${channel}/${name}.tar.xz";
    hashOutput = false;
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
    # GNOME autogen.sh scripts that use gnome-common tend to require which
    which
    autoconf
    automake
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/gnome-common/"
          + "${channel}/${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Common files for development of Gnome packages";
    homepage = https://git.gnome.org/browse/gnome-common;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
