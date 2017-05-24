/* This file defines the composition for Go packages. */

{ stdenv
, buildGoPackage
, fetchFromBitbucket
, fetchFromGitHub
, fetchTritonPatch
, fetchzip
, go
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
    { rev
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
    }));

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    version = 3;
    rev = "a2f4131514e563cedfdb6e7d267df9ad48591e93";
    owner = "golang";
    repo = "appengine";
    sha256 = "1wlhi1blkjwkk84ka8vnaxsa2x5rc0mavc5m6ljln5xn1cmxknzv";
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
    date = "2017-05-22";
  };

  crypto = buildFromGitHub {
    version = 3;
    rev = "7e9105388ebff089b3f99f0ef676ea55a6da3a7e";
    date = "2017-05-23";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "1m4j17lqi4898bipw9s8kvacc46cr4gkh6lvl9d18k2whq09m7fg";
    goPackagePath = "golang.org/x/crypto";
    buildInputs = [
      net_crypto_lib
      sys
    ];
  };

  debug = buildFromGitHub {
    version = 3;
    rev = "e48e17184ecf6cd503223592fb27874c510e44f7";
    date = "2017-05-05";
    owner  = "golang";
    repo   = "debug";
    sha256 = "1084b2l6hi0hjn7rgmlah96xz9a3gl3804vj93byvfg02y4aaxhl";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
  };

  geo = buildFromGitHub {
    version = 3;
    rev = "5747e9816367bd031622778e3e538f9737814005";
    owner = "golang";
    repo = "geo";
    sha256 = "1bhyc4xs3drl02l2cdcvfacpz18bxwd1y1jd3j6ww41c15zbzgkz";
    date = "2017-04-30";
  };

  glog = buildFromGitHub {
    version = 1;
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-25";
    owner  = "golang";
    repo   = "glog";
    sha256 = "0wj30z2r6w1zdbsi8d14cx103x13jszlqkvdhhanpglqr22mxpy0";
  };

  net = buildFromGitHub {
    version = 3;
    rev = "5b58a9c3e1690d33a592e5b791638e25eb9b3f70";
    date = "2017-05-24";
    owner  = "golang";
    repo   = "net";
    sha256 = "1jmqvy8rr9z3ga14j4pwwgw3ji7hb70ywgf4r8kab3hmbm22n2ia";
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
    rev = "f047394b6d14284165300fd82dad67edb3a4d7f6";
    date = "2017-05-17";
    owner = "golang";
    repo = "oauth2";
    sha256 = "0gfj8hjkjlnnizcr758010jhzaqp3g78q4i7ld14qxgwarf41550";
    goPackagePath = "golang.org/x/oauth2";
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };


  protobuf = buildFromGitHub {
    version = 3;
    rev = "7a211bcf3bce0e3f1d74f9894916e6f116ae83b4";
    date = "2017-05-23";
    owner = "golang";
    repo = "protobuf";
    sha256 = "0gyqjj4m7b4z8daldbgcm5x8817avngwzmcvrw2hziafpw33lmxy";
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
    rev = "a55a76086885b80f79961eacb876ebd8caf3868d";
    date = "2017-05-24";
    owner  = "golang";
    repo   = "sys";
    sha256 = "1kzqf6bcvhfmyrqh3p4r04i51wkss8rz4nlxaqsg1wiz5j4k1b6w";
    goPackagePath = "golang.org/x/sys";
  };

  text = buildFromGitHub {
    version = 3;
    rev = "19e51611da83d6be54ddafce4a4af510cb3e9ea4";
    date = "2017-05-12";
    owner = "golang";
    repo = "text";
    sha256 = "0w35c7a4pmm8d7220q3bkll77yxqlcv9d9n4yll019gxpwxdgzj3";
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
    rev = "bf4b54dc687c73b6ef63de8b8abf0ad3951e3edc";
    date = "2017-05-15";
    owner = "golang";
    repo = "tools";
    sha256 = "0g453jhb4bzx4hfb84rxnk0r36a1b9k9va9zzhdsvd922yvn4wfl";
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
      crypto
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
    version = 2;
    owner = "eknkc";
    repo = "amber";
    rev = "f0d8fdb67f9f4a2c0d02fb6ce4830b8b6754de10";
    date = "2017-04-15";
    sha256 = "1ryrllxs3zyxla31c6wij3pajgaj5jhk0mi2i51gyfkx1smp6cxc";
  };

  amqp = buildFromGitHub {
    version = 3;
    owner = "streadway";
    repo = "amqp";
    rev = "dfe15e36048539f4cda41f240b27a5ca25b9cd46";
    date = "2017-05-21";
    sha256 = "1l9npvqs1g7wz5bmic4asii0qllk569s3yhk5pxn739c90w2gfx8";
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
    rev = "v1.8.29";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "0fzk5djypj19630jylhlp50ybq0xjk0bpxvfiqgkj4886kv41p8s";
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
    date = "2017-05-19";
    rev = "26132835cbefa2669a306b777f34b929b56aa0a2";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "17mirakbjaxxw91gl818c0sw626nll60n1rqsskh55f1nfjldybd";
    excludedPackages = "\\(Gododir\\|storageimportexport\\)";
    buildInputs = [
      crypto
      decimal
      satori_uuid
    ];
    propagatedBuildInputs = [
      go-autorest
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

  barcode = buildFromGitHub {
    version = 2;
    owner = "boombuler";
    repo = "barcode";
    rev = "059b33dac2e9f716cf906bc5071ebb42e607228f";
    date = "2017-04-17";
    sha256 = "0rlbykck5zq9rcp2p9k20zqm89hx5mqcv73mci96hyz1z31abqsc";
  };

  bigfft = buildFromGitHub {
    version = 1;
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
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
    date = "2017-05-21";
    rev = "1513c901915731e941815f60ede6a9c21c69a550";
    owner = "go-macaron";
    repo = "binding";
    sha256 = "1l193ynh23qy2vz5d3l2qz6bj5g1s2w8w140zkm3vb3qlfcwcwwv";
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
    rev = "0ba0f2b6ed7c475a92e4df8641825cb7a11d1fa3";
    sha256 = "12vs9gagapd7jn9j19xljhq5k9bixkq62n8a8yrilksfgasn50x2";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    date = "2017-05-09";
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
    version = 1;
    rev = "v1.3.0";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "1kjbih12cs9x380d5fb0qrx6n63pkfb2j9hnqrr95gz2215pqczp";
    buildInputs = [
      sys
    ];
  };

  btcd = buildFromGitHub {
    version = 3;
    owner = "btcsuite";
    repo = "btcd";
    date = "2017-05-21";
    rev = "f8673776ab781c033b57ac2147fc4a9e6837ccd2";
    sha256 = "1c4qd5npyqmci1h77pbl92z94cfpcafgixiiv12lnpc0ywfmriha";
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
    version = 2;
    owner = "pquerna";
    repo = "cachecontrol";
    rev = "9299cc36e57c32f83e47ffb3c25d8a3dec10ea0b";
    date = "2017-03-29";
    sha256 = "1mjnxp0k3sr503smgp0bbrfv4x0dghimwyldw5j6f2lihy4bmj04";
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

  certificate-transparency = buildFromGitHub {
    version = 2;
    owner = "google";
    repo = "certificate-transparency";
    rev = "173728300b695a5336f65f4dfb6645ad1b1665e2";
    date = "2017-02-24";
    sha256 = "73627100e0e5874e268903118a4a7852ece1bcb78a18cfc99136cacd850deaa5";
    propagatedBuildInputs = [
      go-sqlite3
      net
      ratelimit
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
    version = 2;
    date = "2016-11-21";
    rev = "7d649b46cdc2cd2ed102d350688a75a4fd7778c6";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "0hp4s4zvkwnd3q6s06mhwxi8hhdhcpsp2911qkrq4m8r670xhzc1";
  };

  cli_minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "cli";
    rev = "v1.3.0";
    sha256 = "08z1g5g3f07inpgyb93ip037f4y1cnhsm2wvg63qnnnry9chwy36";
    buildInputs = [
      elastic_v5
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
    date = "2017-05-24";
    rev = "61c0b9f78d30a87e63e78971d34947761e547150";
    owner = "docker";
    repo = "cli";
    sha256 = "1a0m9lhdnsswkll27i63yrgbq2wm974y5w6g9m36qzrsny0smrsx";
    subPackages = [
      "cli/config/configfile"
    ];
    buildInputs = [
      errors
      moby_for_go-dockerclient
    ];
  };

  mitchellh_cli = buildFromGitHub {
    version = 3;
    date = "2017-05-23";
    rev = "b481eac70eea3ad671b7c360a013f89bb759b252";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "0cgfrfvgg783jc6qgm05wp2vcrpajv5924mjmzhgl6lvnf8xaq2j";
    propagatedBuildInputs = [
      crypto
      go-isatty
      go-radix
      speakeasy
    ];
  };

  urfave_cli = buildFromGitHub {
    version = 2;
    rev = "v1.19.1";
    owner = "urfave";
    repo = "cli";
    sha256 = "0083s7jjxcgkssh5kpr34f5razf1x04f6n1kk9mrdsk1s1xw6h1k";
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
    rev = "ca57f0f5dba473a8a58765d16d7e811fb8027add";
    date = "2017-05-20";
    sha256 = "13cky4drkp0vvkbkq2fzwkg98sxgnac69fp95vxm32k5xp7afvgi";
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
    version = 2;
    rev = "ddeb643de91b4ee0d9d87172c931a4ea3d81d49a";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "0r26l715451slfx62f7m92w7c5dqcxmz1adzx2p84w2y77bphy71";
    date = "2017-02-08";
  };

  com = buildFromGitHub {
    version = 2;
    rev = "0db4a625e949e956314d7d1adea9bf82384cc10c";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "0flgww88p314wh3nikmmqmrnx2p7nq523cx40dsj2rh3kyxchy6i";
    date = "2017-02-13";
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
    rev = "v0.8.3";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "1azd6mri0v0h69xj43061zb918cmgm2lfwkncc0bgrika79m342d";

    buildInputs = [
      armon_go-metrics
      aws-sdk-go
      circbuf
      columnize
      copystructure
      dns
      errors
      go-bindata-assetfs
      go-checkpoint
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
    version = 2;
    rev = "6e4498b7b673f45b190f2fef31d79935385e87e3";
    owner = "bwester";
    repo = "consulfs";
    sha256 = "16n8g6vgaxbykxnal7vrnmj77n984ip4p9kcxg1akqdxz77r92dd";
    date = "2017-01-20";
    buildInputs = [
      consul_api
      fuse
      logrus
      net
    ];
  };

  consul-template = buildFromGitHub {
    version = 3;
    rev = "v0.18.3";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "0c9bi0k1bcw02d2xdwx1wgs1fy9czdlkxspcdxz89cicyyg4mb7p";

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
    version = 2;
    date = "2017-01-15";
    rev = "f81071c9d77b7931f78c90b416a074ecdc50e959";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "0d4bjp8dhzxjgwsxrjcysyhjwjxifpbq1d5p6j6vq6kyjncslbli";
    propagatedBuildInputs = [ reflectwalk ];
  };

  core = buildFromGitHub {
    version = 3;
    rev = "6c9f9bf3130d143937e4adcef1cf1bb9f6899260";
    owner = "go-xorm";
    repo = "core";
    sha256 = "0bjdnxpick0wk98mmcw98bvdhd1is8w305y27bbb7br20inj0izr";
    date = "2017-05-03";
  };

  cors = buildFromGitHub {
    version = 2;
    owner = "rs";
    repo = "cors";
    date = "2017-04-20";
    rev = "2d7dd2a10331137ae3f931ba08c21fd00cbf208d";
    sha256 = "0l9fbh3sf53gfq79381icch8aywgsh4m4sml23hx1vpalqjgwbii";
    propagatedBuildInputs = [
      net
      xhandler
    ];
  };

  cpuid = buildFromGitHub {
    version = 1;
    rev = "v1.0";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "1bwp3mx8dik8ib8smf5pwbnp6h8p2ai4ihqijncd0f981r31c6ms";
    excludedPackages = "testdata";
  };

  crc32 = buildFromGitHub {
    version = 2;
    rev = "v1.1";
    owner  = "klauspost";
    repo   = "crc32";
    sha256 = "0kzb3yhk6s0919b5w0xy99fwv0xw02k79iw8issy07mx6an9dh31";
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
    version = 1;
    owner = "xordataexchange";
    repo = "crypt";
    rev = "749e360c8f236773f28fc6d3ddfce4a470795227";
    date = "2015-05-23";
    sha256 = "0zc00mpvqv7n1pz6fn6570wf9j8dc5d2m49yrqqygs52r2iarpx5";
    propagatedBuildInputs = [
      consul_api
      crypto
      go-etcd
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
    rev = "8a466719ecfaf26ae3d712084f3da9bfcae0fdd2";
    owner = "godbus";
    repo = "dbus";
    sha256 = "0y6czl1qgpc4rafn39r8vpsq1qmb8l35i9cb8afxywrybp79zsr0";
    date = "2017-05-08";
  };

  decimal = buildFromGitHub {
    version = 3;
    rev = "16a941821474ee3986fdbeab535a68a8aa5a85d2";
    owner  = "shopspring";
    repo   = "decimal";
    sha256 = "18678cx1mg9gvqjzki47zh9z3fql3fl3v31xyrk7pwdc9jlmcij1";
    date = "2017-05-17";
  };

  distribution = buildFromGitHub {
    version = 3;
    rev = "a1576d6e2165de28e0a5a0530f8e2e5c151b1ae3";
    owner = "docker";
    repo = "distribution";
    sha256 = "1gg3vdipblpii32d1plazw4m38zgazy8z3yv08rc65883m80gvkq";
    meta.useUnstable = true;
    date = "2017-05-24";
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
    rev = "193f91db0b8cd713863aeab710f35381472b2e8e";
    date = "2017-05-24";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0ivm9djiqydzaahxpds81sz7dfgy8cymkgx5d63g2ggq0y3qpikh";
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
    version = 2;
    rev = "68650ee11e182e30773781d391c66a0c80ccf9f2";
    owner = "decker502";
    repo = "dnspod-go";
    sha256 = "0iinhizgg6882nrbbvwhyw10g8p50gc45z9ycj1dr09rhpiw2k30";
    date = "2017-01-26";
  };

  docopt-go = buildFromGitHub {
    version = 1;
    rev = "0.6.2";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "11cxmpapg7l8f4ar233f3ybvsir3ivmmbg1d4dbnqsr1hzv48xrf";
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

  dsync = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "dsync";
    date = "2017-04-19";
    rev = "535db94aebce49cacce4de9c6f5f5821601281cd";
    sha256 = "0f3lc7yszyl3yv9rq7bsyda2yfp56xydvh834qrpplf998973yii";
  };

  easyjson = buildFromGitHub {
    version = 3;
    owner = "mailru";
    repo = "easyjson";
    rev = "dffba8d13bbd998df17d8557570cdea0624b9d1d";
    date = "2017-05-15";
    sha256 = "1h53yx5ydskdmix5k8yabhr4yh2aiwrwwd4s0mz96dnx8gii83fp";
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
    rev = "v3.0.68";
    sha256 = "1rasiq7xw87n25cyjsmbq5r5l0a4sl6a4lcbmkd7zs9vib951qgb";
    goPackagePath = "gopkg.in/olivere/elastic.v3";
    propagatedBuildInputs = [
      net
    ];
  };

  elastic_v5 = buildFromGitHub {
    version = 3;
    owner = "olivere";
    repo = "elastic";
    rev = "v5.0.38";
    sha256 = "1yl44m8y2y44whnmggqsb96zp2bb6yjymxg508fvvyndlrwwqasi";
    goPackagePath = "gopkg.in/olivere/elastic.v5";
    propagatedBuildInputs = [
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
    rev = "v3.1.8";
    sha256 = "0r2mh9rl32x5q8jq8x8vx6iq4c3j6fscx3rvk0jbrzl5myfx9jy5";
    buildInputs = [
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
      grpc
      grpc-gateway
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

  etcd_client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256 version meta;
    subPackages = [
      "client"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
      "version"
    ];
    buildInputs = [
      go-systemd
      net
    ];
    propagatedBuildInputs = [
      go-semver
      pkg
      ugorji_go
    ];
  };

  etcd_for_vault = buildFromGitHub {
    inherit (etcd) rev owner repo sha256 version meta;
    subPackages = [
      "auth/authpb"
      "client"
      "clientv3"
      "clientv3/concurrency"
      "etcdserver/api/v3rpc/rpctypes"
      "etcdserver/etcdserverpb"
      "mvcc/mvccpb"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
      "version"
    ];
    propagatedBuildInputs = [
      go-grpc-prometheus
      go-semver
      grpc
      grpc-gateway
      net
      pkg
      protobuf
      ugorji_go
      yaml
    ];
    patches = [
      (fetchTritonPatch {
        rev = "4b06ab3e49c8267ba5fa34fd680264fa8c385e3c";
        file = "e/etcd/get-version.patch";
        sha256 = "1de1c765d53972da683985751dd9c5a832f16518cf53a9c6c9c2a5f84aa761fb";
      })
    ];
  };

  ewma = buildFromGitHub {
    version = 2;
    owner = "VividCortex";
    repo = "ewma";
    rev = "c595cd886c223c6c28fc9ae2727a61b5e4693d85";
    date = "2016-08-22";
    sha256 = "0367b039e90b5e08abd501874aeab77ba1c597f7395d5e3b2762642caf653ab9";
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
    version = 2;
    date = "2017-02-23";
    rev = "3836a321743b3e6c4c4585da402fd2390b358c86";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "17sg1ydkr84j3sqkbd7ij06awdcmla5vj0br473mvichkck37i30";
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
    version = 2;
    date = "2016-01-28";
    rev = "98c11a7a6ec829d672b03833c3d69a7fae1ca972";
    owner  = "philhofer";
    repo   = "fwd";
    sha256 = "15wamyn4xfxvdnf6d2figrl8my1lm00n49m6l3qxdxcdkfa69qnv";
  };

  gabs = buildFromGitHub {
    version = 2;
    owner = "Jeffail";
    repo = "gabs";
    rev = "1.0";
    sha256 = "1pbsgk0pmhzi8crds5ys8nsrxyra6q6w9rmv6i09zqyf7icn9wwa";
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
    version = 2;
    date = "2017-03-21";
    rev = "9af46dd5a1713e8b5cd71106287eba3cefdde50b";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "09j0pix0wfl24k9lzp53nv2ph7akz39g2qdbvpkkpw49yf6fcrvg";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
  };

  genproto = buildFromGitHub {
    version = 3;
    date = "2017-05-23";
    rev = "d80a6e20e776b0b17a324d0ba1ab50a39c8e8944";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "1gaxh822c10vvs4sqsd3clhxpnk1xcva99kvgxj6p62nic17f2sz";
    propagatedBuildInputs = [
      grpc
      net
      protobuf
    ];
  };

  genproto_protobuf = buildFromGitHub {
    inherit (genproto) version date rev owner repo goPackagePath sha256;
    subPackages = [
      "protobuf"
    ];
    buildInputs = [
      protobuf_genproto
    ];
  };

  genproto_for_grpc = buildFromGitHub {
    inherit (genproto) version date rev owner repo goPackagePath sha256;
    subPackages = [
      "googleapis/rpc/status"
    ];
    buildInputs = [
      protobuf
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
    version = 2;
    rev = "v1.3.1";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "1ssa4lm68zfy9lim4xw294fvsinyfrnjvdj28sxb2hah9dw557nk";
    buildInputs = [
      sys
    ];
  };

  gitmap = buildFromGitHub {
    version = 2;
    rev = "dcb907b39a0690430d435eb8f63cd8811961231f";
    date = "2017-02-17";
    owner = "bep";
    repo = "gitmap";
    sha256 = "1zykf519xplb23lj0rjggpgbmd375l0zhzx29q4vxrsppyjsqzkk";
  };

  gjson = buildFromGitHub {
    version = 3;
    owner = "tidwall";
    repo = "gjson";
    date = "2017-05-11";
    rev = "0623bd8fbdbf97cc62b98d15108832851a658e59";
    sha256 = "0ghn9rj5wgjjg1xkbll80al9jmwmx1gq94bkgbj9xiiv7xqg27xb";
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
    version = 2;
    date = "2017-03-12";
    rev = "708a42d246822952f38190a8d8c4e6b16a0e600c";
    owner = "ugorji";
    repo = "go";
    sha256 = "0jx44bnpx3wy6ka3pidsfjp0n0ns1spcp7wy3ixvcfpixz3pfl46";
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
    version = 2;
    owner = "Azure";
    repo = "go-ansiterm";
    rev = "fa152c58bc15761d0200cb75fe958b89a9d4888e";
    date = "2016-06-22";
    sha256 = "1iwkrl0vxp08hxjw6lvgl6b11ciky3r6fbxwidbaamp08naaglzp";
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
    date = "2017-05-05";
    rev = "16ace784e4b16df1d51c3435223b1d602cd43bfa";
    owner = "camlistore";
    repo = "go4";
    sha256 = "1229mrzs8m4bwsh1npx9mq4jyci8vr44wpjf4b6a5jj518q89mfx";
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
    version = 2;
    rev = "e7cb7fa329f456b3855136a2642b197bad7366ba";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "0k8nbsg4h9b8srd2ykkilf73m19b8lm6ib2cx98n5s6m0af4m7y7";
    date = "2016-09-28";
  };

  gocql = buildFromGitHub {
    version = 3;
    rev = "00a4bbccd77eaa1e28dd06bbc527b4b4a0c53728";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "1hilhsibph2ih2b6240ihdgx9g9aavgdhlbdb2c478cz41w391cw";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2017-05-22";
  };

  gofuzz = buildFromGitHub {
    version = 2;
    rev = "44d81051d367757e1c7c6a5a86423ece9afcf63c";
    owner  = "google";
    repo   = "gofuzz";
    sha256 = "0kj873dl0c5bav3lacz4qijxvkni61b8w5zwjshbr95xymk33zgp";
    date = "2016-11-22";
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
    rev = "a55c211c418162597a32c74c7230f81adb5ad616";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "1hdfi2vh45bqa5ph6sjyhri4p0k7655y3y8h2mkl0bj8cpdbmxg4";
    date = "2017-04-30";
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
    rev = "1f30cbc110d3f6a525188ae7d87b84fa5b3751a5";
    date = "2017-05-19";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "1m49hkvcpm3m8zf0s1cf43jlzw9da3d3ji4c6935lzfk46v0ia6d";
    propagatedBuildInputs = [
      goutils_logging
    ];
  };

  gopacket = buildFromGitHub {
    version = 3;
    rev = "f10e8ef82a38b32acce3de1d6cec5453a2a28c74";
    owner = "google";
    repo = "gopacket";
    sha256 = "081zzn68v1l1kw6krh4rchk0jlxxvgcqn7wgziqbhv25yjg7qsf4";
    buildInputs = [
      pkgs.libpcap
      pkgs.pf-ring
    ];
    propagatedBuildInputs = [
      net
      sys
    ];
    date = "2017-05-23";
  };

  google-cloud-go = buildFromGitHub {
    version = 3;
    date = "2017-05-24";
    rev = "c657c56d8141b4cc4f30e9a68537cd4a8cf5b278";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "0mhhgkzk1km5sxikbvly37yvwa3kqm0pps0cgj012bi2937hs0dl";
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
      google-api-go-client
      grpc
      net
      oauth2
      protobuf
      sync
      text
      time
    ];
    postPatch = ''
      sed -i 's,bundler.Close,bundler.Stop,g' logging/logging.go
    '';
    excludedPackages = "\\(oauth2\\|readme\\)";
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
    version = 2;
    rev = "bc6c333206f446a53cac4db5d2e6a4316139d737";
    date = "2017-03-17";
    owner = "buger";
    repo = "goterm";
    sha256 = "0awypcapx6n1csx2kchbjsd667vb4l6s433ndvnz1wafrfw4pzfz";
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
    version = 2;
    rev = "82b8055850965344f7d89d8a0abe364ac09dfa5e";
    date = "2017-04-21";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "1l7rszrqiv31431fnmc2vcbkiv2vpkqwfgf4g5nchacpj98x8qsb";
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
    version = 2;
    rev = "8c81ea47d4c41a385645e133e15510fc6a2a74b4";
    date = "2017-04-09";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "08yqjwp6652f9kc7h69xgwzllw501m6s7brydfy871rfgb00nzhf";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "0j00hpga37272rd4ncw9l0v6skrwmxy7srqmdadndwy4hw5pdf4a";
    propagatedBuildInputs = [
      protobuf
      yaml_v2
    ];
  };

  google-api-go-client = buildGoPackage rec {
    name = nameFunc {
      inherit
        goPackagePath
        rev;
      date = "2017-05-19";
    };
    rev = "d9d64fe74969b80fb4a435ae9280c9ff061a6097";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 3;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "1yqvdpk30xvcxr8x93rff9zqfpcqakdspmflp29q1d1qq9qn6g6b";
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
    rev = "v2.17.04";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "1cr757wsqfn4yp9l9s3ldxb2p4ycak21zqlgvqvn8hv9nc88242k";
    buildInputs = [
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
    rev = "948702997351133e1cc5a1b5842313ca46deeb0d";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "0zv6mri1g6dv8vry5mgm4qbmxrcpgzd51ryigwfjpbzfmfwjck1s";
    date = "2017-05-16";
  };

  go-autorest = buildFromGitHub {
    version = 3;
    rev = "v8.0.0";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "1xp48h6r98x5h1f7jmg54wjgk80g4aag1icfc9mh19l467d56sqy";
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
    version = 2;
    rev = "7ac151875ffb48b9f3ccce9ea20f020b0c1596c8";
    owner = "patrickmn";
    repo = "go-cache";
    sha256 = "0cxfikqd2wn1q004zlcky4kjrm5kkgs3hcj8xh32y7xqysj6pnx2";
    date = "2017-04-18";
  };
  go-checkpoint = buildFromGitHub {
    version = 1;
    date = "2016-08-16";
    rev = "f8cfd20c53506d1eb3a55c2c43b84d009fab39bd";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "066rs0gbflz5jbfpvklc3vg5zs7l1fdfjrfy21y4c4j5vkm49gz5";
    buildInputs = [
      go-cleanhttp
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
    version = 2;
    rev = "v0.0.7";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "0r7qqrdpy19whvkifcpc6w53am83rq05vmax1ajaw2ywl0gwvvlq";
    buildInputs = [
      go-isatty
    ];
  };

  go-connections = buildFromGitHub {
    version = 2;
    rev = "e15c02316c12de00874640cd76311849de2aeed5";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "154a8z0jcqqqgnn1x08q1yffb09hz90qvpqs5h45676anb7cb8a8";
    propagatedBuildInputs = [
      errors
      go-winio
      logrus
      net
      runc
    ];
    date = "2017-03-31";
  };

  go-couchbase = buildFromGitHub {
    version = 3;
    rev = "98e48116286caa5c3ba06d9bb197f94498c97e89";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "063wqlyqvdnwv6li1ncrx55mqys5lki61nzqlbgs6fjjf31nkl1a";
    date = "2017-05-19";
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
    rev = "b5f4c79208fa609f364833f8c356535100d602ad";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "1r19r2jm6wpm1xfsh3q867jmf5wn6mgb0n156zn996aarhfg8p87";
    date = "2017-05-22";
    propagatedBuildInputs = [
      ed25519
    ];
  };

  go-deadlock = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "0d7kl9fw4d5mpn1ivd2hicnxp3fxp8yhmd287nz39appgl0gwkf8";
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
    rev = "eaa60544f31ccf3b0653b1a118b76d33418ff41b";
    owner  = "opencontainers";
    repo   = "go-digest";
    sha256 = "1wp08dm8pqx8lnw2ab4vlvgmm0as4jm0rppjpaxivsc6k7h7z0s5";
    date = "2017-05-10";
    goPackageAliases = [
      "github.com/docker/distribution/digest"
    ];
  };

  go-dockerclient = buildFromGitHub {
    version = 3;
    date = "2017-05-22";
    rev = "c933ed18bef34ec2955de03de8ef9a3bb996e3df";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "1c3fqrl9zy221rydw7dbyy0c4mgq66xhm6l46xr48mj2rn1ap33f";
    propagatedBuildInputs = [
      go-cleanhttp
      go-units
      go-winio
      moby_for_go-dockerclient
      mux
      net
    ];
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
    date = "2017-05-24";
    rev = "344f25fb3ec26818c673a5b68b21b527759d7499";
    owner  = "ethereum";
    repo   = "go-ethereum";
    sha256 = "1l44gbpkcr8zclk0kw9szpyjzr96gy4w4d3ya9v5h0fy00dvlkaf";
    subPackages = [
      "crypto/sha3"
    ];
  };

  go-events = buildFromGitHub {
    version = 2;
    owner = "docker";
    repo = "go-events";
    rev = "aa2e3b613fbbfdddbe055a7b9e3ce271cfd83eca";
    date = "2016-09-06";
    sha256 = "9a343e28d608971d2baec59bc62637a697f1b45c44e61b782b81c212b5ef507b";
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
    version = 2;
    rev = "v1.2.0";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0cv6vf1vwysblni8lzy0lmyi7fkgqh8jsz4rwn6rvds9n1481nf5";
  };

  go-floodsub = buildFromGitHub {
    version = 2;
    rev = "54f07fdf3c3de6526b986cf6260437b7cd8187f9";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "1jhypw45jm9vg5hy6ql1jn1gagbvyxq59c8aircqjdka2a5mz75l";
    date = "2017-03-25";
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
    rev = "90b6568eac830f62a08e8f1f46375daa63e57015";
    date = "2017-05-04";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "1kp246k8pva2q39rbm1qb63n38aapsn2s7556c2rg4gsa7gg1nzv";
    propagatedBuildInputs = [
      aws-sdk-go
      go-homedir
      go-netrc
      go-testing-interface
      go-version
    ];
  };

  go-git-ignore = buildFromGitHub {
    version = 2;
    rev = "87c28ffedb6cb7ff29ae89e0440e9ddee0d95a9e";
    date = "2016-12-22";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "1c8nsr9c2lnfc7d57wdmszkmk29jd3f82mnc1334dnlz5qls8rbc";
  };

  go-github = buildFromGitHub {
    version = 3;
    date = "2017-05-19";
    rev = "ebfec748347a9af6793c723f8859afcd906860fb";
    owner = "google";
    repo = "go-github";
    sha256 = "0abfp2s24yw6lghf39iv9mzf2gvac1l2n70wryhsvb4s22pr3y7r";
    buildInputs = [
      appengine
      oauth2
    ];
    propagatedBuildInputs = [
      go-querystring
    ];
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
    version = 2;
    rev = "2500245aa6110c562d17020fb31a2c133d737799";
    owner = "grpc-ecosystem";
    repo = "go-grpc-prometheus";
    sha256 = "143jhgq0jx8h3a6l58r1h213b52vjgh52avdpgrmxw0r4761d3i4";
    propagatedBuildInputs = [
      grpc
      net
      prometheus_client_golang
    ];
    date = "2017-03-30";
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
    date = "2017-05-16";
    rev = "a7ee80e4c344cab722502d3f074c5b7245d0bbe7";
    sha256 = "1p6i88h83rrg354lcng5mjsb2rgfxkkxdjhjnls0rv5jdrhxwcpr";
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
    version = 2;
    date = "2017-02-13";
    rev = "30664b879c9a771d8d50b137ab80ee0748cb2fcc";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1akj47vd7p8ysa4apiqhp7s110ms40y10sg0k84yy3n323yyx4mj";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ipfs-api = buildFromGitHub {
    version = 2;
    rev = "e577e1054cd11374e1f31c4082ce6952916271c3";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "0b9qw6jx5p303kxd34di6kz4gbvyh4yvgcyc5g3z4vvi17vymlrp";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-floodsub
      go-libp2p-peer
      go-multiaddr
      go-multiaddr-net
      go-multipart-files
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2017-04-16";
  };

  go-ipfs-util = buildFromGitHub {
    version = 2;
    rev = "f25fcc891281327394bb48000ef0970d11baff2b";
    owner  = "ipfs";
    repo   = "go-ipfs-util";
    sha256 = "0bcfrsii05cgqnx94hcy07h71l00fr0vchyqirj9096yycgyzyz4";
    date = "2017-03-28";
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
    rev = "v2.1.1";
    owner = "square";
    repo = "go-jose";
    sha256 = "0ldk59z9wdsxjw66qpvk6sw6a87ydff2hz2wbm7mir9g1izw879r";
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

  go-libp2p-crypto = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-crypto";
    date = "2017-05-11";
    rev = "b75b5790f5d12e8f283c85f5cfdd40b14693b815";
    sha256 = "07l0im4xbqb16yzdkmnfwv0jjgv48l5flwlr6a30rxkv6nbg6gc5";
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
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-host";
    date = "2017-03-24";
    rev = "f8f42d4bd009c695860e920525e5df659924ba00";
    sha256 = "167lpqjfxzpj2c698mmlhprh92iykvzv86mwadzqz32almd7clm4";
    propagatedBuildInputs = [
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
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-interface-conn";
    date = "2017-03-24";
    rev = "95afdbf0c900237f3b9104f1f7cfd3d56175a241";
    sha256 = "0yxq323kzh2skn1z416g4zb7hmlk5vm9p9l91b8qd99sv7d9jcb9";
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
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-net";
    date = "2017-04-01";
    rev = "dcad67edbe37dbedcfdb84712ac0fa4c589a5dd3";
    sha256 = "06gz8qcdi4ny9gw7rbv100bq56bqyh9hx05gf8vf2q7cl5xq1w5v";
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
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-peer";
    date = "2017-03-24";
    rev = "c497a0cf30b2c123a8b46641aa1a420f381581a4";
    sha256 = "02frzv7vld93yidpkkpcj4ql9mnpzl7594mw9681apay8fr4bri1";
    propagatedBuildInputs = [
      go-base58
      go-ipfs-util
      go-libp2p-crypto
      go-log
      go-multihash
    ];
  };

  go-libp2p-peerstore = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-peerstore";
    date = "2017-04-28";
    rev = "744a149e48eb42e032540507c8545d12cc3b7f6f";
    sha256 = "1vaz08fw0pb9rhc0r48bq7j57yi0qag7wr8vpfv5ldd6m7dcjpps";
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
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-transport";
    date = "2017-03-24";
    rev = "5d3cb5861b59c26052a5fe184e45c381ec17e22d";
    sha256 = "1w20p1gbw87q8z4scrc9f49vnjq2nci8gff3wv1aw5xkrn1ci387";
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
    rev = "de2c8bfd65a78752d6a70b4ad99114c6969363b0";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "0n8046hv1h3kj53bh976hw47ylywi0m0hhx21r3icb6wj71pwzfv";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2017-05-04";
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
    version = 2;
    owner = "libp2p";
    repo = "go-maddr-filter";
    date = "2017-03-24";
    rev = "90aacb5ee155f0d6f3fa8b34d775de842606c0b1";
    sha256 = "02dpignagmapwl48smmippzrshrw8jmhpsfrkv44d46fwxm7wvk2";
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-net
    ];
  };

  go-md2man = buildFromGitHub {
    version = 3;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "bcc0a711c5e6bbe72c7cb13d81c7109b45267fd2";
    sha256 = "0b8hm7b61jlr6pi434c0l6x5f3i86k8fh7nc16128422ax9si98g";
    propagatedBuildInputs = [
      blackfriday
    ];
    date = "2017-05-09";
  };

  go-memdb = buildFromGitHub {
    version = 3;
    date = "2017-05-16";
    rev = "e889dc5b880d6619aa3ccc653d802ae172c0904c";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "1amnwghy75qfgpf4jnq4lbjjd3r1wk5i88i8c77yk4d2ayh2zj4i";
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
    version = 2;
    date = "2017-01-14";
    rev = "93f237eba9b0602f3e73710416558854a81d9337";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0f1c24krssll6k90ldf3hzf362r05km8j88riqj5lp6m4yxc4dka";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
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
    version = 2;
    rev = "e3bd523cf238e14637d0e028becc25651098a138";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "025n6h2dsknpp3jban8j6ad4gccy7k1yw0cv7r0dkxabvcxxinps";
    date = "2017-04-23";
    buildInputs = [
      crypto
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 2;
    rev = "33741da7b3f5773a599d4a03c333704fc560ef34";
    date = "2017-03-24";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "0i3cykfdi7mdak64pkk7zv9kfi01xi1ji3lyy4nzjwqwcwgy3kvg";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 2;
    rev = "a7b93d11855f04f56908e1385991eb6a400fcc43";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "0g2q84a3470kpqiyv9jsg77vyrfnbiv78g99b7g68plvgkqb10g3";
    date = "2017-03-28";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
      utp
    ];
  };

  go-multierror = buildFromGitHub {
    version = 2;
    date = "2016-12-16";
    rev = "ed905158d87462226a13fe39ddf685ea65f1c11f";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "1lvmjf3mb1qx295djzddzj8w1j86c0cklkg19kfmzr5cbk257rzc";
    propagatedBuildInputs = [
      errwrap
    ];
  };

  go-multihash = buildFromGitHub {
    version = 3;
    rev = "3c7a8c2d615963114d8be8f70e8c2cf0f5b02544";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "18sm54zljbad1kchfr1p2zdsq20hfprcmgjp5ry6r5d89j3rca49";
    goPackageAliases = [ "github.com/jbenet/go-multihash" ];
    propagatedBuildInputs = [
      crypto
      go-base58
      go-ethereum
      hashland
      murmur3
    ];
    date = "2017-05-21";
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
    date = "2017-05-09";
    rev = "c797a55f1c1001ec3169f1d0fbb4c5523563bec6";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "0w7a9xydv2m4ipwxm1c7zgq03q34fxbpipzw66lyb9017b4rxs22";
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
    rev = "64b3cb9e3a7b6d0c4e4432576c873e492d152666";
    owner = "sstarcher";
    repo = "go-okta";
    sha256 = "19pspqvcanydpbdvx3scsgqxli55b48j66wrygjq5dc3x6m7fmbd";
    date = "2017-04-28";
  };

  go-ole = buildFromGitHub {
    version = 2;
    date = "2017-02-09";
    rev = "de8695c8edbf8236f30d6e1376e20b198a028d42";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "127k5hw9ghsqwqfnxirlzf7zvzgb13g1x41654bg533857j2491p";
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
    version = 2;
    rev = "d2207178e10e4527e8f222fd8707982df8c3af17";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "1kx6n608vwr7njbc59wgbpvwflq1haw7vp6qaa2ymbvjkn1b9ypv";
    date = "2017-01-02";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-plugin = buildFromGitHub {
    version = 3;
    rev = "b7d6477501c13292d71fd3b8e688269e51b028ba";
    date = "2017-05-16";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "0qbjfcf6f37b5a8bgbmf08cqm9rh706dl3fnibw6ji1b0z06928l";
    buildInputs = [
      yamux
    ];
  };

  go-ps = buildFromGitHub {
    version = 2;
    rev = "4fdf99ab29366514c69ccccddab5dc58b8d84062";
    date = "2017-03-09";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "1x70gc6y9licdi6qww1lkwx1wkwwkqylzhkfl0wpnizl8m7vpdmp";
  };

  go-python = buildFromGitHub {
    version = 2;
    owner = "sbinet";
    repo = "go-python";
    date = "2017-03-14";
    rev = "ba7e58341058bdefb92b359870caf2dc0a05cfcf";
    sha256 = "1jkkkg5nrdqz6iv6bzlbxg7gycmq4bjc5mrpw3r3lvzqn73sdga7";
    nativeBuildInputs = [
      pkgs.pkgconfig
    ];
    buildInputs = [
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
    version = 1;
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  go-restful = buildFromGitHub {
    version = 2;
    rev = "ff4f55a206334ef123e4f79bbf348980da81ca46";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "1rj2mklgkx5y5h8qr4jxxxd2h1l2pp78mvf4770iw494af13dbpi";
    date = "2017-04-10";
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
    version = 2;
    rev = "5e3acbb5668c4c3deb4842615c4098eb61fb6b1e";
    owner  = "coreos";
    repo   = "go-semver";
    sha256 = "1msmlbkv0mp25p0x74d1k8l1zrkz1prs9mcxhck77inzckq4fg81";
    date = "2017-02-09";
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
    rev = "2d10d7c10258d11196c0ebf2943509e4afd06cd4";
    owner  = "hashicorp";
    repo   = "go-sockaddr";
    sha256 = "19psd72iwgrr9w9jkwmgifz2kfnnh78vcwkmmspipdaqvh035k1w";
    date = "2017-05-23";
    propagatedBuildInputs = [
      mitchellh_cli
      columnize
      errwrap
      go-wordwrap
    ];
  };

  go-spew = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1a3hlwra1nbd6pl37dqj82i2q6vy36fdab31z4nj59gpgji35zy3";
  };

  go-sqlite3 = buildFromGitHub {
    version = 2;
    rev = "v1.2.0";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0s6s46achp1dczxcp9fw3n71wkhw8y5x5kd8izyllygrbs56h28c";
    excludedPackages = "test";
    buildInputs = [
      goquery
    ];
    propagatedBuildInputs = [
      net
    ];
  };

  go-stun = buildFromGitHub {
    version = 2;
    rev = "04a4eed61c57ecc9903f8983d1d2c17b88d2e9e1";
    owner  = "ccding";
    repo   = "go-stun";
    sha256 = "1sadm5cr2108z25glyvsdkkxf8pr0jis67vyv56bbk01bqpvgkql";
    date = "2017-03-23";
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
    version = 2;
    rev = "1f9909e51b2dab2487c26d64c8f2e7e580e4c9f5";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "0xfagwn3hd3j5x4bzsl0i10jxlf3azjh7s3cxacy9bghj1zzp0g9";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2017-03-24";
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
    rev = "477c2d05a845d8b55912a5a7993b9b24abcc5ef8";
    sha256 = "1g7cg4d43sgd8cdiyjsj22y09lf5r04q3g05p8qq6y914mk9w129";
    date = "2017-04-30";
  };

  go-toml = buildFromGitHub {
    version = 3;
    owner = "pelletier";
    repo = "go-toml";
    rev = "5c26a6ff6fd178719e15decac1c8196da0d7d6d1";
    sha256 = "0xqj8i9c35sqnb0lami9gwjygzqqs4l1zlw3ifr7cqlfsyl3dwq6";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2017-05-16";
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
    rev = "v0.4.2";
    owner  = "Microsoft";
    repo   = "go-winio";
    sha256 = "1m4yx0falil8sgzn3j9pknb692r11npc48d3y08bzfc3kk1grr5a";
    buildInputs = [
      sys
    ];
  };

  go-wordwrap = buildFromGitHub {
    version = 2;
    rev = "ad45545899c7b13c020ea92b2072220eefad42b8";
    owner  = "mitchellh";
    repo   = "go-wordwrap";
    sha256 = "0yj17x3c1mr9l3q4dwvy8y2xgndn833rbzsjf10y48yvr12zqjd0";
    date = "2015-03-14";
  };

  go-zookeeper = buildFromGitHub {
    version = 2;
    rev = "1d7be4effb13d2d908342d349d71a284a7542693";
    date = "2016-10-28";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "15jwlcscvqpj6yfsjmi7735q45zn5pv1h0by3dzggfry6y0h44fs";
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
    rev = "v4.3.1";
    sha256 = "1yz6r4n1i6jv3i64nrm57w3zcd1qy0w0g3pv2vs2a37s2i4xj95m";
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
    date = "2017-05-24";
    rev = "72395c537b06215f76e659735c6c827363913869";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "010mrpvy08pigwmb8dfd86wx41iqj58dm1yc85vx4bj94lnz4zkr";
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
    meta.useUnstable = true;
  };

  grpc_for_gax-go = buildFromGitHub {
    inherit (grpc) version date rev owner repo sha256 goPackagePath goPackageAliases meta;
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
    version = 2;
    rev = "v0.11.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "0pmwyscmbbqxdkpzncffn70d01vb7gb0ikg1gnhzkd8nwbx2kqzz";
    propagatedBuildInputs = [
      go-git-ignore
      go-homedir
      go-multiaddr
      go-multihash
      go-multiaddr-net
      go-os-rename
      json-filter
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
    version = 2;
    rev = "c083961707697e230e779d56b0a3e2ac632139ed";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "09v2x0y63imy6cfjcs0b1p4ljc1y6267v2mg18jd47k3az8wl24q";
    buildInputs = [
      urfave_cli
      fs
      go-homedir
      gx
      stump
    ];
    date = "2017-04-26";
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
    version = 2;
    date = "2017-04-03";
    rev = "22d4470af89e09998fc16b35029df973932df4ae";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "1yb6zq2g3nr3r8c4wp60b9dlfw2rfn422l2x36ym1sikjm5g1gj1";
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
    date = "2017-05-11";
    rev = "9204ce590301a868e3e86938bc12eadd416b211e";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "02xpdf0w3aihd22li3lkzihzxf2vbqgh8j1ci2cipldhyhdisbnv";
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
    date = "2017-05-12";
    rev = "fac2259da677551de1fb92b844c4d020a38d8468";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "1g9rwpljkjhngc3x61nshzhm00mcwiiyv0c29h1wjmpa7j7mf1sp";
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
    owner = "spf13";
    repo = "hugo";
    rev = "v0.21";
    sha256 = "0fay6gxv6libchrhwbb22lfgrm2h8dvazz883gr7a2sah7rhn5x6";
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
      go-toml
      goorgeous
      inflect
      jwalterweatherman
      mapstructure
      mmark
      nitro
      osext
      pflag
      purell
      text
      viper
      websocket
      yaml_v2
    ];
  };

  image-spec = buildFromGitHub {
    version = 3;
    rev = "56b55a17598362bd1bf78c9c307738335a2510eb";
    owner  = "opencontainers";
    repo   = "image-spec";
    sha256 = "1pv62pn2dhxad024pnd076ifgrgh9nak2f90qpfyl1w4fpgjgz8m";
    date = "2017-05-24";
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
    rev = "v1.2.4";
    sha256 = "1xic0sbkpzjs8gxvbm0g1f01nd7cv8sxgxv4dyyhsclg62m1srcm";
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
    rev = "v1.27.2";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "04ax161nzzp76shfpvrwr8qa8cz5rhs01a2x9v13p15r3fznc14s";
  };

  ini_v1 = buildFromGitHub {
    version = 3;
    rev = "v1.27.2";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "1ykb657fmxsxfb5a5xczrg9r27rh5lg63lk5d7virxl72rvpn0zi";
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
    rev = "v0.4.9";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "17d13vays2drcxn7bpzyjx4cxi8fn9q6mcj4nva19xwlgb0z1jz4";
    gxSha256 = "128r9pv0gcrsv2x7msgr180i3ls4sxxhr0a077yhgs1ylldp5h1p";
    nativeBuildInputs = [
      gx-go.bin
    ];
    allowVendoredSources = true;
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
    rev = "6c8dedd55f8a2e41f605de6d5d66e51ed1f299fc";
    sha256 = "0b7dakw71aa1lq21zivnx4q956g0z0wl96wnz9sq2dl3xy0cs576";
    date = "2017-05-08";
  };

  kcp-go = buildFromGitHub {
    version = 2;
    owner = "xtaci";
    repo = "kcp-go";
    rev = "v3.15";
    sha256 = "06b712agm0wfhdnx7n6h7lzpsdqaccmvrwyiwny0gmzjwszrz59w";
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
    version = 2;
    rev = "v2.2.4";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "1bfayjmh2l2paq306hjdy5k3gjjd8amq4r7w5jmh6w8ymlwwv4aq";
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
    version = 2;
    rev = "v2.5.0";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "15mc4hrlfvjpbjr89w4s0267x3s3zkmhjd0qj2ls0bk2q3l48vmg";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [
      asn1-ber
    ];
  };

  ledisdb = buildFromGitHub {
    version = 3;
    rev = "0b1b6de120e1ed3e2b369dec21e250b982b21c31";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "1c0a5q03djv0fiyzkmqpzahbnfw80v2sn7rxzcvspl2d2q5fvw1b";
    date = "2017-05-18";
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
    rev = "aaa8e70aec58a858b6bef0706b367dd5e8d58128";
    owner = "xenolf";
    repo = "lego";
    sha256 = "0qjf2m4dhqz5rf35s0p2dnv48y141l7cqv9mlr4ai8c5gpmqlb8l";
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
    date = "2017-05-05";
  };

  lemma = buildFromGitHub {
    version = 2;
    rev = "cbfbc8381e93147bc50db64509634327d0f6d626";
    owner = "mailgun";
    repo = "lemma";
    sha256 = "1rqg0fw94vavi6a9c0cgc0xg9gy6p25ps2p9bs65flda60cm59ph";
    date = "2016-09-01";
    propagatedBuildInputs = [
      crypto
      metrics
      timetools
      mailgun_ttlmap
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
    version = 2;
    rev = "39bacc234bf1afd0b68573e95b45871f67ba2cd4";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "0sqk1yjya1gbfdy2sr453q07rvhfg3whxm0kj60qv35l68c8sw68";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
    date = "2017-02-16";
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
    version = 2;
    rev = "v0.11.5";
    owner = "Sirupsen";
    repo = "logrus";
    sha256 = "13r9xjrhjfs8kjcbvhy6a53qvqm2iqn48ik3bk1bsfjdbqh326rb";
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
    version = 2;
    rev = "lxd-2.13";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "09xslmmfk3xa86bj61icw40pjlm26f1yrbskn6xvcrzc4sd2laz1";
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
    version = 2;
    date = "2017-03-24";
    rev = "15300f9d3a2d71db61951a8705d5ea8878764837";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "1kz254lswq71qf5107abrq8zz8hybkig5nn1ayygkd1fdfhq7grs";
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
    version = 2;
    date = "2017-03-13";
    rev = "1447ad269d64ca91aa8d7079baa40b6fc8b965e7";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "1v1ff44562dwmijs5pnmsa1ylxnskpm916rfcwqf1padgjxmp6bm";
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
    rev = "6c677e0d116eaf7af58ed2a3c711c96711b7c51e";
    sha256 = "1n5jlavnyp47nlfflkqr0230w2ykjdsy36djsml46mz7nccvbj3z";
    propagatedBuildInputs = [
      cli_minio
      color
      go-colorable
      go-homedir_minio
      go-humanize
      go-version
      minio_pkg
      minio-go
      notify
      pb
      profile
      structs
    ];
    date = "2017-05-22";
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
    version = 2;
    rev = "v0.1.0";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "044mwkcf84qx8xdl5imad59ghjbp5r8qj0330pxcq2j600fwmlxz";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
      go-sockaddr
      seed
    ];
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
    version = 2;
    date = "2017-03-26";
    rev = "d806ba8c21777d504a2090a2ca4913c750dd3a33";
    owner = "imdario";
    repo = "mergo";
    sha256 = "0izq7mjmpp3m9fa7zizg2qggc89slzc9wz5fmgzid5s3sp1wqlzk";
  };

  metrics = buildFromGitHub {
    version = 2;
    date = "2015-01-23";
    rev = "2b3c4565aafdcd40c8069e50de08ac5379787943";
    owner = "mailgun";
    repo = "metrics";
    sha256 = "01nnm2wl2m1p1bj86rj87r1yf5f9fmvxxamd2v88p04958xbj0jk";
    propagatedBuildInputs = [
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
    version = 2;
    rev = "7c28d80e2ada649fc8ab1a37b86d30a2633bd47c";
    owner = "mailgun";
    repo = "minheap";
    sha256 = "06lyppnqhyfq1ksc8c50c2czjp3h1ra38jsm8r5mafxrn6rv7p7w";
    date = "2013-12-07";
  };

  minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.2017-03-16T21-50-32Z";
    sha256 = "09ddcbzh05sv35m7nvabjv4j8n3byr4gfj3iab37712ivpgzx1il";
    buildInputs = [
      amqp
      blake2b-simd
      cli_minio
      color
      cors
      crypto
      dsync
      elastic_v3
      gjson
      go-bindata-assetfs
      go-homedir_minio
      go-humanize
      go-version
      handlers
      jwt-go
      logrus
      mc
      minio-go
      mux
      pb
      profile
      redigo
      reedsolomon
      rpc
      sha256-simd
      skyring-common
      structs
    ];
  };

  # The pkg package from minio, for bootstrapping minio
  minio_pkg = buildFromGitHub {
    inherit (minio) version owner repo rev sha256;
    propagatedBuildInputs = [
      # Propagate minio_pkg_probe from here for consistency
      minio_pkg_probe
      pb
      structs
    ];
    postUnpack = ''
      mv -v "$sourceRoot" "''${sourceRoot}.old"
      mkdir -pv "$sourceRoot"
      mv -v "''${sourceRoot}.old"/pkg "$sourceRoot"/pkg
      rm -rf "''${sourceRoot}.old"
    '';
  };

  # Probe pkg was remove in later releases, but still required by mc
  minio_pkg_probe = buildFromGitHub {
    version = 2;
    inherit (minio) owner repo;
    rev = "RELEASE.2017-03-16T21-50-32Z";
    sha256 = "09ddcbzh05sv35m7nvabjv4j8n3byr4gfj3iab37712ivpgzx1il";
    propagatedBuildInputs = [
      go-humanize
    ];
    postUnpack = ''
      mv -v "$sourceRoot" "''${sourceRoot}.old"
      mkdir -pv "$sourceRoot"/pkg
      mv -v "''${sourceRoot}.old"/pkg/probe "$sourceRoot"/pkg/probe
      rm -rf "''${sourceRoot}.old"
    '';
    meta.autoUpdate = false;
  };

  minio-go = buildFromGitHub {
    version = 3;
    owner = "minio";
    repo = "minio-go";
    rev = "46e4328e64b7c53669b14183610a221c2f06f460";
    sha256 = "09nmxz391vcxbaz19mvzwjl7bcf7fb59h5p4id8djn13wrrx51yz";
    meta.useUnstable = true;
    date = "2017-05-24";
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
    rev = "v1.3.5";
    sha256 = "1my31k9da518ak3ry6nz7rk1lfqwxp54qka85l5vph5mmza1di31";
    propagatedBuildInputs = [
      toml
    ];
  };

  moby = buildFromGitHub {
    version = 3;
    owner = "moby";
    repo = "moby";
    rev = "e4abe7c2ce9bb496f12adbd6e00713e776fd1807";
    date = "2017-05-24";
    sha256 = "0hgf681cw6i3h7h87af1675357nvl3p1c791lav0mnfgsraz71jc";
    goPackageAliases = [
      "github.com/docker/docker"
    ];
    postPatch = ''
      find . -name \*.go -exec sed -i 's,github.com/docker/docker,github.com/moby/moby,g' {} \;
    '';
    meta.useUnstable = true;
  };

  moby_for_nomad = buildFromGitHub {
    inherit (moby) version owner repo rev date sha256 meta postPatch goPackageAliases;
    subPackages = [
      "api/types"
      "api/types/blkiodev"
      "api/types/container"
      "api/types/filters"
      "api/types/mount"
      "api/types/network"
      "api/types/strslice"
      "api/types/swarm"
      "api/types/registry"
      "api/types/versions"
      "opts"
      "pkg/httputils"
      "pkg/ioutils"
      "pkg/jsonlog"
      "pkg/jsonmessage"
      "pkg/longpath"
      "pkg/random"
      "pkg/stringid"
      "pkg/tarsum"
      "pkg/term"
      "pkg/term/windows"
      "registry"
    ];
    propagatedBuildInputs = [
      distribution_for_moby
      errors
      go-ansiterm
      go-connections
      go-units
      gotty
      image-spec
      logrus
      net
      pflag
      sys
    ];
  };

  moby_for_runc = buildFromGitHub {
    inherit (moby) version owner repo rev date sha256 meta postPatch goPackageAliases;
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
  };

  moby_for_go-dockerclient = buildFromGitHub {
    inherit (moby) version owner repo rev date sha256 meta postPatch goPackageAliases;
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
      "api/types/versions"
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
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
      "pkg/system"
      "pkg/term"
      "pkg/term/windows"
    ];
    propagatedBuildInputs = [
      distribution_for_moby
      errors
      go-ansiterm
      go-connections
      go-units
      go-winio
      gotty
      image-spec
      logrus
      net
      runc
      sys
    ];
  };

  mock = buildFromGitHub {
    version = 2;
    owner = "golang";
    repo = "mock";
    rev = "bd3c8e81be01eef76d4b503f5e687d2d1354d2d9";
    date = "2016-01-21";
    sha256 = "5d964bd99a35234ae8a9a0a9ea030665f57ede3459dff10290788475744ba470";
  };

  mongo-tools = buildFromGitHub {
    version = 3;
    rev = "r3.5.7";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "0mgpdgi33wmhwvwc975fy9v0yc14yjh190lklny58075d1ir3kyi";
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
  };

  mousetrap = buildFromGitHub {
    version = 2;
    rev = "76626ae9c91c4f2a10f34cad8ce83ea42c93bb75";
    owner = "inconshreveable";
    repo = "mousetrap";
    sha256 = "1905y88ajawg5x0ia88jba1fsg85yfdjip82m5x1r0ypgjicvk9n";
    date = "2014-10-17";
  };

  mow-cli = buildFromGitHub {
    version = 3;
    rev = "8327d12beb75e6471b7f045588acc318d1147146";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "1sa1jz0khizmqcnsi2yp058n6hb4448y673n75cl1a4a4wjwmqi2";
    date = "2017-04-30";
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
    rev = "v1.0.1";
    owner  = "tinylib";
    repo   = "msgp";
    sha256 = "18jd20j8zsrsdpmx8cdq21vqwiimdch429sv4c63zs8wxqgh3cr2";
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

  murmur3 = buildFromGitHub {
    version = 2;
    rev = "0d12bf811670bf6a1a63828dfbd003eded177fce";
    owner  = "spaolacci";
    repo   = "murmur3";
    sha256 = "1biq3rv8ycnyrma135273bi6pd62866gy84dnv17vqf3pnrcz3bd";
    date = "2015-08-29";
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
    version = 2;
    rev = "v1.3";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "1jy5ak2ka6qi16i99c06b1k6nvf3fbngcj454dzxk1xwrd5y076h";
    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';
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
    rev = "0872fbf3015e21e760f71debd11379a9daf7abcc";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "0qm2k1cm1gwgg9bpddrldw3mv20plr7qmslrksf467w32ivg94ss";
    date = "2017-05-18";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    version = 2;
    rev = "54f0e4339ce73702a0607f49922aaa1e749b418d";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "0rwb0bk1dcz477di5md4jd643d5cpc3yizwqlq6zfwx7yxi0nqp2";
    date = "2017-02-19";
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
    version = 2;
    rev = "v0.5.6";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "1p7qlyqwznyf9y4hgqs4x3qqniy4ibg396hihhd4kqylpaql2gyk";

    nativeBuildInputs = [
      ugorji_go.bin
    ];

    buildInputs = [
      armon_go-metrics
      circbuf
      colorstring
      columnize
      consul-template
      consul_api
      copystructure
      cronexpr
      distribution_for_engine-api
      docker_cli
      go-checkpoint
      go-cleanhttp
      go-dockerclient
      go-getter
      go-humanize
      go-lxc_v2
      go-memdb
      go-multierror
      go-plugin
      go-ps
      go-rootcerts
      go-syslog
      go-version
      gopsutil
      gziphandler
      hashstructure
      hcl
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      moby_for_nomad
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
    version = 2;
    owner = "rjeczalik";
    repo = "notify";
    date = "2017-04-14";
    rev = "660542b98f76c58910002c82e912b71248f4daa0";
    sha256 = "0l67ba34dbpdnj5fvzbqbrvfkamsxqjkwv0ly1z29gb8ldyrxfn4";
    propagatedBuildInputs = [
      sys
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
    version = 2;
    date = "2016-09-22";
    rev = "5be686e264d836e7a01ca7fc7c53acdb8edbe768";
    owner = "10gen";
    repo = "openssl";
    sha256 = "0jlr0y8812ayj5xfpn7m0m1pfm8pf1g43xbw7ngs4zxcs0ip7l9g";
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
    version = 2;
    date = "2017-02-23";
    rev = "9e1935374bc73ffe011187dafed51a412b90fe43";
    owner = "pquerna";
    repo = "otp";
    sha256 = "01i40xfnr5wg7l15vq7xsd8p287apj7r2bnj8jnzq5k3ijzmms97";
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
    date = "2017-05-08";
    rev = "f6ccf2184de4dd34495277e38dc19b6e7fbe0ea2";
    sha256 = "19hp12sfnrir41yn5fcja85blhfncf1x7y4b2cz9zmp34468q5kr";
    propagatedBuildInputs = [
      go-runewidth
    ];
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 3;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.15";
    sha256 = "1fchaz4sqapqc673d9jng3phlczqpxbabhlzlyhdpspndv5dq7j9";
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
    version = 2;
    owner = "sethgrid";
    repo = "pester";
    rev = "4f4c0a67b6496764028e1ab9fd8dfb630282ed2f";
    date = "2017-04-08";
    sha256 = "0xydrln1gmzb9kqf0kq7g62xazsxrnza5w8g0jzppdpf25zjnxwm";
  };

  pfilter = buildFromGitHub {
    version = 2;
    owner = "AudriusButkevicius";
    repo = "pfilter";
    rev = "09b3cfdd04de89f0196caecb0b335d7149a6593a";
    date = "2017-02-09";
    sha256 = "1p57lgdsssvl6s0jsf6ggh20z4rj06scnjr5cilp1jpjgrc87xzs";
  };

  pflag = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "pflag";
    rev = "e57e3eeb33f795204c1ca35f56c44f83227c6e66";
    date = "2017-05-08";
    sha256 = "16r9jwvd3gi2brlgdagcaq5hgiwqx13isp68x2w7r269xhjj8a6q";
  };

  pkcs7 = buildFromGitHub {
    version = 2;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "eb67e7e564b9eae64dc7d95fae0784d6086a5fc4";
    date = "2017-02-08";
    sha256 = "0814z5w0pcsnb64pg356xhxamkl4aa1hdal2w6xhnhcz9xmsaxan";
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

  pq = buildFromGitHub {
    version = 2;
    rev = "2704adc878c21e1329f46f6e56a1c387d788ff94";
    owner  = "lib";
    repo   = "pq";
    sha256 = "1j00p9gzclsnbqn4iv3k06fvpy3jc9iyh2mzsahm880x9njswrnw";
    date = "2017-03-24";
  };

  probing = buildFromGitHub {
    version = 2;
    rev = "07dd2e8dfe18522e9c447ba95f2fe95262f63bb2";
    owner  = "xiang90";
    repo   = "probing";
    sha256 = "140b5bizry0cw2s98dscp5b8zy57h2l5ybkmr7abx9d1c2nrxqnj";
    date = "2016-08-13";
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

  prometheus = buildFromGitHub {
    version = 3;
    rev = "v1.6.3";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "0piwazyxr0wigfrcpg60pn9cwfpgk2szrjk1y776dk3h63mf1hq8";
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
    rev = "42552c195dd3f3089fbf9cf26e139da150af35aa";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "1izxma5dh6qz62bryv7ffn14vqw9q39ac4raj0xgxdn9v3827nvz";
    propagatedBuildInputs = [
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      beorn7_perks
    ];
    date = "2017-05-11";
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
    date = "2017-04-27";
    rev = "13ba4ddd0caa9c28ca7b7bffe1dfa9ed8d5ef207";
    owner = "prometheus";
    repo = "common";
    sha256 = "0m5f06pfd7r28rw1gws5ya1362jx34cpf6p17j1ca79h030nsrks";
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

  prometheus_common_for_client = buildFromGitHub {
    inherit (prometheus_common) date rev owner repo sha256 version;
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
    rev = "65c1f6f8f0fc1e2185eb9863a3bc751496404259";
    date = "2017-05-19";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "0q434q97q1h2xf8nysawv1qs4pbgwk7yg8hmwnbfw2hfhgkh2zlb";
  };

  properties = buildFromGitHub {
    version = 2;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.2";
    sha256 = "16v6c3d85r4pv74aqfa5rj6pbyfminvprhjxyqlcl13byi2hjzxh";
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
    version = 2;
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "v1.1.0";
    sha256 = "0fm0yr5iaxhkg5kkqry6pi0v2hq469x3fwfb1p90afzzav500xsf";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
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

  rabbit-hole = buildFromGitHub {
    version = 2;
    rev = "v1.3.0";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "1xplz3mwj6dia7y7jzgk5r2vdmmi2rk89ndzz1mg2hibq85cs2fr";
  };

  radius = buildFromGitHub {
    version = 2;
    rev = "8ecfc6afafd1730084ea411c01b3618b093a1ccc";
    date = "2016-12-24";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "1l2s1v5zj9fy1jybq3gv2s5ybjx3r70fhpsmilwrmpk45hjrs4lg";
    goPackagePath = "layeh.com/radius";
  };

  raft_v2 = buildFromGitHub {
    version = 2;
    date = "2017-05-04";
    # Use the library-v2-stage-one branch until it is merged
    # into master.
    rev = "939ebd2103731c2f38c7964d8dd24af0e1b26dc3";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "bea889b347503217cb134a9c2e451e86c8709cfd8767c0ed00d3a0ddb02d1497";
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
    version = 2;
    owner = "paulbellamy";
    repo = "ratecounter";
    rev = "66b206d2a2d00245e34b1494fcaeef5e99041ea7";
    sha256 = "09h6khbzhvrp22kw1wbfm986lx7c26pr6rkspv8wkhzfrpgbm02v";
    date = "2017-03-30";
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
    date = "2017-05-24";
    rev = "ae9f8304fabea607b444c4435c3f903498827de9";
    sha256 = "0sh72lskgrdzh0gh7jmmyxipjzz27qgirfs1w9hs811g5j0jzl7g";
    propagatedBuildInputs = [
      aws-sdk-go
      cobra
      crypto
      dropbox
      eme
      errors
      ewma
      fs
      fuse
      go-acd
      goconfig
      google-api-go-client
      net
      oauth2
      open-golang
      pflag
      sftp
      swift
      sys
      tb
      text
    ];
    excludedPackages = "fstest";
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
    date = "2017-05-11";
    rev = "433969511232c397de61b1442f9fd49ec06ae9ba";
    sha256 = "1x5nqlfq7l1v8ms6zklm9fc0avp65bgbvb3g6awli9fq1gr35fvv";
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
    version = 2;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2017-02-19";
    rev = "5abf0ee302ccf4834e84f63ff74eca3e8b88e4e2";
    sha256 = "1r6yk16id1nk1qmpn21g6cw4ipy68j2711mc8ysd39js3pginff2";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  reflectwalk = buildFromGitHub {
    version = 3;
    date = "2017-05-08";
    rev = "8d802ff4ae93611b807597f639c19f76074df5c6";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "0i5ywlrhhq38282scw6cigw6kydpihgldj3hh2rkxgihlxniy8rc";
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
    version = 2;
    rev = "v0.3.8";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "0cs9qdnh9kzdd38w8gl8prg7lwpvyx4n6480jgcnif6lgrr3rhym";
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
    version = 2;
    rev = "v3.5.0";
    owner = "blang";
    repo = "semver";
    sha256 = "1maxa24la1y37dgngaw7ar7fykcxzix54xy60jhnfap8p0yrzs74";
  };

  serf = buildFromGitHub {
    version = 2;
    rev = "v0.8.1";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1afffipv2msa5062jlb52glmfsz9qh2zp58n847190j7b9mm93j9";

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
    rev = "a5f8514e29e90a859e93871b1582e5c81f466f82";
    date = "2017-05-11";
    sha256 = "0f8byxq931cjnqlwdxrxnssrppklqhylc97173wh6k9q06mk5s07";
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
      go-logging
      go-python
      gorequest
      graphite-golang
      influxdb
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
    version = 2;
    rev = "v1.0.3";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "1vb7bwls06fqpxnkwlsb0lbq0nic2hsd5dpf9g94h59avgnxilrz";
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

  sortutil = buildFromGitHub {
    version = 1;
    date = "2015-06-17";
    rev = "4c7342852e65c2088c981288f2c5610d10b9f7f4";
    owner = "cznic";
    repo = "sortutil";
    sha256 = "11iykyi1d7vjmi7778chwbl86j6s1742vnd4k7n1rvrg7kq558xq";
  };

  spacelog = buildFromGitHub {
    version = 2;
    date = "2017-01-06";
    rev = "16604ed16156d8634877b208e8acc9279f399777";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "0rcqgs6n9hklscl0ay9wk36yknd4sim3hxkpii3zcf3sis2s1bh2";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    version = 2;
    date = "2017-04-17";
    rev = "4aabc24848ce5fd31929f7d1e4ea74d3709c14cd";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "05w4vlyglkzgwhfp2ini4yd3l8zblpx8b5sfsy649hzh8mm5v68p";
  };

  spec = buildFromGitHub {
    version = 2;
    date = "2017-04-13";
    rev = "e51c28f07047ad90caff03f6450908720d337e0c";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "0vjwzncllssv75f6q2kpd1y0dfv6spk1zr2vsdsmr70cjpcicir9";
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

  stack = buildFromGitHub {
    version = 3;
    rev = "v1.5.3";
    owner = "go-stack";
    repo = "stack";
    sha256 = "1inwxpdprdjh70zn75ym7qx676m6pw37rp1p7cpi11gklxhazq75";
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
    rev = "e43299b4afa7bc7f22e5e82e3d48607230e4c177";
    owner = "go-openapi";
    repo = "swag";
    sha256 = "0c96zhl0svsry48wjy7cdckssjdsq3vpka14qmslis4y60ljc4md";
    date = "2017-05-20";
    propagatedBuildInputs = [
      easyjson
      yaml_v2
    ];
  };

  swift = buildFromGitHub {
    version = 3;
    rev = "bf51ccd3b5c3a1f12ac762b4511c5f9f1ce6b26f";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "0jrxn0jnihlxsqphkbz02w6d7386na8f6dhraak8dskb9pj4grzx";
    date = "2017-05-16";
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
    rev = "v0.14.28";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "1pqdgxg7yq1fk5zb7hp7vy09d8zf9hb76g3d9p99411vvsj8k2w5";
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

  syncthing-lib = buildFromGitHub {
    inherit (syncthing) rev owner repo sha256 version;
    subPackages = [
      "lib/sync"
      "lib/logger"
      "lib/protocol"
      "lib/osutil"
      "lib/tlsutil"
      "lib/dialer"
      "lib/relay/client"
      "lib/relay/protocol"
    ];
    propagatedBuildInputs = [ go-lz4 luhn xdr text suture du net ];
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
    version = 2;
    rev = "febf2d34b54a69ce7530036c7503b1c9fbfdf0bb";
    date = "2017-01-28";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "0wava2c1by6cdrm0kxf1ldkayip6sivlwankgrhiw6sj645w5km9";
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
    version = 2;
    rev = "faf842bde7ed83bbc3c65a2c454fae39bc29a95f";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "1mxqwvslhjkpn1qfbzmca5p3r75jz2myi95cq76cdd1w9prigihb";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
    ];
    date = "2017-02-06";
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
    rev = "v2.0.6";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "124j646zjcf290hh4q1lvfkb4iwi2v63szp9vd35zdxqm0s0lkn4";
    buildInputs = [
      aws-sdk-go
      bolt
      configure
      clockwork
      crypto
      etcd_client
      go-oidc
      go-shellwords
      goterm
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

    excludedPackages = "\\(test\\|suite\\)";

    patches = [
      (fetchTritonPatch {
        rev = "dee53e8ac6a783b38886b19138e9e7512f55b243";
        file = "t/teleport/fix.patch";
        sha256 = "daa97773d7a358971a87f42d91d2ff5fe0f4c3ae1dc2f7c4020b16f73442bcbc";
      })
    ];
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
    version = 2;
    rev = "7994c181db7761ca3c67a217068cf31826113f5f";
    date = "2017-03-27";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "0xvim7nlrkapwv5hxfgh7m3p0crg900y58kf4b09z3pr0dnsv3lh";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 2;
    rev = "v1.1.4";
    owner = "stretchr";
    repo = "testify";
    sha256 = "0n3z8225px7rylkwz6rvf48ykrh591a7p8gc27a2dh2zskny5qsz";
    propagatedBuildInputs = [
      go-difflib
      go-spew
      objx
    ];
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
    version = 2;
    rev = "fd192d755b00c968d312d23f521eb0cdc6f66bd0";
    date = "2015-05-05";
    owner = "mailgun";
    repo = "timetools";
    sha256 = "0ja8k6b1gp99jifm9ljkwfrqsn00c87pz7alafmy34sc0xlxdcy9";
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
    rev = "a81b26cd14cab7e5045b9391fe77662c00a7e438";
    sha256 = "0ilrr9yyishm2gk401rlch2fd15rpd8fw4xrqzqlfvi2gz4sbz18";
    date = "2017-05-11";
    propagatedBuildInputs = [
      clockwork
      grpc
      logrus
      net
    ];
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
    version = 2;
    owner = "mailgun";
    repo = "ttlmap";
    rev = "8210f93bcb6393a9f36a22ac02fb3c4f53289850";
    sha256 = "1ir31h07xmjwkn0mnx3hkp6mj0x1qa58ling09czxqjqwm263ab3";
    date = "2016-08-25";
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
    version = 2;
    owner = "PuerkitoBio";
    repo = "urlesc";
    rev = "bbf7a2afc14f93e1e0a5c06df524fbd75e5031e5";
    sate = "2015-02-08";
    sha256 = "0rmcdn7z2rvms4j3pjbwbydffgl4s9igcjcfyin47sss0ywf6pmd";
    date = "2017-03-24";
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
    version = 2;
    rev = "1a2093d4dfa2a614da54529a1d63109e7ae34f93";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "1g9np02sb7zymbbw1141vjpmxz8s08msgcxsj9317j1b0yrnf6n6";
    date = "2017-04-12";
    propagatedBuildInputs = [
      envpprof
      missinggo
      anacrolix_sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 2;
    rev = "1b00554d822231195d1babd97ff4a781231955c9";
    owner = "pborman";
    repo = "uuid";
    sha256 = "0frx4d0459axn4s30ipdagfr28xxz491fxl01igg3g03z7flkf5p";
    date = "2017-01-12";
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
    rev = "v0.7.2";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "047w4hyk2njc2dfqj8gpq77xj3zh1pkmn1bbm372xrry5sh8sif6";

    nativeBuildInputs = [
      pkgs.protobuf-cpp
      protobuf.bin
    ];

    buildInputs = [
      armon_go-metrics
      aws-sdk-go
      azure-storage-go
      columnize
      consul_api
      copystructure
      crypto
      duo_api_golang
      errwrap
      etcd_for_vault
      go-cleanhttp
      go-colorable
      go-crypto
      go-github
      go-glob
      go-homedir
      go-mssqldb
      go-multierror
      go-okta
      go-plugin
      go-radix
      go-rootcerts
      go-semver
      go-syslog
      go-zookeeper
      gocql
      golang-lru
      google-api-go-client
      google-cloud-go
      govalidator
      grpc
      hashicorp_go-uuid
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

  vault_api = buildFromGitHub {
    inherit (vault) rev owner repo sha256 version;
    subPackages = [
      "api"
      "helper/compressutil"
      "helper/jsonutil"
    ];
    propagatedBuildInputs = [
      hcl
      go-cleanhttp
      go-multierror
      go-rootcerts
      mapstructure
      net
      pester
      structs
    ];
  };

  viper = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "viper";
    rev = "0967fc9aceab2ce9da34061253ac10fb99bba5b2";
    date = "2017-04-17";
    sha256 = "1kc3m6637gnw6hm84qsadn0pijiaqd77ih1vbak27swgg7c7dcjn";
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
    version = 2;
    rev = "v1.1.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "0qrvpvjnsi9bash1x8fhnj1fnpgydxjvys2adbkih2vys20a3hch";
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
    version = 2;
    rev = "cd8b52f8269e0feb286dfeef29f8fe4d5b397e0b";
    date = "2017-04-07";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "1dvq75d687rmj49hqzbhv6bbjn7arpkgzla911yv3aps766gx33s";
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
    version = 2;
    owner = "rs";
    repo = "xhandler";
    date = "2016-06-18";
    rev = "ed27b6fd65218132ee50cd95f38474a3d8a2cd12";
    sha256 = "14e5d9f09a28bff8a9687e2f1d2250e034852b2dd784eb8c1ee04fac676f9357";
    propagatedBuildInputs = [
      net
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

  xxhash = buildFromGitHub {
    version = 2;
    rev = "09e1e23aaa83fc6b47aa8aedbb62846c521ede77";
    owner  = "cespare";
    repo   = "xxhash";
    sha256 = "10axqp9jvwj7ssqh11qzx3k5n6b7rq5zvk7jlna54bxdvqlfmrwd";
    date = "2017-03-30";
  };

  zap = buildFromGitHub {
    version = 3;
    rev = "v1.4.0";
    owner  = "uber-go";
    repo   = "zap";
    sha256 = "1ylcwm8zaks9s1g1rh4rp8k2f923zdgljjvr0k4lh5cx66i56kp9";
    goPackagePath = "go.uber.org/zap";
    goPackageAliases = [
      "github.com/uber-go/zap"
    ];
    propagatedBuildInputs = [
      atomic
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
