/* Build configuration used to build glibc, Info files, and locale
   information.  */

{ name
, fetchurl
, fetchTritonPatch
, stdenv
, linux-headers
, meta
, preConfigure ? ""
, preBuild ? ""
, ...
} @ args:

let

  version = "2.24";

  nscdPatch = fetchTritonPatch {
    rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
    file = "glibc/glibc-remove-datetime-from-nscd.patch";
    sha256 = "72a050d394c9a4785f997b9c853680150996b65646a388e347e51d3dde8790e8";
  };

in

stdenv.mkDerivation ({
  patches = [
    /* Have rpcgen(1) look for cpp(1) in $PATH.  */
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/rpcgen-path.patch";
      sha256 = "4f7f58b96098b0ae3e2945481f9007c719c5f56704724a4d36074b76e29bee81";
    })

    /* Allow NixOS and Nix to handle the locale-archive. */
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/nix-locale-archive.patch";
      sha256 = "079f4eb8f051c20291ea8bc133c582bf4e9c743948f5052069cb40fe776eeb79";
    })

    /* Don't use /etc/ld.so.cache, for non-NixOS systems.  */
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/dont-use-system-ld-so-cache.patch";
      sha256 = "c55c79b1f5e41d8331e23801556b90a678803746f92c7cf550c13f3f775dd974";
    })

    /* Don't use /etc/ld.so.preload, but /etc/ld-nix.so.preload.  */
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/dont-use-system-ld-so-preload.patch";
      sha256 = "de897e0f53379f87459f5d350a229768159159f5e44eb7f6bd3050fd416d4aa6";
    })

    /* Add blowfish password hashing support.  This is needed for
       compatibility with old NixOS installations (since NixOS used
       to default to blowfish). */
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/glibc-crypt-blowfish.patch";
      sha256 = "436f80937b5e6a40f198cc7552fb502c71f44e2e2e00a25520cf4efce3e660a4";
    })

    /* The command "getconf CS_PATH" returns the default search path
       "/bin:/usr/bin", which is inappropriate on NixOS machines. This
        patch extends the search path by "/run/current-system/sw/bin". */
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/fix_path_attribute_in_getconf.patch";
      sha256 = "d7176285b786c701bd963d97047d845aaf05fdc1e400de3a0526e0cd8ab68047";
    })

    (fetchTritonPatch {
      rev = "2372c3f82f0b4b5f81202ca6a7e10898b9becc46";
      file = "g/glibc/fix-nsswitch.patch";
      sha256 = "71bcbce374883fedd895ff67eb4400c97c43b229df457a73f218c89a69b4cdb5";
    })
  ];

  postPatch =
    # Needed for glibc to build with the gnumake 3.82
    # http://comments.gmane.org/gmane.linux.lfs.support/31227
    ''
      sed -i 's/ot \$/ot:\n\ttouch $@\n$/' manual/Makefile
    ''
    # nscd needs libgcc, and we don't want it dynamically linked
    # because we don't want it to depend on bootstrap-tools libs.
    + ''
      echo "LDFLAGS-nscd += -static-libgcc" >> nscd/Makefile
    ''
    # Replace the date and time in nscd by a prefix of $out.
    # It is used as a protocol compatibility check.
    # Note: the size of the struct changes, but using only a part
    # would break hash-rewriting. When receiving stats it does check
    # that the struct sizes match and can't cause overflow or something.
    + ''
      cat ${nscdPatch} | sed "s,@out@,$out," | patch -p1
    ''
    # CVE-2014-8121, see https://bugzilla.redhat.com/show_bug.cgi?id=1165192
    + ''
      substituteInPlace ./nss/nss_files/files-XXX.c \
        --replace 'status = internal_setent (stayopen);' \
                  'status = internal_setent (1);'
    ''
    # Always treat fortify source warnings as errors
    + ''
      sed -i 's,\(#[ ]*\)warning\( _FORTIFY_SOURCE\),\1error\2,g' include/features.h
    '';

  disableStatic = false; # Disabling static is not recognized by glibc

  configureFlags = [
    "-C"
    "--enable-add-ons"
    "--enable-obsolete-rpc"
    "--sysconfdir=/etc"
    "--localedir=/var/run/current-system/sw/lib/locale"
    "libc_cv_ssp=no"
    "--with-headers=${linux-headers}/include"
    "--enable-profile"
    "--enable-kernel=3.2"
    "--disable-werror"
    "--with-fp"
    "--with-tls"
  ];

  installFlags = [
    "sysconfdir=$(out)/etc"
  ];

  # Needed to install share/zoneinfo/zone.tab.  Set to impure /bin/sh to
  # prevent a retained dependency on the bootstrap tools in the stdenv-linux
  # bootstrap.
  BASH_SHELL = "/bin/sh";

  # Workaround for this bug:
  #   http://sourceware.org/bugzilla/show_bug.cgi?id=411
  # I.e. when gcc is compiled with --with-arch=i686, then the
  # preprocessor symbol `__i686' will be defined to `1'.  This causes
  # the symbol __i686.get_pc_thunk.dx to be mangled.
  NIX_CFLAGS_COMPILE = stdenv.lib.optionalString (stdenv.system == "i686-linux") "-U__i686"
    + " -Wno-error=strict-prototypes";
}

// (removeAttrs args [ "fetchurl" "fetchTritonPatch" "linux-headers" ]) //

{
  name = name + "-${version}";

  src = fetchurl {
    url = "mirror://gnu/glibc/glibc-${version}.tar.xz";
    sha256 = "1s8kas3yan6pzav7ic59dz41alqalphv7vww4138ag30wh0fpvwl";
  };

  # Glibc cannot have itself in its RPATH.
  NIX_DONT_SET_RPATH = true;
  NIX_NO_SELF_RPATH = true;
  NIX_CFLAGS_LINK = false;
  NIX_LDFLAGS_BEFORE = false;
  patchELFAddRpath = false;

  preBuild = ''
    unset CFLAGS

    ${preBuild}
  '';

  # Remove absolute paths from `configure' & co.; build out-of-tree.
  preConfigure = ''
    export PWD_P=$(type -tP pwd)
    for i in configure io/ftwtest-sh; do
        # Can't use substituteInPlace here because replace hasn't been
        # built yet in the bootstrap.
        sed -i "$i" -e "s^/bin/pwd^$PWD_P^g"
    done

    mkdir ../build
    cd ../build

    configureScript="`pwd`/../$srcRoot/configure"

    ${stdenv.lib.optionalString (stdenv.cc.libc != null)
      ''makeFlags="$makeFlags BUILD_LDFLAGS=-Wl,-rpath,${stdenv.cc.libc}/lib"''
    }

    ${preConfigure}
  '';

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libc/;
    description = "The GNU C Library";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  } // meta;
})
