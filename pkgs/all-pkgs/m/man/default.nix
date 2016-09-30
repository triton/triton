{ stdenv
, fetchTritonPatch
, fetchurl

, groff
, less
, xz
}:

stdenv.mkDerivation rec {
  name = "man-1.6g";

  src = fetchurl {
    url = "http://primates.ximian.com/~flucifredi/man/${name}.tar.gz";
    multihash = "QmPEiRrLPmTcipKqh5wLHNLerkpHPR5BEadLDBonf8Hm9o";
    sha256 = "ccdcb8c3f4e0080923d7e818f0e4a202db26c46415eaef361387c20995b8959f";
  };

  buildInputs = [
    groff
    less
    xz
  ];

  patches = [
    # Search in "share/man" relative to each path in $PATH (in addition
    # to "man").
    (fetchTritonPatch {
      rev = "6b5138f35bf922b6e99ba1268d9ace7f4c875325";
      file = "m/man/share.patch";
      sha256 = "ef0bcdc1f8c4425a7a807d0bee837d6a0fb5d2f3cbe7cc05922134cf606b1403";
    })

    # Prefer /etc/man.conf over $out/lib/man.conf.  Man only reads the
    # first file that exists, so this is necessary to allow the
    # builtin config to be overriden.
    (fetchTritonPatch {
      rev = "6b5138f35bf922b6e99ba1268d9ace7f4c875325";
      file = "m/man/conf.patch";
      sha256 = "27ee6eb2ff64e8fdca5e6a6fd414233eeaa650051090877349183a05154c9d17";
    })

    (fetchTritonPatch {
      rev = "f91320136e6cd9815cb8ecb67557a8de3bbf2388";
      file = "m/man/man-1.6f-man2html-compression-2.patch";
      sha256 = "92960d3837c59a8dabbbe11cdd119a00278aa636077fed7a43ee27383df3403a";
    })
    (fetchTritonPatch {
      rev = "f91320136e6cd9815cb8ecb67557a8de3bbf2388";
      file = "m/man/man-1.6-cross-compile.patch";
      sha256 = "ea806bcbcd4c0dae51fb1d5066dff5205ca768984794523db182d8d5779b2c72";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6f-unicode.patch";
      sha256 = "1c7624b5824e5585abd1c3d27ffd8e2d9207a05bf67e268aeaabaddf842d4709";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6c-cut-duplicate-manpaths.patch";
      sha256 = "a9557114725da765265891a4c1cf846b6a8f0b38c0180628a7fec7dfb1b76a4d";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.5m2-apropos.patch";
      sha256 = "c524c12eaa1f40e26eba40e3c6b88b32b5b24bd4cb75d2ba9a0361a539877ec9";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6g-fbsd.patch";
      sha256 = "fd4e50be32571103e9880b9291c691d45a225a7d6f2b27ff05168d22dbce7336";
    })
    (fetchTritonPatch {
      rev = "f91320136e6cd9815cb8ecb67557a8de3bbf2388";
      file = "m/man/man-1.6e-headers.patch";
      sha256 = "99ae9f46731a301aec8af678cb523347c537448214360a2e6b80a54206360f72";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6f-so-search-2.patch";
      sha256 = "8f4c6bcfde17291f92c677b82e2367458916488a1a8de6ba345eecd5bfccb2e8";
    })
    (fetchTritonPatch {
      rev = "f91320136e6cd9815cb8ecb67557a8de3bbf2388";
      file = "m/man/man-1.6g-compress.patch";
      sha256 = "2dca9ea262ac9e9d346f56c158585aee333e519150010f21edcceb54567346f3";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6f-parallel-build.patch";
      sha256 = "158a5bfb6bcfe7f82b1ed4586a62a30cbd7c7688244e3c274fcb490112c18d13";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6g-xz.patch";
      sha256 = "7c11114ec34f017d0641c9a7ecd9ad8b93f6c226e9bdd54fd0fedf1313451634";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6f-makewhatis-compression-cleanup.patch";
      sha256 = "885fde98225f122597dc16ab05cd5666c808df9d2004589e3aefe7ba63860267";
    })
    (fetchTritonPatch {
      rev = "f144e0b082a4b4c7692a5f4a4b4d80997c956e02";
      file = "m/man/man-1.6g-echo-escape.patch";
      sha256 = "31ae1e0f3321b2e9e16b604c71cbd9a806d061e80e80a3ff1ae24b22c8a501df";
    })
  ];

  postPatch = ''
    # make sure `less` handles escape sequences #287183
    sed -i configure \
      -e '/^DEFAULTLESSOPT=/s:"$:R":'
  '';

  preConfigure = ''
    sed -i configure \
      -e 's/^PREPATH=.*/PREPATH=$PATH/'
  '' + ''
    COMPRESS="${xz}/bin/xz"
    export COMPRESS
  '';

  preBuild = ''
    makeFlagsArray+=(
      "bindir=$out/bin"
      "sbindir=$out/sbin"
      "libdir=$out/lib"
      "mandir=$out/share/man"
    )
  '';

  postInstall = /* Fixup man.conf, Use UTF-8 by default. */ ''
    sed -i "$out/lib/man.conf" \
      -e 's/ -Tlatin1//g'
  '';

  meta = with stdenv.lib; {
    description = "Tools to read man pages";
    homepage = http://primates.ximian.com/~flucifredi/man/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
