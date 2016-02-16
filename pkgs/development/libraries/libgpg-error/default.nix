{ stdenv, fetchurl, gettext }:

stdenv.mkDerivation rec {
  name = "libgpg-error-1.21";

  src = fetchurl {
    url = "mirror://gnupg/libgpg-error/${name}.tar.bz2";
    sha256 = "0kdq2cbnk84fr4jqcv689rlxpbyl6bda2cn6y3ll19v3mlydpnxp";
  };

  postPatch = "sed '/BUILD_TIMESTAMP=/s/=.*/=1970-01-01T00:01+0000/' -i ./configure";

  # If architecture-dependent MO files aren't available, they're generated
  # during build, so we need gettext for cross-builds.
  crossAttrs.buildInputs = [ gettext ];

  doCheck = true;

  meta = {
    homepage = "https://www.gnupg.org/related_software/libgpg-error/index.html";
    description = "A small library that defines common error values for all GnuPG components";

    longDescription = ''
      Libgpg-error is a small library that defines common error values
      for all GnuPG components.  Among these are GPG, GPGSM, GPGME,
      GPG-Agent, libgcrypt, Libksba, DirMngr, Pinentry, SmartCard
      Daemon and possibly more in the future.
    '';

    license = stdenv.lib.licenses.lgpl2Plus;
    platforms = stdenv.lib.platforms.all;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
  };
}

