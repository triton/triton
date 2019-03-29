{ stdenv
, asciidoctor_1
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

, bash-completion
, keyutils
, kmod
, json-c
, systemd_lib
, systemd-dummy
, util-linux_lib
}:

let
  version = "64.1";
in
stdenv.mkDerivation rec {
  name = "ndctl-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "pmem";
    repo = "ndctl";
    rev = "v${version}";
    sha256 = "3ecb47251b48a529dc82fd7ea13322f30aa51962bf73ddcf9cb1bd9a1da09ba6";
  };

  nativeBuildInputs = [
    asciidoctor_1
    autoconf
    automake
    docbook_xml_dtd_45
    docbook-xsl
    libtool
    #libxslt
    which
    #xmlto
  ];

  buildInputs = [
    bash-completion
    keyutils
    kmod
    json-c
    systemd_lib
    systemd-dummy
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

  preInstall = ''
    cat Makefile
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "ndctl_keysdir=$out/etc/ndctl/keys"
      "ndctl_monitorconfdir=$out/etc/ndctl"
      "localstatedir=$TMPDIR"
    )
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
