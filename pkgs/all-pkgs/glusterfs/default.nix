{ stdenv
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
  versionMajor = "3.7";
  versionMinor = "11";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "glusterfs-${version}";

  src = fetchurl {
    url = "https://download.gluster.org/pub/gluster/glusterfs/${versionMajor}/${version}/${name}.tar.gz";
    sha256 = "ad07b7e887b33e10cd6293e9f7884fa0a07e7099ea96d23271d5a96afefd6d20";
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
    # For some reason this pkgconfig file depends on an unknown library that doesn't exist
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
