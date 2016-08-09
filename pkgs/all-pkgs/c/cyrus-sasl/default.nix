{ stdenv
, fetchTritonPatch
, fetchurl
, gettext

, db
, kerberos
, openssl
, pam
}:

stdenv.mkDerivation rec {
  name = "cyrus-sasl-2.1.26";

  src = fetchurl {
    url = "ftp://ftp.cyrusimap.org/cyrus-sasl/${name}.tar.gz";
    sha256 = "1hvvbcsg21nlncbgs0cgn3iwlnb3vannzwsp6rwvnn9ba4v53g4g";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    db
    kerberos
    openssl
    pam
  ];

  patches = [
    (fetchTritonPatch {
      rev = "21857afe6c9cce8ad86cfea358c023b3805f64b4";
      file = "cyrus-sasl/cyrus-sasl-2.1.23-gss_c_nt_hostbased_service.patch";
      sha256 = "f84854e4096b40ad091cc8c194e0c35e98b70652d4288144392350f5c5b2b862";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-as_needed.patch";
      sha256 = "5143036f20fdc1ff0b44b73b6d245392edc2f786d74730fc0f8f75d7b40ea5c6";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-autotools_fixes.patch";
      sha256 = "390aef512c359ae3eee9d1c781ab9586b71b98e4b8961594de0872b09acfbea2";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-auxprop.patch";
      sha256 = "d9f63e60aa664f064755151fb5aa442ed52a3053057b5a63f2d88c937906dc7c";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-avoid_pic_overwrite.patch";
      sha256 = "80cb9cf22b0507b503ff0cf6c5946a44eb5c3808e0a77e66d56d5a53e5e76fa7";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-fix_heimdal.patch";
      sha256 = "3ebd714afa092c102a8112bb6ac1255802fb67f35fb3ced6ce0e6ecc02b51ea2";
    })
    (fetchTritonPatch {
      rev = "fbe93a57735f1be48c3c0cd016a3c0c3ab98d565";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-missing_header.patch";
      sha256 = "cabaeddb3b55bba7d5995d33759eed5309a02371c9f80b330eaf0d3e86e271fe";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-saslauthd_libtool.patch";
      sha256 = "76ba2532083630a05ed0e3a5f2976eef6ec62e0fc1782bfee6147aee749e2ce8";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-sasldb_al.patch";
      sha256 = "3885246eda016e7a6d273305b2a011770465e8324d1774ef0d021e3def3008d5";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.25-service_keytabs.patch";
      sha256 = "38746033490ea2f451fbda8f343c2f993a6a7987b7db9f34304f542b5a2dfa14";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.26-canonuser-ldapdb-garbage-in-out-buffer.patch";
      sha256 = "334c3a2c7f409707026136ef595845f61e971e369035c3b5e3bf284f1e7e6e1d";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.26-CVE-2013-4122.patch";
      sha256 = "39c3c404d6fc0da79c51157c6a3c05aeb9117cf5df87615d6a8f8086056bf94e";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.26-fix_dovecot_authentication.patch";
      sha256 = "0a95f71784376db70b80473f49a61b733694525545b871cfcd792555f21f2093";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.26-missing-size_t.patch";
      sha256 = "9aa3895bd56986cb3334c38979324f2156d157945f9dcf260e51452b5538897e";
    })
    (fetchTritonPatch {
      rev = "8f1328e4577cd812e3d4708e2e65f9e472e402d6";
      file = "cyrus-sasl/cyrus-sasl-2.1.26-send-imap-logout.patch";
      sha256 = "021289615c690937dacf7bd0d1f23823255d141ea0c7f81a9f98d4d2b42260d4";
    })
  ];

  postPatch = ''
    # Get rid of the -R switch (runpath_switch for Sun)
    # >=gcc-4.6 errors out with unknown option
    sed -i configure.in \
      -e '/LIB_SQLITE.*-R/s/ -R[^"]*//'

    # Use plugindir for sasldir
    sed -i plugins/Makefile.{am,in} \
      -e '/^sasldir =/s:=.*:= $(plugindir):'

    sed -i configure.in \
      -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:g' \
      -e 's:AC_CONFIG_MACRO_DIR:AC_CONFIG_MACRO_DIRS:g'

    sed -i saslauthd/configure.in \
      -e 's:AC_CONFIG_MACRO_DIR:AC_CONFIG_MACRO_DIRS:g'
  '';

  # Set this variable at build-time to make sure $out can be evaluated.
  preConfigure = ''
    configureFlagsArray+=("--with-plugindir=$out/lib/sasl2")
    configureFlagsArray+=("--with-configdir=$out/lib/sasl2")
  '';

  configureFlags = [
    "--enable-auth-sasldb"
    "--with-openssl=${openssl}"
    "--with-saslauthd=/run/saslauthd"
  ];

  parallelBuild = false;
  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "Library for authentication to connection-based protocols";
    homepage = "http://cyrusimap.web.cmu.edu/";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
