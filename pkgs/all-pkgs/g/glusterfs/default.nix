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

  versionMajor = "3.9";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "glusterfs-${version}";

  src = fetchurl {
    url = "https://download.gluster.org/pub/gluster/glusterfs/${versionMajor}/"
      + "${version}/${name}.tar.gz";
    sha256 = "896fdbaf6696a90cfd5ce1e338e158669d0f6c839b13f3a1844e44907f88e30a";
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
