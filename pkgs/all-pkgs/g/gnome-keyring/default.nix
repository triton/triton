{ stdenv
, fetchurl
, gettext
, intltool
, lib
, libxslt

, gcr
, glib
, libcap-ng
, libgcrypt
, p11-kit
, pam
}:

let
  inherit (lib)
    boolEn
    boolWt;

  channel = "3.20";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "gnome-keyring-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-keyring/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "97964e723f454be509c956ed5e38b5c2fd7363f43bd3f153b94a4a63eb888c8c";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    gcr
    glib
    libcap-ng
    libgcrypt
    p11-kit
    pam
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-pkcs11-config=$out/etc/pkcs11/"
      "--with-pkcs11-modules=$out/lib/pkcs11/"
    )
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--${boolEn (pam != null)}-pam"
    "--enable-ssh-agent"
    "--disable-selinux"
    "--disable-p11-tests"
    "--disable-doc"
    "--disable-debug"
    "--disable-coverage"
    "--disable-valgrind"
    #"--with-dbus-services="
    #"--with-pam-dir="
    "--${boolWt (libcap-ng != null)}-libcap-ng"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-keyring/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Password and keyring managing daemon";
    homepage = https://wiki.gnome.org/Projects/GnomeKeyring;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
