{ stdenv
, fetchurl

, krb5_lib
, libsodium
, util-linux_lib
}:

let
  inherit (builtins)
    replaceStrings;
  inherit (stdenv.lib)
    strings;

  version = "4.1.5";

  versionMajorMinor = replaceStrings ["."] ["-"] (strings.substring 0 3 version);
in
stdenv.mkDerivation rec {
  name = "zeromq-${version}";

  src = fetchurl {
    url = "https://github.com/zeromq/zeromq${versionMajorMinor}/releases/"
      + "download/v${version}/${name}.tar.gz";
    sha256 = "04aac57f081ffa3a2ee5ed04887be9e205df3a7ddade0027460b8042432bdbcf";
  };

  buildInputs = [
    krb5_lib
    libsodium
    util-linux_lib
  ];

  configureFlags = [
    "--with-gssapi_krb5"
    "--with-libsodium"
    # "--with-pgm" # TODO: Implement
  ];

  meta = with stdenv.lib; {
    description = "The Intelligent Transport Layer";
    homepage = "http://www.zeromq.org";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
