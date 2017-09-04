{ stdenv
, automake
, bison
, fetchurl
, flex
, makeWrapper
, python

, acl
, attr
, coreutils
, gawk
, glib
, gnugrep
, gnused
, libaio
, liburcu
, libxml2
, lvm2
, ncurses
, openssl
, rdma-core
, readline
, sqlite
, util-linux_lib
, which
, zlib
}:

let
  inherit (stdenv.lib)
    concatStringsSep;

  mountPath = [
    attr
    coreutils
    gawk
    gnugrep
    gnused
    which
  ];

  versionMajor = "3.12";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "glusterfs-${version}";

  src = fetchurl {
    url = "https://download.gluster.org/pub/gluster/glusterfs/${versionMajor}/"
      + "${version}/${name}.tar.gz";
    sha256 = "874292f6a09f7a2f6d81fe43bf478717d72093ffcd27de7ff1aa398256210459";
  };

  nativeBuildInputs = [
    bison
    flex
    makeWrapper
    python
  ];

  buildInputs = [
    acl
    attr
    glib
    libaio
    liburcu
    libxml2
    lvm2
    ncurses
    openssl
    rdma-core
    readline
    sqlite
    util-linux_lib
    zlib
  ];

  postPatch = ''
    # Glusterfs ships broken config.* files
    cp ${automake}/share/automake*/config.* .

    # Don't chown / setuid anything
    sed -i '/\(chown\|chmod\)/d' contrib/fuse-util/Makefile.in
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
  ];

  preInstall = ''
    find . -name Makefile -exec sed -i {} \
      -e "s,sysconfdir[ ]*=.*,sysconfdir = $out/etc," \
      -e "s,localstatedir[ ]*=.*,localstatedir = $TMPDIR," \
      -e "s,mountutildir[ ]*=.*,mountutildir = $out/bin," \
      -e "s,utildir[ ]*=.*,utildir = $out/bin," \
      -e "s,GLUSTERD_WORKDIR[ ]*=.*,GLUSTERD_WORKDIR = $TMPDIR," \
      -e "\,/var/lib/glusterd/events,d" \
      \;
  '';

  preFixup = ''
    # For some reason this pkgconfig file depends on an unknown library
    # that doesn't exist
    grep -q '\-lgfchangedb' $out/lib/pkgconfig/libgfdb.pc
    sed -i 's, -lgfchangedb,,g' $out/lib/pkgconfig/libgfdb.pc

    # Fix mount.glusterfs
    sed -i '/export PATH/d' "$out"/bin/mount.glusterfs
    wrapProgram "$out"/bin/mount.glusterfs \
      --set PATH "${concatStringsSep ":" (map (n: "${n}/bin") mountPath)}"
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
