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
    version = "0.8.1";
    maxLinuxVersion = "5.1";
    src = fetcher {
      inherit version;
      sha256 = "0af79fde44b7b8ecb94d5166ce2e4fff7409c20ed874c2d759db92909e6c2799";
    };
    patches = [
      (fetchTritonPatch {
        rev = "af81e3b365a91a63b44e468b2dc0c770686dfa6e";
        file = "z/zfs/0001-Fix-binary-paths.patch";
        sha256 = "8009b1df288109d4f386842210c39e9e1ba3f0734d719dc6eb56deb3d29d2963";
      })
    ];
  };
  "dev" = {
    date = "2019-07-25";
    maxLinuxVersion = "5.2";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "d274ac54609894d00a49c0a0da89abd3a7f3998d";
      sha256 = "bac602c69e1fc00dbd8725eaf321465fc8bbec41a7c4a35c38f73a7c95a4f2dd";
    };
    patches = [
      (fetchTritonPatch {
        rev = "af81e3b365a91a63b44e468b2dc0c770686dfa6e";
        file = "z/zfs/0001-Fix-binary-paths.patch";
        sha256 = "8009b1df288109d4f386842210c39e9e1ba3f0734d719dc6eb56deb3d29d2963";
      })
    ];
  };
}
