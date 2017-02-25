{ stdenv
, autoreconfHook
, fetchFromGitHub
, gettext
, perl

, libxml2
}:

let
  version = "2.3.2";
in
stdenv.mkDerivation rec {
  name = "libsmbios-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "dell";
    repo = "libsmbios";
    rev = "v${version}";
    sha256 = "9247ae2566e8d3b7f9044db1c25d991410a4cee26c279691a7b48e0053244efb";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    perl
  ];

  buildInputs = [
    libxml2
  ];

  postPatch = ''
    sed -i 's, doxygen,,g' Makefile.am
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
