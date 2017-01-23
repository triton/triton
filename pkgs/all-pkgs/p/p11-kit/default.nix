{ stdenv
, fetchurl

, libffi
, libtasn1
}:

stdenv.mkDerivation rec {
  name = "p11-kit-0.23.2";

  src = fetchurl {
    url = "https://p11-glue.freedesktop.org/releases/${name}.tar.gz";
    multihash = "QmbAbYcMhxSwfMRnnBMdyVUoHu6aptC5pZdqdpuAqVRYjY";
    sha256 = "1w7szm190phlkg7qx05ychlj2dbvkgkhx9gw6dx4d5rw62l6wwms";
  };

  buildInputs = [
    libffi
    libtasn1
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--without-trust-paths"
  ];

  preInstall = ''
    installFlagsArray+=("exampledir=$out/etc/pkcs11")
  '';

  meta = with stdenv.lib; {
    homepage = https://p11-glue.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
