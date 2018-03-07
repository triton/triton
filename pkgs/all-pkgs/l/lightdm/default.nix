{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, itstool
, lib
, libxml2

, audit_lib
, glib
, libgcrypt
, libx11
, libxcb
, libxdmcp
, libxklavier
, pam
}:

let
  ver_branch = "1.24";
  version = "${ver_branch}.0";
in

stdenv.mkDerivation rec {
  name = "lightdm-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm/${ver_branch}/${version}/+download/${name}.tar.xz";
    multihash = "QmccP64cjisjrVUNFAjbV9gwvp5XUTtTeCeTBrMKHfnVeS";
    sha256 = "cd509b74382bcf382c6e3e4b54ac30ba804022fec968d6993d134552ea1a43a2";
  };

  patches = [
    (fetchTritonPatch {
      rev = "4ea97c22cd362ea9b2586f916795eb5cba5499fc";
      file = "l/lightdm/fix-paths.patch";
      sha256 = "a408fa254ff01ec2b9c805cdf5a22da6bf6e49c1fdb82dc3882d500295ff8819";
    })
  ];

  nativeBuildInputs = [
    intltool
    itstool
    libxml2
  ];

  buildInputs = [
    audit_lib
    glib
    libgcrypt
    libx11
    libxcb
    libxdmcp
    libxklavier
    pam
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-tests"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIr"
    )
  '';

  meta = with lib; {
    homepage = https://launchpad.net/lightdm;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
