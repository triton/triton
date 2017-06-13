{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, krb5_lib
, openssl
, sqlite
, zlib
}:

let
  rev = "e5ce85b0b6f2e734b497aea5c2eff6398da749f5";
  date = "2017-06-08";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "MariaDB";
    repo = "mariadb-connector-c";
    inherit rev;
    sha256 = "00898eda42dce5a432336fbfdbac71e7e3af81799b1afcd70667be88aada7749";
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
    ln -sv mariadb_config "$out"/bin/mysql_config
    ln -sv mariadb "$out"/include/mysql
    ln -sv libmariadb.so "$out"/lib/libmysqlclient.so
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
