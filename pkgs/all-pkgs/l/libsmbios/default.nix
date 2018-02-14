{ stdenv
, autoreconfHook
, fetchFromGitHub
, gettext
, help2man
, perl

, libxml2
, python3Packages
}:

let
  version = "2.4.1";
in
stdenv.mkDerivation rec {
  name = "libsmbios-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "dell";
    repo = "libsmbios";
    rev = "v${version}";
    sha256 = "54c173da3b49c9dafe17af29f900a4188e3e9e6a7c7be31b090514706b03c52d";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    help2man
    perl
  ];

  buildInputs = [
    libxml2
    python3Packages.python
  ];

  postPatch = ''
    sed -i 's, doxygen,,g' Makefile.am
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-doxygen"
    "--disable-graphviz"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
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
