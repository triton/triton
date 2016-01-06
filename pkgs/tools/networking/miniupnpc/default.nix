{ stdenv, fetchurl }:

let version = "1.9.20151026"; in
stdenv.mkDerivation rec {
  name = "miniupnpc-${version}";

  src = fetchurl {
    name = "${name}.tar.gz";
    url = "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz";
    sha256 = "0isxlakdz24v1papxqj8mb2h0kgqa2yfadwj9myr32jq65d9mkzk";
  };

  patches = stdenv.lib.optional stdenv.isFreeBSD ./freebsd.patch;

  doCheck = !stdenv.isFreeBSD;

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preInstall = ''
    installFlagsArray+=("INSTALLPREFIX=$out")
  '';

  meta = {
    inherit version;
    homepage = http://miniupnp.free.fr/;
    description = "A client that implements the UPnP Internet Gateway Device (IGD) specification";
    platforms = with stdenv.lib.platforms; linux ++ freebsd;
  };
}
