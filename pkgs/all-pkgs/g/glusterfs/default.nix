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
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "glusterfs-${version}";

  src = fetchurl {
    url = "https://download.gluster.org/pub/gluster/glusterfs/${versionMajor}/${version}/${name}.tar.gz";
    sha256 = "af3c666a7eca3f2d85bfa729cae38182e73d0abba48ee40b78be2f722aa0364e";
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
