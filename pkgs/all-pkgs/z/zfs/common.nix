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
    version = "0.8.0-rc4";
    maxLinuxVersion = "5.0";
    src = fetcher {
      inherit version;
      sha256 = "2a006686c0cf4360fbc1352cbf82ecd69a5029555bb038d23fbf5ad5d49359ba";
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
    date = "2019-03-19";
    maxLinuxVersion = "5.1";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "73c25a78e6b420ff37d703d2e1911c17cf449caa";
      sha256 = "4fe9854e47dd0fa0fdb04e34e24319629846d8b0130b9817719b13cce0ad81c8";
    };
    patches = [
      (fetchTritonPatch {
        rev = "8c2686354b8307407391b0434ce48aef322ab3b3";
        file = "z/zfs/0001-Fix-binary-paths.patch";
        sha256 = "bc4ad5b4da1ba0f1ae72f78195f958229d8e4dd617db812babf10ae1902e5720";
      })
    ];
  };
}
