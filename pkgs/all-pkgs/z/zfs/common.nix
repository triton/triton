{ stdenv
, fetchFromGitHub
, fetchTritonPatch
, fetchurl
}:

let
  fetcher = { fetchzipVersion ? null, version ? null, rev ? null, sha256 }:
    if fetchzipVersion != null then
      fetchFromGitHub {
        owner = "zfsonlinux";
        repo = "zfs";
        rev = if version != null then "zfs-${version}" else rev;
        inherit sha256;
        version = fetchzipVersion;
      }
    else
      fetchurl {
        url = "https://github.com/zfsonlinux/zfs/releases/download/zfs-${version}/zfs-${version}.tar.gz";
        inherit sha256;
      };
in
{
  "stable" = rec {
    version = "0.8.3";
    maxLinuxVersion = "5.4";
    src = fetcher {
      inherit version;
      sha256 = "545a4897ce30c2d2dd9010a0fdb600a0d3d45805e2387093c473efc03aa9d7fd";
    };
    patches = [
      (fetchTritonPatch {
        rev = "cde0dd71d1cd1f7b91d783a80b6dddda4c165886";
        file = "z/zfs/0.8/0001-Fix-binary-paths.patch";
        sha256 = "561a213bf25d334656d7be2b743229e7ffc82533642f222ea65768bc3461f74c";
      })
    ];
  };
  "dev" = {
    date = "2020-02-14";
    maxLinuxVersion = "5.5";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "ecbbdac799e0fd33f9d8b5fd6315008e3b4c9a50";
      sha256 = "c1a12e63d78b47dc4e16302124e8e2aafb3fdf7492d7fff18b7b1ec66626520d";
    };
    patches = [
      (fetchTritonPatch {
        rev = "0dbe87cf3492212d1cbddf9b24f579bf1cfbe2e5";
        file = "z/zfs/0001-Fix-binary-paths.patch";
        sha256 = "233d3449babd612625a2fdd2bfceb4356329af77db3c1aba76e5447ccd0f4973";
      })
    ];
  };
}
