{ stdenv
, fetchTritonPatch
, fetchurl
, lib
, substituteAll

, curl
, libpcap
, linux-headers
, openssl_1-0-2
, pam
}:

let
  inherit (lib)
    optionals;

  ppp-dhcp = fetchurl {
    url = "http://www.netservers.net.uk/gpl/ppp-dhcpc.tgz";
    multihash = "QmT3nn26NeeXs8cokCuqJnU93U46rrNDLXJfCF9svnZqNd";
    sha256 = "977fd980bb1d285963d8e27a87b7601ea84317faadfdb40989b258d1853db644";
  };
in
stdenv.mkDerivation rec {
  name = "ppp-2.4.7";

  src = fetchurl {
    url = "mirror://samba/ppp/${name}.tar.gz";
    sha256 = "0c7vrjxl52pdwi4ckrvfjr08b31lfpgwf3pp0cqy76a77vfs7q02";
  };

  buildInputs = [
    curl
    libpcap
    linux-headers
    openssl_1-0-2
    pam
    stdenv.libc
  ];

  postUnpack = ''
    mkdir -p $srcRoot/pppd/plugins
    tar zxvf ${ppp-dhcp} -C $srcRoot/pppd/plugins
  '';

  patches = [
    (substituteAll {
      src = ./nix-purity.patch;
      inherit libpcap;
      glibc = stdenv.libc;
    })
    # Gentoo patchset 2.4.7-2
    # https://dev.gentoo.org/~pinkbyte/distfiles/patches/
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/02_all_make-vars.patch";
      sha256 = "0ec7e8c1f1f681057f376b5c789ef5a324a141ea1381205fbe9a64df65a7e217";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/03_all_use_internal_logwtmp.patch";
      sha256 = "1bbe171fec0c98f07bf19437b534c8b253b373d4571727770398d86fc6d40d37";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/04_all_mpls.patch";
      sha256 = "0c6c0c10081e7748b8032f1fab44e8e31b93b7e4a4755656b3f1a31f20fc1bbf";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/06_all_killaddr-smarter.patch";
      sha256 = "4c6c83d66c30ddcf0a9ce9166514309474c45c805b4ae44620fc43685b0a4cbc";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/08_all_wait-children.patch";
      sha256 = "46ecaad1c0efa4ddb4878990dd8c9b61cd3e2807e2dbac85f881fffa96a350b7";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/10_all_defaultgateway.patch";
      sha256 = "44acdd7598237dfd73ee784e535871b7b6fcd9a21499d5469b8bd395e23cc26d";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/12_all_linkpidfile.patch";
      sha256 = "4e929dcc631196c85cc8858f18c7e442de6b82abb15aa735f982911487210ff5";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/16_all_auth-fail.patch";
      sha256 = "a9d087b902de1c884ca97f048ab45bc41d4e0e3863ce4c6518a562d9a3ef2023";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/18_all_defaultmetric.patch";
      sha256 = "08d0908f3bdc615951a1e3c9ef7954c3c6a8c1c308e22dd610fbac1473ccb8c6";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/20_all_dev-ppp.patch";
      sha256 = "280b90f9cea3d308561423efa278329f74581a2e86c16ce88e1accff210ac7a3";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/24_all_passwordfd-read-early.patch";
      sha256 = "0e986caa84c5c10c99260b4a130b219860fc9f7d32f233fc57bc0e5c991f6d28";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/26_all_pppd-usepeerwins.patch";
      sha256 = "764134da123fcdf7df7977119dad9aa67e5362720065bcba3527ae300c59fa40";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/28_all_connect-errors.patch";
      sha256 = "8b1839e196f8b9f75a53d23c48d0e70523dbb4248ab7045660aa6370a5098a87";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/30_all_Makefile.patch";
      sha256 = "f9f5a3a112373443098621ed82d5dfd49136113cacdfd4202fe9a767b316e7cb";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/32_all_pado-timeout.patch";
      sha256 = "703c32285f5fb0011a7157fbd8075016965de2d370b1def3db06da98ab1dbfdc";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/34_all_lcp-echo-adaptive.patch";
      sha256 = "0c0ad5a3af1cbfe4dc3872d6c42dac89ae186970b9ee657cb543904b5fb1d0a1";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/80_all_eaptls-mppe-0.997.patch";
      sha256 = "17a82a3d438660a35fe89569961a88ce7dba30236d227a882ddf0ff7cbd3a187";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/85_all_dhcp-make-vars.patch";
      sha256 = "3c1fb119ea7ab0d43d308c90cf2f5e0281d8258b4021c7f1b330c64d7e013a28";
    })
    (fetchTritonPatch {
      rev = "c6c35cb66086fa42cd6b547f739f3b4da042a54e";
      file = "p/ppp/86_all_dhcp-sys_error_to_strerror.patch";
      sha256 = "e14b4853b28787b9e56ab5cd8fb26616075cca82396c6efe76e3a6b03afc285f";
    })
  ];

  postPatch = /* Enable dhcp */ ''
    sed -i pppd/plugins/Makefile.linux \
      -e '/^SUBDIRS :=/s:$: dhcp:'
  '' + /* Don't setuid as nixbuild doesn't allow this */ ''
    sed -i pppd/plugins/pppoatm/Makefile.linux \
      -i pppd/plugins/rp-pppoe/Makefile.linux \
      -e 's/-m 4550/-m 550/'
  '';

  preBuild = ''
    # Prevent build from creating sbin/
    makeFlagsArray+=("BINDIR=$out/bin")
  '';

  NIX_LDFLAGS = [
    "-L${stdenv.libc}/lib -lcrypt"
  ];

  makeFlags = [
    /* Microsoft callback control protocol */
    "CBDP=y"
  ] ++ optionals (pam != null) [
    /* PAM support */
    "USE_PAM=y"
  ];

  meta = with lib; {
    description = "Point-to-point implementation for Linux and Solaris";
    homepage = https://ppp.samba.org/;
    license = with licenses; [
      bsd3
      gpl2
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
