{ stdenv, fetchurl, fetchTritonPatch, ncurses, which, perl, autoreconfHook
, sslSupport ? true
, imapSupport ? true
, headerCache ? true
, saslSupport ? true
, gpgmeSupport ? true
, gdbm ? null
, openssl ? null
, cyrus_sasl ? null
, gpgme ? null
, withSidebar ? false
}:

assert headerCache -> gdbm != null;
assert sslSupport -> openssl != null;
assert saslSupport -> cyrus_sasl != null;
assert gpgmeSupport -> gpgme != null;

let
  version = "1.5.24";
in
stdenv.mkDerivation rec {
  name = "mutt${stdenv.lib.optionalString withSidebar "-with-sidebar"}-${version}";

  src = fetchurl {
    url = "http://ftp.mutt.org/pub/mutt/mutt-${version}.tar.gz";
    sha256 = "0012njrgxf1barjksqkx7ccid2l0xyikhna9mjs9vcfpbrvcm4m2";
  };

  buildInputs = with stdenv.lib;
    [ ncurses which perl ]
    ++ optional headerCache gdbm
    ++ optional sslSupport openssl
    ++ optional saslSupport cyrus_sasl
    ++ optional gpgmeSupport gpgme;

  nativeBuildInputs = stdenv.lib.optional withSidebar autoreconfHook;

  configureFlags = [
    "--with-mailpath=" "--enable-smtp"

    # Look in $PATH at runtime, instead of hardcoding /usr/bin/sendmail
    "ac_cv_path_SENDMAIL=sendmail"

    # This allows calls with "-d N", that output debug info into ~/.muttdebug*
    "--enable-debug"

    "--enable-pop" "--enable-imap"

    # The next allows building mutt without having anything setgid
    # set by the installer, and removing the need for the group 'mail'
    # I set the value 'mailbox' because it is a default in the configure script
    "--with-homespool=mailbox"
    (if headerCache then "--enable-hcache" else "--disable-hcache")
    (if sslSupport then "--with-ssl" else "--without-ssl")
    (if imapSupport then "--enable-imap" else "--disable-imap")
    (if saslSupport then "--with-sasl" else "--without-sasl")
    (if gpgmeSupport then "--enable-gpgme" else "--disable-gpgme")
  ];

  # Adding the sidebar
  patches = stdenv.lib.optional withSidebar [
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/sidebar-compose.patch";
      sha256 = "9d08dc2ca9aab3697273d6f77bce9d0ed701e066aeb42e1e4f15ded3b888c20b";
    })
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/sidebar-delimnullwide.patch";
      sha256 = "3fdae2e6db9b223fd30d24faf52dc0f9a9377cf75291533ee1e36c46fdcb314c";
    })
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/sidebar-dotpathsep.patch";
      sha256 = "e31c6be587087314f59d11235b95e03f3aa095f70c64d33b47d7d510466c0581";
    })
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/sidebar-new.patch";
      sha256 = "6c8345d67696145fa93d414ef6e514f577d5edbd2ba12369cde34198bdeb2edb";
    })
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/sidebar-newonly.patch";
      sha256 = "afd43eb47b27dd820c2195ac18cfe6421dcf0bb74188881521adbe9a8216efee";
    })
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/sidebar-utf8.patch";
      sha256 = "998fa2c73aa50c495071c019c2616f4b7fd1f8ef7bc44ee08bad5af76a69d776";
    })
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/sidebar.patch";
      sha256 = "fefc1d12ac6006c4ad53a7a3893170ae312ae8dabbc913bd15a8906a9f9396bf";
    })
    (fetchTritonPatch {
      rev = "e12fe48a1f06e9d8cecd18c79ec0f06bd6dc3fe7";
      file = "mutt/trash-folder.patch";
      sha256 = "bec56cd374735dfd2ccd05f606f3b0e4fa70ac0403bdc24d802cb3c98c1ddf40";
    })
  ];

  meta = with stdenv.lib; {
    description = "A small but very powerful text-based mail client";
    homepage = http://www.mutt.org;
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ the-kenny ];
  };
}
