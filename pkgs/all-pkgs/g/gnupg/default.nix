{ stdenv
, fetchurl
, gettext
, texinfo

#, adns
, bzip2
, curl
, gnutls
, libassuan
, libgcrypt
, libgpg-error
, libksba
, libusb
, libusb-compat
, npth
, pth
, openldap
, pcsc-lite_lib
, readline
, sqlite
, zlib

, channel
}:

let
  inherit (stdenv)
    targetSystem;

  inherit (stdenv.lib)
    elem
    optional
    optionals
    platforms
    versionAtLeast
    versionOlder;

  sources = import ./sources.nix;

  tarballUrls = version: [
    "mirror://gnupg/gnupg/gnupg-${version}.tar.bz2"
  ];

  version = sources.${channel}.version;

  libusb' =
    if versionAtLeast channel "2.1" then
      libusb
    else
      libusb-compat;

  pth' =
    if versionAtLeast channel "2.1" then
      npth
    else
      pth;
in

stdenv.mkDerivation rec {
  name = "gnupg-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    inherit (sources.${channel}) sha256;
  };

  nativeBuildInputs = [
    gettext
    texinfo
  ];

  buildInputs = [
    #adns
    bzip2
    gnutls
    libassuan
    libgcrypt
    libgpg-error
    libksba
    libusb'
    pth'
    openldap
    readline
    sqlite
    zlib
  ] ++ optionals (versionOlder version "2.1") [
    curl
  ];

  postPatch = ''
    sed -i 's,"libpcsclite\.so[^"]*","${pcsc-lite_lib}/lib/libpcsclite.so",g' scd/scdaemon.c
  '';

  preConfigure = ''
    export CPPFLAGS="$CPPFLAGS -I$(echo "${libusb'}"/include/*)"
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
    # "--with-adns"  # This seems to be buggy
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

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls sources.${channel}.newVersion;
      pgpsigUrl = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        "D869 2123 C406 5DEA 5E0F  3AB5 249B 39D2 4F25 E3B6"
        "46CC 7308 65BB 5C78 EBAB  ADCF 0437 6F3E E085 6959"
        "031E C253 6E58 0D8E A286  A9F2 2071 B08A 33BD 3F06"
        "D238 EA65 D64C 67ED 4C30  73F2 8A86 1B1C 7EFD 60D9"
      ];
      sha256 = sources.${channel}.newSha256;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://gnupg.org;
    description = "a complete and free implementation of the OpenPGP standard";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
