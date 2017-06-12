{ stdenv
, cmake
, fetchurl
, ninja

, curl
, krb5_lib
, openssl
, sqlite
, zlib
}:

let
  version = "3.0.1";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${version}";

  src = fetchurl {
    url = "mirror://mariadb/connector-c-${version}/${name}-beta-src.tar.gz";
    hashOutput = false;
    sha256 = "37b7922254e637285e69deceaa81667be103b1ac904b5a946a74d6d3ec97eeac";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    krb5_lib
    openssl
    sqlite
    zlib
  ];

  cmakeFlags = [
    "-DINSTALL_LIBDIR=lib"
    "-DWITH_MYSQLCOMPAT=ON"
    "-DWITH_UNITTEST=OFF"
    "-DWITH_EXTERNAL_ZLIB=ON"
    "-DWITH_SQLITE=ON"
  ];

  postInstall = ''
    ln -sv mariadb "$out"/include/mysql
    ln -sv libmariadb.so "$out"/lib/libmysqlclient.so
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "1993 69E5 404B D5FC 7D2F  E43B CBCB 082A 1BB9 43DB";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
