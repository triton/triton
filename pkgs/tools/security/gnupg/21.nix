{ fetchurl, stdenv, libgcrypt, libassuan, libksba, npth
, autoreconfHook, gettext, texinfo, pcsclite

# Each of the dependencies below are optional.
# Gnupg can be built without them at the cost of reduced functionality.
, pinentry, x11Support ? true
, adns ? null, gnutls ? null, libusb ? null, openldap ? null
, readline ? null, zlib ? null, bzip2 ? null
}:

with {
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    optional
    platforms;
};

assert x11Support -> pinentry != null;

stdenv.mkDerivation rec {
  name = "gnupg-2.1.11";

  src = fetchurl {
    url = "mirror://gnupg/gnupg/${name}.tar.bz2";
    sha256 = "06mn2viiwsyq991arh5i5fhr9jyxq2bi0jkdj7ndfisxihngpc5p";
  };

  postPatch =
    optional (elem targetSystem platforms.linux)
    /* fix Emacs syntax highlighting */ ''
      sed -i scd/scdaemon.c \
        -e 's,"libpcsclite\.so[^"]*","${pcsclite}/lib/libpcsclite.so",g'
    '';

  postConfigure = "substituteAllInPlace tools/gpgkey2ssh.c";

  buildInputs = [
    libgcrypt libassuan libksba npth
    autoreconfHook gettext texinfo
    readline libusb gnutls adns openldap zlib bzip2
  ];

  configureFlags = optional x11Support "--with-pinentry-pgm=${pinentry}/bin/pinentry";

  meta = with stdenv.lib; {
    homepage = http://gnupg.org;
    description = "a complete and free implementation of the OpenPGP standard";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ wkennington ];
    platforms = platforms.all;
  };
}
