/* Build configuration used to build glibc, Info files, and locale
   information.  */

{ name
, fetchurl
, fetchTritonPatch
, stdenv
, linux-headers
, meta
, gccCross
, profilingLibraries
, preConfigure ? ""
, ...
} @ args:

let

  version = "2.21";

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
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/cve-2014-8121.patch";
      sha256 = "5d103ecc74c6bd30cf5314890bbb4efcfd55894a9a27230a763ba896e60dc596";
    })
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/cve-2015-1781.patch";
      sha256 = "cc9cf79a31c2ccec66bfa3d8c960b33d4a14f482c743aa12cfa8e3e1b93e044b";
    })
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/security-4a28f4d5.patch";
      sha256 = "a761ac60a7be72693044ae2584e2cfddaeb63c6b2b82192312b0391da3beff80";
    })
    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/security-bdf1ff05.patch";
      sha256 = "22f15a0fe09add647ef16f0350c42e8a92ec8dd0b802387da78a7cacb8d57c92";
    })

    (fetchTritonPatch {
      rev = "7ac98bac3cf181b4823633bfd9ce6ce7f831089e";
      file = "glibc/glibc-locale-incompatibility.patch";
      sha256 = "0a313362bbb49cbbf4ab8d44d7108aad12da4856c790659f74a50253ef49d38e";
    })
    ./cve-2015-7547.patch
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
    '';

  dontDisableStatic = true; # Disabling static is not recognized by glibc

  configureFlags = [
    "-C"
    "--enable-add-ons"
    "--enable-obsolete-rpc"
    "--sysconfdir=/etc"
    "--localedir=/var/run/current-system/sw/lib/locale"
    "libc_cv_ssp=no"
    "--with-headers=${linux-headers}/include"
    (if profilingLibraries then "--enable-profile" else "--disable-profile")
    "--enable-kernel=2.6.32"
    "--with-fp"
    "--with-tls"
  ];

  installFlags = [
    "sysconfdir=$(out)/etc"
  ];

  buildInputs = [ gccCross ];

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

# Remove the `gccCross' attribute so that the *native* glibc store path
# doesn't depend on whether `gccCross' is null or not.
// (removeAttrs args [ "gccCross" "fetchurl" "fetchTritonPatch" ]) //

{
  name = name + "-${version}";

  src = fetchurl {
    url = "mirror://gnu/glibc/glibc-${version}.tar.gz";
    sha256 = "0f4prv4c0fcpi85wv4028wqxn075197gwxhgf0vp571fiw2pi3wd";
  };

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

    configureScript="`pwd`/../$sourceRoot/configure"

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
