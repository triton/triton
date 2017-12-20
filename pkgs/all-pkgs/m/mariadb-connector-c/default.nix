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
  rev = "6d2fb0155c17be2f77c51248dedf567e3531f20e";
  date = "2017-12-15";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "MariaDB";
    repo = "mariadb-connector-c";
    inherit rev;
    sha256 = "6e60eb54246ffa09712b71440677fc620e93c6bc8a57e684d3f8d0c79a667221";
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

  # Hack to make sure we include the libpath in the _config binaries
  preBuild = ''
    sed \
      -e 's,-lz,-L${zlib}/lib -lz,g' \
      -e 's,-lssl,-L${openssl}/lib -lssl,g' \
      -i mariadb_config/mariadb_config.c
  '';

  postInstall = ''
    ln -sv mariadb_config "$out"/bin/mysql_config
    ln -sv mariadb "$out"/include/mysql
  '';

  # Make sure we have all the needed lib paths
  preFixupCheck = ''
    echo 'void main() {}' | NIX_LDFLAGS= gcc -x c -o main - $("$out"/bin/mariadb_config --libs)
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
