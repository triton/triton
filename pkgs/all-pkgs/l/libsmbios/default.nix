{ stdenv
, autoreconfHook
, fetchFromGitHub
, gettext
, perl

, libxml2
, python2Packages
}:

let
  version = "2.3.3";
in
stdenv.mkDerivation rec {
  name = "libsmbios-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "dell";
    repo = "libsmbios";
    rev = "v${version}";
    sha256 = "3cae3fa513023c237ee967745540008c8687587a24aba581953f25eab74c64f9";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    perl
  ];

  buildInputs = [
    libxml2
    python2Packages.python
  ];

  postPatch = ''
    sed -i 's, doxygen,,g' Makefile.am
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-libsmbios_cxx"
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
