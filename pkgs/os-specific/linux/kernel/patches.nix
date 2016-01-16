{ stdenv, fetchurl, fetchTritonPatch }:

let

  grsecPatch = { grversion ? "3.1", kversion, revision, branch, sha256 }:
    { name = "grsecurity-${grversion}-${kversion}";
      inherit grversion kversion revision;
      patch = fetchurl {
        url = "http://grsecurity.net/${branch}/grsecurity-${grversion}-${kversion}-${revision}.patch";
        inherit sha256;
      };
      features.grsecurity = true;
    };

in

rec {

  bridge_stp_helper = fetchTritonPatch {
    rev = "e25b3bc3302773b2572eb86db102b4769631c675";
    file = "linux-kernel/bridge-stp-helper.patch";
    sha256 = "53d467696157b4ca71535a3021d8b9d8db3fa765ea2f8db01fbf2e607e6032e5";
  };

  grsecurity_unstable = grsecPatch {
    kversion  = "4.2.3";
    revision  = "201510130858";
    branch    = "test";
    sha256    = "0ndzcx9i94c065dlyvgykmin5bfkbydrv0kxxq52a4c9is6nlsrb";
  };

  grsec_fix_path = fetchTritonPatch {
    rev = "e25b3bc3302773b2572eb86db102b4769631c675";
    file = "linux-kernel/grsec-path.patch";
    sha256 = "3e9917d624a4e40f46e6e973acbef04f823e174e5dc48921277606fe6c67a607";
  };
}
