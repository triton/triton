{ stdenv
, fetchTritonPatch
, fetchurl
, lib
, substituteAll

, curl
, libpcap
, linux-headers
, openssl
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
    openssl
    pam
    stdenv.cc.libc
  ];

  postUnpack = ''
    mkdir -p $srcRoot/pppd/plugins
    tar zxvf ${ppp-dhcp} -C $srcRoot/pppd/plugins
  '';

  patches = [
    (substituteAll {
      src = ./nix-purity.patch;
      inherit libpcap;
      glibc = stdenv.cc.libc;
    })
    # Gentoo patchset 2.4.7-7
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/02_all_make-vars.patch";
      sha256 = "13536f8c3c608aa1e61909eb610c814e171b481c270a670b5292ce9f2c7d7a5a";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/03_all_use_internal_logwtmp.patch";
      sha256 = "5d93c77ab5b1eff5ba35e08b1513af3f16634948842e2934eb8d8fefa9abb907";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/04_all_mpls.patch";
      sha256 = "3c169b051fdcad6f9c2f79224700f996073b05070126863192c1a9a9419d7d17";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/06_all_killaddr-smarter.patch";
      sha256 = "f1236902fe30e3b812fedd0e78be5432b638f03b85ff4d1619f9c204d7e480b0";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/08_all_wait-children.patch";
      sha256 = "7b749571c71525971c344119dd419e741180180b7c61fd36a13d81f90c658a6c";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/10_all_defaultgateway.patch";
      sha256 = "44acdd7598237dfd73ee784e535871b7b6fcd9a21499d5469b8bd395e23cc26d";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/12_all_linkpidfile.patch";
      sha256 = "0f3b3c2d11b68962c15450219f83e97d429b4871d2fd869a8ef3fc07966af3f4";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/16_all_auth-fail.patch";
      sha256 = "5d888846404299287c5c09d3ca2392117f80fcf104fd2504ad6129dafb3290c6";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/18_all_defaultmetric.patch";
      sha256 = "3ec2883595d634fda8fc85229e840b0d876e1c18f573cb8acec91f9a3c357190";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/19_all_radius_pid_overflow.patch";
      sha256 = "b3eb3023ba9971a16eb8edfd1e04b8a572bb7ac811389012a79c28c1d14412fb";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/20_all_dev-ppp.patch";
      sha256 = "280b90f9cea3d308561423efa278329f74581a2e86c16ce88e1accff210ac7a3";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/21_all_custom_iface_names.patch";
      sha256 = "2bbee025694c8e1beec05fed484e0deb02fea68aca73e543699ce7b3cc5d0545";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/24_all_passwordfd-read-early.patch";
      sha256 = "9f98c2b6cf43b1c9030ca21d908bec787608478861bd77a59ad44e915ef956f2";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/26_all_pppd-usepeerwins.patch";
      sha256 = "764134da123fcdf7df7977119dad9aa67e5362720065bcba3527ae300c59fa40";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/28_all_connect-errors.patch";
      sha256 = "08fc29b899771ebd9cfe230e9b527bbe8eed21823bdcdc30f048dd6aaed716f7";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/30_all_Makefile.patch";
      sha256 = "37d79477d9b0dcce5ae91c7dd39f9513c0070d1005e1ee175cd1f85b25e52d2d";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/32_all_pado-timeout.patch";
      sha256 = "703c32285f5fb0011a7157fbd8075016965de2d370b1def3db06da98ab1dbfdc";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/34_all_lcp-echo-adaptive.patch";
      sha256 = "15bb5b7484a0adf4677d6c94fd00cf41e4e294713ff0697b33c15a439d5953fb";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/50_all_linux-headers.patch";
      sha256 = "231766e8000bd5d3439fee1d680c00f6b2f411cf18d88c522ad25360ca7a9e3c";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/51_all_glibc-2.28.patch";
      sha256 = "3f199d83d2632274dbbe7345e5369891469f64642f28e4afb471747a88888b62";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/80_all_eaptls-mppe-1.101a.patch";
      sha256 = "4a5abce4bd97aede03e2afe945bd8d35939299044ae3c86bff4422a99516526b";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
      file = "p/ppp/85_all_dhcp-make-vars.patch";
      sha256 = "3c1fb119ea7ab0d43d308c90cf2f5e0281d8258b4021c7f1b330c64d7e013a28";
    })
    (fetchTritonPatch {
      rev = "5a608b342d642004635c2272a8ad4f2aaebce530";
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
  '' + /* Fix hardcoded plugin path */ ''
    sed -i pppd/pathnames.h \
      -e "s,/usr/lib,$out,"
  '' + /* Fix hardcoded includes */ ''
    sed -i pppd/Makefile.linux \
      -e 's,/usr/include/openssl,${openssl}/include/openssl,' \
      -e 's,/usr/local/ssl/lib,${openssl}/lib,'
  '';

  preBuild = ''
    # Prevent build from creating sbin/
    makeFlagsArray+=("BINDIR=$out/bin")
  '';

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
