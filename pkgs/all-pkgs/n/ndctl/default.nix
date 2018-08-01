{ stdenv
, asciidoc
, autoconf
, automake
, docbook_xml_dtd_45
, docbook-xsl
, fetchFromGitHub
, lib
, libtool
, libxslt
, which
, xmlto

, kmod
, json-c
, systemd_lib
, util-linux_lib
}:

let
  version = "61.2";
in
stdenv.mkDerivation rec {
  name = "ndctl-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "pmem";
    repo = "ndctl";
    rev = "v${version}";
    sha256 = "1b39188a6ddf5310f27ff1e89c70693508c1fc2b710b66eaaf8b546d2b22bb0a";
  };

  nativeBuildInputs = [
    asciidoc
    autoconf
    automake
    docbook_xml_dtd_45
    docbook-xsl
    libtool
    libxslt
    which
    xmlto
  ];

  buildInputs = [
    kmod
    json-c
    systemd_lib
    util-linux_lib
  ];

  postPatch = ''
    test -f git-version
    echo "#! $SHELL" >git-version
    echo 'echo ${version}' >>git-version
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
