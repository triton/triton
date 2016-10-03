{ stdenv
, automake
, bison
, fetchurl
, flex
, python

, acl
, attr
, glib
, libaio
, libibverbs
, librdmacm
, liburcu
, libxml2
, lvm2
, ncurses
, openssl
, readline
, sqlite
, util-linux_lib
, zlib
}:

let
  versionMajor = "3.8";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "glusterfs-${version}";

  src = fetchurl {
    url = "https://download.gluster.org/pub/gluster/glusterfs/${versionMajor}/"
      + "${version}/${name}.tar.gz";
    sha256 = "575969ec57ff29eaa880d6ea56c71314fde53e4e450c1af4194b04b74c2ee138";
  };

  nativeBuildInputs = [
    bison
    flex
    python
  ];

  buildInputs = [
    acl
    attr
    glib
    libaio
    libibverbs
    librdmacm
    liburcu
    libxml2
    lvm2
    ncurses
    openssl
    readline
    sqlite
    util-linux_lib
    zlib
  ];

  # Glusterfs ships broken config.* files
  postPatch = ''
    cp ${automake}/share/automake*/config.* .
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemddir=$out/lib/systemd/system"
      "--with-initdir=$out/etc/init.d"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-mountutildir=/run/current-system/sw/bin"
    "--enable-bd-xlator"
    "--enable-crypt-xlator"
    "--enable-qemu-block"
    "--disable-firewalld"
    "--disable-systemtap"
  ];

  preInstall = ''
    find . -name Makefile | xargs sed -i "s,\(pyglupydir = \)${python},\1$out,g"
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
      "utildir=$out/bin"
      "GLUSTERD_WORKDIR=$TMPDIR"
    )
  '';

  preFixup = ''
    # For some reason this pkgconfig file depends on an unknown library
    # that doesn't exist
    grep -q '\-lgfchangedb' $out/lib/pkgconfig/libgfdb.pc
    sed -i 's, -lgfchangedb,,g' $out/lib/pkgconfig/libgfdb.pc
  '';

  meta = with stdenv.lib; {
    description = "Distributed storage system";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
