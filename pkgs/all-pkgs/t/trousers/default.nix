{ stdenv
, fetchTritonPatch
, fetchurl

, gmp
, openssl
}:

let
  version = "0.3.14";
in
stdenv.mkDerivation rec {
  name = "trousers-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/trousers/trousers/${version}/${name}.tar.gz";
    sha256 = "ce50713a261d14b735ec9ccd97609f0ad5ce69540af560e8c3ce9eb5f2d28f47";
  };

  srcRoot = ".";

  buildInputs = [
    gmp
    openssl
  ];

  preUnpack = ''
    mkdir src
    cd src
  '';

  patches = [
    (fetchTritonPatch {
      rev = "35e456a096e677dc4ee1453c76c52821423f7405";
      file = "t/trousers/trousers-0.3-allow-non-tss-config-file-owner.patch";
      sha256 = "891938eb62275871cafd5c279d677662e89620c59265cd8b4605f630f97afb87";
    })
  ];

  postPatch = ''
    sed \
      -e 's,^localstatedir = .*,localstatedir = /var,' \
      -e 's,^sysconfdir = .*,sysconfdir = /etc,' \
      -i dist/Makefile.in

    sed \
      -e 's,@localstatedir@,''${localstatedir},g' \
      -e 's,@sysconfdir@,''${sysconfdir},g' \
      -i dist/Makefile.in
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-openssl=${openssl}"
    "--with-gmp"
    "--disable-usercheck"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  NIX_CFLAGS_COMPILE = "-DALLOW_NON_TSS_CONFIG_FILE";
  NIX_LDFLAGS = "-lgcc_s";

  meta = with stdenv.lib; {
    description = "Trusted computing software stack";
    homepage = http://trousers.sourceforge.net/;
    license = licenses.cpl10;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

