{ stdenv, fetchurl, perl, gmp ? null
, aclSupport ? true, acl ? null
, selinuxSupport? false, libselinux ? null, libsepol ? null
, withPrefix ? false
}:

assert aclSupport -> acl != null;
assert selinuxSupport -> libselinux != null && libsepol != null;


with { inherit (stdenv.lib) optional optionals optionalString optionalAttrs; };

let
  self = stdenv.mkDerivation rec {
    name = "coreutils-8.25";

    src = fetchurl {
      url = "mirror://gnu/coreutils/${name}.tar.xz";
      sha256 = "11yfrnb94xzmvi4lhclkcmkqsbhww64wf234ya1aacjvg82prrii";
    };

    nativeBuildInputs = [ perl ];
    buildInputs = [ gmp ]
      ++ optional aclSupport acl
      ++ optionals selinuxSupport [ libselinux libsepol ];

    crossAttrs = {
      buildPhase = ''
        make || (
          pushd man
          for a in *.x; do
            touch `basename $a .x`.1
          done
          popd; make )
      '';

      postInstall = ''
        rm $out/share/man/man1/*
        cp ${self}/share/man/man1/* $out/share/man/man1
      '';

      # Needed for fstatfs()
      # I don't know why it is not properly detected cross building with glibc.
      configureFlags = [ "fu_cv_sys_stat_statfs2_bsize=yes" ];
      doCheck = false;
    };

    doCheck = true;

    NIX_LDFLAGS = optionalString selinuxSupport "-lsepol";

    # e.g. ls -> gls; grep -> ggrep
    postFixup = # feel free to simplify on a mass rebuild
      if withPrefix then
      ''
        (
          cd "$out/bin"
          find * -type f -executable -exec mv {} g{} \;
        )
      ''
      else null;

    meta = {
      homepage = http://www.gnu.org/software/coreutils/;
      description = "The basic file, shell and text manipulation utilities of the GNU operating system";

      longDescription = ''
        The GNU Core Utilities are the basic file, shell and text
        manipulation utilities of the GNU operating system.  These are
        the core utilities which are expected to exist on every
        operating system.
      '';

      license = stdenv.lib.licenses.gpl3Plus;

      platforms = stdenv.lib.platforms.all;

      maintainers = [ stdenv.lib.maintainers.eelco ];
    };
  };
in
  self
