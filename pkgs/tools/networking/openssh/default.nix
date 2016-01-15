{ stdenv, fetchurl, fetchpatch, zlib, openssl, perl, libedit, pkgconfig, pam
, etcDir ? null
, hpnSupport ? false
, withKerberos ? false
, withGssapiPatches ? withKerberos
, kerberos
}:

assert withKerberos -> kerberos != null;

let

  hpnSrc = stdenv.mkDerivation {
    name = "openssh-hpn-patch-7.1p2";
    src = fetchurl {
      url = mirror://sourceforge/hpnssh/openssh-7_1_P1-hpn-14.9.diff;
      sha256 = "09aib9ygr2jm9xybl52sdblcx8jcickvgh0acqkh8h5vlkvqh3b8";
    };
    # Fix the version for the second patch release
    buildCommand = ''
      sed '/SSH_PORTABLE/ s,"p1","p2",g' $src > $out
    '';
    preferLocalBuild = true;
  };

  gssapiSrc = fetchpatch {
    url = "http://anonscm.debian.org/cgit/pkg-ssh/openssh.git/plain/debian/patches/gssapi.patch?h=debian/6.9p1-3";
    sha256 = "03zlgkb3a1igj20kn8cz55ggaxg65h6f0kg20m39m0wsb94qjdb1";
  };

in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "openssh-7.1p2";

  src = fetchurl {
    url = "mirror://openbsd/OpenSSH/portable/${name}.tar.gz";
    sha256 = "dd75f024dcf21e06a0d6421d582690bf987a1f6323e32ad6619392f3bfde6bbd";
  };

  patches = [ ./locale_archive.patch ]
    ++ optional withGssapiPatches gssapiSrc
    ++ optional hpnSupport hpnSrc;

  buildInputs = [ zlib openssl libedit pkgconfig pam ]
    ++ optional withKerberos [ kerberos ];

  # I set --disable-strip because later we strip anyway. And it fails to strip
  # properly when cross building.
  configureFlags = [
    "--localstatedir=/var"
    "--with-pid-dir=/run"
    "--with-mantype=man"
    "--with-libedit=yes"
    "--disable-strip"
    (if pam != null then "--with-pam" else "--without-pam")
  ] ++ optional (etcDir != null) "--sysconfdir=${etcDir}"
    ++ optional withKerberos "--with-kerberos5=${kerberos}"
    ++ optional stdenv.isDarwin "--disable-libutil";

  preConfigure = ''
    configureFlagsArray+=("--with-privsep-path=$out/empty")
    mkdir -p $out/empty
  '';

  enableParallelBuilding = true;

  postInstall = ''
    # Install ssh-copy-id, it's very useful.
    cp contrib/ssh-copy-id $out/bin/
    chmod +x $out/bin/ssh-copy-id
    cp contrib/ssh-copy-id.1 $out/share/man/man1/
  '';

  installTargets = [ "install-nokeys" ];
  installFlags = [
    "sysconfdir=\${out}/etc/ssh"
  ];

  meta = {
    homepage = "http://www.openssh.org/";
    description = "An implementation of the SSH protocol";
    license = stdenv.lib.licenses.bsd2;
    platforms = platforms.unix;
    maintainers = with maintainers; [ eelco ];
  };
}
