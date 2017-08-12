/* This file defines the composition for Go packages. */

{ stdenv
, buildGoPackage
, fetchFromGitHub
, fetchTritonPatch
, fetchzip
, go
, lib
, overrides
, pkgs
}:

let
  self = _self // overrides; _self = with self; {

  inherit go buildGoPackage;

  fetchGxPackage = { src, sha256 }: stdenv.mkDerivation {
    name = "gx-src-${src.name}";

    impureEnvVars = [ "IPFS_API" ];

    buildCommand = ''
      if ! [ -f /etc/ssl/certs/ca-certificates.crt ]; then
        echo "Missing /etc/ssl/certs/ca-certificates.crt" >&2
        echo "Please update to a version of nix which supports ssl." >&2
        exit 1
      fi

      start="$(date -u '+%s')"

      unpackDir="$TMPDIR/src"
      mkdir "$unpackDir"
      cd "$unpackDir"
      unpackFile "${src}"
      cd *

      echo "Environment:" >&2
      echo "  IPFS_API: $IPFS_API" >&2

      mtime=$(find . -type f -print0 | xargs -0 -r stat -c '%Y' | sort -n | tail -n 1)
      if [ "$start" -lt "$mtime" ]; then
        str="The newest file is too close to the current date:\n"
        str+="  File: $(date -u -d "@$mtime")\n"
        str+="  Current: $(date -u)\n"
        echo -e "$str" >&2
        exit 1
      fi
      echo -n "Clamping to date: " >&2
      date -d "@$mtime" --utc >&2

      gx --verbose install --global

      echo "Building GX Archive" >&2
      cd "$unpackDir"
      ${src.tar}/bin/tar --sort=name --owner=0 --group=0 --numeric-owner \
        --no-acls --no-selinux --no-xattrs \
        --mode=go=rX,u+rw,a-s \
        --clamp-mtime --mtime=@$mtime \
        -c . | ${src.brotli}/bin/brotli --quality 6 --output "$out"
    '';

    buildInputs = [ gx.bin ];
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = sha256;
    preferLocalBuild = true;
  };

  nameFunc =
    { rev
    , goPackagePath
    , name ? null
    , date ? null
    }:
    let
      name' =
        if name == null then
          baseNameOf goPackagePath
        else
          name;
      version =
        if date != null then
          date
        else if builtins.stringLength rev != 40 then
          rev
        else
          stdenv.lib.strings.substring 0 7 rev;
    in
      "${name'}-${version}";

  buildFromGitHub =
    lib.makeOverridable ({ rev
    , date ? null
    , owner
    , repo
    , sha256
    , version
    , gxSha256 ? null
    , goPackagePath ? "github.com/${owner}/${repo}"
    , name ? null
    , ...
    } @ args:
    buildGoPackage (args // (let
      name' = nameFunc {
        inherit
          rev
          goPackagePath
          name
          date;
      };
    in {
      inherit rev goPackagePath;
      name = name';
      src = let
        src' = fetchFromGitHub {
          name = name';
          inherit rev owner repo sha256 version;
        };
      in if gxSha256 == null then
        src'
      else
        fetchGxPackage { src = src'; sha256 = gxSha256; };
    })));

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    version = 3;
    rev = "c5a90ac045b779001847fec87403f5cba090deae";
    owner = "golang";
    repo = "appengine";
    sha256 = "0wlardkhsq6c4b6phr9qa881bxz7h351ry829cc6d6hliji26bid";
    goPackagePath = "google.golang.org/appengine";
    excludedPackages = "aetest";
    propagatedBuildInputs = [
      protobuf
      net
    ];
    postPatch = ''
      find . -name \*_classic.go -delete
      rm internal/main.go
    '';
    date = "2017-08-01";
  };

  arch = buildFromGitHub {
    version = 3;
    rev = "f185940480d2c897e1ca8cf2f1be122e1258341b";
    date = "2017-07-24";
    owner = "golang";
    repo = "arch";
    sha256 = "1kv3b8w8c6vwjvdc3szza7y000gzfw4m2cnks5kcf2wily54qvhl";
    goPackagePath = "golang.org/x/arch";
    excludedPackages = "spec";
  };

  build = buildFromGitHub {
    version = 3;
    rev = "5d60a938406c724d4372f6eb5d69073a83734c25";
    date = "2017-08-11";
    owner = "golang";
    repo = "build";
    sha256 = "0w4r49w0m8xsn0n2ck4qiyh778p258p0377lhg03706f1v5s4fgv";
    goPackagePath = "golang.org/x/build";
    subPackages = [
      "autocertcache"
    ];
    propagatedBuildInputs = [
      crypto
      google-cloud-go
    ];
  };

  crypto = buildFromGitHub {
    version = 3;
    rev = "b176d7def5d71bdd214203491f89843ed217f420";
    date = "2017-08-08";
    owner = "golang";
    repo = "crypto";
    sha256 = "11skdz6wl86w9krf0w96yl1rv8ypsxhg1sxxh0iydqxp54vzv31y";
    goPackagePath = "golang.org/x/crypto";
    buildInputs = [
      net_crypto_lib
    ];
    propagatedBuildInputs = [
      sys
    ];
  };

  debug = buildFromGitHub {
    version = 3;
    rev = "e48e17184ecf6cd503223592fb27874c510e44f7";
    date = "2017-05-05";
    owner = "golang";
    repo = "debug";
    sha256 = "1084b2l6hi0hjn7rgmlah96xz9a3gl3804vj93byvfg02y4aaxhl";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
  };

  geo = buildFromGitHub {
    version = 3;
    rev = "31fb0106dc4a947e5aaee1fe186e56447f839510";
    owner = "golang";
    repo = "geo";
    sha256 = "1bvbipbsr5kj3hq1mxcj0jxcbynmbm1cfyi0fv9arjylil8hcpr7";
    date = "2017-08-10";
  };

  glog = buildFromGitHub {
    version = 1;
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-25";
    owner = "golang";
    repo = "glog";
    sha256 = "0wj30z2r6w1zdbsi8d14cx103x13jszlqkvdhhanpglqr22mxpy0";
  };

  image = buildFromGitHub {
    version = 3;
    rev = "426cfd8eeb6e08ab1932954e09e3c2cb2bc6e36d";
    date = "2017-05-23";
    owner = "golang";
    repo = "image";
    sha256 = "0v22aiwr8i7y6bvi18ycvxv2ji8vsmclcp2lasr2zr8j7jgm4y2l";
    goPackagePath = "golang.org/x/image";
    propagatedBuildInputs = [
      text
    ];
  };

  net = buildFromGitHub {
    version = 3;
    rev = "1c05540f6879653db88113bc4a2b70aec4bd491f";
    date = "2017-08-09";
    owner = "golang";
    repo = "net";
    sha256 = "0wvbwrxijndc0qdaalx0p831k79bb3zj34jad23xq8l61m317rmg";
    goPackagePath = "golang.org/x/net";
    goPackageAliases = [
      "github.com/hashicorp/go.net"
    ];
    excludedPackages = "h2demo";
    propagatedBuildInputs = [
      text
      crypto
    ];
  };

  net_crypto_lib = buildFromGitHub {
    inherit (net) rev date owner repo sha256 version goPackagePath;
    subPackages = [
      "context"
    ];
  };

  oauth2 = buildFromGitHub {
    version = 3;
    rev = "9a379c6b3e95a790ffc43293c2a78dee0d7b6e20";
    date = "2017-08-07";
    owner = "golang";
    repo = "oauth2";
    sha256 = "0cj611nv7n61p64jmxq1vvvhdph7xqijz6cvwvjkph79v3305dbs";
    goPackagePath = "golang.org/x/oauth2";
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };


  protobuf = buildFromGitHub {
    version = 3;
    rev = "1909bc2f63dc92bb931deace8b8312c4db72d12f";
    date = "2017-08-08";
    owner = "golang";
    repo = "protobuf";
    sha256 = "191w1qbwhp2m74xwgkb4n3gbssrk6f1chkwvqfcchgnwczp2y9bd";
    goPackagePath = "github.com/golang/protobuf";
    buildInputs = [
      genproto_protobuf
    ];
  };

  protobuf_genproto = buildFromGitHub {
    inherit (protobuf) version rev date owner repo goPackagePath sha256;
    subPackages = [
      "proto"
      "ptypes/any"
    ];
  };

  snappy = buildFromGitHub {
    version = 2;
    rev = "553a641470496b2327abcac10b36396bd98e45c9";
    date = "2017-02-16";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "1p27dax5jy6isvxmhnssz99pz9mzwcr1wbvdp1m3s6ap0qq708gg";
  };

  sync = buildFromGitHub {
    version = 3;
    rev = "f52d1811a62927559de87708c8913c1650ce4f26";
    date = "2017-05-17";
    owner  = "golang";
    repo   = "sync";
    sha256 = "1lrlz11mqkc81s4wj9vagyfvdql8ngq5ipw6wk09m9i8kj57ws9i";
    goPackagePath = "golang.org/x/sync";
    propagatedBuildInputs = [
      net
    ];
  };

  sys = buildFromGitHub {
    version = 3;
    rev = "e42485b6e20ae7d2304ec72e535b103ed350cc02";
    date = "2017-08-09";
    owner  = "golang";
    repo   = "sys";
    sha256 = "1kafrx5q9s1alyxfbnr7lvym9hzjrh41kalqcn9jf4ms8bxgrwps";
    goPackagePath = "golang.org/x/sys";
  };

  text = buildFromGitHub {
    version = 3;
    rev = "b19bf474d317b857955b12035d2c5acb57ce8b01";
    date = "2017-08-10";
    owner = "golang";
    repo = "text";
    sha256 = "0246vzli5b6qb6ib8yg2wgnbicf20aycyqbdr3sas25az87adafb";
    goPackagePath = "golang.org/x/text";
    excludedPackages = "cmd";
  };

  time = buildFromGitHub {
    version = 2;
    rev = "8be79e1e0910c292df4e79c241bb7e8f7e725959";
    date = "2017-04-24";
    owner  = "golang";
    repo   = "time";
    sha256 = "1swqcy5a5l03ni8j3v0798q6nnrdw0apy4ii413pnsmk1w81ig7w";
    goPackagePath = "golang.org/x/time";
    propagatedBuildInputs = [
      net
    ];
  };

  tools = buildFromGitHub {
    version = 3;
    rev = "5831d16d18029819d39f99bdc2060b8eff410b6b";
    date = "2017-08-08";
    owner = "golang";
    repo = "tools";
    sha256 = "1dgkrspzklbgl1898b971fg8vq59946kmckrab6a1rcmbqc8yxmq";
    goPackagePath = "golang.org/x/tools";

    preConfigure = ''
      # Make the builtin tools available here
      mkdir -p $bin/bin
      eval $(go env | grep GOTOOLDIR)
      find $GOTOOLDIR -type f | while read x; do
        ln -sv "$x" "$bin/bin"
      done
      export GOTOOLDIR=$bin/bin
    '';

    excludedPackages = "\\("
      + stdenv.lib.concatStringsSep "\\|" ([ "testdata" ] ++ stdenv.lib.optionals (stdenv.lib.versionAtLeast go.meta.branch "1.5") [ "vet" "cover" ])
      + "\\)";

    buildInputs = [
      appengine
      build
      crypto
      google-cloud-go
      net
    ];

    # Do not copy this without a good reason for enabling
    # In this case tools is heavily coupled with go itself and embeds paths.
    allowGoReference = true;

    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';

    # Set GOTOOLDIR for derivations adding this to buildInputs
    postInstall = ''
      mkdir -p $bin/nix-support
      echo "export GOTOOLDIR=$bin/bin" >> $bin/nix-support/setup-hook
    '';
  };


  ## THIRD PARTY

  ace = buildFromGitHub {
    version = 2;
    owner = "yosssi";
    repo = "ace";
    rev = "v0.0.5";
    sha256 = "0i3jfkgwvaz5w1cgz7sqqa7pnpz6hd0dniw2j89yhq6qgb4ikjy0";
    buildInputs = [
      gohtml
    ];
  };

  aeshash = buildFromGitHub {
    version = 2;
    rev = "8ba92803f64b76c91b111633cc0edce13347f0d1";
    owner  = "tildeleb";
    repo   = "aeshash";
    sha256 = "0p1nbk5nx2xhl8kan4bd6lcpmjrh7c60lyy9nf4rafyv2j7qqhnk";
    goPackagePath = "leb.io/aeshash";
    date = "2016-11-30";
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      hashland_for_aeshash
    ];
  };

  afero = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "afero";
    rev = "9be650865eab0c12963d8753212f4f9c66cdcf12";
    date = "2017-02-17";
    sha256 = "0xg09gigsv4c57zixvwnhfh2vfbg5banyhp426kbfs57hda697l8";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  amber = buildFromGitHub {
    version = 3;
    owner = "eknkc";
    repo = "amber";
    rev = "b8bd8b03e4f747e33f092617225e9fa8076c0448";
    date = "2017-07-16";
    sha256 = "0qq27qk8d34c2ivssn2lz6v021pfs5cxc9h1qpdirb6zjqkvb60k";
  };

  amqp = buildFromGitHub {
    version = 3;
    owner = "streadway";
    repo = "amqp";
    rev = "2cbfe40c9341ad63ba23e53013b3ddc7989d801c";
    date = "2017-07-07";
    sha256 = "0aymdq5yc7rn6a4ahk53nqpxvx6pnfc9cw5ycm87g5lcmd7pnhwh";
  };

  ansi = buildFromGitHub {
    version = 2;
    owner = "mgutz";
    repo = "ansi";
    rev = "9520e82c474b0a04dd04f8a40959027271bab992";
    date = "2017-02-06";
    sha256 = "1180ng6y5b1cnxschbswxaq2cp4yjchhwqjzimspnxj2mh16syhd";
    propagatedBuildInputs = [
      go-colorable
    ];
  };

  ansicolor = buildFromGitHub {
    version = 1;
    date = "2015-11-20";
    rev = "a422bbe96644373c5753384a59d678f7d261ff10";
    owner  = "shiena";
    repo   = "ansicolor";
    sha256 = "1qfq4ax68d7a3ixl60fb8kgyk0qx0mf7rrk562cnkpgzrhkdcm0w";
  };

  asn1-ber = buildFromGitHub {
    version = 3;
    rev = "v1.2";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "0xh0f4680jdkh6k3ksnwly5fk9y4a4z4jjwh31yz5crmcf07xzn0";
    goPackageAliases = [
      "github.com/nmcclain/asn1-ber"
      "github.com/vanackere/asn1-ber"
      "gopkg.in/asn1-ber.v1"
    ];
  };

  atomic = buildFromGitHub {
    version = 2;
    owner = "uber-go";
    repo = "atomic";
    rev = "v1.2.0";
    sha256 = "0k6r1x6i8vz2axyf9scmmh39c78mwgw4vv9wa8s9hsna9dmzsgfm";
    goPackagePath = "go.uber.org/atomic";
  };

  auroradnsclient = buildFromGitHub {
    version = 2;
    rev = "v1.0.1";
    owner  = "edeckers";
    repo   = "auroradnsclient";
    sha256 = "0pcjz19aycd01v4v52zbfldhr81rxy6aj7jh1y09issnqr8kgc4h";
    propagatedBuildInputs = [
      logrus
    ];
  };

  aws-sdk-go = buildFromGitHub {
    version = 3;
    rev = "v1.10.24";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "1kbcsx7caa9fzjdn5rsxvr3w05mfq2daspy1cj7ldr2d1nm1bkyr";
    excludedPackages = "\\(awstesting\\|example\\)";
    buildInputs = [
      tools
    ];
    propagatedBuildInputs = [
      ini
      go-jmespath
      net
    ];
    preBuild = ''
      pushd go/src/$goPackagePath
      make generate
      popd
    '';
  };

  azure-sdk-for-go = buildFromGitHub {
    version = 3;
    date = "2017-08-02";
    rev = "0b09de4174ca0cadcd3abb4aa31267c6f5ccebbb";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "025ma1qcs939j48ld886idlzan17i4s4lzjn71yrkzkkdysl4cyw";
    excludedPackages = "\\(Gododir\\|storageimportexport\\)";
    propagatedBuildInputs = [
      crypto
      decimal
      go-autorest
      satori_uuid
    ];
  };

  azure-storage-go = buildFromGitHub {
    version = 3;
    rev = "v0.1.0";
    owner  = "Azure";
    repo   = "azure-storage-go";
    sha256 = "0lwdn0q94k54qh0xn7qaqj191ah4gfv5fc9wfpnd6l4x1pa2m7vk";
    goPackageAliases = [
      "github.com/Azure/azure-sdk-for-go/storage"
    ];
    propagatedBuildInputs = [
      go-autorest
    ];
  };

  b = buildFromGitHub {
    version = 2;
    date = "2017-04-13";
    rev = "6955404bf550e1eae1bf83121739078b027f4547";
    owner  = "cznic";
    repo   = "b";
    sha256 = "1kr8nh3hknlp50c10hnryh9mbdhqxqpkf7yiz8839wbqdhnnnxzj";
    excludedPackages = "example";
  };

  backoff = buildFromGitHub {
    version = 3;
    owner = "cenkalti";
    repo = "backoff";
    rev = "61153c768f31ee5f130071d08fc82b85208528de";
    date = "2017-07-11";
    sha256 = "1g8xc3rqhaiazla2awic337yfbfhjn163g0bygjqcrfjbwzd5in3";
    propagatedBuildInputs = [
      net
    ];
  };

  barcode = buildFromGitHub {
    version = 3;
    owner = "boombuler";
    repo = "barcode";
    rev = "56ef0af91246fb5279df4f87bc3daf1bf7cb9e89";
    date = "2017-06-18";
    sha256 = "0d1nnzy9bflcfj0cmjqs07aj8f9an5hc041f3hr0m2hqfqs4qgzf";
  };

  bigfft = buildFromGitHub {
    version = 3;
    date = "2017-08-06";
    rev = "52369c62f4463a21c8ff8531194c5526322b8521";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "0il8sc0fm5kvgf8b2kddrggfkda6l27rbyw13i9sh60jj9dgh2gz";
  };

  binary = buildFromGitHub {
    version = 2;
    owner = "alecthomas";
    repo = "binary";
    rev = "ec810c4448fb8161fd00898b18c6f72ec661216a";
    date = "2017-01-11";
    sha256 = "1lpaqcxgd0pgrawn1hfss0mcv7wp1h0xdy5q3w75ydblay9g7ri8";
  };

  binding = buildFromGitHub {
    version = 3;
    date = "2017-06-11";
    rev = "ac54ee249c27dca7e76fad851a4a04b73bd1b183";
    owner = "go-macaron";
    repo = "binding";
    sha256 = "08pi8c86vzwrwjid3n8ls88xwxksyfd22vhzy129zkj0vspvl6sy";
    buildInputs = [
      com
      compress
      macaron_v1
    ];
  };

  blackfriday = buildFromGitHub {
    version = 3;
    owner = "russross";
    repo = "blackfriday";
    rev = "v2.0.0";
    sha256 = "0wxgj4q3ksbrih0gxn0a6r1n05paga7r4kxbhry45jqj2b73snfq";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
  };

  blake2b-simd = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "blake2b-simd";
    date = "2016-07-23";
    rev = "3f5f724cb5b182a5c278d6d3d55b40e7f8c2efb4";
    sha256 = "5ead55b23a24393a96cb6504b0a64c48812587c4af12527101c3a7c79c2d35e5";
  };

  bolt = buildFromGitHub {
    version = 3;
    rev = "v1.3.1";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "0j1dmlp9sh1v5kpxzvamyjdwlb0pndpy9a2qjhg2q93ri3dbfr58";
    buildInputs = [
      sys
    ];
  };

  btcd = buildFromGitHub {
    version = 3;
    owner = "btcsuite";
    repo = "btcd";
    date = "2017-08-09";
    rev = "1e331153b4baf5cd161e38ebe35d2fe86ccd02dd";
    sha256 = "0l8zz97dhxwh4cyqhanlwqcapghnp4klp7f1w797mnk3gfh7kmr5";
    subPackages = [
      "btcec"
    ];
  };

  btree = buildFromGitHub {
    version = 2;
    rev = "316fb6d3f031ae8f4d457c6c5186b9e3ded70435";
    owner  = "google";
    repo   = "btree";
    sha256 = "1wjicavprwxpa0rmvc8wz6k0gxl2q4rpsg7ci5hjvkb2j56r4rwk";
    date = "2016-12-17";
  };

  bufio_v1 = buildFromGitHub {
    version = 1;
    date = "2014-06-18";
    rev = "567b2bfa514e796916c4747494d6ff5132a1dfce";
    owner  = "go-bufio";
    repo   = "bufio";
    sha256 = "07dwsbh2c584wrm72hwnqsk22mr936hshsxma2jaxpgpkf6z1f3c";
    goPackagePath = "gopkg.in/bufio.v1";
  };

  bufs = buildFromGitHub {
    version = 1;
    date = "2014-08-18";
    rev = "3dcccbd7064a1689f9c093a988ea11ac00e21f51";
    owner  = "cznic";
    repo   = "bufs";
    sha256 = "0551h2slsb7lg3r6yif65xvf6k8f0izqwyiigpipm3jhlln37c6p";
  };

  cachecontrol = buildFromGitHub {
    version = 3;
    owner = "pquerna";
    repo = "cachecontrol";
    rev = "5475d973ea70916980bee28c2b674f3dc3eaed0a";
    date = "2017-07-06";
    sha256 = "0q2dv82zgjp4zi0s813y7hbnwhhf0ppcn6zakcxwj1dk9xx7flwq";
  };

  cascadia = buildFromGitHub {
    version = 2;
    date = "2016-12-24";
    rev = "349dd0209470eabd9514242c688c403c0926d266";
    owner  = "andybalholm";
    repo   = "cascadia";
    sha256 = "0xhdlrsvzsv3va4in3iw9v1nz2f6n8zca98mq4swl8zwfdly2jj8";
    propagatedBuildInputs = [
      net
    ];
  };

  cast = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "cast";
    rev = "v1.1.0";
    sha256 = "0b7i6dwk06w710cjcd0wnhgyrf15m344lmhm9jpfhfs678bg7va5";
    buildInputs = [
      jwalterweatherman
    ];
  };

  cbauth = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "couchbase";
    repo = "cbauth";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  ccache = buildFromGitHub {
    version = 2;
    rev = "v2.0.2";
    owner = "karlseguin";
    repo = "ccache";
    sha256 = "11zg85f5v89dfqy1s5xs42cs56sxdqs768l9wx73yksxqkidddbh";
  };

  certificate-transparency-go = buildFromGitHub {
    version = 3;
    owner = "google";
    repo = "certificate-transparency-go";
    rev = "a35c9da66104bb5febb28f15e163bb9d30c18d13";
    date = "2017-08-11";
    sha256 = "092am4q82bggz6ykh74gh6a3f6rhh9grz6b88ggxgy4m7bdb4b60";
    subPackages = [
      "."
      "asn1"
      "client"
      "jsonclient"
      "tls"
      "x509"
      "x509/pkix"
    ];
    propagatedBuildInputs = [
      net
    ];
  };

  cfssl = buildFromGitHub {
    version = 3;
    date = "2017-08-09";
    rev = "c369ce1578c380a7c05b01d6e0d0ac51caac0611";
    owner  = "cloudflare";
    repo   = "cfssl";
    sha256 = "1z4b7523h1bxpj6jggkp3w1xw9dl1bhcp84ppixddqnyl1hf0ar4";
    subPackages = [
      "auth"
      "api"
      "certdb"
      "config"
      "csr"
      "crypto/pkcs7"
      "errors"
      "helpers"
      "helpers/derhelpers"
      "info"
      "initca"
      "log"
      "ocsp/config"
      "signer"
      "signer/local"
    ];
    propagatedBuildInputs = [
      crypto
      certificate-transparency-go
      net
    ];
  };

  cfssl_errors = cfssl.override {
    subPackages = [
      "errors"
    ];
    buildInputs = [
    ];
    propagatedBuildInputs = [
    ];
    rev = "c369ce1578c380a7c05b01d6e0d0ac51caac0611";
    sha256 = "1z4b7523h1bxpj6jggkp3w1xw9dl1bhcp84ppixddqnyl1hf0ar4";
    version = 3;
  };

  cgofuse = buildFromGitHub {
    version = 3;
    rev = "v1.0.2";
    owner  = "billziss-gh";
    repo   = "cgofuse";
    sha256 = "0vcj9b9lrvs40k9k7vwsfja0b08xir3av8ppwrq2f62rckmdk9a1";
    buildInputs = [
      pkgs.fuse_2
    ];
  };

  chalk = buildFromGitHub {
    version = 2;
    rev = "22c06c80ed312dcb6e1cf394f9634aa2c4676e22";
    owner  = "ttacon";
    repo   = "chalk";
    sha256 = "0s5ffh4cilfg77bfxabr5b07sllic4xhbnz5ck68phys5jq9xhfs";
    date = "2016-06-26";
  };

  check = buildFromGitHub {
    version = 2;
    date = "2016-12-08";
    rev = "20d25e2804050c1cd24a7eea1e7a6447dd0e74ec";
    owner = "go-check";
    repo = "check";
    goPackagePath = "gopkg.in/check.v1";
    goPackageAliases = [
      "github.com/go-check/check"
    ];
    sha256 = "003qj5rpr27923bjvgd3mbgack3blw0m4izrq9plpxkha1glylz3";
  };

  circbuf = buildFromGitHub {
    version = 1;
    date = "2015-08-26";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "0wgpmzh0ga2kh51r214jjhaqhpqr9l2k6p0xhy5a006qypk5fh2m";
  };

  circonus-gometrics = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "1hkpsargcvzj21rw5ccf9sckzdbi2n6nqqpbrxsi5xmdmch5868g";
    propagatedBuildInputs = [
      circonusllhist
      go-retryablehttp
    ];
  };

  circonusllhist = buildFromGitHub {
    version = 3;
    date = "2017-05-25";
    rev = "6e85b9352cf0c2bb969831347491388bb3ae9c69";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "0qpkipra8irp0mxcr0b8pssjbqjhcfdp1rd0blzgicx4z01zpcq2";
  };

  cli_minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "cli";
    rev = "v1.3.0";
    sha256 = "08z1g5g3f07inpgyb93ip037f4y1cnhsm2wvg63qnnnry9chwy36";
    buildInputs = [
      toml
      urfave_cli
      yaml_v2
    ];
  };

  AudriusButkevicius_cli = buildFromGitHub {
    version = 2;
    rev = "7f561c78b5a4aad858d9fd550c92b5da6d55efbb";
    owner = "AudriusButkevicius";
    repo = "cli";
    sha256 = "0m9vi5cw611mddyxs7i7ss0j45xq2zmjdrf4mzi5d2khija7iirm";
    date = "2014-07-27";
  };

  docker_cli = buildFromGitHub {
    version = 3;
    date = "2017-08-08";
    rev = "4b61f560b5b0812fcebbe320a98baac9408a5dd4";
    owner = "docker";
    repo = "cli";
    sha256 = "01c6f2byg2q7kkhdc9s7qvxfxxm52agqlm7dzi5yy86bqiwkvzhk";
    subPackages = [
      "cli/config/configfile"
      "cli/config/credentials"
      "opts"
    ];
    propagatedBuildInputs = [
      docker-credential-helpers
      errors
      go-connections
      moby_lib
      go-units
    ];
  };

  mitchellh_cli = buildFromGitHub {
    version = 3;
    date = "2017-08-03";
    rev = "8a539dbef410aa4191e0bcc7a6246c104b313009";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "16l4d1ab6vq7vq11pyihzp3q0wrdq3mlh3hvmyg6xaz3j5xk284j";
    propagatedBuildInputs = [
      complete
      crypto
      go-isatty
      go-radix
      speakeasy
    ];
  };

  urfave_cli = buildFromGitHub {
    version = 3;
    rev = "v1.20.0";
    owner = "urfave";
    repo = "cli";
    sha256 = "1fmmp302zgs19br94v8ppymid9m9dz3iwvwypg7182r3rlbnwp9s";
    goPackagePath = "gopkg.in/urfave/cli.v1";
    goPackageAliases = [
      "github.com/codegangsta/cli"
      "github.com/urfave/cli"
    ];
    buildInputs = [
      toml
      yaml_v2
    ];
  };

  clock = buildFromGitHub {
    version = 2;
    owner = "jmhodges";
    repo = "clock";
    rev = "880ee4c335489bc78d01e4d0a254ae880734bc15";
    date = "2016-05-18";
    sha256 = "6290b02c154e2ac0a6360133cef7584a9fe2008086002dff94846bcbc167109b";
  };

  clockwork = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner = "jonboulle";
    repo = "clockwork";
    sha256 = "1hwdrck8k4nxdc0zpbd4hbxsyh8xhip9k7d71cv4ziwlh71sci5g";
  };

  clog = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "couchbase";
    repo = "clog";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  cmux = buildFromGitHub {
    version = 2;
    date = "2017-01-10";
    rev = "30d10be492927e2dcae0089c374c455d42414fcb";
    owner = "cockroachdb";
    repo = "cmux";
    sha256 = "07g8dff49mg9plpd3v23bgbfyaj3g1vj38yixay1sgl2k4p6ip98";
    propagatedBuildInputs = [
      net
    ];
  };

  cobra = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "cobra";
    rev = "b26b538f693051ac6518e65672de3144ce3fbedc";
    date = "2017-07-31";
    sha256 = "0bwzbq3ihjn5yqr3q2m99pym3p0r045sg924afqksj2mb5dfy8qv";
    buildInputs = [
      go-homedir
      mousetrap
      pflag
      viper
    ];
    propagatedBuildInputs = [
      go-md2man
      yaml_v2
    ];
  };

  cockroach-go = buildFromGitHub {
    version = 3;
    rev = "c806b484b8611fc587b6abc07f8bb0f7824a78d6";
    owner  = "cockroachdb";
    repo   = "cockroach-go";
    sha256 = "01qi0gn71cw9lr6axc6vib9m31xdkgnb21gs5xyk0fm1qaayzckm";
    date = "2017-08-08";
    propagatedBuildInputs = [
      pq
    ];
  };

  color = buildFromGitHub {
    version = 3;
    rev = "v1.5.0";
    owner  = "fatih";
    repo   = "color";
    sha256 = "1mss7grj2kv8nh31ib8kmsz63rj2iqkjs3f9z8r3zh4fnrm1i4ym";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
    ];
  };

  colorstring = buildFromGitHub {
    version = 1;
    rev = "8631ce90f28644f54aeedcb3e389a85174e067d1";
    owner  = "mitchellh";
    repo   = "colorstring";
    sha256 = "14dgak39642j795miqg5x7sb4ncpjgikn7vvbymxc5azy7z764hx";
    date = "2015-09-17";
  };

  columnize = buildFromGitHub {
    version = 3;
    rev = "abc90934186a77966e2beeac62ed966aac0561d5";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "00nrx8yh3ydynjlqf4daj49niwyrrmdav0g2a7cdzbxpsz6j7x22";
    date = "2017-07-03";
  };

  com = buildFromGitHub {
    version = 2;
    rev = "0db4a625e949e956314d7d1adea9bf82384cc10c";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "0flgww88p314wh3nikmmqmrnx2p7nq523cx40dsj2rh3kyxchy6i";
    date = "2017-02-13";
  };

  complete = buildFromGitHub {
    version = 3;
    rev = "f4461a52b6329c11190f11fe3384ec8aa964e21c";
    owner  = "posener";
    repo   = "complete";
    sha256 = "00rc393cyn30lpsrm0vyk5dxnkqlmciv0mkqs5i1xws0hs98yi0s";
    date = "2017-07-30";
    propagatedBuildInputs = [
      go-multierror
    ];
  };

  compress = buildFromGitHub {
    version = 2;
    rev = "v1.2.1";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "0ycfchs0brgxlvz48km955pzw0b71a9ipx3r2dqdawbf6zds5ix4";
    propagatedBuildInputs = [
      cpuid
      crc32
    ];
  };

  configure = buildFromGitHub {
    version = 2;
    rev = "4e0f2df8846ee9557b5c88307a769ff2f85e89cd";
    owner = "gravitational";
    repo = "configure";
    sha256 = "04qdmaz5pyd6nn7r5mdc2chzsx1zr2q0wv245xzzahx5n9m2x34x";
    date = "2016-10-02";
    propagatedBuildInputs = [
      gojsonschema
      kingpin_v2
      trace
      yaml_v2
    ];
    excludedPackages = "test";
  };

  consul = buildFromGitHub rec {
    version = 3;
    rev = "v0.9.2";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "16vml94kmccfxjbs19181icw2s051jsnh6v90k0hl4qwfgbh1860";

    buildInputs = [
      armon_go-metrics
      circbuf
      columnize
      copystructure
      dns
      errors
      go-bindata-assetfs
      go-checkpoint
      go-connections
      go-discover
      go-dockerclient
      go-memdb
      go-multierror
      go-radix
      go-rootcerts
      go-sockaddr
      go-syslog
      go-version
      golang-lru
      golang-text
      google-api-go-client
      gopsutil
      hashicorp_go-uuid
      hcl
      hil
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      net-rpc-msgpackrpc
      oauth2
      raft-boltdb_v2
      raft_v2
      scada-client
      ugorji_go
      yamux
    ];

    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];

    postPatch = let
      v = stdenv.lib.substring 1 (stdenv.lib.stringLength rev - 1) rev;
    in ''
      sed \
        -e 's,\(Version[ \t]*= "\)unknown,\1${v},g' \
        -e 's,\(VersionPrerelease[ \t]*= "\)unknown,\1,g' \
        -i version/version.go
    '';

    # Keep consul.ui for backward compatability
    passthru.ui = pkgs.consul-ui;
  };

  consul_api = buildFromGitHub {
    inherit (consul) rev owner repo sha256 version;
    propagatedBuildInputs = [
      go-cleanhttp
      go-rootcerts
      serf
    ];
    subPackages = [
      "api"
      "lib"
      "tlsutil"
    ];
  };

  consulfs = buildFromGitHub {
    version = 3;
    rev = "v0.2";
    owner = "bwester";
    repo = "consulfs";
    sha256 = "1br7zs43lmbxydw2ywsr8vdb5r5xwdlxd7hi120a0a0i77076cik";
    buildInputs = [
      consul_api
      fuse
      logrus
      net
    ];
  };

  consul-replicate = buildFromGitHub {
    version = 3;
    rev = "675a2c291d06aa1d152f11a2ac64b7001b588816";
    owner = "hashicorp";
    repo = "consul-replicate";
    sha256 = "0cjrsibg0d7p7rkgp5plxgsxb920ljs0g7wbajjnhizmlnprx3zk";
    propagatedBuildInputs = [
      consul_api
      consul-template
      errors
      go-multierror
      hcl
      mapstructure
    ];
    meta.useUnstable = true;
    date = "2017-08-10";
  };

  consul-template = buildFromGitHub {
    version = 3;
    rev = "v0.19.0";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "19pl5yxjq228syvaq2sn97z2dpcmvdbdki55fzmi43r7i70aqh3l";

    propagatedBuildInputs = [
      consul_api
      errors
      go-homedir
      go-multierror
      go-rootcerts
      go-shellwords
      go-syslog
      hcl
      logutils
      mapstructure
      toml
      yaml_v2
      vault_api
    ];
  };

  context = buildFromGitHub {
    version = 1;
    rev = "v1.1";
    owner = "gorilla";
    repo = "context";
    sha256 = "0fsm31ayvgpcddx3bd8fwwz7npyd7z8d5ja0w38lv02yb634daj6";
  };

  copystructure = buildFromGitHub {
    version = 3;
    date = "2017-05-25";
    rev = "d23ffcb85de31694d6ccaa23ccb4a03e55c1303f";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "1fg0jzz54d0xmkfh2gxk42bd3bcfci1h498bqf05rq576blbpcld";
    propagatedBuildInputs = [ reflectwalk ];
  };

  core = buildFromGitHub {
    version = 3;
    rev = "cd38c8eb3375b27cbc8c7f3f4f6501cce1eb4b4c";
    owner = "go-xorm";
    repo = "core";
    sha256 = "0g8flf592svx9gnylqb5xwq88x7bg083hd7vrx3mhnr8shkv3b2l";
    date = "2017-07-20";
  };

  cors = buildFromGitHub {
    version = 3;
    owner = "rs";
    repo = "cors";
    rev = "v1.2";
    sha256 = "0zgk21r48vwlhl7z9y3g6rckn8lhiz43x0kg4abb0id54z2jhmcb";
    propagatedBuildInputs = [
      net
      xhandler
    ];
  };

  cpuid = buildFromGitHub {
    version = 3;
    rev = "v1.1";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "1a4mcdvddiz9z7x6652z5qb81b0c5hdxfy9awrxzhcqs3dwnrgpa";
    excludedPackages = "testdata";
  };

  crc32 = buildFromGitHub {
    version = 3;
    rev = "bab58d77464aa9cf4e84200c3276da0831fe0c03";
    owner  = "klauspost";
    repo   = "crc32";
    sha256 = "1x40fs9im3hj56zzr6yfba8bd0vdg4dd434h52lfg1p2a5w8kh1w";
    date = "2017-06-28";
  };

  cronexpr = buildFromGitHub {
    version = 2;
    rev = "d520615e531a6bf3fb69406b9eba718261285ec8";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "0cjnck67s18sdrlx8cv0yys5vaf1sknywbzd2dyq2l144cjrsj7h";
    date = "2016-12-05";
  };

  cuckoo = buildFromGitHub {
    version = 2;
    rev = "44c50ab64b38d3a9e59e352d1f316ba363d66d3b";
    owner  = "tildeleb";
    repo   = "cuckoo";
    sha256 = "12q72scaa5h3dnzf9qhj5a75nzg4dq6ahlfsfvwa6rra0x9ylap6";
    date = "2016-12-04";
    goPackagePath = "leb.io/cuckoo";
    goPackageAliases = [
      "github.com/tildeleb/cuckoo"
    ];
    excludedPackages = "\\(example\\|dstest\\|primes/primes\\)";
    propagatedBuildInputs = [
      aeshash
      binary
    ];
  };

  crypt = buildFromGitHub {
    version = 3;
    owner = "xordataexchange";
    repo = "crypt";
    rev = "b2862e3d0a775f18c7cfe02273500ae307b61218";
    date = "2017-06-26";
    sha256 = "0jng0cymgbyl1mwiqr8cq2zkhycf0m2jwiwpqnps911faqdgk9fh";
    propagatedBuildInputs = [
      consul_api
      crypto
      etcd_client
    ];
    postPatch = ''
      sed -i backend/consul/consul.go \
        -e 's,"github.com/armon/consul-api",consulapi "github.com/hashicorp/consul/api",'
    '';
  };

  cssmin = buildFromGitHub {
    version = 1;
    owner = "dchest";
    repo = "cssmin";
    rev = "fb8d9b44afdc258bfff6052d3667521babcb2239";
    date = "2015-12-10";
    sha256 = "1m9zqdaw2qycvymknv6vx2i4jlpdj6lcjysxd18czbf5kp6pcri4";
  };

  datadog-go = buildFromGitHub {
    version = 3;
    rev = "1.1.0";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "1xxr9xjcx0is2y4477as03gxnxkc10cg65818s5kzlv8b2y1m15n";
  };

  dbus = buildFromGitHub {
    version = 3;
    rev = "bd29ed602e2cf4207ebcabcd530259169e4289ba";
    owner = "godbus";
    repo = "dbus";
    sha256 = "07ms9vg7pay4jbhjcavapfjsvxid0968m97fl24qwvcl2znmv089";
    date = "2017-07-07";
  };

  decimal = buildFromGitHub {
    version = 3;
    rev = "3c692774ac4c47c7a296ec96e553719dba1a68fc";
    owner  = "shopspring";
    repo   = "decimal";
    sha256 = "1ydxpvjdwxbfh2rfzlg4g9k8l70hcsx36bgrzqpcd5a6wipp7w5j";
    date = "2017-07-28";
  };

  demangle = buildFromGitHub {
    version = 3;
    date = "2016-09-27";
    rev = "4883227f66371e02c4948937d3e2be1664d9be38";
    owner = "ianlancetaylor";
    repo = "demangle";
    sha256 = "1fx4lz9gwps99ck0iskdjm0l3pnqr306h4w7578x3ni2vimc0ahy";
  };

  distribution = buildFromGitHub {
    version = 3;
    rev = "06fa77aa11a3913096efcb9b5bd25db8ef55a939";
    owner = "docker";
    repo = "distribution";
    sha256 = "12d977v85zk5nmnpyzkc3sz6ybkbyiarn7vw12z33548vqv165vg";
    meta.useUnstable = true;
    date = "2017-08-11";
  };

  distribution_for_moby = buildFromGitHub {
    inherit (distribution) date rev owner repo sha256 version meta;
    subPackages = [
      "."
      "digestset"
      "context"
      "manifest"
      "manifest/manifestlist"
      "reference"
      "registry/api/errcode"
      "registry/api/v2"
      "registry/client"
      "registry/client/auth"
      "registry/client/auth/challenge"
      "registry/client/transport"
      "registry/storage/cache"
      "registry/storage/cache/memory"
      "uuid"
    ];
    propagatedBuildInputs = [
      go-digest
      logrus
      mux
      net
    ];
  };

  distribution_for_engine-api = buildFromGitHub {
    inherit (distribution) date rev owner repo sha256 version meta;
    subPackages = [
      "digestset"
      "reference"
    ];
    propagatedBuildInputs = [
      go-digest
    ];
  };

  dns = buildFromGitHub {
    version = 3;
    rev = "bbca4873b326f5dc54bfe31148446d4ed79a5a02";
    date = "2017-08-08";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "1mgrvkqvmbvd49dhkwqz6rjbc4ih3fqq06cal6cjskr9wy61iyw9";
  };

  dnsimple-go = buildFromGitHub {
    version = 2;
    rev = "v0.14.0";
    owner  = "dnsimple";
    repo   = "dnsimple-go";
    sha256 = "0bvgl8wwkkl98kfn86lx2y74zfvc05dwqrzd46v4blw7vcm3wya5";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  dnspod-go = buildFromGitHub {
    version = 3;
    rev = "f33a2c6040fc2550a631de7b3a53bddccdcd73fb";
    owner = "decker502";
    repo = "dnspod-go";
    sha256 = "1dag0m8q3332b5dilml72bhrw9ixpv2r51p5rsfqcliag1ajc6zh";
    date = "2017-06-01";
  };

  docker-credential-helpers = buildFromGitHub {
    version = 3;
    rev = "v0.5.2";
    owner = "docker";
    repo = "docker-credential-helpers";
    sha256 = "03hmhqcplinffkvgdjy4wdjw85hvl4wh6b2wggs5nxlhinzprpbn";
    postPatch = ''
      find . -name \*_windows.go -delete
    '';
    buildInputs = [
      pkgs.libsecret
    ];
  };

  docopt-go = buildFromGitHub {
    version = 1;
    rev = "0.6.2";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "11cxmpapg7l8f4ar233f3ybvsir3ivmmbg1d4dbnqsr1hzv48xrf";
  };

  dropbox = buildFromGitHub {
    version = 2;
    owner = "stacktic";
    repo = "dropbox";
    rev = "58f839b21094d5e0af7caf613599830589233d20";
    date = "2016-04-24";
    sha256 = "4e9d14fa3be992f94b7672a21a90abfa746429d5ee260dcbfa11b391012595ad";
    propagatedBuildInputs = [
      net
      oauth2
    ];
  };

  dropbox-sdk-go-unofficial = buildFromGitHub {
    version = 3;
    rev = "5d9f46f9862ae5f65e264e178de6ce2c41a32d40";
    owner  = "ncw";
    repo   = "dropbox-sdk-go-unofficial";
    sha256 = "0jc4f7x0k6p57xksb0585hr057av240mmyj0dg9m2mylg78i8hja";
    date = "2017-05-30";
    propagatedBuildInputs = [
      oauth2
    ];
    excludedPackages = "generator";
  };

  dsync = buildFromGitHub {
    version = 3;
    owner = "minio";
    repo = "dsync";
    date = "2017-05-25";
    rev = "a26b9de6c8006208d10a9517720d3212b42c374e";
    sha256 = "002g928njl4jmnf2cyr3fc7jq72azyxfvd50324s05h6k3cg3rk7";
  };

  du = buildFromGitHub {
    version = 2;
    rev = "v1.0.1";
    owner  = "calmh";
    repo   = "du";
    sha256 = "00l7y5f2si43pz9iqnfccfbx6z6wni00aqc6jgkj1kwpjq5q9ya4";
  };

  duo_api_golang = buildFromGitHub {
    version = 2;
    date = "2016-06-27";
    rev = "2b2d787eb38e28ce4fd906321d717af19fad26a6";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "17vi9qg1dd02pmqjajqkspvdl676f0jhfzh4vzr4rxrcwgnqxdwx";
  };

  easyjson = buildFromGitHub {
    version = 3;
    owner = "mailru";
    repo = "easyjson";
    rev = "2f5df55504ebc322e4d52d34df6a1f5b503bf26d";
    date = "2017-06-24";
    sha256 = "0294rhzc6rygiq3nlgwaf5n3qncirnl3sdvrrw924iqpg863fg9i";
    excludedPackages = "benchmark";
  };

  ed25519 = buildFromGitHub {
    version = 2;
    owner = "agl";
    repo = "ed25519";
    rev = "5312a61534124124185d41f09206b9fef1d88403";
    sha256 = "0kb8jidncc30cn3dwwczxl7wnzjl862vy6p3rcrcnbgpygz6jhjf";
    date = "2017-01-16";
  };

  egoscale = buildFromGitHub {
    version = 2;
    rev = "ab4b0d7ff424c462da486aef27f354cdeb29a319";
    date = "2017-01-11";
    owner  = "pyr";
    repo   = "egoscale";
    sha256 = "5af0d24c309225f7243d71665b7f5558ae4403179663f40c01b1ba62a405eae5";
    meta.autoUpdate = false;
    subPackages = [
      "src/egoscale"
    ];
  };

  elastic_v3 = buildFromGitHub {
    version = 3;
    owner = "olivere";
    repo = "elastic";
    rev = "v3.0.69";
    sha256 = "0a34zkk8jybw0nzprqc5b8hrmlwxfn1vbsb97932c5v57wrqpyqn";
    goPackagePath = "gopkg.in/olivere/elastic.v3";
    propagatedBuildInputs = [
      net
    ];
  };

  elastic_v5 = buildFromGitHub {
    version = 3;
    owner = "olivere";
    repo = "elastic";
    rev = "v5.0.45";
    sha256 = "0iyfaxq9ikrvkxninsd7cmd4acrbm78s6d1jmlsbvik8aqvvkdd7";
    goPackagePath = "gopkg.in/olivere/elastic.v5";
    propagatedBuildInputs = [
      errors
      net
      sync
    ];
  };

  eme = buildFromGitHub {
    version = 2;
    owner = "rfjakob";
    repo = "eme";
    rev = "da627cc50b6fb2eb623eaffe91fb29d7eddfd06a";
    date = "2017-04-01";
    sha256 = "0g6fhwq4lb0zxm1y9f3n0f1kmd4g26paqn474l89h667bswd4zn4";
    meta.useUnstable = true;
  };

  emoji = buildFromGitHub {
    version = 3;
    owner = "kyokomi";
    repo = "emoji";
    rev = "ddd4753eac3f6480ca86b16cc6c98d26a0935d17";
    sha256 = "00af5gdm74jkp4kkv6gbxgk0j9msyhhcwpm89i5srj6w3zh13b1z";
    date = "2017-05-19";
  };

  encoding = buildFromGitHub {
    version = 2;
    owner = "jwilder";
    repo = "encoding";
    date = "2017-02-09";
    rev = "27894731927e49b0a9023f00312be26733744815";
    sha256 = "0sha9ghh6i9ca8bkw7qcjhppkb2dyyzh8zm760y4yi9i660r95h4";
  };

  engine-api = buildFromGitHub {
    version = 1;
    rev = "v0.4.0";
    owner = "docker";
    repo = "engine-api";
    sha256 = "1cgqhlngxlvplp6p560jvh4p003nm93pl4wannnlhwhcjrd34vyy";
    propagatedBuildInputs = [
      distribution_for_engine-api
      go-connections
      go-digest
      go-units
      net
    ];
  };

  envpprof = buildFromGitHub {
    version = 1;
    rev = "0383bfe017e02efb418ffd595fc54777a35e48b0";
    owner = "anacrolix";
    repo = "envpprof";
    sha256 = "0i9d021hmcfkv9wv55r701p6j6r8mj55fpl1kmhdhvar8s92rjgl";
    date = "2016-05-28";
  };

  errors = buildFromGitHub {
    version = 3;
    owner = "pkg";
    repo = "errors";
    rev = "c605e284fe17294bda444b34710735b29d1a9d90";
    sha256 = "0fafjna7v0m6qh3hx1zxwmqia8p2wlynq3kqsffj77r0pv75wvm2";
    date = "2017-05-05";
  };

  errwrap = buildFromGitHub {
    version = 1;
    date = "2014-10-27";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "02hsk2zbwg68w62i6shxc0lhjxz20p3svlmiyi5zjz988qm3s530";
  };

  escaper = buildFromGitHub {
    version = 2;
    owner = "lucasem";
    repo = "escaper";
    rev = "17fe61c658dcbdcbf246c783f4f7dc97efde3a8b";
    sha256 = "1k0cbipikxxqc4im8dhkiq30ziakbld6h88vzr099c4x00qvpanf";
    goPackageAliases = [
      "github.com/10gen/escaper"
    ];
    date = "2016-08-02";
  };

  etcd = buildFromGitHub {
    version = 3;
    owner = "coreos";
    repo = "etcd";
    rev = "v3.2.5";
    sha256 = "118xmv35br638984cwpd863sfc8jrrjma0nhfjxywi7qghw908mf";
    propagatedBuildInputs = [
      bolt
      btree
      urfave_cli
      ccache
      clockwork
      cobra
      cmux
      crypto
      go-grpc-prometheus
      go-humanize
      go-semver
      go-systemd
      groupcache
      grpc
      grpc-gateway
      jwt-go
      net
      pb_v1
      pflag
      pkg
      probing
      prometheus_client_golang
      protobuf
      gogo_protobuf
      pty
      speakeasy
      tablewriter
      time
      ugorji_go
      yaml

      pkgs.libpcap
    ];

    excludedPackages = "\\(benchmark\\|example\\|bridge\\)";
  };

  etcd_client = etcd.override {
    subPackages = [
      "auth/authpb"
      "client"
      "clientv3"
      "clientv3/concurrency"
      "clientv3/naming"
      "etcdserver/api/v3rpc/rpctypes"
      "etcdserver/etcdserverpb"
      "mvcc/mvccpb"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/srv"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
      "version"
    ];
    buildInputs = [
      go-systemd
    ];
    propagatedBuildInputs = [
      go-semver
      grpc
      net
      pkg
      protobuf
      ugorji_go
    ];
    rev = "v3.2.5";
    sha256 = "118xmv35br638984cwpd863sfc8jrrjma0nhfjxywi7qghw908mf";
    version = 3;
  };

  etcd_for_swarmkit = etcd.override {
    subPackages = [
      "raft/raftpb"
    ];
    buildInputs = [
    ];
    propagatedBuildInputs = [
      protobuf
    ];
    rev = "v3.2.5";
    sha256 = "118xmv35br638984cwpd863sfc8jrrjma0nhfjxywi7qghw908mf";
    version = 3;
  };

  etree = buildFromGitHub {
    version = 3;
    owner = "beevik";
    repo = "etree";
    rev = "15a30b44cfd6c5a16a7ddfe271bf146aaf2d3195";
    sha256 = "0h6lmwl8f4kqkgg3pi95bhpfrbq2a1ijdyqslx20ixlvgfvi9ywy";
    date = "2017-08-09";
  };

  ewma = buildFromGitHub {
    version = 3;
    owner = "VividCortex";
    repo = "ewma";
    rev = "43880d236f695d39c62cf7aa4ebd4508c258e6c0";
    date = "2017-08-04";
    sha256 = "0mdiahsdh61nbvdbzbf1p1rp13k08mcsw5xk75h8bn3smk3j8nrk";
    meta.useUnstable = true;
  };

  exp = buildFromGitHub {
    version = 1;
    date = "2016-07-11";
    rev = "888ba4519f76bfc1e26a9b32e52c6775677b36fd";
    owner  = "cznic";
    repo   = "exp";
    sha256 = "1a32kv2wjzz1yfgivrm1bp4hzg878jwfmv9qy9hvdx0kccy7rvpw";
    propagatedBuildInputs = [ bufs fileutil mathutil sortutil zappy ];
  };

  fifo = buildFromGitHub {
    version = 2;
    owner = "tonistiigi";
    repo = "fifo";
    rev = "8cf41abe4d87641cd48738771bf25a20d06ca0b2";
    date = "2017-02-24";
    sha256 = "83ef31b8e00f05d73bc0a2070c4d9a84e65cb1bb1541d6b80ed01ccbaca397d3";
    propagatedBuildInputs = [
      errors
      net
    ];
  };

  fileutil = buildFromGitHub {
    version = 2;
    date = "2017-03-22";
    rev = "90cf820aafe8f7df39416fdbb932029ff99bd1ab";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "036igc9nll1wnyzymnrkhf81jy4jq5wy6qfwwdacyrqp2glc87dr";
    buildInputs = [
      mathutil
    ];
  };

  fileutils = buildFromGitHub {
    version = 2;
    date = "2016-09-30";
    rev = "4ee1cc9a80582a0c75febdd5cfa779ee4361cbca";
    owner  = "mrunalp";
    repo   = "fileutils";
    sha256 = "1x1war04ck4kkwjfjzjksgldzkplv246qkkivwahfcfqcx8dapr3";
  };

  flagfile = buildFromGitHub {
    version = 3;
    date = "2017-06-19";
    rev = "aec8f353c0832daeaeb6a1bd09a9bf6f8fc677ae";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "0vaqlmayva323hs7qyza1n7383d2ly2k0hv8p2j6jl4bid9w8jy0";
  };

  form = buildFromGitHub {
    version = 3;
    rev = "c4048f792f70d207e6d8b9c1bf52319247f202b8";
    date = "2015-11-09";
    owner = "gravitational";
    repo = "form";
    sha256 = "0800jqfkmy4h2pavi8lhjqca84kam9b1azgwvb6z4kpirbnchpy3";
  };

  fs = buildFromGitHub {
    version = 1;
    date = "2013-11-07";
    rev = "2788f0dbd16903de03cb8186e5c7d97b69ad387b";
    owner  = "kr";
    repo   = "fs";
    sha256 = "16ygj65wk30cspvmrd38s6m8qjmlsviiq8zsnnvkhfy5l0gk4c86";
  };

  fsnotify = buildFromGitHub {
    version = 2;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.2";
    sha256 = "1kbs526vl358dd9rrcdnniwnzhcxkbswkmkl80dl2sgi9x0w45g6";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsnotify_v1 = buildFromGitHub {
    version = 2;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.2";
    sha256 = "1f3zshxdd3kj08b87106gxj68fjljfb7b3r9i8xjrj0i79wy6phn";
    goPackagePath = "gopkg.in/fsnotify.v1";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsync = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "fsync";
    rev = "12a01e648f05a938100a26858d2d59a120307a18";
    date = "2017-03-20";
    sha256 = "1vn313i08byzsmzvq98xqb074iiz1fx7hi912gzbzwrzxk81bish";
    buildInputs = [
      afero
    ];
  };

  ftp = buildFromGitHub {
    version = 3;
    owner = "jlaffaye";
    repo = "ftp";
    rev = "769512c448b98e9efa243279a7e281248332aa98";
    sha256 = "1280k4z9skk3ik7hmdlabrrvgcc2302d1dczxp9w6k91af92lp8s";
    date = "2017-07-21";
  };

  fuse = buildFromGitHub {
    version = 2;
    owner = "bazil";
    repo = "fuse";
    rev = "371fbbdaa8987b715bdd21d6adc4c9b20155f748";
    date = "2016-08-11";
    sha256 = "1f3cb9274f037e14c2437126fa17d39e6284f40f0ddb93b2dbb59d5bab6b97d0";
    goPackagePath = "bazil.org/fuse";
    propagatedBuildInputs = [
      net
      sys
    ];
  };

  fwd = buildFromGitHub {
    version = 3;
    date = "2017-06-16";
    rev = "1612a298117663d7bc9a760ae20d383413859798";
    owner  = "philhofer";
    repo   = "fwd";
    sha256 = "10rxpkclzsm7lwnvg6l6gys0cl265hs9bwyvb411a1c1l6yhvmqw";
  };

  gabs = buildFromGitHub {
    version = 3;
    owner = "Jeffail";
    repo = "gabs";
    rev = "9cef256b595a9e616eb6aec1da446529b7705613";
    sha256 = "1nf3f0q91bzy1gyyq4a7w2c60pg1n9hk2wq3n97jkg4p7yqkp6ih";
    date = "2017-06-07";
  };

  gateway = buildFromGitHub {
    version = 1;
    date = "2016-05-22";
    rev = "edad739645120eeb82866bc1901d3317b57909b1";
    owner  = "calmh";
    repo   = "gateway";
    sha256 = "0gzwns51jl2jm62ii99c7caa9p7x2c8p586q1cjz8bpv2mcd8njg";
    goPackageAliases = [
      "github.com/jackpal/gateway"
    ];
  };

  gax-go = buildFromGitHub {
    version = 3;
    date = "2017-06-10";
    rev = "84ed26760e7f6f80887a2fbfb50db3cc415d2cea";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "04vw26vqpmldysc7vs4cndcam20qq92w7kplv1l25nanixpaqf21";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
  };

  genproto = buildFromGitHub {
    version = 3;
    date = "2017-07-31";
    rev = "09f6ed296fc66555a25fe4ce95173148778dfa85";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "1lb64pnsl4cyshs7012vv4hmm65rzlh7h08jr5kfk6g2734gl820";
    propagatedBuildInputs = [
      grpc
      net
      protobuf
    ];
  };

  genproto_protobuf = genproto.override {
    subPackages = [
      "protobuf"
    ];
    buildInputs = [
      protobuf_genproto
    ];
    propagatedBuildInputs = [
    ];
  };

  genproto_for_grpc = genproto.override {
    subPackages = [
      "googleapis/rpc/status"
    ];
    buildInputs = [
      protobuf
    ];
    propagatedBuildInputs = [
    ];
  };

  geoip2-golang = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "0qs7v3hbhih7a99nd9xqc5mz2bgdvhknlzv3hr15fd1w5w49yv1b";
    propagatedBuildInputs = [
      maxminddb-golang
    ];
  };

  gettext = buildFromGitHub {
    version = 2;
    rev = "v0.9";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "1zrxfzwlv04gadxxyn8whmdin83ij735bbggxrnf3mcbxs8svs96";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  ginkgo = buildFromGitHub {
    version = 3;
    rev = "v1.4.0";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "1bbzwmy18lm2dj9javbn1blbiwz6jaqyz5g77g72i5ycd60my5kx";
    buildInputs = [
      sys
    ];
  };

  gitmap = buildFromGitHub {
    version = 3;
    rev = "de8030ebafb76c6e84d50ee6d143382637c00598";
    date = "2017-06-13";
    owner = "bep";
    repo = "gitmap";
    sha256 = "0r3h63lp98174p1d2qlnc3gc09hdc6gcj501sk85hlh3zr6iws6l";
  };

  gjson = buildFromGitHub {
    version = 3;
    owner = "tidwall";
    repo = "gjson";
    date = "2017-05-26";
    rev = "c784c417818f59d6597274642d8ac1d09efc9b01";
    sha256 = "02w1yj6jz656a6b8czq6grjn24ayr3m4d00wm4wzsys6hwdpvjbi";
    propagatedBuildInputs = [
      match
    ];
  };

  glob = buildFromGitHub {
    version = 2;
    rev = "v0.2.2";
    owner = "gobwas";
    repo = "glob";
    sha256 = "1mzn45p24qn7qdagfb9mlj96jlmwk3kgk637kxnb4qaqnl8bkkh1";
  };

  siddontang_go = buildFromGitHub {
    version = 3;
    date = "2017-05-17";
    rev = "cb568a3e5cc06256f91a2da5a87455f717eb33f4";
    owner = "siddontang";
    repo = "go";
    sha256 = "0g5k8gv7fmviyxpbxa6y05r5hfhchs8gas5idgcf8ahfgkv4x9i5";
  };

  ugorji_go = buildFromGitHub {
    version = 3;
    date = "2017-06-20";
    rev = "5efa3251c7f7d05e5d9704a69a984ec9f1386a40";
    owner = "ugorji";
    repo = "go";
    sha256 = "17mjy6529wggl0a1rdkd1virvf9mihlwjx1djmwfyn96m7kzrn58";
    goPackageAliases = [
      "github.com/hashicorp/go-msgpack"
    ];
  };

  go-acd = buildFromGitHub {
    version = 2;
    owner = "ncw";
    repo = "go-acd";
    rev = "96a49aad3fc3889629f2eceb004927386884bd92";
    date = "2017-03-06";
    sha256 = "0a737iq3chdsgl1wwmk5vjppkpb60qpj6pmma5k2hmbh9p2d51nz";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  go-ansiterm = buildFromGitHub {
    version = 3;
    owner = "Azure";
    repo = "go-ansiterm";
    rev = "19f72df4d05d31cbe1c56bfc8045c96babff6c7e";
    date = "2017-06-29";
    sha256 = "1lnv52868v32djwcl2xfhl8pawnq4hxlzaywlxfyr2yihc7d9vkm";
    buildInputs = [
      logrus
    ];
  };

  go-httpclient = buildFromGitHub {
    version = 2;
    owner = "mreiferson";
    repo = "go-httpclient";
    rev = "31f0106b4474f14bc441575c19d3a5fa21aa1f6c";
    date = "2016-06-30";
    sha256 = "e9fb80be94f61a8df23ee201be2988688cceba4d1c7339b60b955a66daebd3e3";
  };

  go4 = buildFromGitHub {
    version = 3;
    date = "2017-05-25";
    rev = "034d17a462f7b2dcd1a4a73553ec5357ff6e6c6e";
    owner = "camlistore";
    repo = "go4";
    sha256 = "0pfa73nh0gznyljipflnyzaimvrznarx5fmkjajnj3r3vf2gnwj4";
    goPackagePath = "go4.org";
    goPackageAliases = [
      "github.com/camlistore/go4"
    ];
    buildInputs = [
      google-api-go-client
      google-cloud-go
      oauth2
      net
      sys
    ];
  };

  gocapability = buildFromGitHub {
    version = 3;
    rev = "db04d3cc01c8b54962a58ec7e491717d06cfcc16";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "1nv9lnriwgnwqh2pd5cg884w1v9vmj8vzxfv4p4pilvzlz3aid6x";
    date = "2017-07-04";
  };

  gocql = buildFromGitHub {
    version = 3;
    rev = "77431609f517cb41ee9afdcdd373561c4d935316";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "0nd2bk7a86rbrljh3x67bd0fxf4xzvpggjjqrscawx839y8rvk6y";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2017-08-05";
  };

  gofuzz = buildFromGitHub {
    version = 3;
    rev = "24818f796faf91cd76ec7bddd72458fbced7a6c1";
    owner  = "google";
    repo   = "gofuzz";
    sha256 = "1ghcx5q9vsgmknl9954cp4ilgayfkg937c1z4m3lqr41fkma9zgi";
    date = "2017-06-12";
  };

  goid = buildFromGitHub {
    version = 3;
    rev = "0ded85884ba5c4c9267fcd5a149061f7c3455eee";
    owner  = "petermattis";
    repo   = "goid";
    sha256 = "1jfkjhqs3l011ybaz4rkda0yp42ywqzq0sqnxv6mz8ljs7n6cqjn";
    date = "2017-05-04";
  };

  gojsonpointer = buildFromGitHub {
    version = 2;
    rev = "6fe8760cad3569743d51ddbb243b26f8456742dc";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "0gfg90ibq0f6smmysj5svn1b04a39sc4w7xw38rgr4kyszhv4zj5";
    date = "2017-02-25";
  };

  gojsonreference = buildFromGitHub {
    version = 1;
    rev = "e02fc20de94c78484cd5ffb007f8af96be030a45";
    owner  = "xeipuuv";
    repo   = "gojsonreference";
    sha256 = "1c2yhjjxjvwcniqag9i5p159xsw4452vmnc2nqxnfsh1whd8wpi5";
    date = "2015-08-08";
    propagatedBuildInputs = [ gojsonpointer ];
  };

  gojsonschema = buildFromGitHub {
    version = 3;
    rev = "0c8571ac0ce161a5feb57375a9cdf148c98c0f70";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "17p69s1kf6alyap2rg4wffj44mvakp82jpq7c1yw6kpav4df46b0";
    date = "2017-05-28";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gomemcache = buildFromGitHub {
    version = 2;
    rev = "1952afaa557dc08e8e0d89eafab110fb501c1a2b";
    date = "2017-02-08";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "1h1sjgjv4ay6y26g25vg2q0iawmw8fnlam7r66qiq0hclzb72fcn";
  };

  gomemcached = buildFromGitHub {
    version = 3;
    rev = "70b5cd4e71d0714b3aaf449c6d23bbe0dc094c37";
    date = "2017-07-25";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "13b6f3wd9q9dkg9v9pnbjcvqg466rjx7wajvx42njnsxn1a1hyzh";
    propagatedBuildInputs = [
      goutils_logging
    ];
  };

  gopacket = buildFromGitHub {
    version = 3;
    rev = "v1.1.13";
    owner = "google";
    repo = "gopacket";
    sha256 = "14jmwsiks104higrf50rl6hs3364xraacchdn5ryfr22mmfdg93n";
    buildInputs = [
      pkgs.libpcap
      pkgs.pf-ring
    ];
    propagatedBuildInputs = [
      net
      sys
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 3;
    date = "2017-08-11";
    rev = "cfb32ab895c96d205842aa21f0e3a72cd4693385";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "1xbl9bfqbh0vn6cxj5rq2w3r5xss9wsl17ri69sqbhxy64vw362d";
    goPackagePath = "cloud.google.com/go";
    goPackageAliases = [
      "google.golang.org/cloud"
    ];
    propagatedBuildInputs = [
      debug
      gax-go
      genproto
      geo
      glog
      go-cmp
      google-api-go-client
      grpc
      net
      oauth2
      pprof
      protobuf
      sync
      text
      time
    ];
    postPatch = ''
      sed -i 's,bundler.Close,bundler.Stop,g' logging/logging.go
    '';
    excludedPackages = "\\(oauth2\\|readme\\|mocks\\)";
    meta.useUnstable = true;
  };

  google-cloud-go-compute-metadata = buildFromGitHub {
    inherit (google-cloud-go) rev date owner repo sha256 version goPackagePath goPackageAliases meta;
    subPackages = [
      "compute/metadata"
      "internal"
    ];
    propagatedBuildInputs = [
      gax-go
      net
    ];
  };

  gopcap = buildFromGitHub {
    version = 2;
    rev = "00e11033259acb75598ba416495bb708d864a010";
    date = "2015-07-28";
    owner = "akrennmair";
    repo = "gopcap";
    sha256 = "189skp51bd7aqpqs63z20xqm0pj5dra23g51m993rbq81zsvp0yq";
    buildInputs = [
      pkgs.libpcap
    ];
  };

  goprocess = buildFromGitHub {
    version = 2;
    rev = "b497e2f366b8624394fb2e89c10ab607bebdde0b";
    date = "2016-08-25";
    owner = "jbenet";
    repo = "goprocess";
    sha256 = "1i4spw84hlka1l8xxizpiqklsqyc3hxxjz3wbpn3i2ql68raylbx";
  };

  gops = buildFromGitHub {
    version = 3;
    rev = "806455e841dcb0614891ad847500aaa6b10d3d1d";
    owner = "google";
    repo = "gops";
    sha256 = "0c1hbp065q557dkgns7iz3p74z8l0md8rgmn3bdx6dj9wh5mfh0q";
    propagatedBuildInputs = [
      arch
      keybase_go-ps
      osext
    ];
    date = "2017-07-28";
  };

  goredis = buildFromGitHub {
    version = 1;
    rev = "760763f78400635ed7b9b115511b8ed06035e908";
    date = "2015-03-24";
    owner = "siddontang";
    repo = "goredis";
    sha256 = "193n28jaj01q0k8lx2ijvgzmlh926jy6cg2ph3446k90pl5r118c";
  };

  gorelic = buildFromGitHub {
    version = 2;
    rev = "ae09aa139a2b7f638e2412baceaceebd41eff115";
    date = "2016-06-16";
    owner = "yvasiyarov";
    repo = "gorelic";
    sha256 = "1x9hd2hlq796lf87h1jipqrf7vj7c1qxmg49f3qk5s4cvs5gzb5m";
  };

  goreq = buildFromGitHub {
    version = 2;
    rev = "b5b0f5eb2d16f20345cce0a544a75163579c0b00";
    date = "2017-04-18";
    owner = "franela";
    repo = "goreq";
    sha256 = "1bf0nqxrrs9grf0hd2rbyfxb2sj72jd5hd4nb5v5n5mrxhpmmaf4";
  };

  goterm = buildFromGitHub {
    version = 3;
    rev = "2f8dfbc7dbbff5dd1d391ed91482c24df243b2d3";
    date = "2017-08-07";
    owner = "buger";
    repo = "goterm";
    sha256 = "1i2f1vfgiw29x100msx09y27bsf02anbk2m00iaiflqyd2cjaynk";
  };

  gotty = buildFromGitHub {
    version = 2;
    rev = "cd527374f1e5bff4938207604a14f2e38a9cf512";
    date = "2012-06-04";
    owner = "Nvveen";
    repo = "Gotty";
    sha256 = "16slr2a0mzv2bi90s5pzmb6is6h2dagfr477y7g1s89ag1dcayp8";
  };

  goutils = buildFromGitHub {
    version = 3;
    rev = "7a02f3df0ea980574216f469c192985a2083b957";
    date = "2017-07-06";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "0hyy5clkj4rdad4s3prpdwks602p7ss0ag30kxaqvn31hppm9szl";
    buildInputs = [
      cbauth
      go-couchbase
      gomemcached
    ];
  };

  goutils_logging = buildFromGitHub {
    inherit (goutils) rev date owner repo sha256 version;
    subPackages = [
      "logging"
    ];
  };

  golang-lru = buildFromGitHub {
    version = 1;
    date = "2016-08-13";
    rev = "0a025b7e63adc15a622f29b0b2c4c3848243bbf6";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "1nq6q2l5ml3dljxm0ks4zivcci1yg2f2lmam9kvykkwm03m85qy1";
  };

  golang-petname = buildFromGitHub {
    version = 3;
    rev = "1f4996aa8aa05ee066aaf9e3179d340b48c6da74";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "0akdg7vf7ygg69caa2r6m012hi6n0rn2xhina3rdrjk3lxxpczad";
    date = "2017-04-27";
  };

  golang-text = buildFromGitHub {
    version = 2;
    rev = "048ed3d792f7104850acbc8cfc01e5a6070f4c04";
    owner  = "tonnerre";
    repo   = "golang-text";
    sha256 = "188nzg7dcr3xl8ipgdiks6h3wxi51391y4jza4jcbvw1z1mi7iig";
    date = "2013-09-25";
    propagatedBuildInputs = [
      pty
      kr_text
    ];
    meta.useUnstable = true;
  };

  golang_protobuf_extensions = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "0r1sv4jw60rsxy5wlnr524daixzmj4n1m1nysv4vxmwiw9mbr6fm";
    buildInputs = [ protobuf ];
  };

  goleveldb = buildFromGitHub {
    version = 3;
    rev = "b89cc31ef7977104127d34c1bd31ebd1a9db2199";
    date = "2017-07-25";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "1ijqvxh39181i9xirbmqzx8ap9y8q76nli47q59xhswvxsymaa35";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    version = 3;
    rev = "v1.2.0";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "114sz7v0cbdal40jhp8zrzqggws4hnlwrcfbix7hcc9811h8nmp1";
    propagatedBuildInputs = [
      net
      protobuf
      yaml_v2
    ];
  };

  google-api-go-client = buildGoPackage rec {
    name = nameFunc {
      inherit
        goPackagePath
        rev;
      date = "2017-08-10";
    };
    rev = "98825bb0065da4054e5da6db34f5fc598e50bc24";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 3;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "1mbxrlfv9yb0b2x3rl1wmygh3rcja7w13xwvnbi9fkjlhdkl9wdp";
    };
    buildInputs = [
      appengine
      genproto
      grpc
      net
      oauth2
      sync
    ];
  };

  goorgeous = buildFromGitHub {
    version = 3;
    rev = "677defd0e024333503d8c946dd4ba3f32ad3e5d2";
    date = "2017-04-27";
    owner = "chaseadamsio";
    repo = "goorgeous";
    sha256 = "03344fnr9786lc66yna509m0r266r7p47msmh197n8hdix8x653f";
    propagatedBuildInputs = [
      blackfriday
      sanitized-anchor-name
    ];
  };

  gopass = buildFromGitHub {
    version = 2;
    date = "2017-01-09";
    rev = "bf9dde6d0d2c004a008c27aaee91170c786f6db8";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0chij9mja3pwgmyvjcbp86xh9h9v1ljgpvscph6jxa1k1pp9dfah";
    propagatedBuildInputs = [
      crypto
      sys
    ];
  };

  gopsutil = buildFromGitHub {
    version = 3;
    rev = "v2.17.07";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "08farmyfbjpkfq7qdyq2845zsbhv80qk147l4qavxxrgbd9planw";
    buildInputs = [
      sys
      w32
      wmi
    ];
  };

  goquery = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "1c8q4ijhdm7ly26cvhr61kqla9gqc49c9s4v906k0shnbf3ygmm5";
    propagatedBuildInputs = [
      cascadia
      net
    ];
  };

  gosaml2 = buildFromGitHub {
    version = 3;
    rev = "8908227c114abe0b63b1f0606abae72d11bf632a";
    owner  = "russellhaering";
    repo   = "gosaml2";
    sha256 = "ebc793728bfb3f10c7aecedaf1831d4ea77c9c6f9572d374b02ca683ec531633";
    date = "2017-05-15";
    excludedPackages = "test";
    propagatedBuildInputs = [
      etree
      goxmldsig
      satori_go-uuid
    ];
    meta.autoUpdate = false;
  };

  goskiplist = buildFromGitHub {
    version = 1;
    rev = "2dfbae5fcf46374f166f8969cb07e167f1be6273";
    owner  = "ryszard";
    repo   = "goskiplist";
    sha256 = "1dr6n2w5ikdddq9c1fwqnc0m383p73h2hd04302cfgxqbnymabzq";
    date = "2015-03-12";
  };

  govalidator = buildFromGitHub {
    version = 3;
    rev = "15028e809df8c71964e8efa6c11e81d5c0262302";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "14m29wwkc2x5aj7xqll2b25gz01m4q2ibrcibgyg4llgjs2cz0i0";
    date = "2017-07-30";
  };

  goxmldsig = buildFromGitHub {
    version = 3;
    rev = "605161228693b2efadce55323c9c661a40c5fbaa";
    owner  = "russellhaering";
    repo   = "goxmldsig";
    sha256 = "0sclfnwqrkl2nm0l0v0jal9hif54nc4bi1w5s5xkgss8svdr5v5s";
    date = "2017-05-15";
    propagatedBuildInputs = [
      clockwork
      etree
    ];
  };

  go-autorest = buildFromGitHub {
    version = 3;
    rev = "v8.1.1";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "1syimclfjkjxmgj5azvk3bc2qxv2lgc9pj0bjcn5syj79wbk76cw";
    propagatedBuildInputs = [
      crypto
      jwt-go
    ];
  };

  go-base58 = buildFromGitHub {
    version = 1;
    rev = "1.0.0";
    owner  = "jbenet";
    repo   = "go-base58";
    sha256 = "0sbss2611iri3mclcz3k9b7kw2sqgwswg4yxzs02vjk3673dcbh2";
  };

  go-bindata-assetfs = buildFromGitHub {
    version = 2;
    rev = "30f82fa23fd844bd5bb1e5f216db87fd77b5eb43";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "0pval4z7k1bbcdx1hqd4cw9x5l01pikkya0n61c4wrfi0ghx25ln";
    date = "2017-02-27";
  };

  go-bits = buildFromGitHub {
    version = 2;
    owner = "dgryski";
    repo = "go-bits";
    date = "2016-06-01";
    rev = "2ad8d707cc05b1815ce6ff2543bb5e8d8f9298ef";
    sha256 = "d77d906fb806bb9bd9af7f54f0c3277d6b86d84015e198cb367f1d7788c8b938";
  };

  go-bitstream = buildFromGitHub {
    version = 2;
    owner = "dgryski";
    repo = "go-bitstream";
    date = "2016-07-01";
    rev = "7d46cd22db7004f0cceb6f7975824b560cf0e486";
    sha256 = "32a82d1220c6d2ec05cf2d6150ed8f2a3ce6c544f626cc7574acaa57e31bbd9c";
  };

  go-buffruneio = buildFromGitHub {
    version = 2;
    owner = "pelletier";
    repo = "go-buffruneio";
    rev = "v0.2.0";
    sha256 = "080mjg20yp2h04pk5g2ls3jg7z2h80wjj0qv254k2hga63xkk3k6";
  };

  go-cache = buildFromGitHub {
    version = 3;
    rev = "a3647f8e31d79543b2d0f0ae2fe5c379d72cedc0";
    owner = "patrickmn";
    repo = "go-cache";
    sha256 = "154li6f7d9y3nrd6lvyh6nyzynrcjmlmjn8mfn4h05ddmxh34awx";
    date = "2017-07-22";
  };

  go-checkpoint = buildFromGitHub {
    version = 3;
    date = "2017-06-24";
    rev = "a8d0786e7fa88adb6b3bcaa341a99af7f9740671";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "0904djy0kciv2w4ccx0chjpb7fj4mp7w4rw792dj40nhch8xqjpm";
    propagatedBuildInputs = [
      go-cleanhttp
      hashicorp_go-uuid
    ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 2;
    date = "2017-02-10";
    rev = "3573b8b52aa7b37b9358d966a898feb387f62437";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "1q6fzddda47f0n2n04iz7lpz77j1lfs14477qd6ajjj6q0a6sii4";
  };

  go-cmp = buildFromGitHub {
    version = 3;
    rev = "v0.1.0";
    owner  = "google";
    repo   = "go-cmp";
    sha256 = "1z9kypq5yj9asmxmnk9rlsr4f7ghqbgvs7vljf0pg5fac4kbqdjp";
  };

  go-collectd = buildFromGitHub {
    version = 2;
    owner = "collectd";
    repo = "go-collectd";
    rev = "bf0e31aeedfea7fb13f821e0831cfe2b5974d1e9";
    sha256 = "1zz7l4cz9pasnnj3gjc43skw481rxncflsyvyw7n0k4aawklr14b";
    goPackagePath = "collectd.org";
    buildInputs = [
      grpc
      net
      pkgs.collectd
      protobuf
    ];
    preBuild = ''
      # Regerate protos
      srcDir="$(pwd)"/go/src
      pushd go/src/$goPackagePath >/dev/null
      find . -name \*pb.go -delete
      for file in $(find . -name \*.proto | sort | uniq); do
        pushd "$(dirname "$file")" > /dev/null
        echo "Regenerating protobuf: $file" >&2
        protoc -I "$srcDir" -I "$srcDir/$goPackagePath" -I . --go_out=plugins=grpc:. "$(basename "$file")"
        popd >/dev/null
      done
      popd >/dev/null

      # Create a config.h and proper headers
      export COLLECTD_SRC="$(pwd)/collectd-src"
      mkdir -pv "$COLLECTD_SRC"
      pushd "$COLLECTD_SRC" >/dev/null
        unpackFile "${pkgs.collectd.src}"
      popd >/dev/null
      srcdir="$(echo "$COLLECTD_SRC"/collectd-*)"
      # Run configure to generate config.h
      pushd "$srcdir" >/dev/null
        ./configure
      popd >/dev/null
      export CGO_CPPFLAGS="-I$srcdir/src/daemon -I$srcdir/src"
    '';
    date = "2017-04-11";
  };

  go-colorable = buildFromGitHub {
    version = 3;
    rev = "v0.0.9";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "18izn70blaqxynn8448g05brw3qf98fgp9i5p1mqmwfxnsp9zal1";
    propagatedBuildInputs = [
      go-isatty
    ];
  };

  go-connections = buildFromGitHub {
    version = 3;
    rev = "3ede32e2033de7505e6500d6c868c2b9ed9f169d";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "0jaq1w5jbml6g5gdc0cfig8lfwldzx2kwvx0a1xcn74mplnfik9f";
    propagatedBuildInputs = [
      errors
      go-winio
      logrus
      net
      runc
    ];
    date = "2017-06-23";
  };

  go-couchbase = buildFromGitHub {
    version = 3;
    rev = "6c44a8829958bfe71283ed9fec2c28d722a3be27";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "1fgzikknfxnb42m07ia0v7mq5g9gq636j7gvhncfcjzf3p9zhq1k";
    date = "2017-08-02";
    goPackageAliases = [
      "github.com/couchbaselabs/go-couchbase"
    ];
    propagatedBuildInputs = [
      gomemcached
      goutils_logging
    ];
    excludedPackages = "\\(perf\\|example\\)";
  };

  go-crypto = buildFromGitHub {
    version = 3;
    rev = "433e2f3d43ef1bd31387582a899389b2fbe2005e";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "0nbzcyqk440vd6ghp34wbw37cfhrpg65avp7w2b8a6pbxanqwxhh";
    date = "2017-06-28";
    propagatedBuildInputs = [
      ed25519
    ];
  };

  go-deadlock = buildFromGitHub {
    version = 3;
    rev = "97c0c22d81eb010bc97f8f04c6a69489fc95e4c3";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "0dly06dp0xdd6pf2yyndyw1dyr17rqjl2fd2s6hzsi2ss44zby9i";
    date = "2017-08-11";
    propagatedBuildInputs = [
      goid
    ];
  };

  go-discover = buildFromGitHub {
    version = 3;
    rev = "b518491d039b6782035b8881502b4f5e9fcc887b";
    owner  = "hashicorp";
    repo   = "go-discover";
    sha256 = "118k5wlv0c4nh2cynwin4za87h1whi2g1m69qb6hcs039wcmzk97";
    date = "2017-08-02";
    propagatedBuildInputs = [
      aws-sdk-go
      azure-sdk-for-go
      go-autorest
      google-api-go-client
      oauth2
      softlayer-go
    ];
  };

  go-difflib = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0zb1bmnd9kn0qbyn2b62r9apbkpj3752isgbpia9i3n9ix451cdb";
  };

  go-digest = buildFromGitHub {
    version = 3;
    rev = "279bed98673dd5bef374d3b6e4b09e2af76183bf";
    owner  = "opencontainers";
    repo   = "go-digest";
    sha256 = "10fbcg0fj2fawbv25gldj4xwjy14qz0dkrzkhbgmrc0za9k6qwv8";
    date = "2017-06-07";
    goPackageAliases = [
      "github.com/docker/distribution/digest"
    ];
  };

  go-dockerclient = buildFromGitHub {
    version = 3;
    date = "2017-08-11";
    rev = "75772940379e725b5aae213e570f9dcd751951cb";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "0y4vryflnf3rjhpw9s0wbkf99axi6d40fxvcqgm7m24pn8rjzqki";
    propagatedBuildInputs = [
      go-cleanhttp
      go-units
      go-winio
      moby_lib
      mux
      net
    ];
  };

  go-envparse = buildFromGitHub {
    version = 3;
    rev = "7af148db102f1bb91eb8c7c459f1e388688a4426";
    owner  = "hashicorp";
    repo   = "go-envparse";
    sha256 = "04l934fxwa95zdx5mb1xhqzhrszw86lb8h235xhyb5gd6v98n9gf";
    date = "2017-06-02";
  };

  go-errors = buildFromGitHub {
    version = 3;
    date = "2016-12-05";
    rev = "8fa88b06e5974e97fbf9899a7f86a344bfd1f105";
    owner  = "go-errors";
    repo   = "errors";
    sha256 = "1wplsrgwx656695nbq027lva4s422s8m9vvcqdvs86630v0zmz1s";
  };

  go-etcd = buildFromGitHub {
    version = 2;
    date = "2015-10-26";
    rev = "003851be7bb0694fe3cc457a49529a19388ee7cf";
    owner  = "coreos";
    repo   = "go-etcd";
    sha256 = "1cijiw77cy4z6p4zhagm0q7ydyn8kk24v1611arx6wmvzgi7lyc3";
    propagatedBuildInputs = [
      ugorji_go
    ];
  };

  go-ethereum = buildFromGitHub {
    version = 3;
    date = "2017-08-11";
    rev = "6ca59d98f88d4b4cc8bdeb2f023ff8c1fa228c6f";
    owner  = "ethereum";
    repo   = "go-ethereum";
    sha256 = "1nfcgnm3zd57pjqzishjsz7dvz2q7c0kspxi8pj1iv79lgyfhyh8";
    subPackages = [
      "crypto/sha3"
    ];
  };

  go-events = buildFromGitHub {
    version = 3;
    owner = "docker";
    repo = "go-events";
    rev = "9461782956ad83b30282bf90e31fa6a70c255ba9";
    date = "2017-07-21";
    sha256 = "1x902my10kmp3d24jcd9pxpbhma95jyqdd1k4ndjmcc6z4ygxxz1";
    propagatedBuildInputs = [
      logrus
    ];
  };

  go-farm = buildFromGitHub {
    version = 3;
    rev = "e2d0fe22b456fa0a35cd883ba355ecfcf1881490";
    owner  = "dgryski";
    repo   = "go-farm";
    sha256 = "052zb0hcvny391dhfz5wzd9jhzj8x16bw86hapyw9987vv2sx4ps";
    date = "2017-05-02";
  };

  go-flags = buildFromGitHub {
    version = 3;
    rev = "v1.3.0";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "09gljnkkm39lsjzdrbch4i5s5xyvs7n6bwxbrm4rqiglsz33l9fy";
  };

  go-floodsub = buildFromGitHub {
    version = 3;
    rev = "86110cb33f2894a8e3fe2a6158ee9b48fb2067f5";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "1nmbdgs532x20slbf331330fvvlwg221m9brzxs2c8l7ilpzx7sp";
    date = "2017-08-01";
    propagatedBuildInputs = [
      gogo_protobuf
      go-libp2p-host
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-protocol
      go-log
      go-multiaddr
      timecache
    ];
  };

  go-getter = buildFromGitHub {
    version = 3;
    rev = "6aae8e4e2dee8131187c6a54b52664796e5a02b0";
    date = "2017-07-13";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "1birb60gv9571bg3nixhr0r35qclzk9vd3m3cwbsbbx6ay06vxic";
    propagatedBuildInputs = [
      aws-sdk-go
      go-homedir
      go-netrc
      go-testing-interface
      go-version
      xz
    ];
  };

  go-git-ignore = buildFromGitHub {
    version = 3;
    rev = "730f0220149475811d197e7905f73b3eadd28f4b";
    date = "2017-07-08";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "0zw00py1mk5s4vlgfc9xp6kj29rgq5lxl2pw17jfl78wx4493ppd";
  };

  go-github = buildFromGitHub {
    version = 3;
    date = "2017-08-11";
    rev = "6afafa88c26eb51b33a8307c944bd2f0ef227af7";
    owner = "google";
    repo = "go-github";
    sha256 = "1n9g3y0wgcr2hymxpchix6dl9dls2v6vb8aqng1g9w844zxx4z8y";
    buildInputs = [
      appengine
      oauth2
    ];
    propagatedBuildInputs = [
      go-querystring
    ];
    excludedPackages = "example";
  };

  go-glob = buildFromGitHub {
    version = 3;
    date = "2017-01-28";
    rev = "256dc444b735e061061cf46c809487313d5b0065";
    owner = "ryanuber";
    repo = "go-glob";
    sha256 = "0qchs17kd5hs8c3al4nba385qn562hhf1ag4fpk5j2qfgpyw1zc8";
  };

  go-grpc-prometheus = buildFromGitHub {
    version = 3;
    rev = "0c1b191dbfe51efdabe3c14b9f6f3b96429e0722";
    owner = "grpc-ecosystem";
    repo = "go-grpc-prometheus";
    sha256 = "0z7abzyhgvkmkv0jim8y2ly5nfmx6912wlrbj06j5d1fj72c6mwh";
    propagatedBuildInputs = [
      grpc
      net
      prometheus_client_golang
    ];
    date = "2017-06-16";
  };

  go-hclog = buildFromGitHub {
    version = 3;
    date = "2017-07-16";
    rev = "b4e5765d1e5f00a0550911084f45f8214b5b83b9";
    owner  = "hashicorp";
    repo   = "go-hclog";
    sha256 = "0134nhly5751ip6sgjn05gqggraz9n0z1k57ngia5r4yldsccv5c";
  };

  go-hdb = buildFromGitHub {
    version = 3;
    rev = "v0.9.1";
    owner  = "SAP";
    repo   = "go-hdb";
    sha256 = "03jrxil6gsrnfn1y82kajmxm1x7zrp9sd5hcc0dn84fg1hf7bacs";
    propagatedBuildInputs = [
      text
    ];
  };

  go-homedir = buildFromGitHub {
    version = 2;
    date = "2016-12-03";
    rev = "b8bc1bf767474819792c23f32d8286a45736f1c6";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "18j4j5zpxlpqqbdcl7d7cl69gcj747wq3z2m58lb99376w4a5xm6";
  };

  go-homedir_minio = buildFromGitHub {
    version = 3;
    owner = "minio";
    repo = "go-homedir";
    date = "2017-06-05";
    rev = "21304a94172ae3a09dee2cd86a12fb6f842138c7";
    sha256 = "1bimq1gvgh35qq2560ar3618af4bayycw2c5z66mjh9bjp2hidby";
  };

  hailocab_go-hostpool = buildFromGitHub {
    version = 1;
    rev = "e80d13ce29ede4452c43dea11e79b9bc8a15b478";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "06ic8irabl0iwhmkyqq4wzq1d4pgp9vk1kmflgv1wd5d9q8qmkgf";
  };

  gohtml = buildFromGitHub {
    version = 3;
    owner = "yosssi";
    repo = "gohtml";
    rev = "0cb98725f71a637e7bb967a8e87a1bab7ebaa6b0";
    date = "2017-05-01";
    sha256 = "0pmm57d5iz75pqjn3rkq6dmz37yha97j25awczlldwyh0kssrrlj";
    propagatedBuildInputs = [
      net
    ];
  };

  go-humanize = buildFromGitHub {
    version = 2;
    rev = "259d2a102b871d17f30e3cd9881a642961a1e486";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "17mic4dp33ki0hv7snj5y6q96lh357gswzikbj1pqnkgia0hxbqf";
    date = "2017-02-28";
  };

  go-i18n = buildFromGitHub {
    version = 3;
    rev = "v1.8.1";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "14051aj5nr8nxssnjls0q6bibjhqq5cvvkh92vyp05bp04yjl3xl";
    buildInputs = [
      go-toml
      yaml_v2
    ];
  };

  go-immutable-radix = buildFromGitHub {
    version = 3;
    date = "2017-07-25";
    rev = "8aac2701530899b64bdea735a1de8da899815220";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1j7347idaa3qk4sn1gzg0hcch3qvf0lvhqbihmj4ca3bw05zqxpn";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ipfs-api = buildFromGitHub {
    version = 3;
    rev = "1c4abbe587f0f68fee5fcecf741a45dbe3d7bc12";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "06ja2138jhx8ayfndyfagmx5pk315xvzz8f40w4sfb0302by8lzb";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-floodsub
      go-homedir
      go-libp2p-peer
      go-multiaddr
      go-multiaddr-net
      go-multipart-files
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2017-08-07";
  };

  go-ipfs-util = buildFromGitHub {
    version = 3;
    rev = "ca91b45d2e776e6e066151f7b65a3984c87e9fbb";
    owner  = "ipfs";
    repo   = "go-ipfs-util";
    sha256 = "1ri1f5n5m1bdyjzigqygblim9hvf60bh49pd03819hny1wjz1660";
    date = "2017-07-10";
    buildInputs = [
      go-base58
      go-multihash
    ];
  };

  go-isatty = buildFromGitHub {
    version = 2;
    rev = "v0.0.2";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "1i54jlw90c03c05zifdpsv0mvnbv5q5qs6v0cnjan91smhag4y5x";
    buildInputs = [
      sys
    ];
  };

  go-jmespath = buildFromGitHub {
    version = 1;
    rev = "bd40a432e4c76585ef6b72d3fd96fb9b6dc7b68d";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "1jiz511xlndrai7xkpvr045x7fsda030240gcwjc4yg4y36ck8cg";
    date = "2016-08-03";
  };

  go-jose_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner = "square";
    repo = "go-jose";
    sha256 = "b2dac3e4693bbf2ef11c8afd6aec838479acb789c1d156084776e68488bbd64e";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
  };

  go-jose_v2 = buildFromGitHub {
    version = 3;
    rev = "v2.1.2";
    owner = "square";
    repo = "go-jose";
    sha256 = "1m206wxsq4nwr0gq234xz5v5m8h5ac49i5yry2wff0xm3nyplkl1";
    goPackagePath = "gopkg.in/square/go-jose.v2";
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
  };

  go-keyspace = buildFromGitHub {
    version = 2;
    rev = "5b898ac5add1da7178a4a98e69cb7b9205c085ee";
    owner = "whyrusleeping";
    repo = "go-keyspace";
    sha256 = "1kf9gyrhfjhqckziaag8qg5kyyy2zmkfz33wmf9c6p6xqypg0bx7";
    date = "2016-03-22";
  };

  go-libp2p-connmgr = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-connmgr";
    date = "2017-08-01";
    rev = "5aba8058ea40d335acf51a85300424542ab070e5";
    sha256 = "0v270m2jjif8i60ghbl56f787apvq6fykqq71zqdr5girzhc9014";
    propagatedBuildInputs = [
      go-libp2p-net
      go-libp2p-peer
      go-log
      go-multiaddr
    ];
  };

  go-libp2p-crypto = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-crypto";
    date = "2017-07-06";
    rev = "e89e1de117dd65c6129d99d1d853f48bc847cf17";
    sha256 = "0zcy9457502ramr17qyck3wgl233bv39hzlmmdhc758liyq1xgrf";
    propagatedBuildInputs = [
      btcd
      ed25519
      go-base58
      go-ipfs-util
      go-multihash
      gogo_protobuf
    ];
  };

  go-libp2p-host = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-host";
    date = "2017-08-01";
    rev = "828fbee5a8a8a57cf2e9c8464de3f501dab45f1d";
    sha256 = "1q0np50pbq8pilqwdy714qipfxalrr4apq76ainbnfhgvddpxfwl";
    propagatedBuildInputs = [
      go-libp2p-connmgr
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-multiaddr
      go-multistream
      go-semver
    ];
  };

  go-libp2p-interface-conn = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-interface-conn";
    date = "2017-07-11";
    rev = "b3243beaa4d5ee07591b5b3e0a0f18e37b61b8f9";
    sha256 = "0ygkqhgb8wkfpgr1fzixbxglvq2hyja8fq8za6n8fw69dh4vkpnk";
    propagatedBuildInputs = [
      go-ipfs-util
      go-libp2p-crypto
      go-libp2p-peer
      go-libp2p-transport
      go-maddr-filter
      go-multiaddr
    ];
  };

  go-libp2p-net = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-net";
    date = "2017-07-19";
    rev = "61a09c8234f639c70daa5f881e79b4fc1366a40e";
    sha256 = "0l5v0f3fm55hmfidm9rqynswgxxzw0p2f67iwsbvg64bfixvl3hf";
    propagatedBuildInputs = [
      goprocess
      go-libp2p-interface-conn
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-multiaddr
    ];
  };

  go-libp2p-peer = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-peer";
    date = "2017-07-19";
    rev = "d863b451638c441d046c53834ccfef13beebd025";
    sha256 = "1rnd6zcd1wwp74a95yj46nkzwznwvffnnpl3ap6baid0rf8vibi4";
    propagatedBuildInputs = [
      go-base58
      go-ipfs-util
      go-libp2p-crypto
      go-log
      go-multicodec-packed
      go-multihash
    ];
  };

  go-libp2p-peerstore = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-peerstore";
    date = "2017-07-19";
    rev = "b2087a91b1d6f5f0c4477c71a51a32eb68a8c685";
    sha256 = "0z9kdyw0g1436f2ndgb95nria6vqvjpmc6ymm7k6rbcr2v6xia5n";
    excludedPackages = "test";
    propagatedBuildInputs = [
      go-libp2p-crypto
      go-libp2p-peer
      go-log
      go-keyspace
      go-multiaddr
      go-multiaddr-net
      mafmt
    ];
  };

  go-libp2p-protocol = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-protocol";
    date = "2016-10-11";
    rev = "40488c03777c16bfcd65da2f675b192863cbc2dc";
    sha256 = "0mxs1x3cs0srrb2cvqbd2h0361gjhzz9xb7n6pjq013vnq6dyf03";
  };

  go-libp2p-transport = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-transport";
    date = "2017-07-19";
    rev = "1b7d004fdc7582bf3ed714b187a8294e71cf824b";
    sha256 = "1kfc7k8h7r1wngjbf89x9x5ixlf6pxaccplqvc6kq5k076qin9dp";
    propagatedBuildInputs = [
      go-log
      go-multiaddr
      go-multiaddr-net
      mafmt
    ];
  };

  go-log = buildFromGitHub {
    version = 2;
    owner = "ipfs";
    repo = "go-log";
    date = "2017-03-16";
    rev = "48d644b006ba26f1793bffc46396e981801078e3";
    sha256 = "1s2kjgrg12r1lpickn8qxvi3642rf34i17gda3jwzwn2gp9jyyvr";
    propagatedBuildInputs = [
      whyrusleeping_go-logging
    ];
  };

  whyrusleeping_go-logging = buildFromGitHub {
    version = 3;
    owner = "whyrusleeping";
    repo = "go-logging";
    date = "2017-05-15";
    rev = "0457bb6b88fc1973573aaf6b5145d8d3ae972390";
    sha256 = "0fmz7xcsk2k8dr9nmj4fgs7d1l10d85hn1qjc8f68wa0ax83yfjl";
  };

  go-logging = buildFromGitHub {
    version = 2;
    owner = "op";
    repo = "go-logging";
    date = "2016-03-15";
    rev = "970db520ece77730c7e4724c61121037378659d9";
    sha256 = "8087016a076abb7ab630f22c6e2b0ae8ce310350aad9792123c7842b299f87a7";
  };

  go-lxc_v2 = buildFromGitHub {
    version = 3;
    rev = "1a2cf29ce27f74298fe70acbf817ca2f46cf7457";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "01hz0g4vqjyscvs8n05y6zd1v6vi55rxnd2335q69mn2cx1fc96z";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2017-07-12";
  };

  go-lz4 = buildFromGitHub {
    version = 2;
    rev = "7224d8d8f27ef618c0a95f1ae69dbb0488abc33a";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1hbbagvmq7kxrlwqkn0i4mz66i3n37ch7y6bm9yncnjgd97kldms";
    date = "2016-09-24";
  };

  go-maddr-filter = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-maddr-filter";
    date = "2017-07-19";
    rev = "ac6a10c4e30dabf1a55aa0f51102ae4daed951fb";
    sha256 = "05rdpr0481ymc2ps5v77sn36jpl4whqrwyzzh310kjj87jkbxl6n";
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-net
    ];
  };

  go-md2man = buildFromGitHub {
    version = 3;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "23709d0847197db6021a51fdb193e66e9222d4e7";
    sha256 = "0vgvbhc6ygvn7di0f5qfz46w61qzm5p26m04ssgw7kq06wiy5igs";
    propagatedBuildInputs = [
      blackfriday
    ];
    date = "2017-06-03";
  };

  go-memdb = buildFromGitHub {
    version = 3;
    date = "2017-07-25";
    rev = "2b2d6c35e14e7557ea1003e707d5e179fa315028";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "0l4s613g2xsdh1q6m9nf4lzgrn1vp2hxjhgvd1rhizh9qwhvmpli";
    propagatedBuildInputs = [
      go-immutable-radix
    ];
  };

  rcrowley_go-metrics = buildFromGitHub {
    version = 2;
    rev = "1f30fe9094a513ce4c700b9a54458bbb0c96996c";
    date = "2016-11-28";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "1bz5x3i4xr1nnlknliqy5v2544qmr2jw7qb9ssdr9w68l330fpaa";
    propagatedBuildInputs = [ stathat ];
  };

  armon_go-metrics = buildFromGitHub {
    version = 3;
    date = "2017-08-09";
    rev = "023a4bbe4bb9bfb23ee7e1afc8d0abad217641f3";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0fgkzhnlmrfh9zc0gbjf36fa6v7bxsnnn0r6arlmrgnkp3801p3i";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
      go-immutable-radix
      prometheus_client_golang
    ];
  };

  go-metro = buildFromGitHub {
    version = 2;
    date = "2015-06-07";
    rev = "d5cb643948fbb1a699e6da1426f0dba75fe3bb8e";
    owner = "dgryski";
    repo = "go-metro";
    sha256 = "5d271cba19ad6aa9b0aaca7e7de6d5473eb4a9e4b682bbb1b7a4b37cca9bb706";
    meta.autoUpdate = false;
  };

  go-mssqldb = buildFromGitHub {
    version = 3;
    rev = "84dc5e6cc4a674abe81be5bf7835f4ae3dced817";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "1mmkjy2ymibcs168rrvidfnb4cb25fpmlybcr42xsv16lhcf2ax4";
    date = "2017-07-28";
    buildInputs = [
      crypto
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 3;
    rev = "6addc7f583980ebb06b33b5c24b703b245c6984f";
    date = "2017-07-31";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "1y70d7sirr848989hd6yvaldkv8iary4pxdw2xbm7za6lbagfaq9";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 3;
    rev = "f41dec4bb74b6eb5bc51eb1697a595d854d652b4";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "072nk1q8g697rrzldrihlp4q5wb3m2vgwdwyapz0a17n69xvvmd5";
    date = "2017-07-11";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
      utp
    ];
  };

  go-multicodec-packed = buildFromGitHub {
    version = 3;
    owner = "multiformats";
    repo = "go-multicodec-packed";
    date = "2017-06-28";
    rev = "0ee69486dc1c9087aacfcc575e333f305009997e";
    sha256 = "00f0dly4q5zic84gk7p513y08xgy7xqwsw6n5wv7mc89wj397s9w";
  };

  go-multierror = buildFromGitHub {
    version = 3;
    date = "2017-06-22";
    rev = "83588e72410abfbe4df460eeb6f30841ae47d4c4";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "0j2wkfr596av3ba1vd7bxqjvbipbh6p23b22afrfncpfq7hgqvh4";
    propagatedBuildInputs = [
      errwrap
    ];
  };

  go-multihash = buildFromGitHub {
    version = 3;
    rev = "f1ef5a02f28c862ca5a2037907cf76cc6c98dbf9";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "1chv3lkl59dbk18rccq25932fkifg4iirjxf6fqn218pws3p9vab";
    goPackageAliases = [ "github.com/jbenet/go-multihash" ];
    propagatedBuildInputs = [
      crypto
      go-base58
      go-ethereum
      hashland
      murmur3
    ];
    date = "2017-07-13";
  };

  go-multipart-files = buildFromGitHub {
    version = 1;
    rev = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "0fdzi6v6rshh172hzxf8v9qq3d36nw3gc7g7d79wj88pinnqf5by";
    date = "2015-09-03";
  };

  go-multistream = buildFromGitHub {
    version = 2;
    rev = "b8f1996688ab586031517919b49b1967fca8d5d9";
    date = "2017-03-17";
    owner  = "multiformats";
    repo   = "go-multistream";
    sha256 = "0110p4bk3m9xri96bn65kfibi5ir0ima6xbfsv7m8drijgzjyx3a";
  };

  go-nat-pmp = buildFromGitHub {
    version = 1;
    rev = "452c97607362b2ab5a7839b8d1704f0396b640ca";
    owner  = "AudriusButkevicius";
    repo   = "go-nat-pmp";
    sha256 = "0jjwqvanxxs15nhnkdx0mybxnyqm37bbg6yy0jr80czv623rp2bk";
    date = "2016-05-22";
    buildInputs = [
      gateway
    ];
  };

  go-nats = buildFromGitHub {
    version = 3;
    rev = "v1.3.0";
    owner = "nats-io";
    repo = "go-nats";
    sha256 = "13066sdbwp2r5zwljb5096q87q52i21k3p4aj6dypgclrnl072vi";
    excludedPackages = "test";
    propagatedBuildInputs = [
      nuid
      protobuf
    ];
    goPackageAliases = [
      "github.com/nats-io/nats"
    ];
  };

  go-nats-streaming = buildFromGitHub {
    version = 3;
    rev = "74358b8d57b1beed7a9cebbe332437f46ac2aed4";
    owner = "nats-io";
    repo = "go-nats-streaming";
    sha256 = "1vwssdpmz2ai2s6wzhn7c12ixh9bkzdz1v2ilv1lm7fkinw031sd";
    propagatedBuildInputs = [
      go-nats
      nuid
      gogo_protobuf
    ];
    date = "2017-08-09";
  };

  go-netrc = buildFromGitHub {
    version = 2;
    owner = "bgentry";
    repo = "go-netrc";
    date = "2014-05-22";
    rev = "9fd32a8b3d3d3f9d43c341bfe098430e07609480";
    sha256 = "68984543a73f4d7ad4b58708207a483bd74fc9388ac582eac532434b11361a9e";
  };

  go-oidc = buildFromGitHub {
    version = 3;
    date = "2017-07-11";
    rev = "a4973d9a4225417aecf5d450a9522f00c1f7130f";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "1kln6hlc9hkspmwr7fjlh7ajzwzrnqwgvdc5mybmcs82ayy0xf1s";
    propagatedBuildInputs = [
      cachecontrol
      clockwork
      go-jose_v2
      net
      oauth2
      pkg
    ];
  };

  go-okta = buildFromGitHub {
    version = 3;
    rev = "604992f291fddf4ca2c474811b483764e55827c7";
    owner = "sstarcher";
    repo = "go-okta";
    sha256 = "1hp04nvknxmvksvpr0n2jabxni58qhcviyzdis00m7l7n4snhdj0";
    date = "2017-07-30";
  };

  go-ole = buildFromGitHub {
    version = 3;
    date = "2017-07-12";
    rev = "085abb85892dc1949567b726dff00fa226c60c45";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "160lpmhs67hcyyfzicmv3zy5ss7wbikcm87bknsr83pqm5hp75b6";
    excludedPackages = "example";
  };

  go-os-rename = buildFromGitHub {
    version = 1;
    rev = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2";
    owner  = "jbenet";
    repo   = "go-os-rename";
    sha256 = "0y8rq0y654lcyl7ysijni75j8fpq4hhqnh9qiy2z4hvmnzvb85id";
    date = "2015-04-28";
  };

  go-ovh = buildFromGitHub {
    version = 3;
    rev = "d95f6f91b1fb339a53fc438df7289cd85756193b";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "03255kvlrmfmszf2nrki5v11nk4llxszvi1xslz70k0lhmkpi42x";
    date = "2017-06-30";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-plugin = buildFromGitHub {
    version = 3;
    rev = "871e7582ebde6a93f3e03d8c6fa0d2eb2eb98d02";
    date = "2017-08-07";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "0g1rgyy9kzgbnhx2gd5nd8wxhrgcyn1cxcbdkrfjmw2fi5a4jm9r";
    propagatedBuildInputs = [
      go-hclog
      go-testing-interface
      grpc
      net
      protobuf
      yamux
    ];
  };

  go-proxyproto = buildFromGitHub {
    version = 3;
    date = "2017-06-20";
    rev = "48572f11356f1843b694f21a290d4f1006bc5e47";
    owner  = "armon";
    repo   = "go-proxyproto";
    sha256 = "1csy3srrl28zfpf3nfaliqzkz5miclygydq8cwdggksivs471jac";
  };

  go-ps = buildFromGitHub {
    version = 2;
    rev = "4fdf99ab29366514c69ccccddab5dc58b8d84062";
    date = "2017-03-09";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "1x70gc6y9licdi6qww1lkwx1wkwwkqylzhkfl0wpnizl8m7vpdmp";
  };

  keybase_go-ps = buildFromGitHub {
    version = 3;
    rev = "668c8856d9992f97248b3177d45743d2cc1068db";
    date = "2016-10-05";
    owner  = "keybase";
    repo   = "go-ps";
    sha256 = "04f1qw4h19907d6x8lg4r1gkzl3i7z120bqsmrpl6lwb5irfy065";
  };

  go-python = buildFromGitHub {
    version = 2;
    owner = "sbinet";
    repo = "go-python";
    date = "2017-03-14";
    rev = "ba7e58341058bdefb92b359870caf2dc0a05cfcf";
    sha256 = "1jkkkg5nrdqz6iv6bzlbxg7gycmq4bjc5mrpw3r3lvzqn73sdga7";
    propagatedBuildInputs = [
      pkgs.python2Packages.python
    ];
  };

  go-querystring = buildFromGitHub {
    version = 2;
    date = "2017-01-11";
    rev = "53e6ce116135b80d037921a7fdd5138cf32d7a8a";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "1ibpx1hpqjkvcmn4gsz54k9p62sl1iac2kgb97spcl630nn4p0yj";
  };

  go-radix = buildFromGitHub {
    version = 3;
    rev = "1fca145dffbcaa8fe914309b1ec0cfc67500fe61";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "1lwh7qfsn0nk20jprdfa79ibnz9vw8yljhcvw7c2sqhss4lwyvkz";
    date = "2017-07-27";
  };

  go-resiliency = buildFromGitHub {
    version = 3;
    rev = "b1fe83b5b03f624450823b751b662259ffc6af70";
    owner  = "eapache";
    repo   = "go-resiliency";
    sha256 = "0iyn9ssm02ila0n8lm44awgsdpvzv833y0zwk9pgnm7s089slm8g";
    date = "2017-06-07";
  };

  go-restful = buildFromGitHub {
    version = 3;
    rev = "v2.2.1";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "1xf7r69i3kn36jrvqdy9ssfnaz5ywggviwnb7cvm5igkrvanji5a";
  };

  go-restful-swagger12 = buildFromGitHub {
    version = 2;
    rev = "1.0.1";
    owner = "emicklei";
    repo = "go-restful-swagger12";
    sha256 = "1ngfny928f2prwn1dgsih0z3fdhwqnnix89n045pk5q56dpd8b5s";
    goPackageAliases = [
      "github.com/emicklei/go-restful/swagger"
    ];
    propagatedBuildInputs = [
      go-restful
    ];
  };

  go-retryablehttp = buildFromGitHub {
    version = 2;
    rev = "2d5f5dbd904dbad432492c3ca2c12c72c9e3045a";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "1jdjjk5lrrkss81cinb092i4c63nzs0xra08p6zwz2ny9b6a5z54";
    date = "2017-04-21";
    propagatedBuildInputs = [
      go-cleanhttp
    ];
  };

  go-rootcerts = buildFromGitHub {
    version = 1;
    rev = "6bb64b370b90e7ef1fa532be9e591a81c3493e00";
    owner = "hashicorp";
    repo = "go-rootcerts";
    sha256 = "0wi9ar5av0s4a2xarxh360kml3nkicrcdzzmhq1d406p10c3qjp2";
    date = "2016-05-03";
    buildInputs = [
      go-homedir
    ];
  };

  go-runewidth = buildFromGitHub {
    version = 2;
    rev = "v0.0.2";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "1j99da81h9s528g3lmhgy1pvmzhhcxl8g3p9dzg8byxdsvjadxia";
  };

  go-semver = buildFromGitHub {
    version = 3;
    rev = "1817cd4bea52af76542157eeabd74b057d1a199e";
    owner  = "coreos";
    repo   = "go-semver";
    sha256 = "0fkf0myxfwwwcngk7wl3yr593xyvx905ag1s4hfbxx0mzgn7zy9n";
    date = "2017-06-13";
  };

  go-shellwords = buildFromGitHub {
    version = 2;
    rev = "v1.0.3";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "11prxlsk3kwgq6v5ikdsjv5vjv4hfihvw55qc27jip1ia2grcxvz";
  };

  go-simplejson = buildFromGitHub {
    version = 2;
    rev = "da1a8928f709389522c8023062a3739f3b4af419";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "0qrqmhi7wng3nb42ch4pp7xly2yia8grg3mkifqnra5d9pr7q91j";
    date = "2017-02-06";
  };

  go-snappy = buildFromGitHub {
    version = 1;
    rev = "d8f7bb82a96d89c1254e5a6c967134e1433c9ee2";
    owner  = "siddontang";
    repo   = "go-snappy";
    sha256 = "18ikmwl43nqdphvni8z15jzhvqksqfbk8rspwd11zy24lmklci7b";
    date = "2014-07-04";
  };

  go-sockaddr = buildFromGitHub {
    version = 3;
    rev = "41949a141473f6340abc6ba0fcd0f89da6f6f837";
    owner  = "hashicorp";
    repo   = "go-sockaddr";
    sha256 = "1mbhdbyj3gnlh8akpm4hj1r78blxkqj5ds3l34ssdyg8mp6gwxgx";
    date = "2017-06-27";
    propagatedBuildInputs = [
      mitchellh_cli
      columnize
      errwrap
      go-wordwrap
    ];
  };

  go-spew = buildFromGitHub {
    version = 3;
    rev = "adab96458c51a58dc1783b3335dcce5461522e75";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1fv0anfh2ccpdfj7w8h70i4i7wd6mcm7ddamb2fikrvlgx5vd2lq";
    date = "2017-07-11";
  };

  go-sqlite3 = buildFromGitHub {
    version = 3;
    rev = "6654e412c3c7eabb310d920cf73a2102dbf8c632";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0ij6pi5zjmr9b6nan8rsvs1mhc5g0k0gy9csmvs2fqy1j17dr83q";
    excludedPackages = "test";
    buildInputs = [
      goquery
    ];
    propagatedBuildInputs = [
      net
    ];
    date = "2017-08-01";
  };

  go-stun = buildFromGitHub {
    version = 3;
    rev = "0.1.0";
    owner  = "ccding";
    repo   = "go-stun";
    sha256 = "0rw7r4vmb4h7wm9r1wqymvx04jgsmdqrpf7sp523npdni4d1j1my";
  };

  go-syslog = buildFromGitHub {
    version = 2;
    date = "2016-12-13";
    rev = "b609c7d9de4658cded34a7336b90886c56f9dbdb";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "0py0lgqxcwyjhjl68bi6psrgs0vqhd38nd06jihk235wdxq6149a";
  };

  go-systemd = buildFromGitHub {
    version = 3;
    rev = "d2196463941895ee908e13531a23a39feb9e1243";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "18fhvqdlh4gkznpm1q479cancwmgq2vdgyfjpzvxigfqs3alh8nm";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2017-07-31";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 version date;
    subPackages = [
      "journal"
    ];
  };

  go-testing-interface = buildFromGitHub {
    version = 3;
    owner = "mitchellh";
    repo = "go-testing-interface";
    rev = "9a441910b16872f7b8283682619b3761a9aa2222";
    sha256 = "057c7lnnvv3g26kj82dkhvfxya76shyacbkpzi95i0g93z8nashv";
    date = "2017-07-30";
  };

  go-toml = buildFromGitHub {
    version = 3;
    owner = "pelletier";
    repo = "go-toml";
    rev = "69d355db5304c0f7f809a2edc054553e7142f016";
    sha256 = "1db2xaaihw3ygrrd1n2mxys7cyzxrl07kcs70s923sv1qk11wif6";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2017-06-28";
  };

  go-units = buildFromGitHub {
    version = 2;
    rev = "0dadbb0345b35ec7ef35e228dabb8de89a65bf52";
    owner = "docker";
    repo = "go-units";
    sha256 = "19xnz75m0qmydh2pgcgb6im6hmp4606jwagfxf892rs446vn2wqi";
    date = "2017-01-27";
  };

  go-unsnap-stream = buildFromGitHub {
    version = 2;
    rev = "87275cecd8e984c5875577d22da7ce8945df780e";
    owner = "glycerine";
    repo = "go-unsnap-stream";
    sha256 = "1bgwgfg34s3zb39g2ifp5sj65gibvsj9b82dy05vk6wv9zxqh5n2";
    date = "2016-12-13";
    propagatedBuildInputs = [
      snappy
    ];
  };

  hashicorp_go-uuid = buildFromGitHub {
    version = 1;
    rev = "64130c7a86d732268a38cb04cfbaf0cc987fda98";
    date = "2016-07-16";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "072c84wn90di09qxrg0ml8vjfb5k10zk2n4k0rgxk1n45wyghkjx";
  };

  satori_go-uuid = buildFromGitHub {
    version = 3;
    rev = "5bf94b69c6b68ee1b541973bb8e1144db23a194b";
    date = "2017-03-21";
    owner  = "satori";
    repo   = "go.uuid";
    sha256 = "0xdavv3zghc00xa8in1427yksbx1lzk2x2fzq8y82vhdj3majrr7";
  };

  go-version = buildFromGitHub {
    version = 2;
    rev = "03c5bf6be031b6dd45afec16b1cf94fc8938bc77";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "0py0cmlj4c1zfxnszr0jqgvqgrpa1iwk8r0iai5p0vvzf4zafbkj";
    date = "2017-02-02";
  };

  go-winio = buildFromGitHub {
    version = 3;
    rev = "v0.4.5";
    owner  = "Microsoft";
    repo   = "go-winio";
    sha256 = "1jb47ynakszf0yrgx31m1shgkqngih7ck61p2w47rhwpr4415cyr";
    buildInputs = [
      sys
    ];
    # Doesn't build on non-windows machines
    postPatch = ''
      rm vhd/zvhd.go
    '';
  };

  go-wordwrap = buildFromGitHub {
    version = 2;
    rev = "ad45545899c7b13c020ea92b2072220eefad42b8";
    owner  = "mitchellh";
    repo   = "go-wordwrap";
    sha256 = "0yj17x3c1mr9l3q4dwvy8y2xgndn833rbzsjf10y48yvr12zqjd0";
    date = "2015-03-14";
  };

  go-xerial-snappy = buildFromGitHub {
    version = 3;
    rev = "bb955e01b9346ac19dc29eb16586c90ded99a98c";
    owner  = "eapache";
    repo   = "go-xerial-snappy";
    sha256 = "055fdp516prfb61sl4gww6mkj0wd909n3m80l5mvhbyngsh67h8i";
    date = "2016-06-09";
    propagatedBuildInputs = [
      snappy
    ];
  };

  go-zookeeper = buildFromGitHub {
    version = 3;
    rev = "8ac67fae881ed12e87206ba2243c75b079b419a4";
    date = "2017-08-04";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "1anl49g6f5f9r2h126k7g0g3ybg4vjfy6ysh830n95a51lqw5yds";
  };

  goconfig = buildFromGitHub {
    version = 2;
    owner = "Unknwon";
    repo = "goconfig";
    rev = "87a46d97951ee1ea20ed3b24c25646a79e87ba5d";
    date = "2016-11-21";
    sha256 = "4b1e8153d3bcaa0e5f929b1cd09e4fb780a4753d4aaf8df12b4915c6a65eb70a";
  };

  gorequest = buildFromGitHub {
    version = 2;
    owner = "parnurzeal";
    repo = "gorequest";
    rev = "v0.2.15";
    sha256 = "0r3jidgjrnh43slhxhggwy11ka90gd05blsh102x48di7pxz3kn8";
    propagatedBuildInputs = [
      errors
      http2curl
      net
    ];
  };

  grafana = buildFromGitHub {
    version = 3;
    owner = "grafana";
    repo = "grafana";
    rev = "v4.4.3";
    sha256 = "0knz4jhjs7f249ykzqk80gpv84nvwv998wfggbl7xlhz06lzlfld";
    buildInputs = [
      amqp
      aws-sdk-go
      binding
      urfave_cli
      color
      goreq
      go-spew
      go-sqlite3
      go-version
      gzip
      inject
      ini_v1
      ldap
      log15
      macaron_v1
      net
      oauth2
      session
      slug
      toml
      websocket
      xorm
    ];
  };

  graphite-golang = buildFromGitHub {
    version = 2;
    owner = "marpaia";
    repo = "graphite-golang";
    date = "2016-11-29";
    rev = "c474c9b821b4d0a4574edc6412b0003fbce233c4";
    sha256 = "0gvm8x29y4y2cv358hr1cs6sr8p6snbcmnmag6pa0a2sjwahj7i0";
  };

  groupcache = buildFromGitHub {
    version = 2;
    date = "2017-04-21";
    rev = "b710c8433bd175204919eb38776e944233235d03";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "1vjwgr23yf206l4hymdnr3lczlq6v7q5yr5wh20v7m4dd63362k2";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    version = 3;
    rev = "v1.5.1";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "1106vw3gmkxgwn56phhpv88cgdnk5s1gc5q3i5dmn170ynf2i0m2";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [
      "github.com/grpc/grpc-go"
    ];
    excludedPackages = "\\(test\\|benchmark\\)";
    propagatedBuildInputs = [
      genproto_for_grpc
      glog
      net
      oauth2
      protobuf
    ];
  };

  grpc_for_gax-go = grpc.override {
    propagatedBuildInputs = [
      genproto_for_grpc
      net
      protobuf
    ];
    subPackages = [
      "."
      "codes"
      "credentials"
      "grpclb/grpc_lb_v1"
      "grpclog"
      "internal"
      "keepalive"
      "metadata"
      "naming"
      "peer"
      "stats"
      "status"
      "tap"
      "transport"
    ];
  };

  grpc-gateway = buildFromGitHub {
    version = 2;
    rev = "v1.2.2";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "0cd3c038hdkb64myqdq2bhcp6l44bbm1fdd7sb66rkqb461aikkw";
    propagatedBuildInputs = [
      genproto
      glog
      grpc
      net
      protobuf
    ];
  };

  grumpy = buildFromGitHub {
    version = 3;
    owner = "google";
    repo = "grumpy";
    rev = "f1446cd91c750b2439a1eb9a1e92f736a9fbb551";
    sha256 = "6ad8e8b05e189d7c288963c1f1eeed433c6b333ad51c89ec788ae2b1f52b4c03";

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.which
    ];

    buildInputs = [
      pkgs.python2
    ];

    postPatch = ''
      # FIXME: fix executables not installing to $bin correctly
      sed -i Makefile \
        -e "s,[^@]/usr/bin,\)$out/bin,g" \
        -e "s,/usr/lib,$out/lib,g"
    '';

    preBuild = ''
      cd go/src/github.com/google/grumpy
    '';

    buildPhase = ''
      runHook preBuild
      make
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make install "PY_INSTALL_DIR=$out/${pkgs.python2.sitePackages}"
      runHook postInstall
    '';

    preFixup = ''
      for i in $out/bin/grump{c,run}; do
        wrapProgram  "$i" \
          --set 'GOPATH' : "$out" \
          --prefix 'PYTHONPATH' : "$out/${pkgs.python2.sitePackages}"
      done
      # FIXME: prevent failures
      mkdir -p $bin
    '';

    buildDirCheck = false;

    meta = with lib; {
      description = "Python to Go source code transcompiler and runtime";
      homepage = https://github.com/google/grumpy;
      license = licenses.asl20;
      maintainers = with maintainers; [
        codyopel
      ];
      platforms = with platforms;
        x86_64-linux;
    };
  };

  gucumber = buildFromGitHub {
    version = 1;
    date = "2016-07-14";
    rev = "71608e2f6e76fd4da5b09a376aeec7a5c0b5edbc";
    owner = "gucumber";
    repo = "gucumber";
    sha256 = "0ghz0x1zdm1ypp9ycw871r2rcklik84z7pqgs2i88sk2s4m4igar";
    buildInputs = [ testify ];
    propagatedBuildInputs = [ ansicolor ];
  };

  gx = buildFromGitHub {
    version = 3;
    rev = "v0.12.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "1106wm35kf5x9q8if8fqprkbm3802c7pbj6s6v3lyqayakmky6km";
    propagatedBuildInputs = [
      go-git-ignore
      go-homedir
      go-multiaddr
      go-multihash
      go-multiaddr-net
      go-os-rename
      json-filter
      progmeter
      semver
      stump
      urfave_cli
      go-ipfs-api
    ];
    excludedPackages = [
      "tests"
    ];
  };

  gx-go = buildFromGitHub {
    version = 3;
    rev = "v1.5.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "1smfk0gkhdh19k18wkk9q15z107wcy4zskiyz6h9g1blx2s2hpg7";
    buildInputs = [
      urfave_cli
      fs
      go-homedir
      gx
      stump
    ];
  };

  gzip = buildFromGitHub {
    version = 1;
    date = "2016-02-21";
    rev = "cad1c6580a07c56f5f6bc52d66002a05985c5854";
    owner = "go-macaron";
    repo = "gzip";
    sha256 = "1myrzvymwxxck5xw9jbm1fp9aazhvqdp2sc2snymvnnlxwc8f0an";
    propagatedBuildInputs = [
      compress
      macaron_v1
    ];
  };

  gziphandler = buildFromGitHub {
    version = 3;
    date = "2017-08-04";
    rev = "967539e5e271a2bc9b3dcb1285078a1b1df105ae";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "0cgwcpi37dzk6mrpsq0ch79yy7hgl4iqpbmm0qbfrlc1mcgywv43";
  };

  hashland = buildFromGitHub {
    version = 2;
    rev = "e13accbe55f7fa03c73c74ace4cca4c425e47260";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "0gws01aq8fy53kljpngs4y5l02aqjm5jd6pa3l7j1h56pk2n2zs8";
    goPackagePath = "leb.io/hashland";
    date = "2016-11-30";
    excludedPackages = "example";
    propagatedBuildInputs = [
      aeshash
      cuckoo
      go-farm
      go-metro
      hrff
    ];
  };

  hashland_for_aeshash = buildFromGitHub {
    version = 2;
    rev = "e13accbe55f7fa03c73c74ace4cca4c425e47260";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "0gws01aq8fy53kljpngs4y5l02aqjm5jd6pa3l7j1h56pk2n2zs8";
    goPackagePath = "leb.io/hashland";
    date = "2016-11-30";
    subPackages = [
      "nhash"
    ];
  };

  handlers = buildFromGitHub {
    version = 3;
    owner = "gorilla";
    repo = "handlers";
    rev = "v1.2.1";
    sha256 = "1kndqmbzlp5xcapnmaqhwj6w3hxid6b4hb3z7vnai3jqh6fbd690";
  };

  hashstructure = buildFromGitHub {
    version = 3;
    date = "2017-06-09";
    rev = "2bca23e0e452137f789efbc8610126fd8b94f73b";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "12z3vcxbdgkn1hfisj3m23kgq9lkl1rby5cik7878sbdy9zkl0bw";
  };

  hcl = buildFromGitHub {
    version = 3;
    date = "2017-05-09";
    rev = "392dba7d905ed5d04a5794ba89f558b27e2ba1ca";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "1vipx0lliyqgf2kwrd923dc5xcpa1is0wjj64cv89dlbrg9pr9n5";
  };

  hdrhistogram = buildFromGitHub {
    version = 2;
    date = "2016-10-09";
    rev = "3a0bb77429bd3a61596f5e8a3172445844342120";
    owner  = "codahale";
    repo   = "hdrhistogram";
    sha256 = "0xnsf0yzh4z1iyl0vcbj97cyl19zq37hvjfz533zq91xglgpghmc";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  hil = buildFromGitHub {
    version = 3;
    date = "2017-06-27";
    rev = "fa9f258a92500514cc8e9c67020487709df92432";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "1m0gzss7vgq9jdc4sx4cjlid1r1zahf0mi0mc4q6b7hz25zkmkwk";
    propagatedBuildInputs = [
      mapstructure
      reflectwalk
    ];
    meta.useUnstable = true;
  };

  hllpp = buildFromGitHub {
    version = 2;
    owner = "retailnext";
    repo = "hllpp";
    date = "2017-03-17";
    rev = "9fdfea05b3e55bebe7beb22d16c7db15d46cd518";
    sha256 = "0b36yn9si929b2z8p13rz8qf74fmkrkmj4igp6slzc8hniv1606r";
  };

  holster = buildFromGitHub {
    version = 3;
    rev = "v1.0.1";
    owner = "mailgun";
    repo = "holster";
    sha256 = "0l1li5wkfn9xblp7pm9vrfyakn633cp2v7kn66cyq9l3xy5j024n";
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      errors
      logrus
      structs
    ];
  };

  hotp = buildFromGitHub {
    version = 2;
    rev = "c180d57d286b385101c999a60087a40d7f48fc77";
    owner  = "gokyle";
    repo   = "hotp";
    sha256 = "1sv6fq7nw7crnqn7ycg3f5j3x4g0rahxynjprwh8md3cfj1161xr";
    date = "2016-02-17";
    propagatedBuildInputs = [
      rsc
    ];
  };

  hrff = buildFromGitHub {
    version = 2;
    rev = "0b0f30b52b94f5ed2e21ffd14f537f1094ba8ec6";
    owner  = "tildeleb";
    repo   = "hrff";
    sha256 = "009zlvj9qaxxz1zprhgn5w80qyc5mqr2rifm2q6q6a2j3cvm3ccg";
    goPackagePath = "leb.io/hrff";
    date = "2015-09-06";
  };

  http2curl = buildFromGitHub {
    version = 2;
    owner = "moul";
    repo = "http2curl";
    date = "2016-10-31";
    rev = "4e24498b31dba4683efb9d35c1c8a91e2eda28c8";
    sha256 = "1zzdplidhh77s20l6c51fqvrzppmkf830j7mxdv9lf7z5ry169sp";
  };

  httprouter = buildFromGitHub {
    version = 3;
    rev = "975b5c4c7c21c0e3d2764200bf2aa8e34657ae6e";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "1s5skk9a75dllib0hd6bcflrqq992by8ais265gzwv57bixljilc";
    date = "2017-04-30";
  };

  hugo = buildFromGitHub {
    version = 3;
    owner = "gohugoio";
    repo = "hugo";
    rev = "v0.26";
    sha256 = "1ci6jg15s5whw77z64rqjmn82psk3n4fg15b19gf4l13lxraf5k0";
    buildInputs = [
      ace
      afero
      amber
      blackfriday
      cast
      cobra
      cssmin
      emoji
      fsnotify
      fsync
      gitmap
      go-i18n
      go-immutable-radix
      go-toml
      goorgeous
      image
      inflect
      jwalterweatherman
      mapstructure
      mmark
      nitro
      osext
      pflag
      purell
      text
      toml
      viper
      websocket
      yaml_v2
    ];
  };

  image-spec = buildFromGitHub {
    version = 3;
    rev = "v1.0.0";
    owner  = "opencontainers";
    repo   = "image-spec";
    sha256 = "00cf71wsk01j123nw8d7c7zp51ynkyd644rb92ilxfkj26yvvx41";
    propagatedBuildInputs = [
      errors
      go4
      go-digest
      gojsonschema
    ];
  };

  inf_v0 = buildFromGitHub {
    version = 1;
    rev = "v0.9.0";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "0wqf867vifpfa81a1vhazjgfjjhiykqpnkblaxxj6ppyxlzrs3cp";
    goPackagePath = "gopkg.in/inf.v0";
  };

  inflect = buildFromGitHub {
    version = 1;
    owner = "bep";
    repo = "inflect";
    rev = "b896c45f5af983b1f416bdf3bb89c4f1f0926f69";
    date = "2016-04-08";
    sha256 = "13mjcnh6g7ml0gw24rbkfdjmkznjk4hcwfbxcbj5ydyfl0acq8wn";
  };

  influxdb = buildFromGitHub {
    version = 3;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.3.3";
    sha256 = "1wmdbf6a3pja4bcsi1npwvrizvpx4qdgf0g6r5q0rpr4jlz5qj4f";
    propagatedBuildInputs = [
      bolt
      crypto
      encoding
      go-bits
      go-bitstream
      go-collectd
      hllpp
      jwt-go
      liner
      murmur3
      pat
      gogo_protobuf
      ratecounter
      snappy
      statik
      sys
      toml
      usage-client
      xxhash
      zap
    ];
    goPackageAliases = [
      "github.com/influxdb/influxdb"
    ];
    postPatch = /* Remove broken tests */ ''
      rm -rf services/collectd/test_client
    '';
  };

  influxdb_client = buildFromGitHub {
    inherit (influxdb) owner repo rev sha256 version;
    goPackageAliases = [
      "github.com/influxdb/influxdb"
    ];
    subPackages = [
      "client"
      "models"
      "pkg/escape"
    ];
  };

  ini = buildFromGitHub {
    version = 3;
    rev = "v1.28.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "049qg8p7nclq32j3rhy0nlxlx3lsylh344xrfyngv8bqw4alvkwy";
  };

  ini_v1 = buildFromGitHub {
    version = 3;
    rev = "v1.28.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "14yschpv3dx2anxwcsv2v2a01nixxgvpqdfi5gw0fkxyvrz4jq23";
  };

  inject = buildFromGitHub {
    version = 1;
    date = "2016-06-28";
    rev = "d8a0b8677191f4380287cfebd08e462217bac7ad";
    owner = "go-macaron";
    repo = "inject";
    sha256 = "1zb5sw83grna85cgsz7nhwpbkkysnyfc6hzk7gksidf08s8s9dmg";
  };

  internal = buildFromGitHub {
    version = 1;
    rev = "fbe290d56cdd8bb25347df893b14e3454f07bf74";
    owner  = "cznic";
    repo   = "internal";
    sha256 = "0x80s83nq75xajyqspzcgj2mq5gxw9psxghvb676q8y96jn1n10k";
    date = "2016-07-19";
    buildInputs = [
      fileutil
      mathutil
      mmap-go
    ];
  };

  ipfs = buildFromGitHub {
    version = 3;
    rev = "v0.4.10";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "0hnvr08jwdy7b8d6qz943gmgwwfqyryp75ah2sfwiqc3kda3rr96";
    gxSha256 = "18fbx17c8p0z8lqxaj8bnsv86n0wawxpvd9zp5pa3nz6w7mwd3g0";
    nativeBuildInputs = [
      gx-go.bin
    ];
    allowVendoredSources = true;
    excludedPackages = "test";
    postInstall = ''
      find "$bin"/bin -not -name ipfs\* -mindepth 1 -maxdepth 1 -delete
    '';
  };

  iter = buildFromGitHub {
    version = 1;
    rev = "454541ec3da2a73fc34fd049b19ee5777bf19345";
    owner  = "bradfitz";
    repo   = "iter";
    sha256 = "0sv6rwr05v219j5vbwamfvpp1dcavci0nwr3a2fgxx98pjw7hgry";
    date = "2014-01-23";
  };

  jose = buildFromGitHub {
    version = 2;
    owner = "SermoDigital";
    repo = "jose";
    rev = "2bd9b81ac51d6d6134fcd4fd846bd2e7347a15f9";
    date = "2016-12-05";
    sha256 = "1v5df8nkn34m7md3y8qbm71q7224r1la9r6rp06ah9zsakc8pqkb";
  };

  json-filter = buildFromGitHub {
    version = 1;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0y1d6yi09ac0xlf63qrzxsi7dqf10wha3na633qzqjnpjcga97ck";
  };

  jsonpointer = buildFromGitHub {
    version = 2;
    owner = "go-openapi";
    repo = "jsonpointer";
    rev = "779f45308c19820f1a69e9a4cd965f496e0da10f";
    date = "2017-01-02";
    sha256 = "1kdgq87bns9xzvyyybcdk3hj09l8ic8s758dxldj91jjlbd2cc2x";
    propagatedBuildInputs = [
      swag
    ];
  };

  jsonreference = buildFromGitHub {
    version = 2;
    owner = "go-openapi";
    repo = "jsonreference";
    rev = "36d33bfe519efae5632669801b180bf1a245da3b";
    date = "2016-11-05";
    sha256 = "0xqaz9kwlwj205ma9z7dm3j5ad2cl2cs0mvs3xqw3mvd6p0dmg7h";
    propagatedBuildInputs = [
      jsonpointer
      purell
    ];
  };

  jsonx = buildFromGitHub {
    version = 2;
    owner = "jefferai";
    repo = "jsonx";
    rev = "9cc31c3135eef39b8e72585f37efa92b6ca314d0";
    date = "2016-07-21";
    sha256 = "0s5zani868a70hpacqxl1qzzwc8hdappb99qixmbfkf7wdyyzfic";
    propagatedBuildInputs = [
      gabs
    ];
  };

  jwalterweatherman = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "0efa5202c04663c757d84f90f5219c1250baf94f";
    date = "2017-05-23";
    sha256 = "09m0y94jvwv45j5iajs10c6z85kr366zcgn10rnyb4dgn3ahyx51";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
  };

  jwt-go = buildFromGitHub {
    version = 3;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "a539ee1a749a2b895533f979515ac7e6e0f5b650";
    sha256 = "0prwllkpvfiizxlhay0ff2q5hchmd6vhl90fcycvk77xjf6jvbdm";
    date = "2017-06-08";
  };

  kcp-go = buildFromGitHub {
    version = 3;
    owner = "xtaci";
    repo = "kcp-go";
    rev = "v3.18";
    sha256 = "0jhbip3f90yfswy2mf10v0szyic5qhvk1nid2whbwl1dgc4b8jzl";
    propagatedBuildInputs = [
      crypto
      errors
      net
      reedsolomon
    ];
  };

  gravitational_kingpin = buildFromGitHub {
    version = 2;
    rev = "785686550a08e8e2e77641c91714280a6dfb08ee";
    owner = "gravitational";
    repo = "kingpin";
    sha256 = "0klg0nixdy13r50xkfh7mlhdyfk0x7ymmb1m4l29zj00zmhy07if";
    propagatedBuildInputs = [
      template
      units
    ];
    meta.useUnstable = true;
    date = "2016-02-05";
  };

  kingpin_v2 = buildFromGitHub {
    version = 3;
    rev = "v2.2.5";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "0sysp3c9i1vim5w9hbjaklnwskyyddxdfmlx0qcxw4csb5iacppv";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  kubernetes-client-go_1-4 = buildFromGitHub {
    version = 3;
    rev = "e5fcd1eb6215fb420fbfc95d7e2b3b672ab5d8e8";
    date = "2017-02-11";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "e70098488f56e95ec82b92c3f6daf5a4e92e9c0fd73f56e2af5c5a50504c60e1";
    goPackageAliases = [
      "k8s.io/client-go"
    ];
    subPackages = [
      "1.4/pkg/util/yaml"
    ];
    buildInputs = [
      glog
      yaml
    ];
    meta.autoUpdate = false;
  };

  kubernetes-client-go_1-5 = buildFromGitHub {
    version = 2;
    rev = "7c07d5a2af693f43ed616271f4b04fae0e0212cc";
    date = "2017-02-11";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "346af30cb4cac1f27db13a3561a7431c19508a47c1622810088e3f0f41c890d1";
    goPackagePath = "k8s.io/client-go";
    excludedPackages = "examples";
    propagatedBuildInputs = [
      distribution_for_engine-api
      glog
      ugorji_go
      gofuzz
      gopass
      go-oidc
      go-restful-swagger12
      go-spew
      groupcache
      inf_v0
      mergo
      net
      oauth2
      pflag
      gogo_protobuf
      ratelimit
      semver
      spec
      yaml
      pborman_uuid
    ];
    meta.autoUpdate = false;
  };


  ldap = buildFromGitHub {
    version = 3;
    rev = "37f35d7ffc6b8219cc62f5e182e258d143be670b";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "1xkxm08g7r3x66i9k1dspsj21ka91xys6ydrsfhb1m4qkvsq04vh";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [
      asn1-ber
    ];
    date = "2017-06-27";
  };

  ledisdb = buildFromGitHub {
    version = 3;
    rev = "f49ad4d5ed26d265a64954ed0195d5ac1eabb42e";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "0xl3b1qmdms45zzr5lrzq5x3wfzrhffywbbv6j6syrgvxf6g570h";
    date = "2017-07-31";
    prePatch = ''
      dirs=($(find . -type d -name vendor | sort))
      echo "''${dirs[@]}" | xargs -n 1 rm -r
    '';
    propagatedBuildInputs = [
      siddontang_go
      ugorji_go
      goleveldb
      goredis
      liner
      mmap-go
      siddontang_rdb
      toml
    ];
  };

  lego = buildFromGitHub {
    version = 3;
    rev = "v0.4.0";
    owner = "xenolf";
    repo = "lego";
    sha256 = "0nbag8cd6lw5cwn7zgvld9n224i0v6yyc4a363i9gfdxpk4j5v5z";
    buildInputs = [
      auroradnsclient
      aws-sdk-go
      azure-sdk-for-go
      urfave_cli
      crypto
      dns
      dnspod-go
      dnsimple-go
      egoscale
      go-autorest
      go-jose_v1
      go-ovh
      google-api-go-client
      linode
      memcache
      ns1-go_v2
      oauth2
      net
      vultr
    ];
  };

  lemma = buildFromGitHub {
    version = 3;
    rev = "4214099fb348c416514bc2c93087fde56216d7b5";
    owner = "mailgun";
    repo = "lemma";
    sha256 = "1xm2bz2z3v4fwv53qzb6ayxqmjjhalp0kq1gr49sq2xmslhcl83q";
    date = "2017-06-19";
    propagatedBuildInputs = [
      crypto
      metrics
      timetools
      mailgun_ttlmap
    ];
  };

  libkv = buildFromGitHub {
    version = 3;
    rev = "93ab0e6c056d325dfbb11e1d58a3b4f5f62e7f3c";
    owner = "docker";
    repo = "libkv";
    sha256 = "14qw4rmhw5biq5mpiqyrlvzp0vhy2ilgxvgbxflp6114l5w0vkki";
    date = "2017-07-01";
    excludedPackages = "\\(mock\\|testutils\\)";
    propagatedBuildInputs = [
      bolt
      consul_api
      etcd_client
      go-zookeeper
      net
    ];
  };

  libnetwork = buildFromGitHub {
    version = 3;
    rev = "2719c60fbd40d894a9cdabf95d2facbd14d2ba75";
    owner = "docker";
    repo = "libnetwork";
    sha256 = "08wa3gsvsp06hkg76k39kijr2p1ly2ciny4mw7x13a59yrv4ylpf";
    date = "2017-08-11";
    subPackages = [
      "datastore"
      "discoverapi"
      "types"
    ];
    propagatedBuildInputs = [
      libkv
    ];
  };

  libseccomp-golang = buildFromGitHub {
    version = 2;
    rev = "v0.9.0";
    owner = "seccomp";
    repo = "libseccomp-golang";
    sha256 = "0kvrysdhq8yqcv4cvf1bmc38f6fwj2cwvw2zd004gka0qdmwhxx3";
    buildInputs = [
      pkgs.libseccomp
    ];
  };

  libtrust = buildFromGitHub {
    version = 2;
    rev = "aabc10ec26b754e797f9028f4589c5b7bd90dc20";
    owner = "docker";
    repo = "libtrust";
    sha256 = "40837c2420436be95f8098bf3a9c1b2820b72ec2b43fd0983a00c006d66ba1e8";
    date = "2016-07-08";
    postPatch = /* Demo uses same package namespace as actual library */ ''
      rm -rfv tlsdemo
    '';
  };

  liner = buildFromGitHub {
    version = 2;
    rev = "88609521dc4b6c858fd4c98b628147da928ce4ac";
    owner = "peterh";
    repo = "liner";
    sha256 = "05jzx3bfj9iqirwydn4lw75khkj3xjwnnx8a6nq6m1avwkmbzn9z";
    date = "2017-03-17";
  };

  linode = buildFromGitHub {
    version = 2;
    rev = "37e84520dcf74488f67654f9c775b9752c232dc1";
    owner = "timewasted";
    repo = "linode";
    sha256 = "13ypkib9nmm8pc2z8yqa97gh3karvrhwas0i4ck88pqhxwi85liw";
    date = "2016-08-29";
  };

  lldb = buildFromGitHub {
    version = 2;
    rev = "bea8611dd5c407f3c5eab9f9c68e887a27dc6f0e";
    owner  = "cznic";
    repo   = "lldb";
    sha256 = "1a3zd71vkvz1c319ihpmrky4zy84lazhsy3gwmnac71f6r8schii";
    buildInputs = [
      fileutil
      mathutil
      sortutil
    ];
    propagatedBuildInputs = [
      mmap-go
    ];
    extraSrcs = [
      {
        inherit (internal)
          goPackagePath
          src;
      }
      {
        inherit (zappy)
          goPackagePath
          src;
      }
    ];
    meta.useUnstable = true;
    date = "2016-11-02";
  };

  log15 = buildFromGitHub {
    version = 3;
    rev = "74a0988b5f804e8ce9ff74fca4f16980776dff29";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "091d87dz7ddx1jz5hk47465x83f2ayagylpgc8b5fwvbm1lbmlps";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
    date = "2017-06-22";
  };

  log15_v2 = buildFromGitHub {
    version = 1;
    rev = "v2.11";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "1krlgq3m0q40y8bgaf9rk7zv0xxx5z92rq8babz1f3apbdrn00nq";
    goPackagePath = "gopkg.in/inconshreveable/log15.v2";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
  };

  lunny_log = buildFromGitHub {
    version = 2;
    rev = "7887c61bf0de75586961948b286be6f7d05d9f58";
    owner = "lunny";
    repo = "log";
    sha256 = "0jsk5yc7lqlh9zicadbhxh6as3vlhln08f2wxrbnpcw0b1jncnp1";
    date = "2016-09-21";
  };

  mailgun_log = buildFromGitHub {
    version = 2;
    rev = "2f35a4607f1abf71f97f77f99b0de8493ef6f4ef";
    owner = "mailgun";
    repo = "log";
    sha256 = "1akyw7r5as06b6inn16wh9gg16zx3729nxmrgg0c46sgy23xmh9m";
    date = "2015-09-25";
  };

  loghisto = buildFromGitHub {
    version = 2;
    rev = "9d1d8c1fd2a4ac852bf2e312f2379f553345fda7";
    owner = "spacejam";
    repo = "loghisto";
    sha256 = "0dpfgzlf4n0vvppffxk5qwdb72iq6x320srkd1rzys0fd7xyvyz1";
    date = "2016-03-02";
    propagatedBuildInputs = [
      glog
    ];
  };

  logrus = buildFromGitHub {
    version = 3;
    rev = "v1.0.1";
    owner = "sirupsen";
    repo = "logrus";
    sha256 = "06402d7jaa7fi89gw8vvwxc5fpr2ywm1pscbqv3wz499pjm9x13k";
    goPackageAliases = [
      "github.com/Sirupsen/logrus"
    ];
    buildInputs = [
      sys
    ];
  };

  logutils = buildFromGitHub {
    version = 1;
    date = "2015-06-09";
    rev = "0dc08b1671f34c4250ce212759ebd880f743d883";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "11p4p01x37xcqzfncd0w151nb5izmf3sy77vdwy0dpwa9j8ccgmw";
  };

  logxi = buildFromGitHub {
    version = 2;
    date = "2016-10-27";
    rev = "aebf8a7d67ab4625e0fd4a665766fef9a709161b";
    owner  = "mgutz";
    repo   = "logxi";
    sha256 = "10rvbxihgkwbdbb6pc7pn4jhgjxmq7gvxc8r5hckfi7qmc3z0ahk";
    excludedPackages = "Gododir";
    propagatedBuildInputs = [
      ansi
      go-colorable
      go-isatty
    ];
  };

  luhn = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "luhn";
    sha256 = "13brkbbmj9bh0b9j3avcyrj542d78l9hg3bxj7jjvkp5n5cxwp41";
  };

  lxd = buildFromGitHub {
    version = 3;
    rev = "lxd-2.16";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "1np9qasg4asx1lgk2015zljcnmzncqa63labnm3519r3s842p69q";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-colorable
      go-lxc_v2
      go-sqlite3
      log15_v2
      pkgs.lxc
      mux
      pborman_uuid
      pongo2-v3
      protobuf
      tablewriter
      tomb_v2
      yaml_v2
      websocket
    ];
  };

  lz4 = buildFromGitHub {
    version = 3;
    rev = "v1.0";
    owner  = "pierrec";
    repo   = "lz4";
    sha256 = "1g8jpvfgbsdz24ypsj587fp3sl6vrjbg7zczyy5k5vvryha9yr9k";
    propagatedBuildInputs = [
      pierrec_xxhash
    ];
  };

  macaron_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.2.1";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "182xihcysz553g48xl0skcvbimpqngch4ii371fy29mipanis8rj";
    goPackagePath = "gopkg.in/macaron.v1";
    goPackageAliases = [
      "github.com/go-macaron/macaron"
    ];
    propagatedBuildInputs = [
      com
      ini_v1
      inject
    ];
  };

  mafmt = buildFromGitHub {
    version = 3;
    date = "2017-07-11";
    rev = "8eaabeb0013fb995358b239e04394c27acaf38a2";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "1k0r3zdv730r33p0gj2yjvmqscn44gzgla6ivqdc0dvk8wpl6z5g";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  mapstructure = buildFromGitHub {
    version = 3;
    date = "2017-05-23";
    rev = "d0303fe809921458f417bcf828397a65db30a7e4";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "1v3a2jnaing62322aqjdqrdqb1cqqklmjskxaqqrfcczxx8ibqnv";
  };

  match = buildFromGitHub {
    version = 2;
    owner = "tidwall";
    repo = "match";
    date = "2016-08-30";
    rev = "173748da739a410c5b0b813b956f89ff94730b4c";
    sha256 = "362da507bd9755044b3a1f9c0f048ec8758012ca55593b9a1dd63edd76e4e5f9";
  };

  mathutil = buildFromGitHub {
    version = 3;
    date = "2017-06-21";
    rev = "6baf61e0317058e3207936f50e310bd500fbbdb0";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "01w47c14kbhncmvgz5k7xwp1c8h7hfxv9jbdds9abakbb89zvi72";
    excludedPackages = "example";
    buildInputs = [
      bigfft
    ];
  };

  maxminddb-golang = buildFromGitHub {
    version = 3;
    rev = "v1.2.0";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "14qm66rnfkf5d4hajh2cglal3v09x4mmjxjsx5n9d44n4qwq5277";
    propagatedBuildInputs = [
      sys
    ];
  };

  mc = buildFromGitHub {
    version = 3;
    owner = "minio";
    repo = "mc";
    rev = "60681d7fb622c1dc68e1b6e0193e222532d5e5d8";
    sha256 = "0sqgv7rd7ipmnhvszxwfv65775sh0jrxy4aah89pfha8xplgq7d5";
    propagatedBuildInputs = [
      cli_minio
      color
      go-colorable
      go-homedir_minio
      go-humanize
      go-isatty
      go-version
      minio_pkg
      minio-go
      notify
      pb
      profile
      structs
      text
    ];
    date = "2017-08-06";
    postPatch = ''
      # Hack to workaround no longer provided `pkg/probe`
      mv vendor/github.com/minio/minio/pkg/probe pkg/probe
      find cmd -type f | xargs sed -i 's,github.com/minio/minio/pkg/probe,github.com/minio/mc/pkg/probe,g'
    '';
  };

  mc_pkg = buildFromGitHub {
    inherit (mc) version owner repo rev sha256 date;
    subPackages = [
      "pkg/console"
    ];
    propagatedBuildInputs = [
      color
      go-colorable
      go-isatty
    ];
  };

  mdns = buildFromGitHub {
    version = 2;
    date = "2017-02-21";
    rev = "4e527d9d808175f132f949523e640c699e4253bb";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "0d7hknw06jsk3w7cvy5hrwg3y4dhzc5d2176vr0g624ww5jdzh64";
    propagatedBuildInputs = [
      dns
      net
    ];
  };

  memberlist = buildFromGitHub {
    version = 3;
    rev = "ea4ef7f066304a8e6f28bdb958888fe899f3b44e";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "0w34qqcjbjr276lw0h8rsri7lck9bib1dd6n900h0q5cnyv69mmp";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
      go-sockaddr
      seed
    ];
    meta.useUnstable = true;
    date = "2017-08-07";
  };

  memcache = buildFromGitHub {
    version = 2;
    date = "2015-06-22";
    rev = "1031fa0ce2f20c1c0e1e1b51951d8ea02c84fa05";
    owner = "rainycape";
    repo = "memcache";
    sha256 = "0585b0rblaxn4b2p5q80x3ynlcbhvf43p18yxxhlnm0yf0w3hjl9";
  };

  mergo = buildFromGitHub {
    version = 3;
    date = "2017-06-20";
    rev = "e3000cb3d28c72b837601cac94debd91032d19fe";
    owner = "imdario";
    repo = "mergo";
    sha256 = "0lbqfblhj6ys2m3lz5a1i4vmn8dhpbwpzch03lgqm1y2d8zmmfkn";
  };

  metrics = buildFromGitHub {
    version = 3;
    date = "2017-07-14";
    rev = "fd99b46995bd989df0d163e320e18ea7285f211f";
    owner = "mailgun";
    repo = "metrics";
    sha256 = "00c7x0sq3zx9cx8cd93mjz241mqpn4fsnakcsv6q9rwzm7ig9002";
    propagatedBuildInputs = [
      holster
      timetools
    ];
  };

  mgo_v2 = buildFromGitHub {
    version = 1;
    rev = "r2016.08.01";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "0hq8wfypghfcz83035wdb844b39pd1qly43zrv95i99p35fwmx22";
    goPackagePath = "gopkg.in/mgo.v2";
    goPackageAliases = [
      "github.com/10gen/llmgo"
    ];
    excludedPackages = "dbtest";
    buildInputs = [
      pkgs.cyrus-sasl
    ];
  };

  minheap = buildFromGitHub {
    version = 3;
    rev = "3dbe6c6bf55f94c5efcf460dc7f86830c21a90b2";
    owner = "mailgun";
    repo = "minheap";
    sha256 = "1d0j7vzvqizq56dxb8kcp0krlnm18qsykkd064hkiafwapc3lbyd";
    date = "2017-06-19";
  };

  minio = buildFromGitHub {
    version = 3;
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.2017-08-05T00-00-53Z";
    sha256 = "0bam26w63x7znmidh9y47apknfd82ish1ijb014656q67c9marsh";
    buildInputs = [
      amqp
      atomic
      azure-sdk-for-go
      cli_minio
      color
      cors
      crypto
      dsync
      elastic_v5
      gjson
      go-bindata-assetfs
      go-homedir_minio
      go-humanize
      go-nats
      go-nats-streaming
      go-version
      handlers
      jwt-go
      logrus
      mc_pkg
      minio-go
      mux
      mysql
      pb
      pq
      profile
      redigo
      reedsolomon
      rpc
      sarama_v1
      sha256-simd
      skyring-common
      structs
      yaml_v2
    ];
  };

  # The pkg package from minio, for bootstrapping minio
  minio_pkg = buildFromGitHub {
    inherit (minio) version owner repo rev sha256;
    propagatedBuildInputs = [
      minio-go
      pb
      structs
      yaml_v2
    ];
    subPackages = [
      "pkg/madmin"
      "pkg/quick"
      "pkg/safe"
      "pkg/trie"
      "pkg/words"
      "pkg/x/os"
    ];
  };

  minio-go = buildFromGitHub {
    version = 3;
    owner = "minio";
    repo = "minio-go";
    rev = "v2.1.0";
    sha256 = "bc7a0e5dd0a4a0668ee313fd02cdbe6ddd6924395836abb8c5b914d27a96bc66";
    propagatedBuildInputs = [
      go-homedir_minio
      ini
    ];
    meta.autoUpdate = false;
  };

  missinggo = buildFromGitHub {
    version = 1;
    rev = "f3a48f14358dc22876048390ba49b963a476a5db";
    owner  = "anacrolix";
    repo   = "missinggo";
    sha256 = "d5c34a92445e5ec95d897f68f9f1cce2a02fdc0d6adc372a98a8bbce6a441c84";
    date = "2016-06-18";
    propagatedBuildInputs = [
      b
      btree
      docopt-go
      envpprof
      go-humanize
      goskiplist
      iter
      net
      roaring
      tagflag
    ];
    meta.autoUpdate = false;
  };

  missinggo_lib = buildFromGitHub {
    inherit (missinggo) rev owner repo sha256 version date;
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      iter
    ];
    meta.autoUpdate = false;
  };

  mmap-go = buildFromGitHub {
    version = 2;
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "0bce6a6887123b67a60366d2c9fe2dfb74289d2e";
    sha256 = "0svsbzhh9wb800x1gwgnmbi62jvmq269cak78dajpnpjyw2m9a73";
    date = "2017-03-20";
  };

  mmark = buildFromGitHub {
    version = 3;
    owner = "miekg";
    repo = "mmark";
    rev = "v1.3.6";
    sha256 = "1ji3c0klclp13810ymjihhnlsjxpv8bif1xx4brjs4ip9l7lbdpj";
    propagatedBuildInputs = [
      toml
    ];
  };

  moby = buildFromGitHub {
    version = 3;
    owner = "moby";
    repo = "moby";
    rev = "f34e4d295d5c17a78c33beb14b65e5d001c16968";
    date = "2017-08-11";
    sha256 = "08jgs4nbi6v5clzdvclayfvpwa1yjjn24fwnnx8a1a6p27daqsyy";
    goPackageAliases = [
      "github.com/docker/docker"
    ];
    postPatch = ''
      find . -name \*.go -exec sed -i 's,github.com/docker/docker,github.com/moby/moby,g' {} \;
    '';
    meta.useUnstable = true;
  };

  moby_for_runc = moby.override {
    subPackages = [
      "pkg/longpath"
      "pkg/mount"
      "pkg/symlink"
      "pkg/system"
      "pkg/term"
      "pkg/term/windows"
    ];
    propagatedBuildInputs = [
      errors
      go-ansiterm
      go-units
      go-winio
      logrus
      sys
    ];
    rev = "f34e4d295d5c17a78c33beb14b65e5d001c16968";
    sha256 = "08jgs4nbi6v5clzdvclayfvpwa1yjjn24fwnnx8a1a6p27daqsyy";
    version = 3;
  };

  moby_lib = moby.override {
    subPackages = [
      "api/types"
      "api/types/blkiodev"
      "api/types/container"
      "api/types/filters"
      "api/types/mount"
      "api/types/network"
      "api/types/registry"
      "api/types/strslice"
      "api/types/swarm"
      "api/types/swarm/runtime"
      "api/types/versions"
      "daemon/cluster/convert"
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/idtools"
      "pkg/ioutils"
      "pkg/jsonlog"
      "pkg/jsonmessage"
      "pkg/longpath"
      "pkg/mount"
      "pkg/namesgenerator"
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
      "pkg/stringid"
      "pkg/system"
      "pkg/tarsum"
      "pkg/term"
      "pkg/term/windows"
      "registry"
      "registry/resumable"
    ];
    propagatedBuildInputs = [
      distribution_for_moby
      errors
      go-ansiterm
      go-connections
      go-units
      go-winio
      gogo_protobuf
      gotty
      image-spec
      libnetwork
      logrus
      net
      pflag
      runc
      swarmkit
      sys
    ];
    rev = "f34e4d295d5c17a78c33beb14b65e5d001c16968";
    sha256 = "08jgs4nbi6v5clzdvclayfvpwa1yjjn24fwnnx8a1a6p27daqsyy";
    version = 3;
  };

  mock = buildFromGitHub {
    version = 3;
    owner = "golang";
    repo = "mock";
    rev = "v1.0.0";
    sha256 = "00c9g4cqwm3j19mfzdrxdsdpn1bcnb11g7i72ajf68a78z71pvjn";
  };

  mongo-tools = buildFromGitHub {
    version = 3;
    rev = "4da3a69c46185fb20be26e40064c5d0a5647fde6";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "0ag8v0qn2gqxwmbh69i3805kl3b3gkq64bl3rakyjkx468d8jvzf";
    buildInputs = [
      crypto
      escaper
      go-cache
      go-flags
      gopacket
      gopass
      mgo_v2
      openssl
      termbox-go
      tomb_v2
    ];

    # Mongodb incorrectly names all of their binaries main
    # Let's work around this with our own installer
    preInstall = ''
      mkdir -p $bin/bin
      while read b; do
        rm -f go/bin/main
        go install $goPackagePath/$b/main
        cp go/bin/main $bin/bin/$b
      done < <(find go/src/$goPackagePath -name main | xargs dirname | xargs basename -a)
      rm -r go/bin
    '';
    date = "2017-07-31";
  };

  mousetrap = buildFromGitHub {
    version = 3;
    rev = "v1.0";
    owner = "inconshreveable";
    repo = "mousetrap";
    sha256 = "0a5rc2jmgcdbp28qp5di2znps95gwz2fmv1j0b4xi5k6jrbsyib8";
  };

  mow-cli = buildFromGitHub {
    version = 3;
    rev = "82aefbee1e23d398752fbe663f964a6d87016434";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "19xfnl5shxzz46m8vsl6p97wq0p1cg1rxj8siyx2h6qgcwy2x3bc";
    date = "2017-08-02";
  };

  ns1-go_v2 = buildFromGitHub {
    version = 3;
    rev = "c563826f4cbef9c11bebeb9f20a3f7afe9c1e2f4";
    owner  = "ns1";
    repo   = "ns1-go";
    sha256 = "0i1xmx6aw69749m5dy1i97xhhga7zp3sfk4wiflkmdkah2670in2";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2017-05-02";
  };

  msgp = buildFromGitHub {
    version = 3;
    rev = "v1.0.2";
    owner  = "tinylib";
    repo   = "msgp";
    sha256 = "1pd18yp2ja8r137x5g8qrf7i9a7zzvb1lp0g43kzcl03r0v06zgh";
    propagatedBuildInputs = [
      fwd
      chalk
      tools
    ];
  };

  multibuf = buildFromGitHub {
    version = 2;
    rev = "565402cd71fbd9c12aa7e295324ea357e970a61e";
    owner  = "mailgun";
    repo   = "multibuf";
    sha256 = "1csjfl3bcbya7dq3xm1nqb5rwrpw5migrqa4ajki242fa5i66mdr";
    date = "2015-07-14";
  };

  multierr = buildFromGitHub {
    version = 3;
    rev = "v1.1.0";
    owner  = "uber-go";
    repo   = "multierr";
    sha256 = "0yd7ydwhdfaxn6gyq6z9qb4s1y0ijsa9qya3g4zcg9az4vya19bg";
    goPackagePath = "go.uber.org/multierr";
    propagatedBuildInputs = [
      atomic
    ];
  };

  murmur3 = buildFromGitHub {
    version = 3;
    rev = "4ec5a0f56d4fc178129a8433576bf6f2fe672a9e";
    owner  = "spaolacci";
    repo   = "murmur3";
    sha256 = "16vdjz39k0npnvj6dfqzh98x7zv7g2ggcpvm4m28ql4nmgcj29m4";
    date = "2017-08-06";
  };

  mux = buildFromGitHub {
    version = 3;
    rev = "v1.4.0";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1wdmv6iga3hjqbqd2c1w1lf6kxdqf7qawpl7059rz86z96iiyy98";
    propagatedBuildInputs = [
      context
    ];
  };

  mysql = buildFromGitHub {
    version = 3;
    rev = "3955978caca48c1658a4bb7a9c6a0f084e326af3";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "1xygjdllax7794znmpdqzhwnxl35i2qwcq42yvari3h98wzwzdkr";
    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';
    date = "2017-07-15";
  };

  net-rpc-msgpackrpc = buildFromGitHub {
    version = 1;
    date = "2015-11-15";
    rev = "a14192a58a694c123d8fe5481d4a4727d6ae82f3";
    owner = "hashicorp";
    repo = "net-rpc-msgpackrpc";
    sha256 = "007pwdpap465b32cx1i2hmf2q67vik3wk04xisq2pxvqvx81irks";
    propagatedBuildInputs = [ ugorji_go go-multierror ];
  };

  netlink = buildFromGitHub {
    version = 3;
    rev = "f5a6f697a596c788d474984a38a0ac4ba0719e93";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "02bkxx13mnp3h11mbn5gggciw57n4jp8pirljncdf793x4bg1d80";
    date = "2017-08-08";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    version = 3;
    rev = "86bef332bfc3b59b7624a600bd53009ce91a9829";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "03h7cd653rf1qi2yqf5b3cm7a2ak59clp2qpwmk747sdz0g841hk";
    date = "2017-07-07";
  };

  nitro = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "nitro";
    rev = "24d7ef30a12da0bdc5e2eb370a79c659ddccf0e8";
    date = "2013-10-03";
    sha256 = "1dbnfac79lxc1pr1j1n3956i292ck4yjrhr8nsd2wp2jccab5zdz";
  };

  nodb = buildFromGitHub {
    version = 1;
    owner = "lunny";
    repo = "nodb";
    rev = "fc1ef06ad4af0da31cdb87e3fa5ec084c67e6597";
    date = "2016-06-21";
    sha256 = "1w46s9mgqjq0faybr743fs96jp0g1pcahrfamfiwi5hz28dqfcsp";
    propagatedBuildInputs = [
      goleveldb
      lunny_log
      go-snappy
      toml
    ];
  };

  nomad = buildFromGitHub {
    version = 3;
    rev = "v0.6.0";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "0ndy22b4ynrinm6rjv43kl5qjgc028grnsja6cvadfsznw8731y3";

    nativeBuildInputs = [
      ugorji_go.bin
    ];

    buildInputs = [
      armon_go-metrics
      bolt
      circbuf
      colorstring
      columnize
      complete
      consul-template
      consul_api
      copystructure
      cronexpr
      distribution_for_engine-api
      docker_cli
      go-checkpoint
      go-cleanhttp
      go-dockerclient
      go-envparse
      go-getter
      go-humanize
      go-lxc_v2
      go-memdb
      go-multierror
      go-plugin
      go-ps
      go-rootcerts
      go-sockaddr
      go-syslog
      go-testing-interface
      go-version
      gopsutil
      gziphandler
      hashstructure
      hcl
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      moby_lib
      net-rpc-msgpackrpc
      osext
      raft-boltdb_v2
      raft_v2
      runc
      scada-client
      seed
      serf
      snappy
      srslog
      sync
      sys
      tail
      time
      tomb_v1
      tomb_v2
      ugorji_go
      vault_api
      yamux
    ];

    excludedPackages = "testutil";

    # Rename deprecated ParseNamed to ParseNormalizedNamed
    postPatch = ''
      find . -type f -exec sed -i {} \
        -e 's,.ParseNamed,.ParseNormalizedNamed,g' \
        -e 's,"github.com/docker/docker/reference","github.com/docker/distribution/reference",g' \
        -e 's,"github.com/docker/docker/cli,"github.com/docker/cli/cli,g' \
        \;
    '';

    preBuild = ''
      pushd go/src/$goPackagePath
      go list ./... | xargs go generate
      popd
    '';

    postInstall = ''
      rm "$bin"/bin/app
    '';
  };

  notify = buildFromGitHub {
    version = 3;
    owner = "rjeczalik";
    repo = "notify";
    date = "2017-06-01";
    rev = "88a54d914928e1faebb1c2195605dc87bd98dc27";
    sha256 = "0wkrqihjq2cxvl86f4hyksp0bkh7cmf1bipnm0dzv4d1yrxzm80j";
    propagatedBuildInputs = [
      sys
    ];
  };

  nuid = buildFromGitHub {
    version = 3;
    rev = "v1.0.0";
    owner = "nats-io";
    repo = "nuid";
    sha256 = "1fxdhbhww71gsfb91z5nxs6fa4kngvhvd6bvsvr5qsqdmqyxbqng";
  };

  objecthash = buildFromGitHub {
    version = 3;
    date = "2016-08-01";
    rev = "770874ca6c9e9967c6ee7adae3de0f680c922b43";
    owner  = "benlaurie";
    repo   = "objecthash";
    sha256 = "0si2wixfz6nbxrav76iii4lgjh66kfj9i1prdniin9f4r7idiak5";
    subPackages = [
      "go/objecthash"
    ];
  };

  objx = buildFromGitHub {
    version = 1;
    date = "2015-09-28";
    rev = "1a9d0bb9f541897e62256577b352fdbc1fb4fd94";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "0ycjvfbvsq6pmlbq2v7670w1k25nydnz4scx0qgiv0f4llxnr0y9";
  };

  open-golang = buildFromGitHub {
    version = 2;
    owner = "skratchdot";
    repo = "open-golang";
    rev = "75fb7ed4208cf72d323d7d02fd1a5964a7a9073c";
    date = "2016-03-02";
    sha256 = "da900f012522dd61cc0504a16bbb137e3ed2173d0715fbf709046a1e0d923ca3";
  };

  openssl = buildFromGitHub {
    version = 3;
    date = "2017-07-21";
    rev = "2692b9f6fa95e72c75f8d9ba76e49c5dfd2cf8e4";
    owner = "10gen";
    repo = "openssl";
    sha256 = "0zsp8m5gxhiilvlhpgdbyzaw7k0hdch7q5f13cdhjlkb22zk8ps0";
    goPackageAliases = [
      "github.com/spacemonkeygo/openssl"
    ];
    buildInputs = [
      pkgs.openssl
    ];
    propagatedBuildInputs = [
      spacelog
    ];

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,spacemonkeygo/openssl,10gen/openssl,g'
    '';
  };

  osext = buildFromGitHub {
    version = 3;
    date = "2017-05-10";
    rev = "ae77be60afb1dcacde03767a8c37337fad28ac14";
    owner = "kardianos";
    repo = "osext";
    sha256 = "0xbz5vjmgv6gf9f2xrhz48kcfmx5623fbcsw5x22s4hzwmvnb588";
    goPackageAliases = [
      "github.com/bugsnag/osext"
      "bitbucket.org/kardianos/osext"
    ];
  };

  otp = buildFromGitHub {
    version = 3;
    rev = "v1.0.0";
    owner = "pquerna";
    repo = "otp";
    sha256 = "0qx6g6kbm6l6snflz9c624b8wi8yghwp0r2117j73viq5q5n5zjc";
    propagatedBuildInputs = [
      barcode
    ];
  };

  oxy = buildFromGitHub {
    version = 2;
    owner = "vulcand";
    repo = "oxy";
    date = "2016-07-23";
    rev = "db85f00cac5466def1f6f2667063e6e38c1fe606";
    sha256 = "3c32677900a6399eecd80fc47798e998f47f8df502727574052d6ddc654d4a61";
    goPackageAliases = [ "github.com/mailgun/oxy" ];
    propagatedBuildInputs = [
      hdrhistogram
      mailgun_log
      multibuf
      predicate
      timetools
      mailgun_ttlmap
    ];
    meta.autoUpdate = false;
  };

  pat = buildFromGitHub {
    version = 2;
    owner = "bmizerany";
    repo = "pat";
    date = "2016-02-17";
    rev = "c068ca2f0aacee5ac3681d68e4d0a003b7d1fd2c";
    sha256 = "aad2d84661ea918168e60ed7bab467d4e0fce28fe9372e786c2714c10f6490a7";
  };

  pb = buildFromGitHub {
    version = 3;
    owner = "cheggaaa";
    repo = "pb";
    date = "2017-08-02";
    rev = "0af82b7d15eb9371fbdf8f468ff10cbba62e0414";
    sha256 = "13js67mvib5mkv59k0m62d8c332yc5jykxyinlkakvqzqmd1ib8m";
    propagatedBuildInputs = [
      go-runewidth
    ];
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 3;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.16";
    sha256 = "1qk6wwl0v00q21r0brzdsgxnq37h1xhbchhmgbawq9advfd7k747";
    goPackagePath = "gopkg.in/cheggaaa/pb.v1";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  beorn7_perks = buildFromGitHub {
    version = 1;
    date = "2016-08-04";
    owner  = "beorn7";
    repo   = "perks";
    rev = "4c0e84591b9aa9e6dcfdf3e020114cd81f89d5f9";
    sha256 = "19dw6jcvcbnk0nq4wy9dhrb1d3k85xwnfvwn1ld03f2mzmshf9fr";
  };

  pester = buildFromGitHub {
    version = 3;
    owner = "sethgrid";
    repo = "pester";
    rev = "99271bb5a99e5769f688c483eabb3c22d71ebf93";
    date = "2017-06-20";
    sha256 = "1lp61pi2h504m0qjdggf89ixbkz9swhh3b4kiq3zrs79lk12rmmg";
  };

  pfilter = buildFromGitHub {
    version = 3;
    owner = "AudriusButkevicius";
    repo = "pfilter";
    rev = "0.0.1";
    sha256 = "09rcdzpxka30833hfkw2d8icx8gikd3mh7jb6qszvlrkp5z5wjqx";
  };

  pflag = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "pflag";
    rev = "v1.0.0";
    sha256 = "1c6ia0zdf1cxqw256fa5w9qh6i94897l9aq1jkw73gn7vlf86b2r";
  };

  pkcs7 = buildFromGitHub {
    version = 3;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "a009d8d7de53d9503c797cb8ec66fa3b21eed209";
    date = "2017-06-13";
    sha256 = "13xipw188r9lh6hxcd5mlsv941y21a76cv50dagy12mlmrs9m293";
  };

  pkcs11 = buildFromGitHub {
    version = 3;
    owner = "miekg";
    repo = "pkcs11";
    rev = "7283ca79f35edb89bc1b4ecae7f86a3680ce737f";
    sha256 = "1zl6dv4imi1amc3jvfav6i5v9jjqwfs3ahacbfp3k4gkf5gw79jq";
    date = "2017-02-20";
    propagatedBuildInputs = [
      pkgs.libtool
    ];
  };

  pkcs11key = buildFromGitHub {
    version = 3;
    owner = "letsencrypt";
    repo = "pkcs11key";
    rev = "v2.0.0";
    sha256 = "06307qc44967zf7i9r92vhhrm9ziz68nfhdsxy3ynh6940dhxcd4";
    propagatedBuildInputs = [
      cfssl_errors
      pkcs11
    ];
  };

  pkg = buildFromGitHub {
    version = 2;
    date = "2017-04-20";
    owner  = "coreos";
    repo   = "pkg";
    rev = "8dbaa491b063ed47e2474b5363de0c0db91cf9f2";
    sha256 = "0qmwkgad8wakz2iva7qhd9wsp5z81dw1x5bgi3mlwkyfqa0fc3cw";
    buildInputs = [
      crypto
      yaml_v1
    ];
    propagatedBuildInputs = [
      go-systemd_journal
    ];
  };

  pongo2-v3 = buildFromGitHub {
    version = 1;
    rev = "v3.0";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "1qjcj7hcjskjqp03fw4lvn1cwy78dck4jcd0rcrgdchis1b84isk";
    goPackagePath = "gopkg.in/flosch/pongo2.v3";
  };

  pprof = buildFromGitHub {
    version = 3;
    rev = "d127b8fbfcfe0a05e08ef39c6563afb1a002fe47";
    owner  = "google";
    repo   = "pprof";
    sha256 = "0vqcfzyjlv4apwl4hvd68z50sp04plprv406d7g1kxcm09mwc7pj";
    date = "2017-08-08";
    propagatedBuildInputs = [
      demangle
    ];
  };

  pq = buildFromGitHub {
    version = 3;
    rev = "e42267488fe361b9dc034be7a6bffef5b195bceb";
    owner  = "lib";
    repo   = "pq";
    sha256 = "1bhx37vxg2a7iax98mklhdidppn3c7q8x3rpww3maprrn42ff0sb";
    date = "2017-08-10";
  };

  probing = buildFromGitHub {
    version = 3;
    rev = "0.0.1";
    owner  = "xiang90";
    repo   = "probing";
    sha256 = "0wjjml1dg64lfq4s1b6kqabz35pm02yfgc0nc8cp8y4aw2ip49vr";
  };

  predicate = buildFromGitHub {
    version = 2;
    rev = "19b9dde14240d94c804ae5736ad0e1de10bf8fe6";
    owner  = "vulcand";
    repo   = "predicate";
    sha256 = "0i2smqnr8vldz7iiid835kgkvs55hb5vjdjj9h87xlwy7f8y9map";
    date = "2016-06-21";
  };

  profile = buildFromGitHub {
    version = 3;
    owner = "pkg";
    repo = "profile";
    rev = "v1.2.1";
    sha256 = "0j8xam3hkcl265fdqlkmlxf9ri8ynx5iq5dkghbsal85h8jm7mf8";
  };

  progmeter = buildFromGitHub {
    version = 3;
    owner = "whyrusleeping";
    repo = "progmeter";
    rev = "974d8fe8cd87585865b1370184050e89d606e817";
    sha256 = "1nskyr5mrzh7jbagh4qakwh34xc6z1l0md9nmhdjassp4di9s39j";
    date = "2017-06-20";
  };

  prometheus = buildFromGitHub {
    version = 3;
    rev = "v1.7.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "0ciifdfvqymr6db7p4f76k9fa1vj3wlnnl2rn1i4bn6g9l8yi97s";
    buildInputs = [
      aws-sdk-go
      azure-sdk-for-go
      consul_api
      dns
      fsnotify_v1
      go-autorest
      goleveldb
      govalidator
      go-zookeeper
      google-api-go-client
      kubernetes-client-go_1-5
      net
      oauth2
      prometheus_client_golang
      prometheus_client_model
      prometheus_common
      protobuf
      snappy
      time
      yaml_v2
    ];
  };

  prometheus_client_golang = buildFromGitHub {
    version = 3;
    rev = "94ff84a9a6ebb5e6eb9172897c221a64df3443bc";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "1a0kyb38y31spjzd4wgvqv2jfscs8h3fxfl9p2w4h82p8hwcym39";
    propagatedBuildInputs = [
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      beorn7_perks
    ];
    date = "2017-07-24";
  };

  prometheus_client_model = buildFromGitHub {
    version = 2;
    rev = "6f3806018612930941127f2a7c6c453ba2c527d2";
    date = "2017-02-16";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "0a9i3ja3pp6sj2v2qshnp12mdgshngwf73p0jmmhn2yddipbngc0";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 3;
    date = "2017-07-31";
    rev = "61f87aac8082fa8c3c5655c7608d7478d46ac2ad";
    owner = "prometheus";
    repo = "common";
    sha256 = "1mf7wr9ir04qhjmfgx2285gn7vr8wmxp3vsghwdrvavlfxyjdm8h";
    buildInputs = [
      net
      prometheus_client_model
      protobuf
      sys
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      httprouter
      logrus
      prometheus_client_golang
    ];
  };

  prometheus_common_for_client = prometheus_common.override {
    subPackages = [
      "expfmt"
      "model"
      "internal/bitbucket.org/ww/goautoneg"
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      prometheus_client_model
      protobuf
    ];
  };

  procfs = buildFromGitHub {
    version = 3;
    rev = "e645f4e5aaa8506fc71d6edbc5c4ff02c04c46f2";
    date = "2017-07-03";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "1yr574ik2a83c2555vga5mqr155dd4710dc38dp6jgxrq2p7x9bh";
  };

  properties = buildFromGitHub {
    version = 3;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.3";
    sha256 = "1gbi6n1c1v686q2l4vs3az1gm6hvyzvhg7qganvvc7skr8s2v8z1";
  };

  gogo_protobuf = buildFromGitHub {
    version = 2;
    owner = "gogo";
    repo = "protobuf";
    rev = "v0.4";
    sha256 = "17bpsaqg5cqsdfp6da6w14lypjnv7vrdiwd033hbl35m6w6x87xi";
    excludedPackages = "test";
  };

  pty = buildFromGitHub {
    version = 2;
    owner = "kr";
    repo = "pty";
    rev = "v1.0.0";
    sha256 = "1v6xk33d575r598ir2k2zc0myl524ll2mcjkrxbcvg8l5wi7xn0a";
  };

  purell = buildFromGitHub {
    version = 3;
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "7cf257f0a33260797b0febf39f95fccd86aab2a3";
    sha256 = "0mgv5j69nym77yv8mm8lckn0bvjj3ag67333r60q7g94xq5sc0y0";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
    date = "2017-08-10";
  };

  qart = buildFromGitHub {
    version = 1;
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "02n7f1j42jp8f4nvg83nswfy6yy0mz2axaygr6kdqwj11n44rdim";
  };

  ql = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "0ap19p5zgjrqa31fw87rsi10n0jrh5jydyyqqpbjalkg5qxwd63l";
    propagatedBuildInputs = [
      b
      exp
      go4
      lldb
      mathutil
      strutil
    ];
  };

  queue = buildFromGitHub {
    version = 3;
    rev = "44cc805cf13205b55f69e14bcb69867d1ae92f98";
    owner  = "eapache";
    repo   = "queue";
    sha256 = "00bdh38341icyyxf9rpprnbpbwqkg87g3p1sjbcx194370x5jj7d";
    date = "2016-08-05";
  };

  rabbit-hole = buildFromGitHub {
    version = 2;
    rev = "v1.3.0";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "1xplz3mwj6dia7y7jzgk5r2vdmmi2rk89ndzz1mg2hibq85cs2fr";
  };

  radius = buildFromGitHub {
    version = 3;
    rev = "93f59762858cc929b83a34ed2077ddaff47636f0";
    date = "2017-08-10";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "1anv1kcwf5ysr2xq880ljz58ylhnd6h7qnnngza37l6x70zjs166";
    goPackagePath = "layeh.com/radius";
  };

  raft_v2 = buildFromGitHub {
    version = 3;
    date = "2017-06-09";
    # Use the library-v2-stage-one branch until it is merged
    # into master.
    rev = "e5e581e04af7c46974b99195347cc0c380c0d841";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "13a16af54b18db9d1444a6d8c3e9315d9914aa3a1e8eed54c8f404b321b0f204";
    propagatedBuildInputs = [
      armon_go-metrics
      logxi
      ugorji_go
    ];
    meta.autoUpdate = false;
  };

  raft-boltdb_v2 = buildFromGitHub {
    version = 2;
    date = "2017-02-09";
    rev = "df631556b57507bd5d0ed4f87468fd93ab025bef";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "0hhc71684mdz09cm8r9hf9j9m97yzv495ln3kk4cms62pc9yf93b";
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft_v2
    ];
  };

  ratecounter = buildFromGitHub {
    version = 3;
    owner = "paulbellamy";
    repo = "ratecounter";
    rev = "f965c2b56662c5bbb5e6b93cc760d43f8698aab8";
    sha256 = "1190lmnglmc0ayq82wyhqh5hnin7xh71wkpfr97ym7z8ahqx96mf";
    date = "2017-06-20";
  };

  ratelimit = buildFromGitHub {
    version = 3;
    rev = "5b9ff866471762aa2ab2dced63c9fb6f53921342";
    date = "2017-05-23";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0hjy6qjxzbvy3s1mqsjhk30xp3j2n0b5kh2i2l5vwrkzjfq6qilc";
  };

  raw = buildFromGitHub {
    version = 2;
    rev = "4ad22e6f1008c9f1100cb970699da776b45be83c";
    owner  = "feyeleanor";
    repo   = "raw";
    sha256 = "0zb5qwrm7x7p79wzi4lbr4px9q6qm5zz9xwjakf2wb1cnyxim93w";
    date = "2016-12-30";
  };

  rclone = buildFromGitHub {
    version = 3;
    owner = "ncw";
    repo = "rclone";
    date = "2017-08-11";
    rev = "e64435a5c158316946d99bbe91737b7115fea0a3";
    sha256 = "10rgdp85c8132fbimj61f6mzz586pwvr9d424iabql19l7kvw7gs";
    propagatedBuildInputs = [
      aws-sdk-go
      cgofuse
      cobra
      crypto
      #dropbox
      dropbox-sdk-go-unofficial
      eme
      errors
      ewma
      fs
      ftp
      fuse
      go-acd
      goconfig
      google-api-go-client
      net
      oauth2
      open-golang
      pflag
      sftp
      ssh-agent
      swift
      sys
      tb
      termbox-go
      testify
      text
      time
      tree
    ];
    meta.useUnstable = true;
  };

  cupcake_rdb = buildFromGitHub {
    version = 2;
    date = "2016-08-25";
    rev = "43ba34106c765f2111c0dc7b74cdf8ee437411e0";
    owner = "cupcake";
    repo = "rdb";
    sha256 = "0sqs6l4i5f2pd4i719aijbyjhdss8zqvk3b9195d0ljx2di9y84i";
  };

  siddontang_rdb = buildFromGitHub {
    version = 1;
    date = "2015-03-07";
    rev = "fc89ed2e418d27e3ea76e708e54276d2b44ae9cf";
    owner = "siddontang";
    repo = "rdb";
    sha256 = "1rf7dcxymdqjxjld6mb0fpsprnf342y1mr6m93fr073m5k5ij6kq";
    propagatedBuildInputs = [
      cupcake_rdb
    ];
  };

  redigo = buildFromGitHub {
    version = 3;
    owner = "garyburd";
    repo = "redigo";
    date = "2017-07-18";
    rev = "9e66b83d15a259978be267d0b61838c42c3904e3";
    sha256 = "0lvdihkwmq0z2x9gvi17k50n2dbsxha6ga8mf846xw313r7j1p5m";
    meta.useUnstable = true;
  };

  redis_v2 = buildFromGitHub {
    version = 1;
    rev = "v2.3.2";
    owner  = "go-redis";
    repo   = "redis";
    sha256 = "211e91fd3b5e120ca073aecb8088ba513012ab4513b13934890aaa6791b2923b";
    goPackagePath = "gopkg.in/redis.v2";
    propagatedBuildInputs = [
      bufio_v1
    ];
  };

  reedsolomon = buildFromGitHub {
    version = 3;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2017-07-22";
    rev = "48a4fd05f1730dd3ef9c3f9e943f6091d063f2c4";
    sha256 = "1zjwhm988b0lfpjgy3g5v4fb1r39fbbh7qv52vawh67n1xm6h8s9";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  reflectwalk = buildFromGitHub {
    version = 3;
    date = "2017-07-26";
    rev = "63d60e9d0dbc60cf9164e6510889b0db6683d98c";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "1xpgzn3rgc222yz09nmn1h8xi2769x3b5cmb23wch0w43cj8inkz";
  };

  resumable = buildFromGitHub {
    version = 2;
    owner = "stevvooe";
    repo = "resumable";
    date = "2016-09-23";
    rev = "f714bdb9b57a7162bc99aaa0b68a338c0da1c392";
    sha256 = "18jm8ssihjl5flqhahqcvz2s5cifgcl6f7ms23xl70zkls6j0l3a";
  };

  roaring = buildFromGitHub {
    version = 3;
    rev = "v0.3.9";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1j9p9s2jy4wr08qa19g8imf49wx2q626lid68z1miwxvh97736j1";
    propagatedBuildInputs = [
      go-unsnap-stream
      msgp
    ];
  };

  rollinghash = buildFromGitHub {
    version = 2;
    rev = "v2.0.2";
    owner  = "chmduquesne";
    repo   = "rollinghash";
    sha256 = "1krn9jjsjl8c1w09p8qyn3hfrgdbc3a465jzv6a6399fylxhgipf";
  };

  roundtrip = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "roundtrip";
    date = "2017-03-20";
    rev = "4162b978cd8cbec3f35dea84aae8d5fc696363c7";
    sha256 = "0s1lmr264wdxhw8jnx7kifc89dcqdyb9sqg8nq2wc42dhrnm9f3m";
    propagatedBuildInputs = [
      trace
    ];
  };

  rpc = buildFromGitHub {
    version = 2;
    owner = "gorilla";
    repo = "rpc";
    rev = "v1.1.0";
    sha256 = "12qqc07dsi4vqc8wkmjlwdiyzh8fdzclmylbx93dxjfrav3psnl5";
  };

  rsc = buildFromGitHub {
    version = 2;
    owner = "mdp";
    repo = "rsc";
    date = "2016-01-31";
    rev = "90f07065088deccf50b28eb37c93dad3078c0f3c";
    sha256 = "0nibwihq09m5chhryi20dcjg9bbk4yy0x2asz0c8ln73hrcijdm1";
    buildInputs = [
      pkgs.qrencode
    ];
  };

  runc = buildFromGitHub {
    version = 2;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "f9d79f48bbaf1c385219bf8617a25eb88f9a81f25f1a168830700e8ea9004db1";
    propagatedBuildInputs = [
      dbus
      fileutils
      go-systemd
      go-units
      gocapability
      libseccomp-golang
      logrus
      moby_for_runc
      netlink
      protobuf
      runtime-spec
      urfave_cli
    ];
    meta.autoUpdate = false;
  };

  runtime-spec = buildFromGitHub {
    version = 2;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "f5b8967328a8c42eafac05ae8569f6e23cbb5b23d7af55072ee57c04c4622742";
    buildInputs = [
      gojsonschema
    ];
    meta.autoUpdate = false;
  };

  sanitized-anchor-name = buildFromGitHub {
    version = 3;
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "541ff5ee47f1dddf6a5281af78307d921524bcb5";
    date = "2017-05-15";
    sha256 = "1l09ibm48a92q9galxf2q5d81a2b4rcd5qa11ss5if18v9wvcnfa";
  };

  sarama_v1 = buildFromGitHub {
    version = 3;
    owner = "Shopify";
    repo = "sarama";
    rev = "v1.12.0";
    sha256 = "0kjrw3c4p2z4k4nfwd7rpg6d4wfqkmqg6fchjwzmrczfk0z0zi5j";
    goPackagePath = "gopkg.in/Shopify/sarama.v1";
    excludedPackages = "\\(mock\\|tools\\)";
    propagatedBuildInputs = [
      go-resiliency
      go-spew
      go-xerial-snappy
      lz4
      queue
      rcrowley_go-metrics
    ];
  };

  scada-client = buildFromGitHub {
    version = 1;
    date = "2016-06-01";
    rev = "6e896784f66f82cdc6f17e00052db91699dc277d";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "1by4kyd2hrrrghwj7snh9p8fdlqka24q9yr6nyja2acs2zpjgh7a";
    buildInputs = [
      armon_go-metrics
    ];
    propagatedBuildInputs = [
      net-rpc-msgpackrpc
      yamux
    ];
  };

  seed = buildFromGitHub {
    version = 2;
    rev = "e2103e2c35297fb7e17febb81e49b312087a2372";
    owner = "sean-";
    repo = "seed";
    sha256 = "0hnkw8zjiqkyffxfbgh1020dgy0vxzad1kby0kkm8ld3i5g0aq7a";
    date = "2017-03-13";
  };

  semver = buildFromGitHub {
    version = 3;
    rev = "v3.5.1";
    owner = "blang";
    repo = "semver";
    sha256 = "0aanqrqs0kybkvnd5rqpd5lrdv8bnh8k9i938r3rch49a6gwq6qq";
  };

  serf = buildFromGitHub {
    version = 3;
    rev = "e0e11d82226a61dd9b31c1df562dc9101ee86142";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "141yqgcplivpbn8i5qvwxsmzdx820mn1pzbvp59405ya0vhl7xpq";

    buildInputs = [
      armon_go-metrics
      circbuf
      columnize
      go-syslog
      logutils
      mapstructure
      mdns
      memberlist
      mitchellh_cli
      ugorji_go
    ];
    meta.useUnstable = true;
    date = "2017-08-02";
  };

  session = buildFromGitHub {
    version = 2;
    rev = "b8e286a0dba8f4999042d6b258daf51b31d08938";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "12a9irqcs1jsvxpfb6i1357r5xn14qchn4k9a211f4w1ddgiiw7d";
    date = "2017-03-20";
    propagatedBuildInputs = [
      gomemcache
      go-couchbase
      com
      ledisdb
      macaron_v1
      mysql
      nodb
      pq
      redis_v2
    ];
  };

  sets = buildFromGitHub {
    version = 1;
    rev = "6c54cb57ea406ff6354256a4847e37298194478f";
    owner  = "feyeleanor";
    repo   = "sets";
    sha256 = "11gg27znzsay5pn9wp7rl427v8bl1rsncyk8nilpsbpwfbz7q7vm";
    date = "2013-02-27";
    propagatedBuildInputs = [
      slices
    ];
  };

  sftp = buildFromGitHub {
    version = 3;
    owner = "pkg";
    repo = "sftp";
    rev = "1a91f318a0be84de50afcf22d3b3d78bfe32025c";
    date = "2017-08-11";
    sha256 = "055r42y13kfvz8pkvzpc7kj7r5axhkj1ayxlwqkzal8w5gvhq1c8";
    propagatedBuildInputs = [
      crypto
      errors
      fs
    ];
  };

  sha256-simd = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "sha256-simd";
    date = "2017-04-24";
    rev = "f3ec2e4d36d43c3a899ed4b7d9f62188edcf5afd";
    sha256 = "1h446sfh2j000n7sz8qfv7q4jrvcmw0kdl0ibflwi6hy77ni1x9m";
  };

  shell = buildGoPackage rec {
    name = nameFunc {
      inherit
        goPackagePath
        rev;
      date = "2016-01-05";
    };
    rev = "4e4a4403205db46f1ef0590e98dc814a38d2ea63";
    goPackagePath = "bitbucket.org/creachadair/shell";
    src = fetchzip {
      version = 3;
      inherit name;
      url = "https://bitbucket.org/creachadair/shell/get/${rev}.tar.gz";
      sha256 = "15sv6548dcjnp1bv17gmk3lxjdbcf6309x0q9g0nk1k9j2mas725";
    };
  };


  shellescape = buildFromGitHub {
    version = 3;
    owner = "alessio";
    repo = "shellescape";
    rev = "v1.2";
    sha256 = "0vr93zsjhcdgf7q91hv0shj5r3kabagjgv43zakwp7yw9d46bvrk";
  };

  skyring-common = buildFromGitHub {
    version = 2;
    owner = "skyrings";
    repo = "skyring-common";
    date = "2016-09-29";
    rev = "d1c0bb1cbd5ed8438be1385c85c4f494608cde1e";
    sha256 = "0wr3bw55daf8ryz46hviwvs1wz1l2c6x3rrccr70gllg74lg1wd5";
    buildInputs = [
      crypto
      go-logging
      go-python
      gorequest
      graphite-golang
      influxdb_client
      mgo_v2
    ];
    postPatch = /* go-python now uses float64 */ ''
      sed -i tools/gopy/gopy.go \
        -e 's/python.PyFloat_FromDouble(f32)/python.PyFloat_FromDouble(f64)/'
    '';
  };

  slices = buildFromGitHub {
    version = 2;
    rev = "145c47818f5f4e3ab04935822b3bd440e54ffc45";
    owner  = "feyeleanor";
    repo   = "slices";
    sha256 = "1bgzczwymd0498gk9ikrdfw32s5cir9n1skrnz0jh5qwkxdljm9n";
    date = "2016-12-30";
    propagatedBuildInputs = [
      raw
    ];
  };

  slug = buildFromGitHub {
    version = 3;
    rev = "v1.1.0";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "0mhz1vgrvp4asw89f3z4by2kbbd6ysr315wjw4ab276pvhhp9rf3";
    propagatedBuildInputs = [
      com
      macaron_v1
      #unidecode
    ];
  };

  smux = buildFromGitHub {
    version = 2;
    rev = "v1.0.5";
    owner  = "xtaci";
    repo   = "smux";
    sha256 = "0k22a97v7s50a0d62vf7q9my66jg8h4gi27bf3a30amir75cggzb";
    propagatedBuildInputs = [
      errors
    ];
  };

  softlayer-go = buildFromGitHub {
    version = 3;
    date = "2017-08-04";
    rev = "5e1c8cccc730778a87ca5a0c5348fcfddc02cee2";
    owner = "softlayer";
    repo = "softlayer-go";
    sha256 = "18kbfz4pd34ygxq39f87655j5ndwml2mac4yihsl7d8g5q3b4pjb";
    propagatedBuildInputs = [
      tools
      xmlrpc
    ];
  };

  sortutil = buildFromGitHub {
    version = 1;
    date = "2015-06-17";
    rev = "4c7342852e65c2088c981288f2c5610d10b9f7f4";
    owner = "cznic";
    repo = "sortutil";
    sha256 = "11iykyi1d7vjmi7778chwbl86j6s1742vnd4k7n1rvrg7kq558xq";
  };

  spacelog = buildFromGitHub {
    version = 3;
    date = "2017-07-06";
    rev = "b6d9bf7bf3eb5739748f052960716cf9a5eb89ec";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "08z46qkkyzv5qdx2p2fvcs53cqqqx9xdiahadqfgaw38qj1018wb";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    version = 3;
    rev = "v0.1.0";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "1zg744bdadwcpln9lcl2837hkdx0iynrjz99incqavp2nl3974yk";
  };

  spec = buildFromGitHub {
    version = 3;
    date = "2017-08-11";
    rev = "3faa0055dbbf2110abc1f3b4e3adbb22721e96e7";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "02213r0m2157n7rkvvsdjkgxpqxjhj780gzrb4qngbfkbidizvqc";
    propagatedBuildInputs = [
      jsonpointer
      jsonreference
      swag
    ];
  };

  srslog = buildFromGitHub {
    version = 2;
    rev = "a974ba6f7fb527d2ddc73ee9c05d3e2ccc0af0dc";
    date = "2017-01-06";
    owner  = "RackSec";
    repo   = "srslog";
    sha256 = "14714h9wkmb2i2flbljpmsa3mjvi27jkqwxc3rz1q67zbkv7vd1w";
  };

  ssh-agent = buildFromGitHub {
    version = 3;
    rev = "ba9c9e33906f58169366275e3450db66139a31a9";
    date = "2015-12-15";
    owner  = "xanzy";
    repo   = "ssh-agent";
    sha256 = "0qrzy6mla0wdf7nwgy22biccmavznqh4cw8nhzyj4i9pf3vy6570";
    propagatedBuildInputs = [
      crypto
    ];
  };

  stack = buildFromGitHub {
    version = 3;
    rev = "v1.6.0";
    owner = "go-stack";
    repo = "stack";
    sha256 = "1i3wzna0sl8h73217dllzz4n8ndr87a96ral40jn5h46bhsxz4g6";
  };

  stathat = buildFromGitHub {
    version = 1;
    date = "2016-07-15";
    rev = "74669b9f388d9d788c97399a0824adbfee78400e";
    owner = "stathat";
    repo = "go";
    sha256 = "19aki04z76qzgdr8l3zlz904mkalspfa46cja2fdjy70sfvfjdp1";
  };

  statik = buildFromGitHub {
    version = 2;
    owner = "rakyll";
    repo = "statik";
    date = "2017-04-10";
    rev = "89fe3459b5c829c32e89bdff9c43f18aad728f2f";
    sha256 = "027iy2yrppplr4yc14ixriaar5m6b1y3x3z0svlfi8b5n62l5frm";
    postPatch = /* Remove recursive import of itself */ ''
      sed -i example/main.go \
        -e '/"github.com\/rakyll\/statik\/example\/statik"/d'
    '';
  };

  structs = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "10v55lsqanmxpg1647bmrjdz00fbn4nv4ffali5b8s9lg3j3jgga";
  };

  stump = buildFromGitHub {
    version = 1;
    date = "2016-06-11";
    rev = "206f8f13aae1697a6fc1f4a55799faf955971fc5";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "0qmchkr29rzscc148aw2vb2qf5dma2dka0ys96cx5fxa4p516d3i";
  };

  strutil = buildFromGitHub {
    version = 2;
    date = "2017-01-31";
    rev = "43a89592ed56c227c7fdb1fcaf7d1d08be02ec54";
    owner = "cznic";
    repo = "strutil";
    sha256 = "16lv9wc7b8371b08n5hr6mlnllnj60is7mhcpbnk247g25160wp0";
  };

  suture = buildFromGitHub {
    version = 2;
    rev = "v2.0.1";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0jhzl8ihadxyw76h58ijwy73nh390knhkxlgnvfnsfwgf7irghd0";
  };

  swag = buildFromGitHub {
    version = 3;
    rev = "f3f9494671f93fcff853e3c6e9e948b3eb71e590";
    owner = "go-openapi";
    repo = "swag";
    sha256 = "1sxh12fdc1a5mv1nws0lpapdwg41h7yw57f4wbb93hrb5dax21lc";
    date = "2017-06-06";
    propagatedBuildInputs = [
      easyjson
      yaml_v2
    ];
  };

  swarmkit = buildFromGitHub {
    version = 3;
    rev = "43e7983ed357292f9a6f21915841ec86bcb5b589";
    owner = "docker";
    repo = "swarmkit";
    sha256 = "1bvdhjjrnfba5iqrk2hvpansnwmbg4izbvif95pz4r2k42fmqqr7";
    date = "2017-08-10";
    subPackages = [
      "api"
      "api/deepcopy"
      "api/equality"
      "api/genericresource"
      "api/naming"
      "ca"
      "connectionbroker"
      "identity"
      "ioutils"
      "log"
      "manager/raftselector"
      "manager/state"
      "manager/state/store"
      "protobuf/plugin"
      "remotes"
      "watch"
      "watch/queue"
    ];
    propagatedBuildInputs = [
      cfssl
      errors
      etcd_for_swarmkit
      go-digest
      go-events
      go-grpc-prometheus
      go-memdb
      gogo_protobuf
      grpc
      logrus
      net
    ];
  };

  swift = buildFromGitHub {
    version = 3;
    rev = "af59a5adcdb59d343cc10d09804a9cbfbc32d385";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "13z9w3bqwsw1zwqfa6lg6k5pw8wi0lpf5cp4q7zkb2ax6par2l0c";
    date = "2017-08-11";
  };

  anacrolix_sync = buildFromGitHub {
    version = 2;
    rev = "d29d95568d362a0008c1ffbaea39a3449ea67509";
    owner  = "anacrolix";
    repo   = "sync";
    sha256 = "1bfwg17qh4s91rzd4wgczmvi4c67kfdh71dr8qnbwr76qavybl10";
    date = "2016-12-14";
    buildInputs = [
      missinggo
    ];
  };

  syncthing = buildFromGitHub rec {
    version = 3;
    rev = "v0.14.36";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "0h13pa298ibf80wxc496an3vpvg84kb34zlq80g4fd1s85a8ar1i";
    buildFlags = [ "-tags noupgrade" ];
    buildInputs = [
      AudriusButkevicius_cli
      crypto
      du
      gateway
      geoip2-golang
      glob
      go-deadlock
      go-lz4
      go-nat-pmp
      go-stun
      gogo_protobuf
      goleveldb
      groupcache
      kcp-go
      luhn
      net
      osext
      pfilter
      pq
      qart
      ql
      rcrowley_go-metrics
      rollinghash
      sha256-simd
      smux
      suture
      text
      time
      xdr
    ];
    postPatch = ''
      # Mostly a cosmetic change
      sed -i 's,unknown-dev,${rev},g' cmd/syncthing/main.go
    '';
    preBuild = ''
      pushd go/src/$goPackagePath
      go run script/genassets.go gui > lib/auto/gui.files.go
      popd
    '';
  };

  syslogparser = buildFromGitHub {
    version = 1;
    rev = "ff71fe7a7d5279df4b964b31f7ee4adf117277f6";
    date = "2015-07-17";
    owner  = "jeromer";
    repo   = "syslogparser";
    sha256 = "1x1nq7kyvmfl019d3rlwx9nqlqwvc87376mq3xcfb7f5vxlmz9y5";
  };

  tablewriter = buildFromGitHub {
    version = 3;
    rev = "be5337e7b39e64e5f91445ce7e721888dbab7387";
    date = "2017-07-19";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "17hvmj3gmv49xd002ri7ng8sy7bvqb5c794xkd3yz6v835pyfcfg";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  tagflag = buildFromGitHub {
    version = 1;
    rev = "e7497e81ffa475caf0fc24e999eb29edc0335040";
    date = "2016-06-15";
    owner  = "anacrolix";
    repo   = "tagflag";
    sha256 = "3515c691c6ecc867e3e539048b9ca331ccb654c1890cde460748b9b3043eba5a";
    propagatedBuildInputs = [
      go-humanize
      iter
      missinggo_lib
      xstrings
    ];
    meta.autoUpdate = false;
  };

  tail = buildFromGitHub {
    version = 3;
    rev = "66928beff07e654d08f02f592e53aaab8df488d5";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "0llv0iaa2pc7pkvccj0lx3by7kmikkf8y13xa1xl9s96p24sxwqd";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
    ];
    date = "2017-08-03";
  };

  tar-split = buildFromGitHub {
    version = 2;
    owner = "vbatts";
    repo = "tar-split";
    rev = "bd4c5d64c3e9297f410025a3b1bd0c58f659e721";
    date = "2016-09-26";
    sha256 = "e317e4bb73fab3e03ff34b96a861fec72e716f61fc01343876131e50dfacc402";
    propagatedBuildInputs = [
      urfave_cli
      logrus
    ];
  };

  tar-utils = buildFromGitHub {
    version = 1;
    rev = "beab27159606f5a7c978268dd1c3b12a0f1de8a7";
    date = "2016-03-22";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "0p0cmk30b22bgfv4m29nnk2359frzzgin2djhysrqznw3wjpn3nz";
  };

  tb = buildFromGitHub {
    version = 2;
    owner = "tsenart";
    repo = "tb";
    rev = "19f4c3d79d2bd67d0911b2e310b999eeea4454c1";
    date = "2015-12-08";
    sha256 = "fb8fb335f10f48e641b3a6abcfe3eb20737cfb5a71aa6b6dbd3399aaedcb8fad";
  };

  teleport = buildFromGitHub {
    version = 3;
    rev = "v2.2.3";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "1cbkk8nbg6x2lnsdy02h9f4yf5sc4dp1p1n80bxfa2ii1fvamy3y";
    buildInputs = [
      aws-sdk-go
      backoff
      bolt
      configure
      clockwork
      crypto
      etcd_client
      etree
      form
      go-oidc
      go-shellwords
      gops
      gosaml2
      goterm
      goxmldsig
      grpc
      grpc-gateway
      hdrhistogram
      hotp
      httprouter
      gravitational_kingpin
      kubernetes-client-go_1-4
      lemma
      logrus
      moby_for_runc
      net
      osext
      otp
      oxy
      prometheus_client_golang
      protobuf
      pty
      roundtrip
      shellescape
      text
      timetools
      trace
      gravitational_ttlmap
      mailgun_ttlmap
      u2f
      pborman_uuid
      yaml
      yaml_v2
    ];

    excludedPackages = "\\(test\\|suite\\|fixtures\\)";

    patches = [
      (fetchTritonPatch {
        rev = "dee53e8ac6a783b38886b19138e9e7512f55b243";
        file = "t/teleport/fix.patch";
        sha256 = "daa97773d7a358971a87f42d91d2ff5fe0f4c3ae1dc2f7c4020b16f73442bcbc";
      })
    ];

    meta.autoUpdate = false;
  };

  template = buildFromGitHub {
    version = 1;
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "10albmv2bdrrgzzqh1rlr88zr2vvrabvzv59m15wazwx39mqzd7p";
    date = "2016-04-05";
  };

  termbox-go = buildFromGitHub {
    version = 3;
    rev = "4ed959e0540971545eddb8c75514973d670cf739";
    date = "2017-07-10";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "039h0bv1f448dxd6j0hszb1yvvac7fc7aq28by8451cqlh5ilql9";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 3;
    rev = "890a5c3458b43e6104ff5da8dfa139d013d77544";
    owner = "stretchr";
    repo = "testify";
    sha256 = "08xwvwdw5d8ilssc07fjjdaczdwcc1yr3yrfa1avz7gsrqasw0ib";
    propagatedBuildInputs = [
      go-difflib
      go-spew
      objx
    ];
    date = "2017-08-09";
  };

  kr_text = buildFromGitHub {
    version = 2;
    rev = "7cafcd837844e784b526369c9bce262804aebc60";
    date = "2016-05-04";
    owner = "kr";
    repo = "text";
    sha256 = "0qmc5rl6rhafiqiqnfrajngzr7qmwfwnj18yccd8jkpd5ix4r70d";
    propagatedBuildInputs = [
      pty
    ];
  };

  timecache = buildFromGitHub {
    version = 2;
    rev = "cfcb2f1abfee846c430233aef0b630a946e0a5a6";
    date = "2016-09-10";
    owner  = "whyrusleeping";
    repo   = "timecache";
    sha256 = "0w65wbpf0fzxdj2f1d8km9hg91yp9519agdgb6v6jnxnjvi7d43j";
  };

  timetools = buildFromGitHub {
    version = 3;
    rev = "f3a7b8ffff474320c4f5cc564c9abb2c52ded8bc";
    date = "2017-06-19";
    owner = "mailgun";
    repo = "timetools";
    sha256 = "0kjrg9l3w7znm26anbb655ncgw0ya2lcjry78lk77j08a9hmj6r2";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  tokenbucket = buildFromGitHub {
    version = 1;
    rev = "c5a927568de7aad8a58127d80bcd36ca4e71e454";
    date = "2013-12-01";
    owner = "ChimeraCoder";
    repo = "tokenbucket";
    sha256 = "11zasaakzh4fzzmmiyfq5mjqm5md5bmznbhynvpggmhkqfbc28gz";
  };

  tomb_v2 = buildFromGitHub {
    version = 2;
    date = "2016-12-08";
    rev = "d5d1b5820637886def9eef33e03a27a9f166942c";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "0azb4hkv41wl750wapl4jbnpvn1jg54z1clcnqvvs84rh75ywqj1";
    goPackagePath = "gopkg.in/tomb.v2";
    buildInputs = [
      net
    ];
  };

  tomb_v1 = buildFromGitHub {
    version = 1;
    date = "2014-10-24";
    rev = "dd632973f1e7218eb1089048e0798ec9ae7dceb8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1gn3f185fihpd5ccr04bp2iprj75jyx803a6i9b3avbcmn24w7xa";
    goPackagePath = "gopkg.in/tomb.v1";
  };

  toml = buildFromGitHub {
    version = 2;
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.3.0";
    sha256 = "1cnryizxrj7si27knhh83dd03abw5r0yhac2vmv861inpl3lflx2";
    goPackageAliases = [ "github.com/burntsushi/toml" ];
  };

  trace = buildFromGitHub {
    version = 3;
    owner = "gravitational";
    repo = "trace";
    rev = "1.0.0";
    sha256 = "0wgsw2zbmn4s9w1qp7jxcdkwjkwixliwkj1bxxsvkpdwykx6g2jy";
    propagatedBuildInputs = [
      clockwork
      grpc
      logrus
      net
    ];
  };

  tree = buildFromGitHub {
    version = 3;
    rev = "fb478f41c87d959e328f2eac0c1b40f17a2f3e00";
    owner  = "a8m";
    repo   = "tree";
    sha256 = "0ll0hjj0f7zwfxgp1f7yxas45cxq2jw2g6nwwk5541bardlyag3v";
    date = "2017-07-24";
  };

  trillian = buildFromGitHub {
    version = 3;
    rev = "8842731903be9e99aba531f84782de790c1c9785";
    owner  = "google";
    repo   = "trillian";
    sha256 = "0zbmkk4a6q2s23aab3rsjzzv1dsxp8bmxk13fgxw7zpswn64gsx0";
    date = "2017-08-02";
    propagatedBuildInputs = [
      btree
      etcd_client
      genproto
      glog
      gogo_protobuf
      grpc
      grpc-gateway
      mock
      mysql
      net
      objecthash
      pkcs11key
      prometheus_client_golang
      prometheus_client_model
      protobuf
      shell
    ];
    excludedPackages = "\\(test\\|cmd\\)";
  };

  gravitational_ttlmap = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "ttlmap";
    rev = "348cf76cace4d93fdacc38dfdaa2306f4f0e9c16";
    sha256 = "00z54zc4g5h8qdwdqhkycyjl705sg7bb1iilkmrdh04n602wdwr0";
    date = "2016-04-07";
    propagatedBuildInputs = [
      clockwork
      minheap
    ];
  };

  mailgun_ttlmap = buildFromGitHub {
    version = 3;
    owner = "mailgun";
    repo = "ttlmap";
    rev = "c1c17f74874f2a5ea48bfb06b5459d4ef2689749";
    sha256 = "0v0ib54klps23bziczws1vk5vqv3649pl0gamirzzj6z0fcmn08s";
    date = "2017-06-19";
    propagatedBuildInputs = [
      minheap
      timetools
    ];
  };

  u2f = buildFromGitHub {
    version = 2;
    rev = "eb799ce68da4150b16ff5d0c89a24e2a2ad993d8";
    owner = "tstranex";
    repo = "u2f";
    sha256 = "8b2e6912aeced8aa055feedbbe3de2ef065666b81181eb1c9e2826cc6d37f81f";
    date = "2016-05-08";
    meta.autoUpdate = false;
  };

  units = buildFromGitHub {
    version = 1;
    rev = "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a";
    owner = "alecthomas";
    repo = "units";
    sha256 = "1jj055kgx6mfx5zw263ci70axk3z5006db74dqhcilxwk1a2ga23";
    date = "2015-10-22";
  };

  urlesc = buildFromGitHub {
    version = 3;
    owner = "PuerkitoBio";
    repo = "urlesc";
    rev = "de5bf2ad457846296e2031421a34e2568e304e35";
    sate = "2015-02-08";
    sha256 = "0q4m7vhh0bxcj2r6di0f19g7zzgx6sq2m4nrb3p9ds19gbbyg099";
    date = "2017-08-10";
  };

  usage-client = buildFromGitHub {
    version = 2;
    owner = "influxdata";
    repo = "usage-client";
    date = "2016-08-29";
    rev = "6d3895376368aa52a3a81d2a16e90f0f52371967";
    sha256 = "37a9a3330c2a7fac370ccb7117c681dd6fafeef57d327b3071ec13a279fa7996";
  };

  utp = buildFromGitHub {
    version = 3;
    rev = "adfb02f3172f79816912bcf58f2b58531624ae68";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "04qjf1vsw99mpnzsmplq9cwkdbjwsya4vgslpr0ajzfx9knmy3a2";
    date = "2017-05-31";
    propagatedBuildInputs = [
      envpprof
      missinggo
      anacrolix_sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 3;
    rev = "v1.1";
    owner = "pborman";
    repo = "uuid";
    sha256 = "1fxshlxq927ak7cywlzcyqw8w1pfqs5cvidk7qdn685vm0rns5d9";
  };

  satori_uuid = buildFromGitHub {
    version = 2;
    rev = "5bf94b69c6b68ee1b541973bb8e1144db23a194b";
    owner = "satori";
    repo = "uuid";
    sha256 = "0qjww7ng1amsn9m3lhnbxalvlv0gndl86g7l6rsxaybhvbcpr15s";
    date = "2017-03-21";
  };

  vault = buildFromGitHub {
    version = 3;
    rev = "v0.8.0";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "0n4f4x4qrnvl19m7zp7ihab2nqc94ki6ya2mwyj718y7qzrdx9zy";

    nativeBuildInputs = [
      pkgs.protobuf-cpp
      protobuf.bin
    ];

    buildInputs = [
      armon_go-metrics
      aws-sdk-go
      azure-storage-go
      columnize
      cockroach-go
      consul_api
      copystructure
      crypto
      duo_api_golang
      errwrap
      etcd_client
      go-cache
      go-cleanhttp
      go-colorable
      go-crypto
      go-errors
      go-github
      go-glob
      go-hdb
      go-homedir
      go-mssqldb
      go-multierror
      go-okta
      go-plugin
      go-proxyproto
      go-radix
      go-rootcerts
      go-semver
      go-sockaddr
      go-syslog
      go-testing-interface
      hashicorp_go-uuid
      go-zookeeper
      gocql
      golang-lru
      google-api-go-client
      google-cloud-go
      govalidator
      grpc
      hcl
      jose
      jsonx
      ldap
      logxi
      mapstructure
      mgo_v2
      mitchellh_cli
      mysql
      net
      oauth2
      otp
      pester
      pkcs7
      pq
      protobuf
      rabbit-hole
      radius
      reflectwalk
      scada-client
      snappy
      structs
      swift
      sys
      yaml
    ];

    # Regerate protos
    preBuild = ''
      srcDir="$(pwd)"/go/src
      pushd go/src/$goPackagePath >/dev/null
      find . -name \*pb.go -delete
      for file in $(find . -name \*.proto | sort | uniq); do
        pushd "$(dirname "$file")" > /dev/null
        echo "Regenerating protobuf: $file" >&2
        protoc -I "$srcDir" -I "$srcDir/$goPackagePath" -I . --go_out=plugins=grpc:. "$(basename "$file")"
        popd >/dev/null
      done
      popd >/dev/null
    '';
  };

  vault_api = vault.override {
    subPackages = [
      "api"
      "helper/compressutil"
      "helper/jsonutil"
      "helper/parseutil"
    ];
    nativeBuildInputs = [
    ];
    buildInputs = [
    ];
    preBuild = ''
    '';
    propagatedBuildInputs = [
      hcl
      go-cleanhttp
      go-multierror
      go-rootcerts
      mapstructure
      net
      pester
      snappy
      structs
    ];
    rev = "v0.8.0";
    sha256 = "0n4f4x4qrnvl19m7zp7ihab2nqc94ki6ya2mwyj718y7qzrdx9zy";
    version = 3;
  };

  viper = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "viper";
    rev = "25b30aa063fc18e48662b86996252eabdcf2f0c7";
    date = "2017-07-23";
    sha256 = "017jx771lar03dhx12hmzidfjxjv6w3jnwcfl5xyf68mp8yngh4y";
    buildInputs = [
      crypt
      pflag
    ];
    propagatedBuildInputs = [
      afero
      cast
      fsnotify
      go-toml
      hcl
      jwalterweatherman
      mapstructure
      properties
      #toml
      yaml_v2
    ];
  };

  vultr = buildFromGitHub {
    version = 2;
    rev = "1.13.0";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "0ksm28mygg0g7md7n0a1hbcg91rp27v8qnhcwwjv5cncmzmp381n";
    propagatedBuildInputs = [
      crypto
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  websocket = buildFromGitHub {
    version = 3;
    rev = "v1.2.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "1darksigd1zsxpajhvgp39bypif3sjbzc43rhqm0c2n6395k8psp";
  };

  w32 = buildFromGitHub {
    version = 2;
    rev = "bb4de0191aa41b5507caa14b0650cdbddcd9280b";
    owner = "shirou";
    repo = "w32";
    sha256 = "021764v4m4xp2xdsnlzx6871h5l8vraww39qig7sjsvbpw0v1igx";
    date = "2016-09-30";
  };

  wmi = buildFromGitHub {
    version = 2;
    rev = "ea383cf3ba6ec950874b8486cd72356d007c768f";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "00s17x9649l6j5i89ccbg3lx0md0ly858yyszn1j7xkx5nkhdq01";
    date = "2017-04-10";
    buildInputs = [
      go-ole
    ];
  };

  yaml = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "00g8p1grc0m34m55s3572d0d22f4vmws39f4vxp6djs4i2rzrqx3";
    propagatedBuildInputs = [
      yaml_v2
    ];
  };

  yaml_v2 = buildFromGitHub {
    version = 3;
    rev = "25c4ec802a7d637f88d584ab26798e94ad14c13b";
    date = "2017-07-21";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "004w3n5cv18adw4wckvm4q0rlhmmmjxgjdlf6dpwbp002ivv8v7p";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yaml_v1 = buildFromGitHub {
    version = 1;
    rev = "9f9df34309c04878acc86042b16630b0f696e1de";
    date = "2014-09-24";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "128xs9pdz042hxl28fi2gdrz5ny0h34xzkxk5rxi9mb5mq46w8ys";
    goPackagePath = "gopkg.in/yaml.v1";
  };

  yamux = buildFromGitHub {
    version = 1;
    date = "2016-07-20";
    rev = "d1caa6c97c9fc1cc9e83bbe34d0603f9ff0ce8bd";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "19frd5lldxrjybdj8a3al3bq2wn0bghrnldxvrydr5ysf782qalw";
  };

  xdr = buildFromGitHub {
    version = 2;
    rev = "08e072f9cb164f943a92eb59f90f3abc64ac6e8f";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "01dmdnxvrj40s65w729pjdjh6bf18lm3k57b1mx0z3xql00xsc4k";
    date = "2017-01-04";
  };

  xhandler = buildFromGitHub {
    version = 3;
    owner = "rs";
    repo = "xhandler";
    date = "2017-07-07";
    rev = "1eb70cf1520d43c307a89c5dabb7a7efd132fccd";
    sha256 = "0c1g5pipaj6z08778xx7q47lwp516qyd1zv82jhhls5jzy53c845";
    propagatedBuildInputs = [
      net
    ];
  };

  xmlrpc = buildFromGitHub {
    version = 3;
    rev = "ce4a1a486c03a3c6e1816df25b8c559d1879d380";
    owner  = "renier";
    repo   = "xmlrpc";
    sha256 = "10hl5zlhh4kayp0pvr1yjlpcywmmz6k35n8i8jrnglz2cj5cvm56";
    date = "2017-07-08";
    propagatedBuildInputs = [
      text
    ];
  };

  xorm = buildFromGitHub {
    version = 2;
    rev = "v0.6.2";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "13bmig019sg9jy5n6mvri7iz1hs3msh7grnpl4gma504s40m5ysv";
    propagatedBuildInputs = [
      core
    ];
  };

  xstrings = buildFromGitHub {
    version = 1;
    rev = "3959339b333561bf62a38b424fd41517c2c90f40";
    date = "2015-11-30";
    owner  = "huandu";
    repo   = "xstrings";
    sha256 = "16l1cqpqsgipa4c6q55n8vlnpg9kbylkx1ix8hsszdikj25mcig1";
  };

  cespare_xxhash = buildFromGitHub {
    version = 3;
    rev = "1b6d2e40c16ba0dfce5c8eac2480ad6e7394819b";
    owner  = "cespare";
    repo   = "xxhash";
    sha256 = "0lnc15cw0rvcpcqh91dx7ljrd2dl1g5c77xpqs956q81g7bq0ls4";
    date = "2017-06-04";
  };

  pierrec_xxhash = buildFromGitHub {
    version = 3;
    rev = "a0006b13c722f7f12368c00a3d3c2ae8a999a0c6";
    owner  = "pierrec";
    repo   = "xxHash";
    sha256 = "0zzllb2d027l3862rz3r77a07pvfjv4a12jhv4ncj0y69gw4lf7l";
    date = "2017-07-14";
  };

  xz = buildFromGitHub {
    version = 3;
    rev = "v0.5.4";
    owner  = "ulikunitz";
    repo   = "xz";
    sha256 = "0anf7p3y1d3m1ll0bacyp093lz6ahgxqv1pji59xg9wwx88vmgl3";
  };

  zap = buildFromGitHub {
    version = 3;
    rev = "v1.4.1";
    owner  = "uber-go";
    repo   = "zap";
    sha256 = "17mzskysy7822aw0gc6ijizpgm3frl71c5989pvhzwqhmpncmnvg";
    goPackagePath = "go.uber.org/zap";
    goPackageAliases = [
      "github.com/uber-go/zap"
    ];
    propagatedBuildInputs = [
      atomic
      multierr
    ];
  };

  zappy = buildFromGitHub {
    version = 1;
    date = "2016-07-23";
    rev = "2533cb5b45cc6c07421468ce262899ddc9d53fb7";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1fn4kqiggz6b5srkqhn37nwsi381x6hx3n83cbg0fxcb7zb3b6xl";
    buildInputs = [
      mathutil
    ];
    extraSrcs = [
      {
        inherit (internal)
          goPackagePath
          src;
      }
    ];
  };
}; in self
