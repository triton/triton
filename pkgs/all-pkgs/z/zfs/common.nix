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
    version = "0.8.0-rc5";
    maxLinuxVersion = "5.1";
    src = fetcher {
      inherit version;
      sha256 = "c5dc91e3efb7555c6c1846cf89fd4cfb0952271a2900434e697f2b7397ce9b16";
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
    date = "2019-05-02";
    maxLinuxVersion = "5.1";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "b3b60984ee191bdbb00b91842053c83581854db7";
      sha256 = "23386d1fc70c8beee280bdcef984eb2bb2ddbb522e76ae50ee43839366424e57";
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
