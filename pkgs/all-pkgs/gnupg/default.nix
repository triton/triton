{ stdenv
, fetchurl
, gettext
, texinfo

, adns
, bzip2
, gnutls
, libassuan
, libgcrypt
, libgpg-error
, libksba
, libusb
, npth
, openldap
, pcsclite
, readline
, sqlite
, zlib

, channel ? "2.1"
}:

let
  sources = import ./sources.nix;

  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    optional
    platforms;
in
stdenv.mkDerivation rec {
  name = "gnupg-${sources.${channel}.version}";

  src = fetchurl {
    url = "mirror://gnupg/gnupg/${name}.tar.bz2";
    inherit (sources.${channel}) sha256;
  };

  nativeBuildInputs = [
    gettext
    texinfo
  ];

  buildInputs = [
    adns
    bzip2
    gnutls
    libassuan
    libgcrypt
    libgpg-error
    libksba
    libusb
    npth
    openldap
    readline
    sqlite
    zlib
  ];

  postPatch = ''
    sed -i 's,"libpcsclite\.so[^"]*","${pcsclite}/lib/libpcsclite.so",g' scd/scdaemon.c
  '';

  configureFlags = [
    "--with-pinentry-pgm=pinentry"
    "--disable-selinux-support"
    "--disable-gpg-idea"
    "--disable-gpg-cast5"
    "--disable-gpg-md5"
    "--enable-zip"
    "--enable-bzip2"
    "--with-capabilities"
    "--enable-card-support"
    "--enable-ccid-driver"
    "--enable-sqlite"
    "--disable-ntbtls"
    "--enable-gnutls"
    "--with-adns"
    "--enable-ldap"
    "--with-mailprog=sendmail"
    "--with-zlib"
    "--with-bzip2"
    "--enable-optimization"
    "--disable-build-timestamp"
  ];

  # We always want to have a gpg executable
  postInstall = ''
    ln -s gpg2 $out/bin/gpg
  '';

  meta = with stdenv.lib; {
    homepage = http://gnupg.org;
    description = "a complete and free implementation of the OpenPGP standard";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
