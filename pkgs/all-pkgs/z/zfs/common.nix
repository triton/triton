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
    version = "0.8.4";
    maxLinuxVersion = "5.6";
    src = fetcher {
      inherit version;
      sha256 = "2b988f5777976f09d08083f6bebf6e67219c4c4c183c1f33033fb7e5e5eacafb";
    };
    patches = [
      (fetchTritonPatch {
        rev = "4f87fc5682b539844e878b8b914332d53384edcf";
        file = "z/zfs/0.8/0001-Fix-binary-paths.patch";
        sha256 = "9882f9f3c078735e0bde6ae57435ff6a53a35796a3f0b1d5e4d879c33d6cba0c";
      })
    ];
  };
  "dev" = {
    date = "2020-05-23";
    maxLinuxVersion = "5.7";
    src = fetcher {
      fetchzipVersion = 6;
      rev = "c946d5a91329b075fb9bda1ac703a2e85139cf1c";
      sha256 = "fcba79f65f2d07b001abee03190cf608657cc335a6c08d6e9b6aca5a9ad35c00";
    };
    patches = [
      (fetchTritonPatch {
        rev = "4f87fc5682b539844e878b8b914332d53384edcf";
        file = "z/zfs/0001-Fix-binary-paths.patch";
        sha256 = "799eadfd47ab72a0c152f9bd3cce789bc0aa9c077687052f03fba94fee7dd9bd";
      })
    ];
  };
}
