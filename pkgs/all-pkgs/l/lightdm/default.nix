{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, itstool
, libxml2

, audit_lib
, glib
, libgcrypt
, libxklavier
, pam
, xorg
}:

let
  ver_branch = "1.22";
  version = "1.22.0";
in

stdenv.mkDerivation rec {
  name = "lightdm-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm/${ver_branch}/${version}/+download/${name}.tar.xz";
    multihash = "QmZxr1nRvHY5bQPjmP6Z9qftFSjMC24BXJ7mbetM1DC78f";
    sha256 = "e4b9afb6a7e627440ccda140972631e54d005340ec6043d538281f28a8dbab28";
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
    libxklavier
    pam
    xorg.libX11
    xorg.libXdmcp
    xorg.libxcb
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

  meta = with stdenv.lib; {
    homepage = https://launchpad.net/lightdm;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
