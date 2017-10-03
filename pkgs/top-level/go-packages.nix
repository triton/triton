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
    rev = "24e4144ec923c2374f6b06610c0df16a9222c3d9";
    owner = "golang";
    repo = "appengine";
    sha256 = "1xwvrv8csai1ww21nbgz6c0mx8d3660d3wb21dz5wlncclv09fky";
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
    date = "2017-09-21";
  };

  build = buildFromGitHub {
    version = 3;
    rev = "f91a14947366aaad52a178e18dac586119566964";
    date = "2017-10-02";
    owner = "golang";
    repo = "build";
    sha256 = "1l4qscbf7akr4kdq3mib89fvm3if00arxr475naqg45c6ffxy9ra";
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
    rev = "9419663f5a44be8b34ca85f08abc5fe1be11f8a3";
    date = "2017-09-30";
    owner = "golang";
    repo = "crypto";
    sha256 = "01zqmkryc4xh2x3qid15hc8jsxgdjh5gz752y9j02akjfaf6qqj0";
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
    rev = "f11d3bcfb62fc8e5d737acc91534fad5e188b8d4";
    date = "2017-09-05";
    owner = "golang";
    repo = "debug";
    sha256 = "13ysbr6lw4wnxp15kgja17jgdmh017843f4j56alyspfmknxr7q7";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
  };

  exp = buildFromGitHub {
    version = 3;
    rev = "be09b602c40b1028d91bf805b38a6f54741fc34d";
    owner = "golang";
    repo = "exp";
    sha256 = "0kjd832vzds23as8ffkd0qq5i62nwm0f8s4fimijxgjg3w4c8gfd";
    date = "2017-09-29";
    goPackagePath = "golang.org/x/exp";
    subPackages = [
      "ebnf"
    ];
  };

  geo = buildFromGitHub {
    version = 3;
    rev = "6fb829cea43026b93220f914ca1043fdbbb35414";
    owner = "golang";
    repo = "geo";
    sha256 = "0f1ln4qv27raqai8y76rbdivszv1cda27kpdbxx3b078b541zbsi";
    date = "2017-09-21";
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
    rev = "334384d9e19178a0488c9360d94d183c1ef0f711";
    date = "2017-09-27";
    owner = "golang";
    repo = "image";
    sha256 = "031dx48whvxdcwg49s9i9z6wjx50xawfvpaxwxvvh0x9vwh9vqkd";
    goPackagePath = "golang.org/x/image";
    propagatedBuildInputs = [
      text
    ];
  };

  net = buildFromGitHub {
    version = 3;
    rev = "0a9397675ba34b2845f758fe3cd68828369c6517";
    date = "2017-09-27";
    owner = "golang";
    repo = "net";
    sha256 = "0k7czj0gvyj9hgx0q0c07w4lmb4a592jk2fl1nr6vrnxfdff2v78";
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
    rev = "bb50c06baba3d0c76f9d125c0719093e315b5b44";
    date = "2017-09-28";
    owner = "golang";
    repo = "oauth2";
    sha256 = "015yfvvcrbfxbh6mjr21w0zpnmkk6w9fldagvsc3fymik6k6q2nr";
    goPackagePath = "golang.org/x/oauth2";
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };


  protobuf = buildFromGitHub {
    version = 3;
    rev = "130e6b02ab059e7b717a096f397c5b60111cae74";
    date = "2017-09-20";
    owner = "golang";
    repo = "protobuf";
    sha256 = "1d7zcwashq7znp1bisilpkqshnsad3jn56vf7x3qmzdwa68rb000";
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
    rev = "8e0aa688b654ef28caa72506fa5ec8dba9fc7690";
    date = "2017-09-27";
    owner  = "golang";
    repo   = "sync";
    sha256 = "1c7z7j2wrav5l1l6d4390yyqipp4c1i17n8gl337gjs2sc30hvgp";
    goPackagePath = "golang.org/x/sync";
    propagatedBuildInputs = [
      net
    ];
  };

  sys = buildFromGitHub {
    version = 3;
    rev = "314a259e304ff91bd6985da2a7149bbf91237993";
    date = "2017-09-27";
    owner  = "golang";
    repo   = "sys";
    sha256 = "1xpw32hqdwijvcjqy6z9fzpl7qswki88jqy83g1b0xbp6nx45f6k";
    goPackagePath = "golang.org/x/sys";
  };

  text = buildFromGitHub {
    version = 3;
    rev = "1cbadb444a806fd9430d14ad08967ed91da4fa0a";
    date = "2017-09-15";
    owner = "golang";
    repo = "text";
    sha256 = "0i20p2m3bgc4x230lywb1v6j904sx7w733iws1nc3krjg6b9w4f6";
    goPackagePath = "golang.org/x/text";
    excludedPackages = "cmd";
  };

  time = buildFromGitHub {
    version = 3;
    rev = "6dc17368e09b0e8634d71cac8168d853e869a0c7";
    date = "2017-09-27";
    owner  = "golang";
    repo   = "time";
    sha256 = "0n7jygbsq7zd61kl3rqgz9pmsif2vmlmkrfifar0c1rjcg5sdxda";
    goPackagePath = "golang.org/x/time";
    propagatedBuildInputs = [
      net
    ];
  };

  tools = buildFromGitHub {
    version = 3;
    rev = "68e087e2a5786de2c035ed544b1c5a42e31f1933";
    date = "2017-09-27";
    owner = "golang";
    repo = "tools";
    sha256 = "1gq7n8irrhx595wxh19lfysb8kyaynzlnx9k6jl9pv2rks6c38pn";
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
    version = 3;
    owner = "spf13";
    repo = "afero";
    rev = "ee1bd8ee15a1306d1f9201acc41ef39cd9f99a1b";
    date = "2017-09-01";
    sha256 = "0sqikb79l9wr5sablg316h3lpmgpc6iljmq58p9rd57a5vwcxl29";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  amber = buildFromGitHub {
    version = 3;
    owner = "eknkc";
    repo = "amber";
    rev = "4ed0bf703376fff9d12e6fbf8a52914b8ff5f3c3";
    date = "2017-09-22";
    sha256 = "0m2ap5rmwpslswbvpnhbmhhx666rn8dx0w2g8dzcw6r47z762n99";
  };

  amqp = buildFromGitHub {
    version = 3;
    owner = "streadway";
    repo = "amqp";
    rev = "cefed15a0bd808d13947f228770a81b06ebe8e45";
    date = "2017-09-26";
    sha256 = "0wc7fkalyvljh394d5s1c0a6qvzlw4n1m6aw49jn1d8fsfahaysd";
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
    version = 3;
    rev = "v1.0.2";
    owner  = "edeckers";
    repo   = "auroradnsclient";
    sha256 = "1x5vq95n3gb4jznbi2wmxc6fl5c8f8h7d30ppdkwll3gqqykzpvr";
    propagatedBuildInputs = [
      logrus
    ];
  };

  aws-sdk-go = buildFromGitHub {
    version = 3;
    rev = "v1.12.2";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "1j5gvlm62s812a788byv8ryd74ccqkr6bg1m0p2i3zl57pywy7dl";
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
    date = "2017-09-28";
    rev = "2592daf71ab6b95dcfc7f7437ecc1afb9ddb7360";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "13m77x6wklf4ig69jvrb1jw81nd1vwlsv4q3c91h04mkbdzk3yyw";
    excludedPackages = "\\(Gododir\\|storageimportexport\\)";
    propagatedBuildInputs = [
      crypto
      decimal
      go-autorest
      satori_go-uuid
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
    rev = "v1.1.0";
    sha256 = "1370w8zhgdgvmp0prbzmjc93b8di9cb4wgfsgjd5m3xm4jqghzn7";
    propagatedBuildInputs = [
      net
    ];
  };

  barcode = buildFromGitHub {
    version = 3;
    owner = "boombuler";
    repo = "barcode";
    rev = "3cfea5ab600ae37946be2b763b8ec2c1cf2d272d";
    date = "2017-09-22";
    sha256 = "1ml8r6jzdfyqn042jqadc3fg874lby2wzk7grvbvyn1i25lq1lfr";
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
    rev = "4048872b16cc0fc2c5fd9eacf0ed2c2fedaa0c8c";
    sha256 = "ddb0f4a4debe1ad4a210213c95fdf3c08cc21f18fd6a7cc3b76ed45228d57781";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    # V2 breaks goorgeus/go-md2man right now
    meta.autoUpdate = false;
  };

  blake2b-simd = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "blake2b-simd";
    date = "2016-07-23";
    rev = "3f5f724cb5b182a5c278d6d3d55b40e7f8c2efb4";
    sha256 = "5ead55b23a24393a96cb6504b0a64c48812587c4af12527101c3a7c79c2d35e5";
  };

  bbolt = buildFromGitHub {
    version = 3;
    rev = "3eac9d3bd834d07cf6b83b780a750cd10c16597a";
    owner  = "coreos";
    repo   = "bbolt";
    sha256 = "1vx3nchnwxajs0rrhy3vzzdbrhrbmzy2772fhlk0361iv4gbwip0";
    date = "2017-09-28";
    buildInputs = [
      sys
    ];
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
    date = "2017-09-20";
    rev = "4803a8291c92a1d2d41041b942a9a9e37deab065";
    sha256 = "0kijici220a6hxn7a6ss8k97rygvbzw9p519zdf05p3d1fjq9y1k";
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
    version = 3;
    rev = "b425c9ca005a2050ebe723f6a0cddcb907354ab7";
    owner = "karlseguin";
    repo = "ccache";
    sha256 = "1y5iszzyyk4jyzwwbg8nlibd4jr0cl7gj1vi2mvvm09sc7gcczl7";
    date = "2017-09-04";
  };

  certificate-transparency-go = buildFromGitHub {
    version = 3;
    owner = "google";
    repo = "certificate-transparency-go";
    rev = "1b985c8adc65c931126c75c784e7fb6f02b8bfff";
    date = "2017-10-02";
    sha256 = "0l6adyj0ylh7qnm5lx8syyyh5iv5z34jmkf3xzhgg3ccgrqpjnjg";
    subPackages = [
      "."
      "asn1"
      "client"
      "client/configpb"
      "jsonclient"
      "tls"
      "x509"
      "x509/pkix"
    ];
    propagatedBuildInputs = [
      net
      protobuf
      gogo_protobuf
    ];
  };

  cfssl = buildFromGitHub {
    version = 3;
    date = "2017-09-16";
    rev = "7d88da830aad9d533c2fb8532da23f6a75331b52";
    owner  = "cloudflare";
    repo   = "cfssl";
    sha256 = "0gxkciddwdl7vfcr0gr4m8hx0y6786zq0xkfa4ji179sb6spk0g0";
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
  };

  cgofuse = buildFromGitHub {
    version = 3;
    rev = "v1.0.3";
    owner  = "billziss-gh";
    repo   = "cgofuse";
    sha256 = "1gca476kw154891vmyclyvkz7x9mj6anklvm0i0vi651kv5lahzf";
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

  chroma = buildFromGitHub {
    version = 3;
    rev = "v0.1.1";
    owner  = "alecthomas";
    repo   = "chroma";
    sha256 = "0x9v06fi3c69mj2zxagsbkh0ic0898rpr8infrlmvnjdx59f54kc";
    excludedPackages = "cmd";
    propagatedBuildInputs = [
      fnmatch
      regexp2
    ];
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
    version = 3;
    rev = "v1.1.1";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "0ix4r71b2dkmq2shiwxhramcx62w667zwc44gpwk7377zw8qb9cz";
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
    date = "2017-10-02";
    rev = "adfc2d17a001d2d984dc59538cb49d4a9d695c56";
    owner = "docker";
    repo = "cli";
    sha256 = "0mv82l58mw4bb491prd89l5mnr8n6sbjm7lrhnhkz3l1kcibawq0";
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
    date = "2017-09-08";
    rev = "65fcae5817c8600da98ada9d7edf26dd1a84837b";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "0xqy4mm5c0kdbdach752p7wjy01imz3fx0wi9nqz8rm47sqyywb9";
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
    version = 3;
    rev = "v0.1.3";
    owner = "soheilhy";
    repo = "cmux";
    sha256 = "1vayyhn5jb243xrpgsb3q633vff8kwh09rif6r2sbgk5v52zhz9j";
    propagatedBuildInputs = [
      net
    ];
  };

  cobra = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "cobra";
    rev = "0dacccfbaabc71b872087c1719c5380d3e185173";
    date = "2017-10-02";
    sha256 = "07yv6yr9z8v08ldhfbpx8xmbidnsqk4ip61bnkxqi90whx8qa0xa";
    propagatedBuildInputs = [
      go-homedir
      go-md2man
      mousetrap
      pflag
      viper
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
    version = 3;
    rev = "7677a1d7c1137cd3dd5ba7a076d0c898a1ef4520";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "1badabjv94paviyr56cqj5g2gfylgyagjrhrh5ml7wr2zwncvm8y";
    date = "2017-08-19";
  };

  complete = buildFromGitHub {
    version = 3;
    rev = "88e59760adaddb8276c9b15511302890690e2dae";
    owner  = "posener";
    repo   = "complete";
    sha256 = "0zvf57p1r2mav7nnb47z2fwv826w9bz84ql91535943khsd7c3iv";
    date = "2017-09-08";
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
    rev = "v0.9.3";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "1ydlllpbmfgqa6avzwq7mganrbg6jjgqi9d8i5cx9nxnffipwnz9";

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
      time
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
    rev = "v0.19.3";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "0f1pykbh0q4l6vnkdcf891hb1c89jjjmlx0b1cdjaixhyf55x001";

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

  continuity = buildFromGitHub {
    version = 3;
    rev = "617902de2ab5e18974efd88a58eeef67ac82d127";
    owner = "containerd";
    repo = "continuity";
    sha256 = "0qgjrwdi5bfwhy7xp7gwcd3823pgxw08q9yh68sr4kf8p46cisbg";
    date = "2017-09-25";
    subPackages = [
      "pathdriver"
    ];
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
    rev = "v0.5.7";
    owner = "go-xorm";
    repo = "core";
    sha256 = "05ryjv26lwbcj7lha936yhlqdm0nazy8rjmmnbnig3x97ba6lhvq";
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

  cpufeat = buildFromGitHub {
    version = 3;
    rev = "3794dfbfb04749f896b521032f69383f24c3687e";
    owner  = "templexxx";
    repo   = "cpufeat";
    sha256 = "01i4kcfv81gxlglyvkdi4aajj0ivy7rhcsq4b9yind1smq3rfxs5";
    date = "2017-09-27";
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
    version = 3;
    rev = "23d6a3a21bf6bee833d131ddeeab610c71915c30";
    owner  = "tildeleb";
    repo   = "cuckoo";
    sha256 = "0v1nv6laq4mssz13nz49h6fxynyghj0hh2v2a2p4k4mck3srjzki";
    date = "2017-09-28";
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
    rev = "a389bdde4dd695d414e47b755e95e72b7826432c";
    owner = "godbus";
    repo = "dbus";
    sha256 = "0vslxwj58fwmrb94sapg4ajpzd1wb520anzvw7zqmv45s1wk0n63";
    date = "2017-09-18";
  };

  decimal = buildFromGitHub {
    version = 3;
    rev = "aed1bfe463fa3c9cc268d60dcc1491db613bff7e";
    owner  = "shopspring";
    repo   = "decimal";
    sha256 = "1vdcdzpy0ay319pn69y4p7n6dpxvd3xr0j9mvfbnlzahygcmqdy4";
    date = "2017-09-11";
  };

  demangle = buildFromGitHub {
    version = 3;
    date = "2016-09-27";
    rev = "4883227f66371e02c4948937d3e2be1664d9be38";
    owner = "ianlancetaylor";
    repo = "demangle";
    sha256 = "1fx4lz9gwps99ck0iskdjm0l3pnqr306h4w7578x3ni2vimc0ahy";
  };

  diskv = buildFromGitHub {
    version = 3;
    rev = "v2.0.1";
    owner  = "peterbourgon";
    repo   = "diskv";
    sha256 = "0himh621lksnk8wq1j36b607a1nv5mpwbd7d06mq14bcnr68ljvy";
    propagatedBuildInputs = [
      btree
    ];
  };

  distribution = buildFromGitHub {
    version = 3;
    rev = "bb49a1685d2773cb43dacc16e100419f310ba347";
    owner = "docker";
    repo = "distribution";
    sha256 = "06ii1rgcw48hs3cqzbviz79j9p80vl8vdgwqdl93ijvg4skva10q";
    meta.useUnstable = true;
    date = "2017-09-29";
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
    rev = "946bd9fbed05568b0f3cd188353d8aa28f38b688";
    date = "2017-09-30";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0vijbk13miksrhrw2ypjq1z9grz8rh4qb0rkvhrbj84m365zn7ca";
  };

  dnsimple-go = buildFromGitHub {
    version = 3;
    rev = "84b1b693f39ee2d2749fd651148024c014679dbd";
    owner  = "dnsimple";
    repo   = "dnsimple-go";
    sha256 = "06fd681lmb6xxbr06bw01rbamy2jhwp59r540smgbq7dp6wyy1hb";
    propagatedBuildInputs = [
      go-querystring
    ];
    date = "2017-08-30";
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
    rev = "v0.6.0";
    owner = "docker";
    repo = "docker-credential-helpers";
    sha256 = "1k0aym74a6f83nsqjb2avsypakh3i23wk6il9295hfjd8ljwilpm";
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

  dropbox-sdk-go-unofficial = buildFromGitHub {
    version = 3;
    rev = "3620be11411ddb30351ae33ac2ac34c16e13e66b";
    owner  = "dropbox";
    repo   = "dropbox-sdk-go-unofficial";
    sha256 = "08s3d2r38p4mamn19wiz9p815irk45ickrsj7ip4694sqgzgcb8j";
    propagatedBuildInputs = [
      oauth2
    ];
    excludedPackages = "generator";
    meta.useUnstable = true;
    date = "2017-09-20";
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
    rev = "2a92e673c9a6302dd05c3a691ae1f24aef46457d";
    date = "2017-09-02";
    sha256 = "06z4islkl0p76g8zc9v4fvvbnj08zhdvn8zf8x6gmvqgngprpyfg";
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
    version = 3;
    rev = "325740036187ddae3a5b74be00fbbc70011c4d96";
    date = "2017-09-12";
    owner  = "exoscale";
    repo   = "egoscale";
    sha256 = "0vgw4hzrx11yp26xfx4h7h8rfkfffk5grch97yg6jqlw7md4la0b";
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
    rev = "v5.0.48";
    sha256 = "14y92izajqmhrjn23qm6mfcdh9jfy9p2z7p4fp51clfns9s20zak";
    goPackagePath = "gopkg.in/olivere/elastic.v5";
    propagatedBuildInputs = [
      errors
      net
      sync
    ];
  };

  eme = buildFromGitHub {
    version = 3;
    owner = "rfjakob";
    repo = "eme";
    rev = "7c8316a9cb0a6af865265f899f5de6aadb31a24b";
    date = "2017-09-01";
    sha256 = "06vpq435rbcbqsiz46b1gz43nmyjajah14i4r8vj3n2gq6bcp9jl";
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
    rev = "2b3a18b5f0fb6b4f9190549597d3f962c02bc5eb";
    sha256 = "1rna3r0vxnrp9rqq7ahiv1x3cxvfrs9fysrvq710mh73kjz1pq2y";
    date = "2017-09-10";
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
    rev = "3a566fd3ad72a86965c970d64438ce5d17f07d10";
    sha256 = "17pv8lvxh91n8zskrgig1xnmxr5dl85i7hap7qff7q34z7qwdbm0";
    propagatedBuildInputs = [
      bbolt
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

    excludedPackages = "\\(test\\|benchmark\\|example\\|bridge\\)";
    meta.useUnstable = true;
    date = "2017-10-02";
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
  };

  etree = buildFromGitHub {
    version = 3;
    owner = "beevik";
    repo = "etree";
    rev = "v1.0.0";
    sha256 = "0j56c7xqz8nm8nf4104b8y0gwqr2hg5y2fgp25w27h8b3xdmx8gd";
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

  fnmatch = buildFromGitHub {
    version = 3;
    date = "2016-04-03";
    rev = "cbb64ac3d964b81592e64f957ad53df015803288";
    owner  = "danwakefield";
    repo   = "fnmatch";
    sha256 = "126zbs23kbv3zn5g60a2w6cdxjrhqplpn6h8rwvvhm8lss30bql6";
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

  fs-repo-migrations = buildFromGitHub {
    version = 3;
    owner = "ipfs";
    repo = "fs-repo-migrations";
    rev = "v1.3.0";
    sha256 = "1bnlj9hls8bhdcljn21y72g75p0qb768l4i51gib827ylhs9l0ww";
    propagatedBuildInputs = [
      goprocess
      go-homedir
      go-os-rename
      go-random
      go-random-files
      net
    ];
    postPatch = ''
      # Unvendor
      find . -name \*.go -exec sed -i 's,".*Godeps/_workspace/src/,",g' {} \;

      # Remove old, unused migrations
      sed -i 's,&mg[01234].Migration{},nil,g' main.go
      sed -i '/mg[01234]/d' main.go
    '';
    subPackages = [
      "."
      "go-migrate"
      "ipfs-1-to-2/lock"
      "ipfs-1-to-2/repolock"
      "ipfs-4-to-5/go-datastore"
      "ipfs-4-to-5/go-datastore/query"
      "ipfs-4-to-5/go-ds-flatfs"
      "ipfs-5-to-6/migration"
      "mfsr"
      "stump"
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
    rev = "299b7ff5b6096588cceca2edc1fc9f557002fb85";
    sha256 = "1mc57xlajkbsmgz7ccphnnb2jy53wlb09as6nqhhl4mm4nx0mhpx";
    date = "2017-09-27";
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
    date = "2017-09-05";
    rev = "bb6d471dc95d4fe11e432687f8b70ff496cf3136";
    owner  = "philhofer";
    repo   = "fwd";
    sha256 = "04q32rf415iv3lmjba19i1sb5lx8ji7453v0cxv35vcs3dxaxnzf";
  };

  gabs = buildFromGitHub {
    version = 3;
    owner = "Jeffail";
    repo = "gabs";
    rev = "44ad915e1baa36caddb7db85303c3406042f7187";
    sha256 = "12rllsp97391zdhwwsrm25c7i2xnk80l1z1d6agqzgdrngkd4clf";
    date = "2017-09-12";
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
    rev = "v2.0.0";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "06b3nwksr80bmj83vf6m9mdm6q3555xjjjjhx0f8z0s92j6w0y64";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
  };

  genproto = buildFromGitHub {
    version = 3;
    date = "2017-09-18";
    rev = "1e559d0a00eef8a9a43151db4665280bd8dd5886";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "1kni40w0byh9ssz59cfi7143fsxz6sx28vmpaa8kpssw8lkhs4w3";
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
    version = 3;
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
    version = 3;
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
    rev = "v1.0.1";
    sha256 = "099xi3bckrrq7fxxil85qdr705x0wjcgwccwgyxni3g97fns0mi9";
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

  gnostic = buildFromGitHub {
    version = 3;
    rev = "v0.1.0";
    owner = "googleapis";
    repo = "gnostic";
    sha256 = "0maql4kfc6q303lxz7pldjbh3k65pkw9yczxsg7285srmf7yp5s6";
    excludedPackages = "tools";
    propagatedBuildInputs = [
      docopt-go
      protobuf
      yaml_v2
    ];
  };

  json-iterator_go = buildFromGitHub {
    version = 3;
    rev = "1.0.2";
    owner = "json-iterator";
    repo = "go";
    sha256 = "1ah8vlmh8ncj3jnvcb42dnn20bzzy5rbn5dpzck1ng4fi5zhgxy2";
    excludedPackages = "test";
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
    date = "2017-09-18";
    rev = "54210f4e076c57f351166f0ed60e67d3fca57a36";
    owner = "ugorji";
    repo = "go";
    sha256 = "0plsk9qvaq157r5wzj0fmbcfmaiai9kgqnapqz7rxyx5i22fpsj6";
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
    rev = "d6e3b3328b783f23731bc4d058875b0371ff8109";
    date = "2017-09-29";
    sha256 = "1ckr3942pr6xlw9na5ndzs2vlsi412g7vk5bcf6nsr021k0mq0wb";
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
    rev = "ce5020aabae349deda77bc1d559ef2300d3c93c5";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "1k680gmy58ymlrm9l75wxy6qk0vy17rmiz9yz09xmyvdchr7gbi6";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2017-09-30";
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
    rev = "3db12ebb2a599ba4a96bea1c17b61c2f78a40e02";
    owner  = "petermattis";
    repo   = "goid";
    sha256 = "1ylv8w0sa8bc7w5sf1sd8i7dsiba2zm1fp0mjlcg0g0jlbhqgqg9";
    date = "2017-08-16";
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
    rev = "3f523f4c14b6e925da10475eb0447c2f28614aac";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "07ld1qfj3fgw1kf4fgmp3n5pj3k35ra2n1734ppp41z7hd57phyf";
    date = "2017-09-14";
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
    rev = "v1.1.14";
    owner = "google";
    repo = "gopacket";
    sha256 = "0z68x9isjd4l7rxdb6zwq0qf52b5k1vc48v23j9gws3rgvq046wv";
    buildInputs = [
      pkgs.libpcap
      pkgs.pf-ring
    ];
    propagatedBuildInputs = [
      net
      sys
    ];
  };

  gophercloud = buildFromGitHub {
    version = 3;
    rev = "8c5c0c21b452d5d9faf056bbdf5bd59333097c6a";
    owner = "gophercloud";
    repo = "gophercloud";
    sha256 = "00ffif7748wib616vrqycn6v765nl9v0c45n6dcxk38yjh3vfi1l";
    date = "2017-10-03";
    excludedPackages = "test";
    propagatedBuildInputs = [
      crypto
      yaml_v2
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 3;
    date = "2017-10-02";
    rev = "0ceb5a5b67deb9be3a5133e55dcbbf60c57d3c6d";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "00d9vinn3ryrfhiszf1s66lrh687znddz4nlfpzyplbc9qmmw3q5";
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
    rev = "25312cafb9a191a6d377c480a4666beec3105e4a";
    owner = "google";
    repo = "gops";
    sha256 = "0izs0qd4y5hjks4gxy1ia36ss0486b1y5z0frrdlm7fjxasz7y1f";
    propagatedBuildInputs = [
      keybase_go-ps
      goversion
      osext
    ];
    meta.useUnstable = true;
    date = "2017-09-21";
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
    rev = "d443b9114f9c050367638a536310fbec36a0de11";
    date = "2017-09-18";
    owner = "buger";
    repo = "goterm";
    sha256 = "1f8ii092bp3lafkdxl0dwpjyhynqymhi9rdcji71z136dqc90g05";
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
    rev = "d3c2ba80e75eeef10c5cf2fc76d2c809637376b3";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "00vrvfmrx3d20q029iaimi1qk5iwv68cmqm740pi0qzklxv0007f";
    date = "2017-09-21";
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
    propagatedBuildInputs = [
      ginkgo
      gomega
      snappy
    ];
  };

  golex = buildFromGitHub {
    version = 3;
    rev = "4ab7c5e190e49208c823ce8ec803aa39e6a4b31a";
    date = "2017-08-03";
    owner = "cznic";
    repo = "golex";
    sha256 = "02hk6gqr5559v7iz88p14l61h11a111kab391as61xwjhr1pplxa";
    propagatedBuildInputs = [
      lex
      lexer
    ];
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
      date = "2017-09-30";
    };
    rev = "906273f42cdebd65de3a53f30dd9e23de1b55ba9";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 3;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "1y6j6smf069wmvlpascy5x5f6lynq5sqxpanmgmx7qlzzg9368n9";
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
    rev = "098da33fde5f9220736531b3cb26a2dec86a8367";
    date = "2017-09-01";
    owner = "chaseadamsio";
    repo = "goorgeous";
    sha256 = "0w80lfxsz48n78wng28xzgva2i9bsd8fcvgcajjva6gw63ywsy6x";
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
    rev = "v2.17.09";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "1g72405nn6mbcnd036dwara1y4f0f2jny6jyc6069xxdd00jrv21";
    buildInputs = [
      sys
      w32
      wmi
    ];
  };

  goquery = buildFromGitHub {
    version = 3;
    rev = "63e7f870c2298e42bfc8b200db92e175a3e71120";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "0s9f71cd16bxicz7gvjy64dvdshqiv9fij7cmj0qph3g8l9j5h8d";
    propagatedBuildInputs = [
      cascadia
      net
    ];
    date = "2017-09-29";
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
    rev = "ca5f9e638c83bac66bfac70ded5bded1503135a7";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "00brhflp1idivbdq9b9siayccylkcc39fz56x968q72l086axfj0";
    date = "2017-10-02";
  };

  goversion = buildFromGitHub {
    version = 3;
    rev = "v1.0.0";
    owner = "rsc";
    repo = "goversion";
    sha256 = "1f9himpsm4w4m4zngzhs055accri8144rdhixx13mrv72w771vbr";
    goPackagePath = "rsc.io/goversion";
  };

  goxmldsig = buildFromGitHub {
    version = 3;
    rev = "b7efc6231e45b10bfd779852831c8bb59b350ec5";
    owner  = "russellhaering";
    repo   = "goxmldsig";
    sha256 = "1dz7rzxwk47hifdng3g7jc5cvy2sslaqa2rxnwc7d6kdid71li8c";
    date = "2017-09-11";
    propagatedBuildInputs = [
      clockwork
      etree
    ];
  };

  go-autorest = buildFromGitHub {
    version = 3;
    rev = "v8.4.0";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "04zyqfz3dn4xj5x1lnvbmh3dkh2s0clym2pz0y66pd9k6havnaqs";
    propagatedBuildInputs = [
      jwt-go
    ];
    excludedPackages = "\\(cli\\|cmd\\|example\\)";
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
    rev = "v0.3.0";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "0lvkfmkah8yjjq582lxdb6ghpcfc8j2yw8iz19l9v98i6csgcamy";
    propagatedBuildInputs = [
      errors
      go-winio
      logrus
      net
      runc
    ];
  };

  go-couchbase = buildFromGitHub {
    version = 3;
    rev = "195945aa8fd23ea4772883396fd6b31730035eff";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "00hi3nqnaqhm5x2k8pzfw9lpppk53piywhnpfhc8arniadikg2im";
    date = "2017-09-05";
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
    rev = "565eb44395707143937a7e9f7015747585046643";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "1m91sh6gyfblc0n6ghihzd9f3gjx4zc7gn0y36sf5mvwal2xk3f1";
    date = "2017-08-29";
    propagatedBuildInputs = [
      goid
    ];
  };

  go-discover = buildFromGitHub {
    version = 3;
    rev = "25e4565347de14cea0a0e0730374c9fcffa7bab0";
    owner  = "hashicorp";
    repo   = "go-discover";
    sha256 = "1dj3x2xy9ffqgvr3icdr8jdg9pd307382i097wm4q8k7j8phypw9";
    date = "2017-09-25";
    propagatedBuildInputs = [
      aws-sdk-go
      #azure-sdk-for-go
      #go-autorest
      google-api-go-client
      oauth2
      softlayer-go
    ];
    postPatch = ''
      rm -r provider/azure
      sed -i '/azure"/d' discover.go
    '';
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
    date = "2017-09-29";
    rev = "199e3d903f173ca5869445d99a5aebe85872a7a4";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "0h2q1qhf8rxfi92m2cg2nh7g11ij0zhn1bc87vf6gj0qcqic9d87";
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
    rev = "v1.7.0";
    owner  = "ethereum";
    repo   = "go-ethereum";
    sha256 = "0wwzlaqa9cqx44hws2npvs9mragzz7j23c22bg0h6p045r57ibql";
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
    rev = "9366bd3c3107c755e9b111afafa264b7c823ba35";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "120kla8yrcqk26hqhvqrqgwvcpbwzgiicymqci356hgwmls5n2ag";
    date = "2017-09-16";
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

  go-flowrate = buildFromGitHub {
    version = 3;
    rev = "cca7078d478f8520f85629ad7c68962d31ed7682";
    owner  = "mxk";
    repo   = "go-flowrate";
    sha256 = "0xypq6z657pxqj5h2mlq22lvr8g6wvpqza1a1fvlq85i7i5nlkx9";
    date = "2014-04-19";
  };

  go-getter = buildFromGitHub {
    version = 3;
    rev = "a686900cb3753aa644dc4812be91ceaf9fdd3b98";
    date = "2017-09-22";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "0sr1sws13b3m5a152lyxchfynh3b83vr46yb84h2ipb8byk50fqz";
    propagatedBuildInputs = [
      aws-sdk-go
      go-cleanhttp
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
    date = "2017-09-26";
    rev = "511f540f1887d30b88cee4a2fcd1f2922754acf4";
    owner = "google";
    repo = "go-github";
    sha256 = "1dwn2f92ipa0w846z88543xkkqd98dcvjnz7hpd0r38dly6lga9c";
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
    rev = "0dafe0d496ea71181bf2dd039e7e3f44b6bd11a7";
    owner = "grpc-ecosystem";
    repo = "go-grpc-prometheus";
    sha256 = "1n2lrbdic3z1sf5jil7r0p61x3gvk58m2pyfgfj9fc0fk3kycd34";
    propagatedBuildInputs = [
      grpc
      net
      prometheus_client_golang
    ];
    date = "2017-08-26";
  };

  go-hclog = buildFromGitHub {
    version = 3;
    date = "2017-09-03";
    rev = "8105cc0a3736cc153a2025f5d0d91b80045fc9ff";
    owner  = "hashicorp";
    repo   = "go-hclog";
    sha256 = "0ji2bq0zz1v4f9a750l32sxmgqk72jf0zfxdswpdcpk93fyrgwxm";
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
    version = 3;
    rev = "79e699ccd02f240a1f1fbbdcee7e64c1c12e41aa";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "08k0n8sizmqma2bx5y0xcw3m7knhdw8z7j9gbf28siiaczvwbnbk";
    date = "2017-08-28";
  };

  go-i18n = buildFromGitHub {
    version = 3;
    rev = "v1.9.0";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "0xr5g14jil4xmgl2rn3c8302w9n2vkdp5rzc8qwcg86y3c7knr35";
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
    rev = "bc31c1385e9c3966f7c5ea38a853e12b7e2d1f42";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "16k77r5b9xl0s0wl21mj52hgyi6wwkmfliac6rfqv1i28llc0r7b";
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
    date = "2017-08-23";
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
    version = 3;
    rev = "v0.0.3";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "1ds5jqxjzzvlxzr3f94iwz0vsci11i7qshqg8mx1gr64dm8r8vsh";
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
    rev = "v2.1.3";
    owner = "square";
    repo = "go-jose";
    sha256 = "1gdygy4xx8zxyb8lwck9v1x4ldkigabdcnj68gvgvmb50fhr0y8m";
    goPackagePath = "gopkg.in/square/go-jose.v2";
    buildInputs = [
      crypto
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
    date = "2017-09-14";
    rev = "358a6a7cddb35e2494c98bb602a8e6901c0066bc";
    sha256 = "0h8algkvlzjww3xzfg12y9ndyw17nk53wb9c8yvqg5jbczv5n2ay";
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
    date = "2017-09-13";
    rev = "cb85161026a1612c8c9d132a654edf711839bd98";
    sha256 = "14vzikxdfxk151cilqn0f8q8r4kkwv9w7y6wdgpr1mjm446qawq2";
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
    date = "2017-09-12";
    rev = "77bfd37daa5a74bafe4567e12696e3ceeadbfede";
    sha256 = "1wwzb92drl5bd1rzpsf298nqxiwvrfp5nrqjbhrqldfranz5kxlm";
    propagatedBuildInputs = [
      goprocess
      go-libp2p-interface-conn
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-multiaddr
      go-stream-muxer
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
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-protocol";
    date = "2017-08-24";
    rev = "86bfc440c3e51ec65a4629219623cc5c7e31f16a";
    sha256 = "01slk2wspdjrdffyn1fr8pvgh9k822j776fdx0ddhww3bj1s3v00";
  };

  go-libp2p-transport = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-transport";
    date = "2017-09-06";
    rev = "3485c468cd16db221b0762f88a43cf87e8732ec7";
    sha256 = "17hlibvl96q6j5igwwc3rv08cg9f1n7g2p9lilbqb963npwlygk8";
    propagatedBuildInputs = [
      go-log
      go-multiaddr
      go-multiaddr-net
      go-stream-muxer
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
    rev = "89b06ca6fad6daea5a72a1f47e69e39716c46198";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "10jii0rgbslhz849ppaz4bv4b2gwblh5dda80aaibzpd4ayvhlvf";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2017-09-19";
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
    rev = "v1.0.7";
    sha256 = "0inhyhb0ia3d018nq5lgayk9r0qa2x3g5wpsr7z0rh7sra1jiaks";
    propagatedBuildInputs = [
      blackfriday
    ];
  };

  go-memdb = buildFromGitHub {
    version = 3;
    date = "2017-09-01";
    rev = "ec43fcf8f202880feb35d2abb40a570c1f4172e9";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "10dajvxxlwms74h1ix2kj7aai7d42rzk25xnb03zkxy9kywn4q8b";
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
    date = "2017-10-02";
    rev = "9a4b6e10bed6220a1665955aa2b75afc91eb10b3";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "09ilyxzalpxagkvndzzpfzl726bbwivxrznzn74b8hd23asc3z7z";
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
    rev = "c7ee4153c0fc40206bde939f96eefa1f501cbcaa";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "1x9axv95z6wr1bf2rf9gq6rv8zys9i7dr348jsf5r0r2jzwnmcb8";
    date = "2017-09-26";
    buildInputs = [
      crypto
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 3;
    rev = "f5c34dfc88cf420b72e9d4194f58616e745ea3d0";
    date = "2017-09-21";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "06pzx6nnq2ab66k45q3l077s850rw2qskpbhrgxgzk1wlb2yyij9";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 3;
    rev = "376ba58703c84bfff9ca6e0057adf38ad48d3de5";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "1xbbndkqqmvqsgik2gnvskzk2a6c2xvzl5l1qy5kxhzp35fhw069";
    date = "2017-08-13";
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
    rev = "1b74f22f414c315e983e8aa6dea3571c999a31b2";
    owner = "nats-io";
    repo = "go-nats-streaming";
    sha256 = "057hidxf2kqhwrvzz21i5a53b44xvb6g2dyzp2rd0za0ykp99a1y";
    propagatedBuildInputs = [
      go-nats
      nuid
      gogo_protobuf
    ];
    date = "2017-08-18";
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
    date = "2017-10-02";
    rev = "a93f71fdfe73d2c0f5413c0565eea0af6523a6df";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "1cxs0cszz9cv2m5ym2qabni745xlxx2axrbcjr0pan22a4758kjv";
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
    rev = "e1cd21cc5cfdd1ffb4b09577c394adc6a8315107";
    owner = "sstarcher";
    repo = "go-okta";
    sha256 = "0plhg7gsvxmwhd1w648zlvh1d5d7f1inhlf0ybfg3s2jyxc1wqjj";
    date = "2017-09-01";
  };

  go-ole = buildFromGitHub {
    version = 3;
    date = "2017-09-21";
    rev = "8a4f5c214bfb4475619b8bb7ccbe6fa5c91745f4";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "0ib3gy73pdc7c6phm31akrqhmcfq2ycgm78smz8cxz2pvw3fww2m";
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
    rev = "4b1fea467323b74c5f462f0947f402b428ca0626";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "0983hsivji86dpmn63r3dfxdgxrk2hk1lgn3xy6bnvclskl8rm2p";
    date = "2017-09-06";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-plugin = buildFromGitHub {
    version = 3;
    rev = "3e6d191694b5a3a2b99755f31b47fa209e4bcd09";
    date = "2017-08-28";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "1cbshj4qbj0wv3r57s96l48cbw861nq2q96f1kvhbal0ddbxv1wc";
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
    version = 3;
    owner = "sbinet";
    repo = "go-python";
    date = "2017-09-01";
    rev = "6d13f941744b9332d6ed00dc2cd2722acd79a47e";
    sha256 = "1jvwgavfwlhz73wsrnfya8s2whvbwn63j10gp6qyyycj67snsayy";
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

  go-random = buildFromGitHub {
    version = 3;
    rev = "384f606e91f542a98e779e652eed88051618f0f7";
    owner  = "jbenet";
    repo   = "go-random";
    sha256 = "0dsp9g972y0i93fdb9kn3vvjk7px8z1gx4yikw9al1y7mdx37pbp";
    date = "2015-08-29";
    propagatedBuildInputs = [
      go-humanize
    ];
  };

  go-random-files = buildFromGitHub {
    version = 3;
    rev = "737479700b40b4b50e914e963ce8d9d44603e3c8";
    owner  = "jbenet";
    repo   = "go-random-files";
    sha256 = "12dm4bhj0v67w7a3g9rxhdnw8r927dz4z9dpx1pglisw58dc3kci";
    date = "2015-06-09";
    propagatedBuildInputs = [
      go-random
    ];
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
    rev = "v2.4.0";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "1z3b0mc0ldq4nvrz6fgc9arqf2pm4fnixd0ldn226k77s8l1v1kj";
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
    version = 3;
    rev = "794af36148bf63c118d6db80eb902a136b907e71";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "177h5fzmasq79i9sj7wxv7n7qw9ng4yx13f2bwbid71msf41wf1d";
    date = "2017-08-24";
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

  go-shared = buildFromGitHub {
    version = 3;
    rev = "v0.0.8";
    owner  = "pengsrc";
    repo   = "go-shared";
    sha256 = "1iy3xsrnvj64m3k7fkg307sm274r15300p8a9f1z8547j1wcnsjk";
    propagatedBuildInputs = [
      gabs
      logrus
      yaml_v2
    ];
  };

  go-shellquote = buildFromGitHub {
    version = 3;
    rev = "cd60e84ee657ff3dc51de0b4f55dd299a3e136f2";
    owner  = "kballard";
    repo   = "go-shellquote";
    sha256 = "1mihgvq5vmj0z3fp1kp5ap8bl46inb8np2andw97fabcck86qvyy";
    date = "2017-06-19";
  };

  go-shellwords = buildFromGitHub {
    version = 2;
    rev = "v1.0.3";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "11prxlsk3kwgq6v5ikdsjv5vjv4hfihvw55qc27jip1ia2grcxvz";
  };

  go-shuffle = buildFromGitHub {
    version = 3;
    owner = "shogo82148";
    repo = "go-shuffle";
    date = "2017-08-08";
    rev = "59829097ff3b062427a69e2c461ef60523e37280";
    sha256 = "0bmad1aljj4afl6r1h1wqaiw9f2gxn1xb3kwsg0d2rn15497a2k2";
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
    rev = "a476722483882dd40b8111f0eb64e1d7f43f56e4";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1qmsz8samsjp53fj80adp39znrv4w2srr5sjrfcqkbad0jg92k7n";
    date = "2017-08-29";
  };

  go-sqlite3 = buildFromGitHub {
    version = 3;
    rev = "5160b48509cf5c877bc22c11c373f8c7738cdb38";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0cxd8jm61iivdf0pmvc00frmdglkgzfrdy8aksd3ipg3dj4s3xmh";
    excludedPackages = "test";
    buildInputs = [
      goquery
    ];
    propagatedBuildInputs = [
      net
    ];
    date = "2017-09-28";
  };

  go-stdlib = buildFromGitHub {
    version = 3;
    rev = "48e4d763b2fbcd10e666e6a1742acdf8cc2286ef";
    owner  = "opentracing-contrib";
    repo   = "go-stdlib";
    sha256 = "0lpha7d65x4zywhp2dmdb7zl9m8yg0jxcc1ikifnd1lqna7wwwkn";
    date = "2017-05-28";
    propagatedBuildInputs = [
      opentracing-go
    ];
  };

  go-stream-muxer = buildFromGitHub {
    version = 3;
    rev = "6ebe3f58af097068454b167a89442050b023b571";
    owner  = "libp2p";
    repo   = "go-stream-muxer";
    sha256 = "0isz6ab308sdd7a1jsp82db6fx36nb2wxbag15494rv8rwmhwnsg";
    date = "2017-09-11";
  };

  go-stun = buildFromGitHub {
    version = 3;
    rev = "0.1.0";
    owner  = "ccding";
    repo   = "go-stun";
    sha256 = "0rw7r4vmb4h7wm9r1wqymvx04jgsmdqrpf7sp523npdni4d1j1my";
  };

  go-syslog = buildFromGitHub {
    version = 3;
    date = "2017-08-29";
    rev = "326bf4a7f709d263f964a6a96558676b103f3534";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "07z5anbqzgvcd59isahgvisdsq55asqn2d21292zm3xgacpghm4g";
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
    rev = "7bf6f6eaf1bed2fd3c6c63114b18cb64facb9de2";
    sha256 = "0dm9ib3mz99lbv607acw2gn9hwxli6adv7dm595a4rzpxkfbz8cp";
    date = "2017-09-01";
  };

  go-toml = buildFromGitHub {
    version = 3;
    owner = "pelletier";
    repo = "go-toml";
    rev = "2009e44b6f182e34d8ce081ac2767622937ea3d4";
    sha256 = "0zm58baj99qkrprfdmwxka3swcy3gw5gvsc6livn1bna5nwmdb5k";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2017-10-01";
  };

  go-units = buildFromGitHub {
    version = 3;
    rev = "v0.3.2";
    owner = "docker";
    repo = "go-units";
    sha256 = "1xdhpf14y3fx9gnf7fwz31rkj2md1bk9vi2mjiwi7fxsp8dbl4zr";
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
    version = 3;
    rev = "fc61389e27c71d120f87031ca8c88a3428f372dd";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "1shyfphryxzkagvxi6a38r9mkgq6diwkks04ggpyp86sr2b98w7x";
    date = "2017-09-14";
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
    rev = "e6b59f6144beb8570562539c1898a0b1fea34b41";
    date = "2017-08-15";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "0pg36fkaqffbg01slgwl21b2wwqzjzy8hmbkzpfjimq3rrfv2rrj";
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
    version = 3;
    owner = "parnurzeal";
    repo = "gorequest";
    rev = "270e07c2df77170dd42c8dbc09081656b1d46a42";
    sha256 = "14ihmm5y5z1n1cf3870mygsq3wwcw097xj16k4kn9ayqixz8mrq2";
    propagatedBuildInputs = [
      errors
      http2curl
      net
    ];
    date = "2017-09-30";
  };

  grafana = buildFromGitHub {
    version = 3;
    owner = "grafana";
    repo = "grafana";
    rev = "v4.5.2";
    sha256 = "1dyldpxlsfypcfr0grwvdp7ziydgj8r992ql1gyngwqz0nyq14cw";
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
    rev = "v1.5.2";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "b73b1b59a78445c0e8cfbef3720ed63b61d7aded45bcf7f14aff149c084e48a7";
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
      "connectivity"
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
    date = "2017-09-16";
    rev = "97ae7fbaf81620fe97840685304a78a306a39c64";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "0pwiajp6dc8kvv48fn33r7ysh13c8daaiawqxl1i99zmscfjc1i2";
  };

  hashland = buildFromGitHub {
    version = 3;
    rev = "82388a7c46a88ae29c1741138bf992916f2f3d28";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "1lwsy9r8jlklhqrjw7g6x7jc4jhgi5xqp1gpc4smdkq488g2mhjm";
    goPackagePath = "leb.io/hashland";
    date = "2017-10-01";
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
    version = 3;
    rev = "82388a7c46a88ae29c1741138bf992916f2f3d28";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "1lwsy9r8jlklhqrjw7g6x7jc4jhgi5xqp1gpc4smdkq488g2mhjm";
    goPackagePath = "leb.io/hashland";
    date = "2017-10-01";
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
    date = "2017-09-14";
    rev = "68e816d1c783414e79bc65b3994d9ab6b0a722ab";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "1jmqimjm93qzrbafg9jp5s9rs44hq05y8r8bg1f009q1mzdhwvsf";
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
    rev = "v1.3.0";
    owner = "mailgun";
    repo = "holster";
    sha256 = "0wdjmmvw6h755lnmmwrfi7p1ac7khcfjq2k83gvl4r1mimpgwn4h";
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
    version = 3;
    rev = "757f8bd43e20ae62b376efce979d8e7082c16362";
    owner  = "tildeleb";
    repo   = "hrff";
    sha256 = "0qg0y313a4bb01ki35hrzvf8ad2s616gc9ndnia0a936pwwgvml9";
    goPackagePath = "leb.io/hrff";
    date = "2017-09-27";
  };

  http2curl = buildFromGitHub {
    version = 3;
    owner = "moul";
    repo = "http2curl";
    date = "2017-09-19";
    rev = "9ac6cf4d929b2fa8fd2d2e6dec5bb0feb4f4911d";
    sha256 = "1v2sjbgcnip3j1fx05wp73xcw0j8h6p6nwwy5mbc297yklyycvi7";
  };

  httpcache = buildFromGitHub {
    version = 3;
    rev = "c1f8028e62adb3d518b823a2f8e6a95c38bdd3aa";
    owner  = "gregjones";
    repo   = "httpcache";
    sha256 = "11g3lvqpbvbp2fmgrpkyzyf1x7lz1xlhwrr0h2s2q2g4cs086wia";
    date = "2017-09-26";
    propagatedBuildInputs = [
      diskv
      goleveldb
      gomemcache
      redigo
    ];
    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';
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
    rev = "v0.29";
    sha256 = "1gxdqwaigjayhm45mg1mzr4vcnz50dgw4m4v6gqzmas26c9x2gma";
    buildInputs = [
      ace
      afero
      amber
      blackfriday
      cast
      chroma
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
      prose
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
    version = 3;
    owner = "markbates";
    repo = "inflect";
    rev = "ea17041f342f81e8849284b87bc3db1a6fc596bb";
    date = "2017-09-14";
    sha256 = "0q6ag608ivn4v2s9q7cknfrbpwdyiwswgvnkl2c4jg48jlhs97a4";
  };

  influxdb = buildFromGitHub {
    version = 3;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.3.6";
    sha256 = "1yppd7ib2pqhjv2wcgx5z15jvcp8c8fl5syhj2mq1bq7y0cbkslk";
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
    rev = "v1.28.2";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "0fdqyi49hl4hyamrwrxmlsf6i977wiqkl3izy4jhr1kznkjd9c4p";
  };

  ini_v1 = buildFromGitHub {
    version = 3;
    rev = "v1.28.2";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "0x44y3vhxz274j8bv5jpiybdm7lllqr32x92gipq496pjld09kgz";
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
    rev = "v0.4.11";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "0qwha4sjzwd1ibyg0wvam351pxq8vm1ca7jf3l7fc9jq8vvidky1";
    gxSha256 = "1g7pjwc5mdvvw1lnppcadwwsyaxapm1m0i36l4z22r4h8x2nivgi";
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
    version = 3;
    owner = "SermoDigital";
    repo = "jose";
    rev = "1.1";
    sha256 = "1m2b6y8y0nvg6g7w9a38gambajfx9m1a6a3p1r6n88fyr9j2l434";
  };

  json-filter = buildFromGitHub {
    version = 1;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0y1d6yi09ac0xlf63qrzxsi7dqf10wha3na633qzqjnpjcga97ck";
  };

  json-patch = buildFromGitHub {
    version = 3;
    owner = "evanphx";
    repo = "json-patch";
    rev = "944e07253867aacae43c04b2e6a239005443f33a";
    date = "2017-07-19";
    sha256 = "0q7zag1ng95a07xrwdw48bqw7dh7ky8frwadbpd85nxwl6fc7z61";
    propagatedBuildInputs = [
      go-flags
    ];
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
    rev = "12bd96e66386c1960ab0f74ced1362f66f552f7b";
    date = "2017-09-01";
    sha256 = "1hl1qzgxm3f5abpa2ic1gna7x5kjlikfgqar7dg2nbvlvxrwbg7l";
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
    owner = "AudriusButkevicius";
    repo = "kcp-go";
    rev = "d17218ba2121268b854dd84f2bb54679541c4048";
    sha256 = "1sqg10kvx1kdh920sprr66is5w4hymlj1r4v87pv53c0fp7l4vcp";
    propagatedBuildInputs = [
      crypto
      errors
      net
      klauspost_reedsolomon
      xor
    ];
    date = "2017-09-02";
  };

  gravitational_kingpin = buildFromGitHub {
    version = 3;
    rev = "52bc17adf63c0807b5e5b5d91350703630f621c7";
    owner = "gravitational";
    repo = "kingpin";
    sha256 = "1jrlcdblk8vpb544jk4m3rdkzvdmd6qp3ykwspwagy909dpjgwmc";
    propagatedBuildInputs = [
      template
      units
    ];
    meta.useUnstable = true;
    date = "2017-09-06";
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

  kit = buildFromGitHub {
    version = 3;
    rev = "v0.5.0";
    owner = "go-kit";
    repo = "kit";
    sha256 = "1n42pq359bgf39kgiiqwayp6xb4i6bz2isysygr3ip4kjk4r9vz4";
    subPackages = [
      "log"
      "log/level"
    ];
    propagatedBuildInputs = [
      logfmt
      stack
    ];
  };

  kubernetes-api = buildFromGitHub {
    version = 3;
    rev = "81aa34336d28aadc3a8e8da7dfd9258c5157e5e4";
    date = "2017-09-21";
    owner  = "kubernetes";
    repo   = "api";
    sha256 = "09g1gj8f2rp7kkcgisv9zrgv8y91q8xlg4aafs9ppgyas98qxd0g";
    goPackagePath = "k8s.io/api";
    goPackageAliases = [
      "k8s.io/client-go/pkg/apis"
    ];
    propagatedBuildInputs = [
      gogo_protobuf
      kubernetes-apimachinery
    ];
  };

  kubernetes-apimachinery = buildFromGitHub {
    version = 3;
    rev = "3b05bbfa0a45413bfa184edbf9af617e277962fb";
    date = "2017-09-21";
    owner  = "kubernetes";
    repo   = "apimachinery";
    sha256 = "11jvclyjv9zqgyvwncbhyv8dfkgall085crrrhgjicqg6akrx2y4";
    goPackagePath = "k8s.io/apimachinery";
    excludedPackages = "\\(testing\\|fuzzer\\)";
    propagatedBuildInputs = [
      glog
      gofuzz
      go-flowrate
      go-spew
      gogo_protobuf
      golang-lru
      kubernetes-kube-openapi
      inf_v0
      json-iterator_go
      json-patch
      net
      pborman_uuid
      pflag
      spdystream
      spec
      yaml
    ];
  };

  kubernetes-kube-openapi = buildFromGitHub {
    version = 3;
    rev = "abfc5fbe1cf87ee697db107fdfd24c32fe4397a8";
    date = "2017-09-06";
    owner  = "kubernetes";
    repo   = "kub-openapi";
    sha256 = "1xjz10cxj182q6hswxl13iwg8vam2nnpqjabpy24wip67819jrc5";
    goPackagePath = "k8s.io/kube-openapi";
    subPackages = [
      "pkg/common"
    ];
    propagatedBuildInputs = [
      go-restful
      spec
    ];
  };

  kubernetes-client-go = buildFromGitHub {
    version = 3;
    rev = "82aa063804cf055e16e8911250f888bc216e8b61";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "1ym992v5026kcnbd17fgbmch3yz04kv3iw5j7ay6iwkcr13am9zm";
    goPackagePath = "k8s.io/client-go";
    propagatedBuildInputs = [
      diskv
      glog
      gnostic
      gopass
      gophercloud
      go-autorest
      go-oidc
      go-restful-swagger12
      groupcache
      httpcache
      kubernetes-api
      kubernetes-apimachinery
      mergo
      net
      oauth2
      pflag
      protobuf
      ratelimit
    ];
    meta.useUnstable = true;
    date = "2017-09-22";
  };

  ldap = buildFromGitHub {
    version = 3;
    rev = "0ae9f2495c4a9e5d436bc9a2b13a71a2fb06ddf3";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "061rzm2pp1zhpg73a4rzyziphckiw5c7a2l2ls7d3rd9c1drv4w7";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [
      asn1-ber
    ];
    date = "2017-09-29";
  };

  ledisdb = buildFromGitHub {
    version = 3;
    rev = "57a07edd1a2e45e5e812db7aabfc9c7fb43dc7e6";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "10wbm6dqv0lfn2hf3xhcf6mb46m5h1kzq0pp5qffbhqxcpv2ry34";
    date = "2017-08-21";
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
    rev = "v0.4.1";
    owner = "xenolf";
    repo = "lego";
    sha256 = "0nwqwvjq2yp2shycn8ipr3cb8wij00kgkaybgd7147cspbzfmnrq";
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
      testify
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

  lex = buildFromGitHub {
    version = 3;
    rev = "68050f59b71a42ca5b94e7b832e5bc2cdb48af66";
    date = "2017-01-12";
    owner = "cznic";
    repo = "lex";
    sha256 = "1gx2rp0169aznsnv924q80777mzncb0w9vb2vppszpg30kh5w8zv";
    propagatedBuildInputs = [
      fileutil
      lexer
    ];
  };

  lexer = buildFromGitHub {
    version = 3;
    rev = "52ae7862082bd9649e03c1c4013a104b37811bfa";
    date = "2014-12-11";
    owner = "cznic";
    repo = "lexer";
    sha256 = "1sdwxgdx26lzaiprwkc5h8fxnxiq5qaihpqggsmw6205b5rb1yad";
    propagatedBuildInputs = [
      exp
      fileutil
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
    rev = "389e1e612993f4f70531df134fe1e1fca91736ab";
    owner = "docker";
    repo = "libnetwork";
    sha256 = "0660b2xrxw2b23x3rgbrkpsxzx6mc5vpm481ky139yz4ylvs2b7k";
    date = "2017-09-30";
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
    version = 3;
    rev = "a37ad39843113264dae84a5d89fcee28f50b35c6";
    owner = "peterh";
    repo = "liner";
    sha256 = "170lpks1y3rzs5il1v9yy6l4kh99v8avdxh0wm2kfs62cgn7mylb";
    date = "2017-09-02";
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
    propagatedBuildInputs = [
      fileutil
      mathutil
      mmap-go
      sortutil
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
    rev = "v2.12";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "0fcdlvif0jfjihhmhr8imrqvhzvcpxcdbsvqna979zcbl9d25vrk";
    goPackageAliases = [
      "gopkg.in/inconshreveable/log15.v2"
    ];
    propagatedBuildInputs = [
      go-colorable
      stack
      sys
    ];
  };

  log15_v2 = log15;

  kr_logfmt = buildFromGitHub {
    version = 3;
    rev = "b84e30acd515aadc4b783ad4ff83aff3299bdfe0";
    owner  = "kr";
    repo   = "logfmt";
    sha256 = "1p9z8ni7ijg0qxqyhkqr2aq80ll0mxkq0fk5mgsd8ly9l9f73mjc";
    date = "2014-02-26";
  };

  logfmt = buildFromGitHub {
    version = 3;
    rev = "v0.3.0";
    owner  = "go-logfmt";
    repo   = "logfmt";
    sha256 = "104vw0802vk9rmwdzqfqdl616q2g8xmzbwmqcl35snl2dggg5sia";
    propagatedBuildInputs = [
      kr_logfmt
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
    rev = "v1.0.3";
    owner = "sirupsen";
    repo = "logrus";
    sha256 = "0haa76kfw3n907gs7gn7hqa4bfg4ldk290wmdww2h1mb2vvwjrd1";
    goPackageAliases = [
      "github.com/Sirupsen/logrus"
    ];
    propagatedBuildInputs = [
      crypto
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

  lsync = buildFromGitHub {
    version = 3;
    rev = "2d7c40f41402df6f0713a749a011cddc12d1b2f3";
    owner = "minio";
    repo = "lsync";
    sha256 = "1n7kaqly6jgbvp48fznyv94yg9yc6c99pdb3iw3c0kc0ycw9xn4h";
    date = "2017-08-09";
  };

  luhn = buildFromGitHub {
    version = 3;
    rev = "v2.0.0";
    owner  = "calmh";
    repo   = "luhn";
    sha256 = "179qp1rkn185d2xj7djg193y3ia0cdlxw5spp8k7ads4k9yg0xh0";
  };

  lxd = buildFromGitHub {
    version = 3;
    rev = "lxd-2.18";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "19cqslgyzz4z8qm2sjkifz6zga46lqw30azh8kx79w70vd58pdyi";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      pkgs.acl
      pkgs.lxc
    ];
    propagatedBuildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-colorable
      go-lxc_v2
      go-sqlite3
      log15_v2
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
    rev = "v1.0.1";
    owner  = "pierrec";
    repo   = "lz4";
    sha256 = "0l0ww1lf7chx408f1d2wvwniigqpqcsbqvr8f4x1zqwjmgx3rah7";
    propagatedBuildInputs = [
      pierrec_xxhash
    ];
  };

  macaron_v1 = buildFromGitHub {
    version = 3;
    rev = "v1.2.2";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "0r7z750q7184viqcisggmfydf6n4js7nggdcsdbj1mnk6ifsarjm";
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
    version = 3;
    owner = "tidwall";
    repo = "match";
    date = "2017-10-02";
    rev = "1731857f09b1f38450e2c12409748407822dc6be";
    sha256 = "0z94spvy3k99ybj7mk5wppbxw3m059ir8k22hdskc2wy11m763ki";
  };

  mathutil = buildFromGitHub {
    version = 3;
    date = "2017-09-25";
    rev = "53c70789c7ff53526fd6c28c5a6881b138413e0c";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "14j23lzcqn9q6621bnhiw33xz8028h368b3wm7cm13g6v57m9lhb";
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
    rev = "RELEASE.2017-06-15T03-38-43Z";
    sha256 = "0gg8nil2w46pasvwaawjfs5qcsnxwh3y8hzj7r0z2s019xyyiiy5";
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
    postPatch = ''
      # Hack to workaround no longer provided `pkg/probe`
      mv vendor/github.com/minio/minio/pkg/probe pkg/probe
      find cmd -type f | xargs sed -i 's,github.com/minio/minio/pkg/probe,github.com/minio/mc/pkg/probe,g'
    '';
  };

  mc_pkg = mc.override {
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
    rev = "687988a0b5daaf7ed5051e5e374aef27f8254822";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "030ypv5gy2ylq7m369pc52rb89j79whzlnfjy4jynpjpyqnf23z0";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
      go-sockaddr
      seed
    ];
    meta.useUnstable = true;
    date = "2017-09-19";
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
    rev = "60cc6184d253efee4a3120683517028342229e21";
    sha256 = "190vd4z9lj6rd9imllz952gzra6h0cq7ns6jcsf90361argl6d19";
    propagatedBuildInputs = [
      amqp
      atomic
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
      google-api-go-client
      google-cloud-go
      handlers
      jwt-go
      logrus
      lsync
      mc_pkg
      minio-go
      mux
      mysql
      oauth2
      paho-mqtt-golang
      pb
      pq
      profile
      redigo
      klauspost_reedsolomon
      rpc
      sarama_v1
      sha256-simd
      skyring-common
      structs
      yaml_v2
    ];
    meta.useUnstable = true;
    date = "2017-09-29";
    postPatch = ''
      rm cmd/gateway-azure*.go
      sed -i 's,return newAzureLayer.*,break,' cmd/gateway-main.go
    '';
  };

  # The pkg package from minio, for bootstrapping minio
  minio_pkg = minio.override {
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

  missinggo_lib = missinggo.override {
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      iter
    ];
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
    rev = "1e94a4862ee2d92976c26ff741585d090169ed42";
    date = "2017-10-01";
    sha256 = "134inb18ik081dmm47y8w3nwwm678d4zk59gc5f1ci7b8n6pxkpw";
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
      continuity
      errors
      go-ansiterm
      go-units
      go-winio
      logrus
      sys
    ];
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
      "pkg/jsonmessage"
      "pkg/longpath"
      "pkg/mount"
      "pkg/namesgenerator"
      "pkg/pools"
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
      continuity
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
    rev = "7067f765eb93ff5e1c601fc57317e68eda1978a5";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "1gccik3ld8yi13inj9k5k0md76mgvkcg1fs1mk6hi44drk7pxsp3";
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
    date = "2017-09-21";
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
    rev = "v1.0.2";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "1zfwqsmgki2h1kfhh6xlhwvkxljgpvkp0xqj0dp6sw2giwn1wh3d";
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
    rev = "9f5d223c60793748f04a9d5b4b4eacddfc1f755d";
    owner  = "spaolacci";
    repo   = "murmur3";
    sha256 = "0r7qnzhbw0lmhaypgrg78q99qaff873v9ygjqnja946iw1dh3x5b";
    date = "2017-08-19";
  };

  mux = buildFromGitHub {
    version = 3;
    rev = "v1.5.0";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1qih7hh8lrp084p64801kff2vj6zkqglakkwpl29k33z2lh5j42a";
    propagatedBuildInputs = [
      context
    ];
  };

  mysql = buildFromGitHub {
    version = 3;
    rev = "7785c74297136c027fdf2fd6f8931c0e19be8aa7";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "0swljn46wxz9kcqi9yl7nr729rsjnygx357bsxqbkq3vd1w2imqc";
    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';
    date = "2017-09-21";
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
    rev = "177f1ceba557262b3f1c3aba4df93a29199fb4eb";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "011hiq701m01zwzxifk8vnhc8l0lj1v5ilp3z3wq26iiycpwwcff";
    date = "2017-09-24";
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
    rev = "v0.6.3";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "1d6va4pg2ki69d39q5gjy7k16nr1kf4gm78jqs9b5y66ack2aa1i";

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
      crypto
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

    postPatch = ''
      # Rename deprecated ParseNamed to ParseNormalizedNamed
      find . -type f -exec sed -i {} \
        -e 's,.ParseNamed,.ParseNormalizedNamed,g' \
        -e 's,"github.com/docker/docker/reference","github.com/docker/distribution/reference",g' \
        -e 's,"github.com/docker/docker/cli,"github.com/docker/cli/cli,g' \
        \;

      # Remove test junk
      find . \( -name testutil -or -name testagent.go \) -prune -exec rm -r {} \;
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

  oktasdk-go = buildFromGitHub {
    version = 3;
    owner = "chrismalek";
    repo = "oktasdk-go";
    rev = "ae553c909ca06a4c34eb41ee435e83871a7c2496";
    date = "2017-09-11";
    sha256 = "0jcqdiczz94xkw0xcq97adfc9nk3wgy67l419811q8j7caqim7jv";
    propagatedBuildInputs = [
      go-querystring
    ];
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

  opentracing-go = buildFromGitHub {
    version = 3;
    owner = "opentracing";
    repo = "opentracing-go";
    rev = "v1.0.2";
    sha256 = "0g9h4slaiik7fa0rx04jxdjrn9i9w597ws95hmip125jbjafvqc6";
    propagatedBuildInputs = [
      net
    ];
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

  paho-mqtt-golang = buildFromGitHub {
    version = 3;
    owner = "eclipse";
    repo = "paho.mqtt.golang";
    rev = "v1.1.0";
    sha256 = "1ikh7xkxwysk910zw3yv7kyc9g2na095s3hhs8hsp1mgdxf50n49";
    propagatedBuildInputs = [
      net
    ];
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
    date = "2017-08-24";
    rev = "657164d0228d6bebe316fdf725c69f131a50fb10";
    sha256 = "02dw9zj0dqd195nbvw360vvza92mxpbngd9gr12b0d7cihg4bcdz";
    propagatedBuildInputs = [
      go-runewidth
    ];
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 3;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.18";
    sha256 = "03xjvv2falvaq0h2zrc1w34zq3fczs0k8c4066fmxpqpc6p26yq5";
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
    rev = "0af5bab1e1ea2860c5aef8e77427bab011d774d8";
    date = "2017-09-19";
    sha256 = "0lra7i1v34vikwrswkvj0ahz22kp0m7xanyvx1dn4n8dbczqn468";
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
    version = 3;
    date = "2017-09-01";
    owner  = "coreos";
    repo   = "pkg";
    rev = "459346e834d8e97be707cd0ea1236acaaa159ffc";
    sha256 = "0fhj5mw2r1pq8yqifnal8yg1wvfsqmrpa35ig9g9npsgajd8hib7";
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
    rev = "d78d1eaf2bf1979f9ea8a34a83b9c5aa22df1e60";
    owner  = "google";
    repo   = "pprof";
    sha256 = "1drxzhhzncddfnz1qm0482hga6fa68j4cybgdml5kpgd238bxvjd";
    date = "2017-09-29";
    propagatedBuildInputs = [
      demangle
    ];
  };

  pq = buildFromGitHub {
    version = 3;
    rev = "b77235e3890a962fe8a6f8c4c7198679ca7814e7";
    owner  = "lib";
    repo   = "pq";
    sha256 = "113w5f3v6rx105xi9b1mqx0hs1cjprmx0n1gg7njid2xamnxrrg3";
    date = "2017-09-22";
  };

  predicate = buildFromGitHub {
    version = 3;
    rev = "v1.0.0";
    owner  = "vulcand";
    repo   = "predicate";
    sha256 = "1mx35iwn4y2qw396j2qdr0q72xchp3qq826p6wvcyzgsja3yml8r";
    propagatedBuildInputs = [
      trace
    ];
  };

  probing = buildFromGitHub {
    version = 3;
    rev = "0.0.1";
    owner  = "xiang90";
    repo   = "probing";
    sha256 = "0wjjml1dg64lfq4s1b6kqabz35pm02yfgc0nc8cp8y4aw2ip49vr";
  };

  procfs = buildFromGitHub {
    version = 3;
    rev = "e645f4e5aaa8506fc71d6edbc5c4ff02c04c46f2";
    date = "2017-07-03";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "1yr574ik2a83c2555vga5mqr155dd4710dc38dp6jgxrq2p7x9bh";
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
    rev = "v1.7.2";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "142r6ic5a55qzzsf9ymiwf91zz3xb7pwpghy2b23v0fpqwnsqajj";
    buildInputs = [
      aws-sdk-go
      azure-sdk-for-go
      consul_api
      dns
      fsnotify_v1
      go-autorest
      goleveldb
      gophercloud
      go-stdlib
      govalidator
      go-zookeeper
      google-api-go-client
      kubernetes-apimachinery
      kubernetes-client-go
      net
      oauth2
      opentracing-go
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
    rev = "353b8c3f3776541879f9abfd8fa8b1ae162ab394";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "065dbbjqlbj6v2jhqzfnak8jqk5px5mz2cx1m8szawb0q2vaivsc";
    propagatedBuildInputs = [
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      beorn7_perks
    ];
    date = "2017-09-21";
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
    date = "2017-09-08";
    rev = "2f17f4a9d485bf34b4bfaccc273805040e4f86c8";
    owner = "prometheus";
    repo = "common";
    sha256 = "0wn8gz95v27z17l99wvswzyr97qgxw5j8ar87wpylrx5x68b9d1h";
    buildInputs = [
      errors
      kit
      kingpin_v2
      net
      prometheus_client_model
      protobuf
      sys
      yaml_v2
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

  properties = buildFromGitHub {
    version = 3;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.3";
    sha256 = "1gbi6n1c1v686q2l4vs3az1gm6hvyzvhg7qganvvc7skr8s2v8z1";
  };

  prose = buildFromGitHub {
    version = 3;
    owner = "jdkato";
    repo = "prose";
    rev = "v1.0.0";
    sha256 = "15350sg3k7n82158j6glmmmlmzzihxw8zca9cqckbg0rll8dsihb";
    propagatedBuildInputs = [
      urfave_cli
      go-shuffle
      sentences_v1
      stats
    ];
  };

  gogo_protobuf = buildFromGitHub {
    version = 3;
    owner = "gogo";
    repo = "protobuf";
    rev = "f7f1376d9d231a646d4e62fe1075623ced6db327";
    sha256 = "06x1ldwa3fpj4pm0hdyycahxaa88qlq9p9wd1xr0iqssq6s34imj";
    excludedPackages = "test";
    date = "2017-09-27";
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
    rev = "fd18e053af8a4ff11039269006e8037ff374ce0e";
    sha256 = "0ik7nyziaqksy1iw6bkayz6alxb3dyy85icrmxwdqqs2hcvvkfvx";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
    date = "2017-09-17";
  };

  qart = buildFromGitHub {
    version = 1;
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "02n7f1j42jp8f4nvg83nswfy6yy0mz2axaygr6kdqwj11n44rdim";
  };

  qingstor-sdk-go = buildFromGitHub {
    version = 3;
    rev = "v2.2.8";
    owner  = "yunify";
    repo   = "qingstor-sdk-go";
    sha256 = "13l9i2g4w84m941w8h6p5vv0x6xz4hfyzfwvj4xlz0f584l3x4mw";
    excludedPackages = "test";
    propagatedBuildInputs = [
      go-shared
      logrus
    ];
  };

  ql = buildFromGitHub {
    version = 3;
    rev = "8c32ff10fdc2810e93a6e127119d95545497909e";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1zrprzi3zvh1n77gzxsl59pj1wf5gn9kccvl5h2hhvrssrs6a8jw";
    propagatedBuildInputs = [
      b
      exp
      go4
      golex
      lldb
      mathutil
      strutil
    ];
    date = "2017-09-05";
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
    version = 3;
    rev = "v1.4.0";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "07944wgvj6shjzcj04zlmldkcxc892zx03lcv55kc7igi77lnmyi";
  };

  radius = buildFromGitHub {
    version = 3;
    rev = "eebc3671c1699b29d5ff236cf4a8c5519384dcb5";
    date = "2017-09-03";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "1x0zaqhznilqqmvl9qnbn7ymxjwmrjp5bcj3yxbgmbgrvjhsqrr8";
    goPackagePath = "layeh.com/radius";
  };

  raft_v2 = buildFromGitHub {
    version = 3;
    date = "2017-08-30";
    # Use the library-v2-stage-one branch until it is merged
    # into master.
    rev = "c837e57a6077e74a4a3749959fb6cfefc26d7705";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "62d03237236f4c40bcccb1b0120f14aaf493c52b3eea703970d669f29452cacf";
    propagatedBuildInputs = [
      armon_go-metrics
      ugorji_go
    ];
    subPackages = [
      "."
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
    date = "2017-10-02";
    rev = "00fe6d95daadd96b272266faa5441f4f3390f331";
    sha256 = "15wxk3s8v0mwf0r3s0xqjks0qb07xklfwqi8v6mafnfizqlahahd";
    propagatedBuildInputs = [
      appengine
      aws-sdk-go
      #azure-sdk-for-go
      cgofuse
      cobra
      crypto
      #dropbox-sdk-go-unofficial
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
      qingstor-sdk-go
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
    postPatch = ''
      # Azure-sdk-for-go does not provide a stable apit status:
      rm -r azureblob/
      sed -i fs/all/all.go \
        -e '/azureblob/d'

      # Dropbox doesn't build easily
      rm -r dropbox/
      sed -i fs/all/all.go \
        -e '/dropbox/d'
      sed -i fs/hash.go \
        -e '/dbhash/d'
    '';
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
    date = "2017-10-02";
    rev = "e340dd126dfdf0139ecaecfe78f4984370f4b1c9";
    sha256 = "17vndlynzcsavqjfx7n56ym2qi9zfqjxrwx074i076d56a2cq7cn";
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

  klauspost_reedsolomon = buildFromGitHub {
    version = 3;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2017-10-01";
    rev = "6bb6130ff6a76a904c1841707d65603aec9cc288";
    sha256 = "055x7lglmb6166x4hph53iyzlgq188rxj9z3x1dk5s1x4pm5g6yl";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  templexxx_reedsolomon = buildFromGitHub {
    version = 3;
    owner = "templexxx";
    repo = "reedsolomon";
    rev = "0.1.0";
    sha256 = "0n53qkzc3qq61qgg82qg2jb3myhkm40qs5gm7dmiglqwqp9hydf2";
    subPackages = [
      "."
    ];
  };

  reflectwalk = buildFromGitHub {
    version = 3;
    date = "2017-07-26";
    rev = "63d60e9d0dbc60cf9164e6510889b0db6683d98c";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "1xpgzn3rgc222yz09nmn1h8xi2769x3b5cmb23wch0w43cj8inkz";
  };

  regexp2 = buildFromGitHub {
    version = 3;
    rev = "v1.1.6";
    owner  = "dlclark";
    repo   = "regexp2";
    sha256 = "1z44159gfiv99p32qgypwflix4krk88mnx1n5h94gy2sqhh07gi0";
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
    rev = "v0.3.10";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1nfprfxz353ljgrf561w8py2qh9x9vx8lk79c24ijv1g8ya07q7n";
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
    version = 3;
    owner = "gravitational";
    repo = "roundtrip";
    date = "2017-09-07";
    rev = "f39421c51f636f6a03a79a168aacc628e37a584b";
    sha256 = "0xq304csgsbwancqlyp467fl26lnnkwdpj59nxqgf7sh4fha6lml";
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
    rev = "86672fcb3f950f35f2e675df2240550f2a50762f";
    date = "2017-09-18";
    sha256 = "1wz3vr7cm291bmrc7xd6v6vb5fk66iqjkky34snfkv5k1bvqlkqv";
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

  sentences_v1 = buildFromGitHub {
    version = 3;
    rev = "v1.0.6";
    owner = "neurosnap";
    repo = "sentences";
    sha256 = "1shbz0hapziqswhfj2ddq3ppal10xjk63i3ndvf81sv41ipnpi7d";
    goPackagePath = "gopkg.in/neurosnap/sentences.v1";
  };

  serf = buildFromGitHub {
    version = 3;
    rev = "555c6fa2a11d1f8e08ac9964015e864a3f61e7c3";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1xgapa8209q43ciqvxc2n22cybh8xvsnjiqf1w73hld3wm47va0a";

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
    date = "2017-09-02";
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
    rev = "1.0.0";
    sha256 = "cbbc01da5c0c3509df743d99bf801534ad71865530fa119f5c2b280c726b41e9";
    propagatedBuildInputs = [
      crypto
      errors
      fs
    ];
  };

  sha256-simd = buildFromGitHub {
    version = 3;
    owner = "minio";
    repo = "sha256-simd";
    date = "2017-08-28";
    rev = "43ed500fe4d485d97534014d9f98521216240002";
    sha256 = "0nmxx95sq07fbbipfjmzkv43k2plh2ajxy174d9qddwpjv3h2014";
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
    rev = "v1.1.1";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "0zps9gpk356lff5ryxva633fch8ljcn7h6cjl35q0vfwnvx817cj";
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
    date = "2017-08-18";
    rev = "ba0eaed1782df1b25af8af69df2950472b71135d";
    owner = "softlayer";
    repo = "softlayer-go";
    sha256 = "0mvmpjraqcs0avqhh7iily07wcmhyf31hj43bfxplf2y37f9l1hb";
    propagatedBuildInputs = [
      tools
      xmlrpc
    ];
  };

  sortutil = buildFromGitHub {
    version = 3;
    date = "2015-06-17";
    rev = "4c7342852e65c2088c981288f2c5610d10b9f7f4";
    owner = "cznic";
    repo = "sortutil";
    sha256 = "1r57m3g20dm3ayp9mjqp4s4bl0wvak5ahgisgb1k6hbsc5si27vr";
  };

  spacelog = buildFromGitHub {
    version = 3;
    date = "2017-09-25";
    rev = "c1ec013bd4e81a17154d51f3039f79acb3000d1d";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "0rsg4z5lci3fiyby1abh0xai6k25h83r1k94yiwjgmq9fwcfbcbc";
    buildInputs = [
      flagfile
      sys
    ];
  };

  spdystream = buildFromGitHub {
    version = 3;
    rev = "bc6354cbbc295e925e4c611ffe90c1f287ee54db";
    owner = "docker";
    repo = "spdystream";
    sha256 = "0fmssdkjhb18p4inqzf2ydqsa3rza903ni8id9j5qb8pfakx7pqh";
    date = "2017-09-12";
    propagatedBuildInputs = [
      websocket
    ];
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
    date = "2017-09-28";
    rev = "48c2a7185575f9103a5a3863eff950bb776899d2";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "1wkhh19avhpw6ag70c24dzdd3l7ab0b7a1wz8paf0h9cfya052d1";
    propagatedBuildInputs = [
      jsonpointer
      jsonreference
      swag
    ];
  };

  srslog = buildFromGitHub {
    version = 3;
    rev = "4d2c753a4ee12647a5a279ee6e6e767861509706";
    date = "2017-09-20";
    owner  = "RackSec";
    repo   = "srslog";
    sha256 = "0kpfdbh9852zqd4amlj0v3mwhlz650h2czlbgm9vdidps9siz6yq";
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

  stats = buildFromGitHub {
    version = 3;
    rev = "4a163274fa4ca0b524ccee24757d7bec79475aca";
    owner = "montanaflynn";
    repo = "stats";
    sha256 = "13yz9808qjwr4804algxvnhdwgp3hkkj79a3viwjxs4ci0p1cph8";
    date = "2017-07-29";
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
    rev = "144ddc569a1a398856fa9c75dfcf2854ac4d01b0";
    owner = "docker";
    repo = "swarmkit";
    sha256 = "1qrnb4nsr0sqmn3vm91vc9ajxxpvygszv42sy4h6aq763lcxr160";
    date = "2017-09-29";
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
    rev = "9d3f812e23d270d1c66a9a01e20af1005061cdc4";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "0w7c36cq8q3r66wi5bvb7bp3kv9dsxx64zxz5v1cwzr0a8nrl79f";
    date = "2017-08-29";
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
    rev = "v0.14.38";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "0k64f0zy6fxqi40mn0mn7x63b7aray0xk1vcbg60qhskay382lh8";
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
      go-shellquote
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
    rev = "a7a4c189eb47ed33ce7b35f2880070a0c82a67d4";
    date = "2017-09-25";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "1qi34j1m4jpl20injkw9pk69qkj1zbmpbgg2vcvza2ycwc6849fv";
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
    rev = "37f4271387456dd1bf82ab1ad9229f060cc45386";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "1ki7svma2y9va1wb0fc8vwa0wncgsgs17nxz1rqc9i8iim21mfp1";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
    ];
    date = "2017-08-14";
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
    rev = "v2.3.2";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "7ee600d525cbda4893b33556ffa44a92bffe1f2f7a9b6fd6a5ccd5422ab63f58";
    nativeBuildInputs = [
      pkgs.protobuf-cpp
      protobuf.bin
    ];
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
      genproto
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
      lemma
      logrus
      kubernetes-apimachinery
      moby_for_runc
      net
      osext
      otp
      oxy
      predicate
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
    excludedPackages = "\\(test\\|suite\\|fixtures\\|examples\\|docker\\)";
    meta.autoUpdate = false;
    patches = [
      (fetchTritonPatch {
        rev = "bbf0173a53b7b44b052022532eaca9aa0565f5e3";
        file = "t/teleport/fix.patch";
        sha256 = "7deb529032415073c1883b0557b35156c28b9010f6dab0ae41c4262f1ab38f8b";
      })
    ];
    postPatch = ''
      sed -i 's,--gofast_out,--go_out,' Makefile
    '';
    preBuild = ''
      GATEWAY_SRC=$(readlink -f unpack/grpc-gateway*)/src
      API_SRC=$GATEWAY_SRC/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis
      PROTO_INCLUDE=$GATEWAY_SRC:$API_SRC \
        make -C go/src/$goPackagePath buildbox-grpc
    '';
    preFixup = ''
      test -f "$bin"/bin/tctl
    '';
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
    rev = "d51f2f6d6ccb97dd83ed04ae2f79c34234851f39";
    date = "2017-09-30";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "0b866s59zkp8r75msqi8hl2bjpjypxbzb2b4hm18w3vzj7hm4rc2";
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
    rev = "4b871cd428eeab064e45ff2bf65054bb7eb10d6c";
    owner  = "a8m";
    repo   = "tree";
    sha256 = "0a0qvgn01yfs67jf6vgzwr8p221wd9nqqi7wpmpw0vcnr0gm4b0b";
    date = "2017-08-26";
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
    rev = "87ba7933b8d7520e5e6e27460e25e42c2fccab9f";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "1ijb2r8sknrxvdqw4x6x2nxwgam0lms9b8dv0v9k1ssbrszy7vr7";
    date = "2017-08-26";
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
    rev = "v0.8.3";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "1n83qqb7722zprg06kjlv10cvcjybn1cs42l2wvppnpr63i9gxp0";

    nativeBuildInputs = [
      pkgs.protobuf-cpp
      protobuf.bin
    ];

    buildInputs = [
      armon_go-metrics
      aws-sdk-go
      columnize
      cockroach-go
      complete
      consul_api
      copystructure
      crypto
      duo_api_golang
      errwrap
      errors
      etcd_client
      go-cache
      go-cleanhttp
      go-colorable
      go-crypto
      go-errors
      go-github
      go-glob
      go-hclog
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
      oktasdk-go
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
      vault-plugin-auth-gcp
      vault-plugin-auth-kubernetes
      yaml
    ];

    postPatch = ''
      rm -r physical/azure
      sed -i '/physAzure/d' cli/commands.go
    '';

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
    rev = "v0.8.3";
    sha256 = "1n83qqb7722zprg06kjlv10cvcjybn1cs42l2wvppnpr63i9gxp0";
    version = 3;
  };

  vault_for_plugins = vault.override {
    subPackages = [
      "api"
      "helper/certutil"
      "helper/compressutil"
      "helper/consts"
      "helper/errutil"
      "helper/jsonutil"
      "helper/logformat"
      "helper/mlock"
      "helper/parseutil"
      "helper/pluginutil"
      "helper/policyutil"
      "helper/salt"
      "helper/strutil"
      "helper/wrapping"
      "logical"
      "logical/framework"
      "logical/plugin"
      "version"
    ];
    nativeBuildInputs = [
    ];
    buildInputs = [
    ];
    preBuild = ''
    '';
    propagatedBuildInputs = [
      errwrap
      go-cleanhttp
      go-hclog
      go-multierror
      go-plugin
      go-radix
      go-rootcerts
      hashicorp_go-uuid
      hcl
      jose
      logxi
      mapstructure
      net
      pester
      snappy
      structs
      sys
    ];
    rev = "v0.8.3";
    sha256 = "1n83qqb7722zprg06kjlv10cvcjybn1cs42l2wvppnpr63i9gxp0";
    version = 3;
  };

  vault-plugin-auth-gcp = buildFromGitHub {
    version = 3;
    owner = "hashicorp";
    repo = "vault-plugin-auth-gcp";
    rev = "67b1d8aca6119487cefbe8f356342f7eca8bf6e0";
    sha256 = "1jxh94mg5x1day13sv1wqw2fsn2y2q3r7xvajlpdjp0dypm3wwvl";
    date = "2017-09-28";
    propagatedBuildInputs = [
      go-cleanhttp
      google-api-go-client
      go-jose_v2
      jose
      oauth2
      vault_for_plugins
    ];
  };

  vault-plugin-auth-kubernetes = buildFromGitHub {
    version = 3;
    owner = "hashicorp";
    repo = "vault-plugin-auth-kubernetes";
    rev = "382259068d5806ae463e005616a1948dc76e02f7";
    sha256 = "0ag6gyz2cki3cdbc9sbb376zf3qgpa80jlx7vfa0pnplr13l01qw";
    date = "2017-09-27";
    propagatedBuildInputs = [
      go-cleanhttp
      go-multierror
      jose
      kubernetes-api
      kubernetes-apimachinery
      logxi
      mapstructure
      vault_for_plugins
    ];
  };

  viper = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "viper";
    rev = "v1.0.0";
    sha256 = "0x36dg3if4c5nliyq73801jjs0q2k94kjb0q8fssh9azzfqm8cf4";
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
    rev = "eb3733d160e74a9c7e442f435eb3bea458e1d19f";
    date = "2017-08-12";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "1kw11dsc2rrj0j08g2gvcb5azwmf4lbzslk33a5inmwzzn1g79ps";
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

  xor = buildFromGitHub {
    version = 3;
    rev = "0.1.2";
    owner  = "templexxx";
    repo   = "xor";
    sha256 = "0r0gcii6p1qaxxd9sgbwl693jp4kvciqw2qnr1a80l4rv6dyaigf";
    propagatedBuildInputs = [
      cpufeat
    ];
  };

  xorm = buildFromGitHub {
    version = 3;
    rev = "v0.6.3";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "1byqf47ci1y8ny6kcnj6hg3yd0hcg182b41y2x3dxzli6al64k9p";
    propagatedBuildInputs = [
      core
    ];
  };

  xstrings = buildFromGitHub {
    version = 3;
    rev = "d6590c0c31d16526217fa60fbd2067f7afcd78c5";
    date = "2017-09-08";
    owner  = "huandu";
    repo   = "xstrings";
    sha256 = "03ff5krgpq5js8bm32vj31qc7z45a0cswa97c5bqn9kag44cmidm";
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
