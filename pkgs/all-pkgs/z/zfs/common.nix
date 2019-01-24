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
    version = "0.7.12";
    maxLinuxVersion = "4.19";
    src = fetcher {
      inherit version;
      sha256 = "720e3b221c1ba5d4c18c990e48b86a2eb613575a0c3cc84c0aa784b17b7c2848";
    };
    patches = [
      (fetchTritonPatch {
        rev = "a061e816f5a9fa5565f53a4213edb75b42ee5607";
        file = "z/zfs/0002-Fix-binary-paths.patch";
        sha256 = "a114332256ed06c51c2e9c019f0b810947f65393d5b82bcf1e72b13c351c7fe6";
      })
    ];
  };
  "dev" = {
    date = "2019-01-18";
    maxLinuxVersion = "4.20";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "0a10863194b0e7c1c64f702f868c10d5dac45ea5";
      sha256 = "696cfb8fe081d08f7a1a0157dd780785feae83150a99dbef26f5be6a13d2cfa5";
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
