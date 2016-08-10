{ stdenv
, fetchurl
, gettext
, perl

, libxml2
}:

stdenv.mkDerivation rec {
  name = "libsmbios-2.3.0";

  src = fetchurl {
    url = "https://linux.dell.com/libsmbios/download/libsmbios/${name}/${name}.tar.xz";
    sha256 = "c71f040df170f6b55a874f292929792449ba1fad6029ba18544ed04a88343c1c";
  };

  nativeBuildInputs = [
    gettext
    perl
  ];

  buildInputs = [
    libxml2
  ];

  postPatch = ''
    # Fix building without doxygen
    sed -i 's, doxygen,,g' Makefile.in
  '';

  # It forgets to install headers.
  postInstall = ''
    mkdir -p "$out/include"
    cp -va "src/include/"* "$out/include/"
    cp -va "out/public-include/"* "$out/include/"
  '';

  meta = with stdenv.lib; {
    homepage = "http://linux.dell.com/libsmbios/main";
    description = "a library to obtain BIOS information";
    license = licenses.gpl2Plus; # alternatively, under the Open Software License version 2.1
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
