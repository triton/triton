{ stdenv
, fetchurl
, gmp
}:

let
  patchSha256s = {
    "patch01" = "1hhpl0wg3gmv5m5kxc5r3n7vzvjnil4jx6rvk99gmfwylsjqx8lf";
    "patch02" = "19gvq283yspz7yajm4q2ys03hpxj0m5l8ahrkmccjzaqd07jwq53";
    "patch03" = "0p1y7mwbnshbj81hg5nfprzwh4aakxszf7n8bn4kh66jka4cw79c";
    "patch04" = "0vp2ywg8p0a2g8wai4fw29mbx1nq5yjzd361h2mr4cn6vac4a3sz";
    "patch05" = "1y0izl4y17xrdjidl2p1m1vapmgci5qv6shk0aqd187nvrs72jgw";
    "patch06" = "13xq302vqzsb1w09bs8n3q4wa4s7nzjfwi4s3cpka3diga7ah3qm";
    "patch07" = "08vk9ldp3s9kzkqjpsyd3d1ar0dkbamdg7k9yf9s6zmfdvpzjr6y";
    "patch08" = "1ip1x7y8p3jv5wsz57cgbgxg02qza8d1lpvsr01q9hmnp1x31sy8";
    "patch09" = "1sh7x9nk3p5hkq9qzwwhyjvsj91g9a06sb148lkyhi1kid5956rn";
    "patch10" = "19vhfiky30v69igg5yrnggnr8r7sqqwnfkwl33zz4yins9fwphf4";
    "patch11" = "1dj5jjchxnl25bfizxb6xs7470yz6vc5j2iqq9qpgx136iby14k8";
    "patch12" = "17bk5zmxlxql0ch8ybiwmkxm3arfq0r05yyz761ahqc8lxjinr06";
  };
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "mpfr-${version}-p${toString (length patches)}";
  version = "3.1.3";

  src = fetchurl {
    url = "mirror://gnu/mpfr/mpfr-${version}.tar.bz2";
    sha256 = "1z8akfw9wbmq91vrx04bw86mmnxw2sw5qm5cr8ix5b3w2mcv8fzn";
  };

  patches = flip mapAttrsToList patchSha256s (n: sha256: fetchurl {
    name = "mpfr-${version}-${n}";
    url = "http://www.mpfr.org/mpfr-${version}/${n}";
    inherit sha256;
  });

  # mpfr.h requires gmp.h
  propagatedBuildInputs = [ gmp ];

  configureFlags = [
    "--with-pic"
  ];

  doCheck = true;

  meta = {
    homepage = http://www.mpfr.org/;
    description = "Library for multiple-precision floating-point arithmetic";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
