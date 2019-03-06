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
    version = "0.7.13";
    maxLinuxVersion = "5.0";
    src = fetcher {
      inherit version;
      sha256 = "d23f0d292049b1bc636d2300277292b60248c0bde6a0f4ba707c0cb5df3f8c8d";
    };
    patches = [
      (fetchTritonPatch {
        rev = "fd575a18a97ed612beeb15076ef26d3e69faed01";
        file = "z/zfs/0.7/0001-Fix-binary-paths.patch";
        sha256 = "fa0ce1249b3c234254172ae2947d4243c2b3bed128465a38617b382da6fb8640";
      })
    ];
  };
  "dev" = {
    date = "2019-03-02";
    maxLinuxVersion = "5.0";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "762f9ef3d9d897b5baf7c91d6e8a7bf371a9b02f";
      sha256 = "0c5840e43e5775738971a38016a1efdbc0f4790b2522489cc1d8c7a88cdf7a6c";
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
