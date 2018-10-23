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

      SOURCE_DATE_EPOCH=$(find . -type f -print0 | xargs -0 -r stat -c '%Y' | sort -n | tail -n 1)
      if [ "$start" -lt "$SOURCE_DATE_EPOCH" ]; then
        str="The newest file is too close to the current date:\n"
        str+="  File: $(date -u -d "@$SOURCE_DATE_EPOCH")\n"
        str+="  Current: $(date -u)\n"
        echo -e "$str" >&2
        exit 1
      fi
      echo -n "Clamping to date: " >&2
      date -d "@$SOURCE_DATE_EPOCH" --utc >&2

      for json in $(find . -name package.json); do
        pushd "$(dirname "$json")" >/dev/null
        gx --verbose install --global
        popd >/dev/null
      done

      echo "Building GX Archive" >&2
      cd "$unpackDir"
      deterministic-zip '.' >"$out"
    '';

    buildInputs = [
      src.deterministic-zip
      gx.bin
    ];

    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = sha256;
    preferLocalBuild = true;

    passthru = {
      inherit src;
    };
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
    version = 6;
    rev = "v1.2.0";
    owner = "golang";
    repo = "appengine";
    sha256 = "b515763c47d8640696ee5c1672fde386dd74a497314ceced958c2e126b1eb74c";
    goPackagePath = "google.golang.org/appengine";
    excludedPackages = "aetest";
    propagatedBuildInputs = [
      protobuf
      net
      text
    ];
    postPatch = ''
      find . -name \*_classic.go -delete
      rm internal/main.go
    '';
  };

  build = buildFromGitHub {
    version = 6;
    rev = "24469dd429f05bdb34b644430843761abf7e1367";
    date = "2018-10-19";
    owner = "golang";
    repo = "build";
    sha256 = "e7dd9c1effca7b6d25a6fffad05e8a2561516a38e50727940845978d6a3f6a2a";
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
    version = 6;
    rev = "0c41d7ab0a0ee717d4590a44bcb987dfd9e183eb";
    date = "2018-10-15";
    owner = "golang";
    repo = "crypto";
    sha256 = "1f91a6563310ab7d766fa42c51d7feb29f3c5b7dc2eb8666610ef9c617bc6033";
    goPackagePath = "golang.org/x/crypto";
    buildInputs = [
      net_crypto_lib
    ];
    propagatedBuildInputs = [
      sys
    ];
  };

  debug = buildFromGitHub {
    version = 6;
    rev = "488a851a00806d45233e1ef6a0f8fcb891db6fe0";
    date = "2018-10-17";
    owner = "golang";
    repo = "debug";
    sha256 = "b06f95a813d8a5b9533996c5fecb89501d2602b2bb59691386c8d1fd2a3be30d";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
    propagatedBuildInputs = [
      cobra
      readline
    ];
  };

  geo = buildFromGitHub {
    version = 6;
    rev = "476085157cff9aaeef4d4f124649436542d4114a";
    owner = "golang";
    repo = "geo";
    sha256 = "136a3adca9a3707556d4a3ff9210bf383c10a923e233a1d47cc955d9d2184de7";
    date = "2018-10-08";
  };

  glog = buildFromGitHub {
    version = 6;
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-26";
    owner = "golang";
    repo = "glog";
    sha256 = "1ck5grhwbi76lv8v72vgwza0y7cgyb757x69q8i6zfm3kqx96iis";
  };

  image = buildFromGitHub {
    version = 6;
    rev = "991ec62608f3c0da01d400756917825d1e2fd528";
    date = "2018-09-26";
    owner = "golang";
    repo = "image";
    sha256 = "d35271e3381a62e6606a907b80c02ba5690d66339b9c9f9444b939b40cfe60d8";
    goPackagePath = "golang.org/x/image";
    propagatedBuildInputs = [
      text
    ];
  };

  net = buildFromGitHub {
    version = 6;
    rev = "9b4f9f5ad5197c79fd623a3638e70d8b26cef344";
    date = "2018-10-23";
    owner = "golang";
    repo = "net";
    sha256 = "14e634088b2e3e1e098dac8215d3042021e9cdf6612397ae3f7c3681541bb32b";
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
    version = 6;
    rev = "9dcd33a902f40452422c2367fefcb95b54f9f8f8";
    date = "2018-10-17";
    owner = "golang";
    repo = "oauth2";
    sha256 = "9fc43c481cc24f96b41a29d10077b59c015b275fceb9481393b7b75a5b55be43";
    goPackagePath = "golang.org/x/oauth2";
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };

  protobuf = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner = "golang";
    repo = "protobuf";
    sha256 = "8948412b1c28d0dc8939737f4e485eea25f80719d09b146697cff7a932a3e2ed";
    goPackagePath = "github.com/golang/protobuf";
    excludedPackages = "\\(test\\|conformance\\)";
  };

  snappy = buildFromGitHub {
    version = 6;
    rev = "2e65f85255dbc3072edf28d6b5b8efc472979f5a";
    date = "2018-05-18";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "0lr1bp327n6w0f833dwlnwg05wfba4krf4443zahgws5a55mwk39";
  };

  sync = buildFromGitHub {
    version = 6;
    rev = "1d60e4601c6fd243af51cc01ddf169918a5407ca";
    date = "2018-03-14";
    owner  = "golang";
    repo   = "sync";
    sha256 = "26439b8e04b4bb534d823e36b80b0659c29fea5095a9f3d7fb15d12ebf2010ab";
    goPackagePath = "golang.org/x/sync";
    propagatedBuildInputs = [
      net
    ];
  };

  sys = buildFromGitHub {
    version = 6;
    rev = "44b849a8bc13eb42e95e6c6c5e360481b73ec710";
    date = "2018-10-23";
    owner  = "golang";
    repo   = "sys";
    sha256 = "a3061358c2b1d5537fe7718810ee73e3649b9d6641762e632024259a777d65b9";
    goPackagePath = "golang.org/x/sys";
  };

  text = buildFromGitHub {
    version = 6;
    rev = "4d1c5fb19474adfe9562c9847ba425e7da817e81";
    owner = "golang";
    repo = "text";
    sha256 = "071685b06c9f469496fc87dcccba72ce52b95fe4197343e4241a6bc3c66cbfc2";
    goPackagePath = "golang.org/x/text";
    excludedPackages = "\\(cmd\\|test\\)";
    buildInputs = [
      tools_for_text
    ];
    date = "2018-10-10";
  };

  time = buildFromGitHub {
    version = 6;
    rev = "fbb02b2291d28baffd63558aa44b4b56f178d650";
    date = "2018-04-12";
    owner  = "golang";
    repo   = "time";
    sha256 = "1hqz404sg8589x0k49671znn5i2z5f7g9m5i6djjvg27n4k5xdxf";
    goPackagePath = "golang.org/x/time";
    propagatedBuildInputs = [
      net
    ];
  };

  tools = buildFromGitHub {
    version = 6;
    rev = "40a48ad93fbe707101afb2099b738471f70594ec";
    date = "2018-10-23";
    owner = "golang";
    repo = "tools";
    sha256 = "f879c8a003b6f77720d999d83444c56271abaa4e58ccdd6697b540b8cb43c766";
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
      redigo
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

  tools_for_text = tools.override {
    buildInputs = [ ];
    subPackages = [
      "go/ast/astutil"
      "go/buildutil"
      "go/callgraph"
      "go/callgraph/cha"
      "go/gcexportdata"
      "go/internal/cgo"
      "go/internal/gcimporter"
      "go/loader"
      "go/packages"
      "go/ssa"
      "go/ssa/ssautil"
      "go/types/typeutil"
      "internal/fastwalk"
      "internal/gopathwalk"
      "internal/semver"
    ];
  };

  ## THIRD PARTY

  ace = buildFromGitHub {
    version = 6;
    owner = "yosssi";
    repo = "ace";
    rev = "2b21b56204aee785bf8d500c3f9dcbe3ed7d4515";
    sha256 = "0cm342awr2hvbs94gcmacfrxfxrzy1xc7vwm5ghis18g1hpfn0c7";
    buildInputs = [
      gohtml
    ];
    date = "2018-06-17";
  };

  acme = buildFromGitHub {
    version = 5;
    owner = "hlandau";
    repo = "acme";
    rev = "v0.0.67";
    sha256 = "1l2a1y3mqv1mfri568j967n6jnmzbdb6cxm7l06m3lwidlzpjqvg";
    buildInputs = [
      pkgs.libcap
    ];
    propagatedBuildInputs = [
      jmhodges_clock
      crypto
      dexlogconfig
      easyconfig_v1
      hlandau_goutils
      kingpin_v2
      go-jose_v1
      go-systemd
      go-wordwrap
      graceful_v1
      satori_go-uuid
      link
      net
      pb_v1
      service_v2
      svcutils_v1
      xlog
      yaml_v2
    ];
  };

  aeshash = buildFromGitHub {
    version = 6;
    rev = "8ba92803f64b76c91b111633cc0edce13347f0d1";
    owner  = "tildeleb";
    repo   = "aeshash";
    sha256 = "d3428c8f14db3b9589b3c97b0a0c3b30cb7a19356d11ab26a2b08b6ecb5c365c";
    goPackagePath = "leb.io/aeshash";
    date = "2016-11-30";
    subPackages = [
      "."
    ];
    meta.autoUpdate = false;
    propagatedBuildInputs = [
      hashland_for_aeshash
    ];
  };

  afero = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "afero";
    rev = "v1.1.2";
    sha256 = "ec8054728e634fb4abcd14d537f9ed86277836dd6128335b2eb0497b6de4814c";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  akamaiopen-edgegrid-golang = buildFromGitHub {
    version = 6;
    owner = "akamai";
    repo = "AkamaiOPEN-edgegrid-golang";
    rev = "v0.6.2";
    sha256 = "0sbij3pfkig4yggl1l34b8dz17s6a5iyq3alcqiwris3d154zws6";
    propagatedBuildInputs = [
      go-homedir
      gojsonschema
      ini
      logrus
      google_uuid
    ];
  };

  alertmanager = buildFromGitHub {
    version = 6;
    owner = "prometheus";
    repo = "alertmanager";
    rev = "v0.15.2";
    sha256 = "415dac05a0bca72428afc3553231ceac9e4cc682a83faaa1988ea2357513f2be";
    propagatedBuildInputs = [
      backoff
      errors
      golang_protobuf_extensions
      hashicorp_go-sockaddr
      satori_go-uuid
      kingpin_v2
      kit_logging
      memberlist
      mesh
      net
      oklog
      prometheus_pkg
      prometheus_common
      prometheus_client_golang
      gogo_protobuf
      cespare_xxhash
      ulid
      yaml_v2
    ];
    postPatch = ''
      grep -q '= uuid.NewV4().String()' silence/silence.go
      sed -i 's,uuid.NewV4(),uuid.Must(uuid.NewV4()),' silence/silence.go
    '';
  };

  aliyungo = buildFromGitHub {
    version = 6;
    owner = "denverdino";
    repo = "aliyungo";
    rev = "a0026e2d173daac7748efb20d29288c7514d5419";
    date = "2018-10-11";
    sha256 = "2a43b26df1d0329ec73300d74d192b0858f7598f0271015d422c5ba54e4cd766";
    propagatedBuildInputs = [
      protobuf
      text
    ];
  };

  aliyun-oss-go-sdk = buildFromGitHub {
    version = 6;
    rev = "1.9.1";
    owner  = "aliyun";
    repo   = "aliyun-oss-go-sdk";
    sha256 = "baf4347e5b85359892711fab6695595b416234a646dd4a6ca7a59e98b849ffe9";
    subPackages = [
      "oss"
    ];
  };

  amber = buildFromGitHub {
    version = 6;
    owner = "eknkc";
    repo = "amber";
    rev = "cdade1c073850f4ffc70a829e31235ea6892853b";
    date = "2017-10-10";
    sha256 = "006nbvabx3wp7lwpc021crazzxysp8p3zcwd7263fsq3dx225fb7";
  };

  amqp = buildFromGitHub {
    version = 6;
    owner = "streadway";
    repo = "amqp";
    rev = "70e15c650864f4fc47f5d3c82ea117285480895d";
    date = "2018-08-06";
    sha256 = "255767fb809fce04bfe7250ab45cd6ecf368a5905312313b5bda043ab1270d23";
  };

  ansicolor = buildFromGitHub {
    version = 5;
    owner = "shiena";
    repo = "ansicolor";
    rev = "a422bbe96644373c5753384a59d678f7d261ff10";
    date = "2015-11-19";
    sha256 = "1683x3yhny5xbqf9kp3i9rpkj1gkc6a6w5r4p5kbbxpzidwmgb35";
  };

  ansiterm = buildFromGitHub {
    version = 5;
    owner = "juju";
    repo = "ansiterm";
    rev = "720a0952cc2ac777afc295d9861263e2a4cf96a1";
    date = "2018-01-09";
    sha256 = "1kp0qg4rivjqgf4p2ymrbrg980k1xsgigp3f4qx5h0iwkjsmlcm4";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
      vtclean
    ];
  };

  asn1-ber_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.2";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "f2d08ed769d114aec3e8cdfdda5fb862b60a28a86724ef0ba5abb2a36a63279d";
    goPackagePath = "gopkg.in/asn1-ber.v1";
  };

  atime = buildFromGitHub {
    version = 6;
    owner = "djherbis";
    repo = "atime";
    rev = "89517e96e10b93292169a79fd4523807bdc5d5fa";
    sha256 = "0m2s1qqcd1j32i4mxfcxm8r087v5rpf2qp5y49wng8i1qk9jmgzc";
    date = "2017-02-15";
  };

  atomic = buildFromGitHub {
    version = 6;
    owner = "uber-go";
    repo = "atomic";
    rev = "v1.3.2";
    sha256 = "17h66zhhs1d5vvm506ldplckdih6aajxp5pw2v4012y71i18lx04";
    goPackagePath = "go.uber.org/atomic";
    goPackageAliases = [
      "github.com/uber-go/atomic"
    ];
  };

  atomicfile = buildFromGitHub {
    version = 6;
    owner = "facebookgo";
    repo = "atomicfile";
    rev = "2de1f203e7d5e386a6833233882782932729f27e";
    sha256 = "0p2ga2ny0safzmdfx9r5m1hqjd8a5bmild797axczv19dlx2ywvx";
    date = "2015-10-19";
  };

  auroradnsclient = buildFromGitHub {
    version = 5;
    rev = "v1.0.3";
    owner  = "edeckers";
    repo   = "auroradnsclient";
    sha256 = "1zyx9imgqz8y7fdjrnzf0qmggavk3cgmz9vn49gi9nkc57xsqfd8";
    propagatedBuildInputs = [
      logrus
    ];
  };

  aws-sdk-go = buildFromGitHub {
    version = 6;
    rev = "v1.15.60";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "77d7f7e1f43856dc50a7d869dfcacb03e338f9c01359c2e619b872a4febc470c";
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
    version = 6;
    rev = "v21.3.0";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "19321ef22ddc252474ff062bef09aa8c29ed82900b8694ed5b0d8e551eefabf0";
    subPackages = [
      "services/compute/mgmt/2017-12-01/compute"
      "storage"
      "version"
    ];
    propagatedBuildInputs = [
      go-autorest
      satori_go-uuid
      guid
    ];
  };

  backoff = buildFromGitHub {
    version = 6;
    owner = "cenkalti";
    repo = "backoff";
    rev = "62661b46c4093e2c1f38d943e663db1a29873e80";
    sha256 = "24e6144bd6d7a461e7575ab65e41bb3bf135384bea4521493fe5cea2bbbfd56d";
    propagatedBuildInputs = [
      net
    ];
    date = "2018-10-03";
  };

  barcode = buildFromGitHub {
    version = 6;
    owner = "boombuler";
    repo = "barcode";
    rev = "34fff276c74eba9c3506f0c6f4064dbaa67d8da3";
    sha256 = "9c7132b253429911b659230dfdd1066b3be0a1429a7a509ddfc4002a07ef9ecd";
    date = "2018-08-09";
  };

  base32 = buildFromGitHub {
    version = 6;
    owner = "whyrusleeping";
    repo = "base32";
    rev = "c30ac30633ccdabefe87eb12465113f06f1bab75";
    sha256 = "1g2ah84rf7nv08j89crbpmxn74gc4x0x0n2zr0v9l7iwx5iqblv6";
    date = "2017-08-28";
  };

  base58 = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "mr-tron";
    repo   = "base58";
    sha256 = "1fb21a553fb92ffee0fa03c4234709ffdb2498feb2d79d796423ae1e5bf28387";
  };

  binary = buildFromGitHub {
    version = 6;
    owner = "alecthomas";
    repo = "binary";
    rev = "6e8df1b1fb9d591dfc8249e230e0a762524873f3";
    date = "2017-11-01";
    sha256 = "0fms5gs17j1ab1p2kfzf5ihkk2j8lhngg5609km0sydaci7sj5y9";
  };

  binding = buildFromGitHub {
    version = 6;
    date = "2017-06-11";
    rev = "ac54ee249c27dca7e76fad851a4a04b73bd1b183";
    owner = "go-macaron";
    repo = "binding";
    sha256 = "1iarx97i3axs42k6i1x9vijgwc014ra3jjz0nmgaf8xdaxjhvnzv";
    buildInputs = [
      com
      macaron_v1
    ];
  };

  blackfriday = buildFromGitHub {
    version = 6;
    owner = "russross";
    repo = "blackfriday";
    rev = "v1.5.2";
    sha256 = "59c63e5b557a74f80006f369144a465af456b4c2b5b36cd390fed7968f092c09";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    meta.autoUpdate = false;
  };

  blake2b-simd = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "blake2b-simd";
    date = "2016-07-23";
    rev = "3f5f724cb5b182a5c278d6d3d55b40e7f8c2efb4";
    sha256 = "0f6gsg38lljxsbcpnlrmacg0s4rasjd9j4fj8chhvkc1jj5g2n4r";
  };

  blazer = buildFromGitHub {
    version = 6;
    rev = "2081f5bf046503f576d8712253724fbf2950fffe";
    owner  = "minio";
    repo   = "blazer";
    sha256 = "13vp5mzk7kvw61lm1zkwkdrc9pvbvzrmjhmricb18ww16c6yhzki";
    meta.useUnstable = true;
    date = "2017-11-26";
  };

  bbolt = buildFromGitHub {
    version = 6;
    rev = "7ee3ded59d4835e10f3e7d0f7603c42aa5e83820";
    owner  = "coreos";
    repo   = "bbolt";
    sha256 = "7e12ed6c92840f957dc1f00f3f98570a8174a9a61ed2b0ffbc3c85139373ee7d";
    date = "2018-09-12";
    goPackagePath = "go.etcd.io/bbolt";
    goPackageAliases = [
      "github.com/coreos/bbolt"
    ];
    propagatedBuildInputs = [
      sys
    ];
  };

  bolt = buildFromGitHub {
    version = 6;
    rev = "fd01fc79c553a8e99d512a07e8e0c63d4a3ccfc5";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "d1548c62deb449242418446c07490c9332a0d0c7cc3d476ab4ed77810e409474";
    buildInputs = [
      sys
    ];
    date = "2018-03-02";
  };

  btcd = buildFromGitHub {
    version = 6;
    owner = "btcsuite";
    repo = "btcd";
    date = "2018-10-13";
    rev = "67e573d211ace594f1366b4ce9d39726c4b19bd0";
    sha256 = "9653f2eecb46567e0f773b85676b805b4478deed6af0d162b73c706bdadf6643";
    subPackages = [
      "btcec"
    ];
  };

  btree = buildFromGitHub {
    version = 6;
    rev = "4030bb1f1f0c35b30ca7009e9ebd06849dd45306";
    owner  = "google";
    repo   = "btree";
    sha256 = "7b51cd8828f9a0e666aa45ad9afc6f8c0274390632c5fb326752d69f5ad3737e";
    date = "2018-08-13";
  };

  builder = buildFromGitHub {
    version = 6;
    rev = "v0.3.2";
    owner  = "go-xorm";
    repo   = "builder";
    sha256 = "334fa9bb1fe66003f638e06b69b62d1389f922bad9138d56cbbcf478a137267e";
  };

  buildinfo = buildFromGitHub {
    version = 6;
    rev = "337a29b5499734e584d4630ce535af64c5fe7813";
    owner  = "hlandau";
    repo   = "buildinfo";
    sha256 = "10nixanz1iclg1psfxl6nfj4j3i5mlzal29lh68ala04ps8s9r4z";
    date = "2016-11-12";
    propagatedBuildInputs = [
      easyconfig_v1
    ];
  };

  bufio_v1 = buildFromGitHub {
    version = 6;
    date = "2014-06-18";
    rev = "567b2bfa514e796916c4747494d6ff5132a1dfce";
    owner  = "go-bufio";
    repo   = "bufio";
    sha256 = "1xyh0241qc1zwrqc431ngj1azxrqi6gx9zw6rd4dksvsmbz8b4iq";
    goPackagePath = "gopkg.in/bufio.v1";
  };

  bytefmt = buildFromGitHub {
    version = 6;
    date = "2018-09-06";
    rev = "2aa6f33b730c79971cfc3c742f279195b0abc627";
    owner  = "cloudfoundry";
    repo   = "bytefmt";
    sha256 = "68ef35563c3ba19ec34cc815a9973486b7b4d8c18b12b3646fda2c797b2214a4";
    goPackagePath = "code.cloudfoundry.org/bytefmt";
    goPackageAliases = [
      "github.com/cloudfoundry/bytefmt"
    ];
  };

  cachecontrol = buildFromGitHub {
    version = 6;
    owner = "pquerna";
    repo = "cachecontrol";
    rev = "1555304b9b35fdd2b425bccf1a5613677705e7d0";
    date = "2018-05-17";
    sha256 = "1rxvdxb4j7mvbyqsazfxy2vgg5wyvcmw9yx695bdnqicxlkwjpix";
  };

  candidclient = buildFromGitHub {
    version = 6;
    rev = "4bc1e18d38ce89a333e9ea07825ed1778e54278d";
    owner  = "CanonicalLtd";
    repo   = "candidclient";
    sha256 = "89d4a5f99e294e43ddf8c77f9fdb2e608afa8d15179d509d1cafbcb6c557613b";
    date = "2018-10-10";
    excludedPackages = "test";
    propagatedBuildInputs = [
      environschema_v1
      errgo_v1
      httprequest_v1
      macaroon-bakery_v2
      macaroon_v2
      names_v2
      net
      usso
      utils
    ];
    postPatch = ''
      grep -q 'candidclient.v1' groupcache.go
      sed -i 's,gopkg.in/CanonicalLtd/candidclient.v1,github.com/CanonicalLtd/candidclient,g' \
        groupcache.go client.go client_generated.go
      grep -r 'candidclient.v1' .
    '';
  };

  cascadia = buildFromGitHub {
    version = 6;
    rev = "680b6a57bda4f657485ad44bdea42342ead737bc";
    owner  = "andybalholm";
    repo   = "cascadia";
    sha256 = "faf96ccbf3b215549cd417560c8fa24dca1b6c98cb00ea9b8b3e3fd3b164c700";
    propagatedBuildInputs = [
      net
    ];
    date = "2018-10-12";
  };

  cast = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "cast";
    rev = "efb632f0f61348654b631fd11da5ff457a5ca2ef";
    sha256 = "77335f5fdbbeb8d5548d459a98461313d6777c3618233448ef6a6372bd0a5eed";
    buildInputs = [
      jwalterweatherman
    ];
    date = "2018-10-21";
  };

  cbauth = buildFromGitHub {
    version = 3;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38a";
    owner = "couchbase";
    repo = "cbauth";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  cbor = buildFromGitHub {
    version = 6;
    owner = "whyrusleeping";
    repo = "cbor";
    rev = "63513f603b11583741970c5045ea567130ddb492";
    sha256 = "095n3ylchw5nlbg7ca2jjb8ykc91hffxxdzzcql9y96kf4qd1wnb";
    date = "2017-10-05";
  };

  certificate-transparency-go = buildFromGitHub {
    version = 6;
    owner = "google";
    repo = "certificate-transparency-go";
    rev = "v1.0.21";
    sha256 = "91c94ccafc0309801ae72d06946cb6d73fbda74a49253c135cc23433d240578d";
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
      crypto
      net
      protobuf
      gogo_protobuf
    ];
  };

  cfssl = buildFromGitHub {
    version = 6;
    rev = "00198453225de901f8e41208f1656aa63dae0642";
    owner  = "cloudflare";
    repo   = "cfssl";
    sha256 = "6789b16e2d5012cb41b20646fc3dce96b24a171e4b6910294c8438ac354aad6e";
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
    date = "2018-10-22";
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
    version = 6;
    rev = "v1.1.0";
    owner  = "billziss-gh";
    repo   = "cgofuse";
    sha256 = "0ddb6bkls9f7z1lv0jp883940zp82xbcsw2b9w8jj3hhibfgl89g";
    buildInputs = [
      pkgs.fuse_2
    ];
  };

  chacha20 = buildFromGitHub {
    version = 6;
    rev = "8b13a72661dae6e9e5dea04f344f0dc95ea29547";
    owner  = "aead";
    repo   = "chacha20";
    sha256 = "19gpm9iypd9xdqzc2g0rvw9s1vmg63is4kamnsjdd90gcwkkjdbg";
    date = "2018-07-09";
    propagatedBuildInputs = [
      sys
    ];
  };

  chalk = buildFromGitHub {
    version = 6;
    rev = "22c06c80ed312dcb6e1cf394f9634aa2c4676e22";
    owner  = "ttacon";
    repo   = "chalk";
    sha256 = "0s5ffh4cilfg77bfxabr5b07sllic4xhbnz5ck68phys5jq9xhfs";
    date = "2016-06-26";
  };

  chroma = buildFromGitHub {
    version = 6;
    rev = "01e18834b5ddd9869ee9946effe6c23c782fb34b";
    owner  = "alecthomas";
    repo   = "chroma";
    sha256 = "6f8af24e1f0660c6d85fd7e1849ed46db06019dfb6760cecdc1f9b2c6b4f261e";
    excludedPackages = "cmd";
    propagatedBuildInputs = [
      fnmatch
      regexp2
    ];
    meta.useUnstable = true;
    date = "2018-10-13";
  };

  circbuf = buildFromGitHub {
    version = 6;
    date = "2015-08-27";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "1g4rrgv936x8mfdqsdg3gzz79h763pyj03p76pranq9cpvzg3ws2";
  };

  circonus-gometrics = buildFromGitHub {
    version = 6;
    rev = "v2.2.4";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "853cd2d611f8ed641da098e0e9ff2b7df46effbabe188a896c67c57d564a732d";
    propagatedBuildInputs = [
      circonusllhist
      errors
      go-retryablehttp
      httpunix
    ];
  };

  circonusllhist = buildFromGitHub {
    version = 6;
    date = "2018-04-30";
    rev = "5eb751da55c6d3091faf3861ec5062ae91fee9d0";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "1bylnq7llki3ah9ybxq6ghfi00pmp47waj4di26r2kp7a9nhaaxy";
  };

  cli_minio = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "cli";
    rev = "v1.3.0";
    sha256 = "100ga7sjdxfnskd04yqdmvda9ydfalx7fj2s130y72n0zqpxvn0k";
    buildInputs = [
      toml
      urfave_cli
      yaml_v2
    ];
  };

  AudriusButkevicius_cli = buildFromGitHub {
    version = 6;
    rev = "7f561c78b5a4aad858d9fd550c92b5da6d55efbb";
    owner = "AudriusButkevicius";
    repo = "cli";
    sha256 = "17i9igwf84j1ippgws0fvgaswj06fp1y8ls6q6dgqfkm3p68gyi1";
    date = "2014-07-27";
  };

  docker_cli = buildFromGitHub {
    version = 6;
    date = "2018-10-22";
    rev = "ea836abed5ba9c62c3d4444ea2a6bbf9b486ef1a";
    owner = "docker";
    repo = "cli";
    sha256 = "ff71a149d6598c8553504aeb9ffb3670b1627b24e1c2da0a413b7185b8a3fbb9";
    goPackageAlises = [
      "github.com/docker/docker/cli/cli"
    ];
    subPackages = [
      "cli/config/configfile"
      "cli/config/credentials"
      "opts"
    ];
    propagatedBuildInputs = [
      docker-credential-helpers
      errors
      go-connections
      go-units
      logrus
      moby_lib
    ];
  };

  mitchellh_cli = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "3c2fa296927e826b72330b327ab6341f4595fbde9033266e8f8988373d0c4b65";
    propagatedBuildInputs = [
      color
      complete
      go-isatty
      go-radix
      speakeasy
    ];
  };

  urfave_cli = buildFromGitHub {
    version = 6;
    rev = "v1.20.0";
    owner = "urfave";
    repo = "cli";
    sha256 = "1ca93c2vs3d8d3zbc0dadaab5cailmi1ln6vlng7qlxv2m69f794";
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
    version = 6;
    owner = "benbjohnson";
    repo = "clock";
    rev = "7dc76406b6d3c05b5f71a86293cbcf3c4ea03b19";
    date = "2016-12-15";
    sha256 = "01b6g283q95vrhkq45mfysaz2ysm1bh6m9avjfq1jzva104z53gq";
    goPackageAliases = [
      "github.com/facebookgo/clock"
    ];
  };

  jmhodges_clock = buildFromGitHub {
    version = 5;
    owner = "jmhodges";
    repo = "clock";
    rev = "v1.1";
    sha256 = "0qda1xvz0kq5q6jzfvf23j9anzjgs4dylp71bnnlcbq64s9ywwp6";
  };

  clockwork = buildFromGitHub {
    version = 6;
    rev = "e7c6d408fd5c44ee1e1d8b79ae32b426afae1f28";
    owner = "jonboulle";
    repo = "clockwork";
    sha256 = "16bpal7gw2wnbk3x8k7c2lc08csc7mnhw92wgv66j837s7c9fx29";
    date = "2018-07-16";
  };

  cloud-golang-sdk = buildFromGitHub {
    version = 5;
    rev = "7c97cc6fde16c41f82cace5cbba3e5f098065b9c";
    owner = "centrify";
    repo = "cloud-golang-sdk";
    sha256 = "0pmxkf9f9iqcqlm95g1qxj78cxjhp6vl26f89gikc8wz6l0ls0rx";
    date = "2018-01-19";
    excludedPackages = "sample";
  };

  cmux = buildFromGitHub {
    version = 5;
    rev = "v0.1.4";
    owner = "soheilhy";
    repo = "cmux";
    sha256 = "02hbqja3sv9ah6hnb2zzj2v5ajpc2zdgvc4rs3j4mfq1y6hdi4in";
    goPackageAliases = [
      "github.com/cockroachdb/cmux"
    ];
    propagatedBuildInputs = [
      net
    ];
  };

  cni = buildFromGitHub {
    version = 6;
    rev = "cb4cd0e12ce960e860bebf9ac4a13b68908039e9";
    owner = "containernetworking";
    repo = "cni";
    sha256 = "5d53ebb9171ff31ad21106ea17cd84d421f5833e2cc9866b48c39c8af50fa4e6";
    subPackages = [
      "pkg/types"
    ];
    meta.autoUpdate = false;
  };

  cobra = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "cobra";
    rev = "fe5e611709b0c57fa4a89136deaa8e1d4004d053";
    sha256 = "7a182035afd53e581edc5c577f5d460ca3ed86cbf1e8553af671b55afb91152a";
    propagatedBuildInputs = [
      go-homedir
      go-md2man
      mousetrap
      pflag
      viper
      yaml_v2
    ];
    meta.useUnstable = true;
    date = "2018-10-21";
  };

  cockroach = buildFromGitHub {
    version = 6;
    rev = "v2.0.6";
    owner  = "cockroachdb";
    repo   = "cockroach";
    sha256 = "ef566a33682dfda184506548aef2f26250cb927ea93eed4e7a965c510035c408";
    subPackages = [
      "pkg/build"
      "pkg/settings"
      "pkg/util"
      "pkg/util/caller"
      "pkg/util/color"
      "pkg/util/envutil"
      "pkg/util/fileutil"
      "pkg/util/httputil"
      "pkg/util/humanizeutil"
      "pkg/util/log"
      "pkg/util/log/logflags"
      "pkg/util/protoutil"
      "pkg/util/randutil"
      "pkg/util/syncutil"
      "pkg/util/timeutil"
      "pkg/util/tracing"
      "pkg/util/uint128"
      "pkg/util/uuid"
    ];
    propagatedBuildInputs = [
      errors
      goid
      go-deadlock
      go-humanize
      satori_go-uuid
      go-version
      grpc-gateway
      gogo_protobuf
      lightstep-tracer-go
      net
      opentracing-go
      pflag
      raven-go
      sync
      sys
      tools
      zipkin-go-opentracing
    ];
    postPatch = ''
      sed -i 's,uuid.NewV4(),uuid.Must(uuid.NewV4()),' pkg/util/uuid/uuid.go
    '';
  };

  cockroach-go = buildFromGitHub {
    version = 6;
    rev = "e0a95dfd547cc9c3ebaaba1a12c2afe4bf621ac5";
    owner  = "cockroachdb";
    repo   = "cockroach-go";
    sha256 = "3865887d0e653f9e96861f31a97f35f7bf2b9c173c9a2b3644b35d89d21247a1";
    date = "2018-10-01";
    propagatedBuildInputs = [
      pq
    ];
  };

  collections = buildFromGitHub {
    version = 6;
    rev = "9be91dc79b7c185fa8b08e7ceceee40562055c83";
    owner  = "juju";
    repo   = "collections";
    sha256 = "0l1vlgxhq17b501qlnxxsifi7pxynxwfk17dazs7v9r232a151ax";
    date = "2018-07-17";
  };

  color = buildFromGitHub {
    version = 6;
    rev = "v1.7.0";
    owner  = "fatih";
    repo   = "color";
    sha256 = "05s08rihz6b9a4bx1ggdx72iwf2x3402sldw7arp2gcp6g8x985f";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
    ];
  };

  colorstring = buildFromGitHub {
    version = 6;
    rev = "8631ce90f28644f54aeedcb3e389a85174e067d1";
    owner  = "mitchellh";
    repo   = "colorstring";
    sha256 = "1xdggialfb55ph18vkp8c7031py2pns62xk00am449mr4gsyn5ck";
    date = "2015-09-17";
  };

  columnize = buildFromGitHub {
    version = 6;
    rev = "abc90934186a77966e2beeac62ed966aac0561d5";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "00nrx8yh3ydynjlqf4daj49niwyrrmdav0g2a7cdzbxpsz6j7x22";
    date = "2017-07-03";
  };

  com = buildFromGitHub {
    version = 6;
    rev = "41959bdd855fb7db467f78865d5f9044507df1cd";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "f90fce1140a639d37bbf6223ed1e415765dc2bb2bf57c2a789b236c39032b298";
    date = "2018-10-10";
  };

  complete = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner  = "posener";
    repo   = "complete";
    sha256 = "42788c4e8202d28b6304ce6d69972b41948d94648136abc0dfd47a3861d2487e";
    propagatedBuildInputs = [
      go-multierror
    ];
  };

  compress = buildFromGitHub {
    version = 6;
    rev = "v1.4.0";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "05yic0i7wqhxmpvgyvp105aj10wg8m77fqg0v1vmz16br4xw28kr";
    propagatedBuildInputs = [
      cpuid
    ];
  };

  concurrent = buildFromGitHub {
    version = 6;
    rev = "1.0.3";
    owner  = "modern-go";
    repo   = "concurrent";
    sha256 = "965151c099e0ec074cd67a5f138e3c2b2fc3b403d3ad7e53b711dbc519fc1268";
  };

  configurable_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner = "hlandau";
    repo = "configurable";
    sha256 = "0ycp11wnihrwnqywgnj4mn4mkqlsk1j4c7zyypl9s4k525apz581";
    goPackagePath = "gopkg.in/hlandau/configurable.v1";
  };

  configure = buildFromGitHub {
    version = 6;
    rev = "c3428bd84c23f0cfcc759f2ef12632be5ff5d95d";
    owner = "gravitational";
    repo = "configure";
    sha256 = "d93d452617fc0dfa6656373b0ea7cacc52d773019ca3285327a69c4c3cde86e4";
    date = "2018-08-08";
    propagatedBuildInputs = [
      gojsonschema
      kingpin_v2
      trace
      yaml_v2
    ];
    excludedPackages = "test";
  };

  console = buildFromGitHub rec {
    version = 6;
    rev = "0650fd9eeb50bab4fc99dceb9f2e14cf58f36e7f";
    owner = "containerd";
    repo = "console";
    sha256 = "2b1b243077a184833db027ed6cc53f92fa24367d42d02b20a4e3e79be6df01b4";
    date = "2018-10-22";
    propagatedBuildInputs = [
      errors
      sys
    ];
  };

  consul = buildFromGitHub rec {
    version = 6;
    rev = "v1.3.0";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "943d91dee38261adc9f72e09043546ec12f182ae9da54fb800cbf1e6ebb30438";
    excludedPackages = "test";

    propagatedBuildInputs = [
      #armon_go-metrics
      #circbuf
      columnize
      copystructure
      #coredns
      dns
      #errors
      #go-bindata-assetfs
      #go-checkpoint
      go-cleanhttp
      #go-connections
      go-discover
      #go-dockerclient
      go-memdb
      go-multierror
      #go-radix
      go-rootcerts
      hashicorp_go-sockaddr
      go-syslog
      go-testing-interface
      go-version
      golang-lru
      #golang-text
      #google-api-go-client
      gopsutil
      hashicorp_go-uuid
      grpc
      #gziphandler
      hashstructure
      hcl
      hil
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      net
      net-rpc-msgpackrpc
      #oauth2
      prometheus_client_golang
      #raft-boltdb
      raft
      #reflectwalk
      serf
      sys
      testify
      time
      #ugorji_go
      vault_api
      hashicorp_yamux
    ];

    postPatch = let
      v = stdenv.lib.substring 1 (stdenv.lib.stringLength rev - 1) rev;
    in ''
      sed \
        -e 's,\(Version[ \t]*= "\)unknown,\1${v},g' \
        -e 's,\(VersionPrerelease[ \t]*= "\)unknown,\1,g' \
        -i version/version.go
    '';
  };

  consul_api = consul.override {
    propagatedBuildInputs = [
      go-cleanhttp
      armon_go-metrics
      go-rootcerts
      go-testing-interface
      go-version
      golang-text
      mapstructure
      raft
      serf
      hashicorp_yamux
    ];
    subPackages = [
      "agent/consul/autopilot"
      "api"
      "command/flags"
      "lib"
      "lib/freeport"
      "tlsutil"
      "version"
    ];
  };

  consulfs = buildFromGitHub {
    version = 6;
    rev = "bf94bae7e101a444f13844f5c7b9bfbba7f8de6c";
    owner = "bwester";
    repo = "consulfs";
    sha256 = "f423bdfb17b888a13a45c902a81fa41de7e9e4987b5088d9d1c1980fa7c3ce2b";
    buildInputs = [
      consul_api
      fuse
      logrus
      net
    ];
    date = "2018-08-28";
  };

  consul-replicate = buildFromGitHub {
    version = 6;
    rev = "675a2c291d06aa1d152f11a2ac64b7001b588816";
    owner = "hashicorp";
    repo = "consul-replicate";
    sha256 = "16201jwbx89brk36rbbijr429jwqckc1id031s01k6irygwf7fps";
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
    version = 6;
    rev = "v0.19.5";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "0rrd2vz1vfgw4f3c4afhgw73hy56xm4f2gs89w57zn19f5vlfgn3";

    propagatedBuildInputs = [
      consul_api
      errors
      go-homedir
      go-multierror
      go-rootcerts
      go-shellwords
      go-syslog
      hashstructure
      hcl
      logutils
      mapstructure
      toml
      yaml_v2
      vault_api
    ];
  };

  context = buildFromGitHub {
    version = 6;
    rev = "51ce91d2eaddeca0ef29a71d766bb3634dadf729";
    owner = "gorilla";
    repo = "context";
    sha256 = "70150f4a8fe52f7ff0f0d3d0b2288b1d5f53e9afb0abce454776d2da178c3484";
    date = "2018-10-12";
  };

  continuity = buildFromGitHub {
    version = 6;
    rev = "be9bd761db19d4fc551d40be908f02e00487511d";
    owner = "containerd";
    repo = "continuity";
    sha256 = "f3fbc48b07a7c8d76e70006e57fdb9b13af1b060ecbdd94c7b66e42d099cdea0";
    date = "2018-10-03";
    subPackages = [
      "pathdriver"
    ];
  };

  copier = buildFromGitHub {
    version = 6;
    date = "2018-03-08";
    rev = "7e38e58719c33e0d44d585c4ab477a30f8cb82dd";
    owner = "jinzhu";
    repo = "copier";
    sha256 = "1sx33vrks8ml9fnf4zdb5kyf7pmvn7mqgndf04b6lllrcdvhbq40";
  };

  copystructure = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "846f63be5aa014bc3cab423c5f37b61f0f9c9badf48a0984845f5823c842a2f9";
    propagatedBuildInputs = [
      reflectwalk
    ];
  };

  core = buildFromGitHub {
    version = 6;
    rev = "v0.6.0";
    owner = "go-xorm";
    repo = "core";
    sha256 = "0lywnrm9xhbrbcwl0n8nmkxvis094z3dwzfca5d2mg25vs9185zq";
  };

  coredns = buildFromGitHub {
    version = 6;
    rev = "v1.2.4";
    owner = "coredns";
    repo = "coredns";
    sha256 = "195033a9aeea4625a24790a97c04188b1e3b286831f8927eb43b66b9220478a0";
    subPackages = [
      "plugin/etcd/msg"
      "plugin/pkg/dnsutil"
      "plugin/pkg/response"
    ];
    propagatedBuildInputs = [
      dns
    ];
  };

  cors = buildFromGitHub {
    version = 6;
    owner = "rs";
    repo = "cors";
    rev = "v1.6.0";
    sha256 = "7620f131d81549a7a3b3f59f6f59141435bb9655cf798fc679a2931131ed7fe4";
    propagatedBuildInputs = [
      gin
      net
    ];
  };

  cpuid = buildFromGitHub {
    version = 6;
    rev = "e7e905edc00ea8827e58662220139109efea09db";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "1pdf0s88c45w5wvk8mcsdgbi06j9dbdrqd7w8wdbgw9xl5arkkz8";
    excludedPackages = "testdata";
    date = "2018-04-05";
  };

  critbitgo = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner  = "k-sone";
    repo   = "critbitgo";
    sha256 = "002j0njkvfdpdwjf0l7r2bx429ps8p80yfvr0kvwdksbdvssjhyh";
  };

  cronexpr = buildFromGitHub {
    version = 6;
    rev = "88b0669f7d75f171bd612b874e52b95c190218df";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "00my3b7sjs85v918xf2ckqax48gxzvidqp6im0h5acrw9kpc0vhv";
    date = "2018-04-27";
  };

  cuckoo = buildFromGitHub {
    version = 6;
    rev = "23d6a3a21bf6bee833d131ddeeab610c71915c30";
    owner  = "tildeleb";
    repo   = "cuckoo";
    sha256 = "be2e1fa31e9c75204866ae2785b650f3b8df3f1c25b25225618ac1d4d6fdecea";
    date = "2017-09-28";
    goPackagePath = "leb.io/cuckoo";
    goPackageAliases = [
      "github.com/tildeleb/cuckoo"
    ];
    meta.autoUpdate = false;
    excludedPackages = "\\(example\\|dstest\\|primes/primes\\)";
    propagatedBuildInputs = [
      aeshash
      binary
    ];
  };

  crypt = buildFromGitHub {
    version = 6;
    owner = "xordataexchange";
    repo = "crypt";
    rev = "b2862e3d0a775f18c7cfe02273500ae307b61218";
    date = "2017-06-26";
    sha256 = "1p4yf48c7pfjqc9nzb50c6yj55sdh0259ggncprlsfj9kqbfm8xi";
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

  datadog-go = buildFromGitHub {
    version = 6;
    rev = "2.1.0";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "17s2rnblcqwg5gy2l242cf7cglhqja3k7vwc6mmzj50hlpwzqv2x";
  };

  dbus = buildFromGitHub {
    version = 6;
    rev = "31d3e1ada733194efe7fc920c100edc0e7097e1c";
    owner = "godbus";
    repo = "dbus";
    sha256 = "8caa258593f77cddde6d0dab99c9099b38f167532bb5676d5a893fe4f1365327";
    date = "2018-10-22";
  };

  debounce = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "bep";
    repo   = "debounce";
    sha256 = "0hrkin8h3lnpg0lk5lm0jm9xxwccav9w0z0wc7zkawzqpvxbzx5r";
  };

  demangle = buildFromGitHub {
    version = 6;
    date = "2018-07-14";
    rev = "fcd258a6f0b45dc345a407ee5568cf9a4d24a0ae";
    owner = "ianlancetaylor";
    repo = "demangle";
    sha256 = "1j0vml5yz16aczdr27mjj6vh7qg0c79lz498vhg1b34jb8133bw2";
  };

  dexlogconfig = buildFromGitHub {
    version = 6;
    date = "2016-11-12";
    rev = "244f29bd260884993b176cd14ef2f7631f6f3c18";
    owner = "hlandau";
    repo = "dexlogconfig";
    sha256 = "1j3zvhc4cyl9n8sd1apdgc0rw689xx26n8h4q89ymnyrqfg9g5py";
    propagatedBuildInputs = [
      buildinfo
      easyconfig_v1
      go-systemd
      svcutils_v1
      xlog
    ];
  };

  diskv = buildFromGitHub {
    version = 6;
    rev = "0646ccaebea1ed1539efcab30cae44019090093f";
    owner  = "peterbourgon";
    repo   = "diskv";
    sha256 = "4bb2b6d5a1b1b756397db287115d0a4861bb35f3413e65f6569b8e4e664e7cbb";
    propagatedBuildInputs = [
      btree
    ];
    date = "2018-03-12";
  };

  distribution = buildFromGitHub {
    version = 6;
    rev = "1cb4180b1a5b9c029b2f2beaeb38f0b5cf64e12e";
    owner = "docker";
    repo = "distribution";
    sha256 = "96edaee3eb29e67942a733978e098dbc626cb91a90418fa45849fb391ef3ad38";
    meta.useUnstable = true;
    date = "2018-10-02";
  };

  distribution_for_moby = buildFromGitHub {
    inherit (distribution) date rev owner repo sha256 version meta;
    subPackages = [
      "."
      "digestset"
      "context"
      "manifest"
      "manifest/manifestlist"
      "metrics"
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
      docker_go-metrics
      image-spec
      logrus
      mux
      net
    ];
  };

  dlog = buildFromGitHub {
    version = 5;
    rev = "0.3";
    owner  = "jedisct1";
    repo   = "dlog";
    sha256 = "0llzxkwbfmffj5cjdf5avzjypygy0fq6wm2ls2603phjfx5adh6n";
    propagatedBuildInputs = [
      go-syslog
      sys
    ];
  };

  dns = buildFromGitHub {
    version = 6;
    rev = "v1.0.14";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "706d325a41114d2a3a039ad9d5f4248daaa0d41c904a8daea26c523175e77f3b";
    propagatedBuildInputs = [
      crypto
      net
      sys
    ];
  };

  dnscrypt-proxy = buildFromGitHub {
    version = 6;
    rev = "2.0.17";
    owner  = "jedisct1";
    repo   = "dnscrypt-proxy";
    sha256 = "35fd14505860b34cb308ebd56542e0b19e0b98099b3b486e7c5d8c64220e4f0d";
    propagatedBuildInputs = [
      cachecontrol
      critbitgo
      crypto
      dlog
      dns
      ewma
      godaemon
      go-clocksmith
      go-dnsstamps
      go-immutable-radix
      go-minisign
      go-systemd
      golang-lru
      lumberjack_v2
      net
      pidfile
      safefile
      service
      toml
      xsecretbox
    ];
  };

  dnsimple-go = buildFromGitHub {
    version = 6;
    rev = "v0.21.0";
    owner  = "dnsimple";
    repo   = "dnsimple-go";
    sha256 = "05ae706a4d49ecdd1c205f164526ef5679b8af95ddb914779a5d8cbc053cc977";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  dnspod-go = buildFromGitHub {
    version = 6;
    rev = "83a3ba562b048c9fc88229408e593494b7774684";
    owner = "decker502";
    repo = "dnspod-go";
    sha256 = "0hhbvf0r7ir17fa3rxd76jhm2waz3baqmb51ywvq48z3bypx11n0";
    date = "2018-04-16";
    propagatedBuildInputs = [
      json-iterator_go
    ];
  };

  docker-credential-helpers = buildFromGitHub {
    version = 6;
    rev = "v0.6.1";
    owner = "docker";
    repo = "docker-credential-helpers";
    sha256 = "1fb0fc60xvmjx7xdy2nz4zha2g0ikcas6sgjxys2926jj3lfvhrm";
    postPatch = ''
      find . -name \*_windows.go -delete
    '';
    buildInputs = [
      pkgs.libsecret
    ];
  };

  docopt-go = buildFromGitHub {
    version = 6;
    rev = "ee0de3bc6815ee19d4a46c7eb90f829db0e014b1";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "10cd6bef8b281f8fab4daa17238152e028727cc0cd88c7027f5ee890742c3413";
    date = "2018-01-11";
  };

  dqlite = buildFromGitHub {
    version = 6;
    rev = "v0.2.4";
    owner  = "CanonicalLtd";
    repo   = "dqlite";
    sha256 = "8446749fe8c969cce30ea12edb4542f022f8296069a0202177b10d9ed06995f5";
    excludedPackages = "testdata";
    propagatedBuildInputs = [
      cobra
      errors
      fsm
      CanonicalLtd_go-sqlite3
      protobuf
      raft
      raft-boltdb
    ];
  };

  dsync = buildFromGitHub {
    version = 5;
    owner = "minio";
    repo = "dsync";
    date = "2018-01-24";
    rev = "439a0961af700f80db84cc180fe324a89070fa65";
    sha256 = "02nq7jk3hcxxs60r09kfmzc1xfk2qsn4ahp79fcvlvzq6xi46rvz";
  };

  du = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner  = "calmh";
    repo   = "du";
    sha256 = "00l7y5f2si43pz9iqnfccfbx6z6wni00aqc6jgkj1kwpjq5q9ya4";
  };

  duo_api_golang = buildFromGitHub {
    version = 5;
    date = "2018-03-15";
    rev = "d0530c80e49a86b1c3f5525daa5a324bfb795ef3";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "15a8hhxl33qdx9qnclinlwglr8vip37hvxxa5yg3m6kldyisq3vk";
  };

  easyconfig_v1 = buildFromGitHub {
    version = 6;
    owner = "hlandau";
    repo = "easyconfig";
    rev = "v1.0.17";
    sha256 = "c15f8d8683fb7fe616045bef0558d36889ca9a9cf42fbe0934546187c5973fde";
    goPackagePath = "gopkg.in/hlandau/easyconfig.v1";
    excludedPackages = "example";
    propagatedBuildInputs = [
      configurable_v1
      kingpin_v2
      pflag
      toml
      svcutils_v1
    ];
    postPatch = ''
      sed -i '/type Value interface {/a\'$'\t'"Type() string" adaptflag/adaptflag.go
      echo "func (v *value) Type() string {" >>adaptflag/adaptflag.go
      echo $'\t'"return \"string\"" >>adaptflag/adaptflag.go
      echo "}" >>adaptflag/adaptflag.go
    '';
  };

  easyjson = buildFromGitHub {
    version = 6;
    owner = "mailru";
    repo = "easyjson";
    rev = "60711f1a8329503b04e1c88535f419d0bb440bff";
    date = "2018-08-23";
    sha256 = "cdce1853e0f3bbb8227d1357d0da76c6ffe70f9829c8665ecf7af68aacc8f717";
    excludedPackages = "benchmark";
  };

  ed25519 = buildFromGitHub {
    version = 6;
    owner = "agl";
    repo = "ed25519";
    rev = "5312a61534124124185d41f09206b9fef1d88403";
    sha256 = "1zcf7dw0nb8z36763grc383x7a1bq613i1r7a94pjvdsp317ihsg";
    date = "2017-01-16";
  };

  egoscale = buildFromGitHub {
    version = 5;
    rev = "v0.9.12";
    owner  = "exoscale";
    repo   = "egoscale";
    sha256 = "1c6nbgl5r7wcb7y3sij70avrrchnlr4z1srqwckmjflyhi5rfdkv";
    propagatedBuildInputs = [
      copier
    ];
  };

  elastic_v5 = buildFromGitHub {
    version = 6;
    owner = "olivere";
    repo = "elastic";
    rev = "v5.0.76";
    sha256 = "b073e1e1b02ce242f2041f0c64462818a9c5e947762611f52a2a5e6eb9814512";
    goPackagePath = "gopkg.in/olivere/elastic.v5";
    propagatedBuildInputs = [
      easyjson
      errors
      sync
      google_uuid
    ];
  };

  elvish = buildFromGitHub {
    version = 6;
    owner = "elves";
    repo = "elvish";
    rev = "cc924d20b6db87a17dba6b261306d1fd634fe3f5";
    sha256 = "476d41a77f0e20bb563eb8f4b87fe88c3243e534e5682c1bb2fb8072811d823f";
    excludedPackages = "website";
    propagatedBuildInputs = [
      bolt
      go-isatty
      persistent
      sys
    ];
    meta.useUnstable = true;
    date = "2018-10-22";
  };

  eme = buildFromGitHub {
    version = 6;
    owner = "rfjakob";
    repo = "eme";
    rev = "2222dbd4ba467ab3fc7e8af41562fcfe69c0d770";
    date = "2017-10-28";
    sha256 = "1saazrhj3jg4bkkyiy9l3z5r7b3gxmvdwxz0nhxc86czk93bdv8v";
    meta.useUnstable = true;
  };

  emoji = buildFromGitHub {
    version = 6;
    owner = "kyokomi";
    repo = "emoji";
    rev = "v1.5.1";
    sha256 = "1zlwwpvwhnh4ik7mg80pk0b6fgpp1j9zqc9k8slvr7idx9bir781";
  };

  encoding = buildFromGitHub {
    version = 6;
    owner = "jwilder";
    repo = "encoding";
    date = "2017-08-11";
    rev = "b4e1701a28efcc637d9afcca7d38e495fe909a09";
    sha256 = "0qzzrxiwynsqwrp2y6xpz5i2yk6wncfcjjzbvqrhnm08hvra74dc";
  };

  environschema_v1 = buildFromGitHub {
    version = 6;
    owner = "juju";
    repo = "environschema";
    rev = "7359fc7857abe2b11b5b3e23811a9c64cb6b01e0";
    sha256 = "1yb94v3l6ciwl3551w6fshmbla575qmmyz1hw788ll2cmcjyz7qn";
    goPackagePath = "gopkg.in/juju/environschema.v1";
    date = "2015-11-04";
    propagatedBuildInputs = [
      crypto
      errgo_v1
      juju_errors
      schema
      utils
      yaml_v2
    ];
  };

  envy = buildFromGitHub {
    version = 6;
    owner = "gobuffalo";
    repo = "envy";
    rev = "v1.6.5";
    sha256 = "0eaf47a2308652af2e3ca5851a507dd34f8c54e036bd5adc7ae844c2105012d4";
    propagatedBuildInputs = [
      godotenv
      go-homedir
    ];
  };

  errgo_v1 = buildFromGitHub {
    version = 6;
    owner = "go-errgo";
    repo = "errgo";
    rev = "v1.0.0";
    sha256 = "f08b3f68d2bdf35dbb01c1204478f7c9127fdd317592deaf8311239d4a07c6fd";
    goPackagePath = "gopkg.in/errgo.v1";
  };

  juju_errors = buildFromGitHub {
    version = 6;
    owner = "juju";
    repo = "errors";
    rev = "a4583d0a56eac4bdd939e38050d0c69abe0a9b41";
    sha256 = "9e4ac089724b037a14c6fb185b82afee9a329c94d46e93b59e423e7c3e6d8dae";
    date = "2018-10-12";
  };

  errors = buildFromGitHub {
    version = 6;
    owner = "pkg";
    repo = "errors";
    rev = "d58f94251046e7f70ac45aceea6cf6f61415ccca";
    sha256 = "2bc825a926672268d9f3f377489afd9df5a2a2b8bd3a4822ea94ed44d92bf8ce";
    date = "2018-10-20";
  };

  errwrap = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "fbc03ac022295b56866d516f2014d3a67a96c7b451e54478338c0d838ed70908";
  };

  escaper = buildFromGitHub {
    version = 6;
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
    version = 6;
    owner = "coreos";
    repo = "etcd";
    rev = "86b933311d239aeba576fac32077e41157d328eb";
    sha256 = "e9115dd938620b525794d6008cd6775b1ef5551e66bce598d498873a74c8dec4";
    goPackagePath = "go.etcd.io/etcd";
    goPackageAliases = [
      "github.com/coreos/etcd"
    ];
    propagatedBuildInputs = [
      bbolt
      btree
      urfave_cli
      clockwork
      cobra
      cmux
      crypto
      go-grpc-middleware
      go-grpc-prometheus
      go-humanize
      go-semver
      go-systemd
      groupcache
      grpc
      grpc-gateway
      grpc-websocket-proxy
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
      zap

      pkgs.libpcap
    ];

    excludedPackages = "\\(test\\|benchmark\\|example\\|bridge\\)";
    meta.useUnstable = true;
    date = "2018-10-22";
  };

  etcd_client = etcd.override {
    subPackages = [
      "auth/authpb"
      "client"
      "clientv3"
      "clientv3/balancer"
      "clientv3/balancer/picker"
      "clientv3/balancer/resolver/endpoint"
      "etcdserver/api/v3rpc/rpctypes"
      "etcdserver/etcdserverpb"
      "mvcc/mvccpb"
      "pkg/logutil"
      "pkg/pathutil"
      "pkg/srv"
      "pkg/systemd"
      "pkg/types"
      "raft"
      "raft/raftpb"
      "version"
    ];
    propagatedBuildInputs = [
      go-grpc-middleware
      go-semver
      go-systemd
      grpc
      net
      pkg
      protobuf
      gogo_protobuf
      ugorji_go
      zap
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
      gogo_protobuf
    ];
  };

  etree = buildFromGitHub {
    version = 6;
    owner = "beevik";
    repo = "etree";
    rev = "v1.0.1";
    sha256 = "0bkny66hap77l9gc1v6nq5r6imd3gr1z5w0216wsxwg5l68fvwam";
  };

  eventfd = buildFromGitHub {
    version = 6;
    owner = "gxed";
    repo = "eventfd";
    rev = "80a92cca79a8041496ccc9dd773fcb52a57ec6f9";
    date = "2016-09-16";
    sha256 = "1z5dqpawjj2r0hhlh57l49w1hw6dz148hgnklxcc9274ghzgyiny";
    propagatedBuildInputs = [
      goendian
    ];
  };

  ewma = buildFromGitHub {
    version = 6;
    owner = "VividCortex";
    repo = "ewma";
    rev = "43880d236f695d39c62cf7aa4ebd4508c258e6c0";
    date = "2017-08-04";
    sha256 = "0mdiahsdh61nbvdbzbf1p1rp13k08mcsw5xk75h8bn3smk3j8nrk";
    meta.useUnstable = true;
  };

  fastuuid = buildFromGitHub {
    version = 6;
    date = "2015-01-06";
    rev = "6724a57986aff9bff1a1770e9347036def7c89f6";
    owner  = "rogpeppe";
    repo   = "fastuuid";
    sha256 = "190ixhjlwhgdc2s52hlmq95yj3lr8gx5rg1q9jkzs7717bsf2c15";
  };

  filepath-securejoin = buildFromGitHub {
    version = 6;
    rev = "v0.2.2";
    owner  = "cyphar";
    repo   = "filepath-securejoin";
    sha256 = "d5bf2e604a0d799082cda1ff07b8aa4d91b238e021262fcb9dd59c78dc00b80e";
    propagatedBuildInputs = [
      errors
    ];
  };

  fileutils = buildFromGitHub {
    version = 6;
    date = "2017-11-03";
    rev = "7d4729fb36185a7c1719923406c9d40e54fb93c7";
    owner  = "mrunalp";
    repo   = "fileutils";
    sha256 = "0b2ba3bvx1pwbywq395nkgsvvc1rihiakk8nk6i6drsi6885wcdz";
  };

  flagfile = buildFromGitHub {
    version = 6;
    date = "2018-04-26";
    rev = "0d750334dbb886bfd9480d158715367bfef2441c";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "0fm67m72mlfxhmpzcs4vyrl5kfzc40f8d2jqbqsqca46iwvljivf";
  };

  fnmatch = buildFromGitHub {
    version = 6;
    date = "2016-04-03";
    rev = "cbb64ac3d964b81592e64f957ad53df015803288";
    owner  = "danwakefield";
    repo   = "fnmatch";
    sha256 = "126zbs23kbv3zn5g60a2w6cdxjrhqplpn6h8rwvvhm8lss30bql6";
  };

  form = buildFromGitHub {
    version = 6;
    rev = "c4048f792f70d207e6d8b9c1bf52319247f202b8";
    date = "2015-11-09";
    owner = "gravitational";
    repo = "form";
    sha256 = "0800jqfkmy4h2pavi8lhjqca84kam9b1azgwvb6z4kpirbnchpy3";
  };

  fs = buildFromGitHub {
    version = 6;
    rev = "v0.1.0";
    owner  = "kr";
    repo   = "fs";
    sha256 = "1q5bgxmwkvjah22lad1ddma0lgk6s0jxabwfd11in53l26rlnblk";
  };

  fsm = buildFromGitHub {
    version = 6;
    date = "2016-01-10";
    rev = "3dc1bc0980272fd56d81167a48a641dab8356e29";
    owner  = "ryanfaerman";
    repo   = "fsm";
    sha256 = "1i30f7k4ilwy51nfnl5x5k4ib4sg3i2acy0ys1l5mkzf3m8pc4lz";
  };

  fsnotify = buildFromGitHub {
    version = 6;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "ccc981bf80385c528a65fbfdd49bf2d8da22aa23";
    sha256 = "8ba64d93c10f1831a31cef052bcf330eb9c47e45d4926dedc3dd45711a85abfb";
    propagatedBuildInputs = [
      sys
    ];
    date = "2018-08-30";
  };

  fsnotify_v1 = buildFromGitHub {
    version = 6;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.7";
    sha256 = "9f31c302115214ccf104b8bdea3a52a5ca70ab2e6210c6afba3ca1a14e0ed05a";
    goPackagePath = "gopkg.in/fsnotify/fsnotify.v1";
    propagatedBuildInputs = [
      sys
    ];
  };

  fs-repo-migrations = buildFromGitHub {
    version = 6;
    owner = "ipfs";
    repo = "fs-repo-migrations";
    rev = "v1.4.0";
    sha256 = "1qmwgk5f401vbnmrby6yhmbj58a65dp544gc2capsfayhn4cz9lh";
    propagatedBuildInputs = [
      goprocess
      go-homedir
      go-os-rename
    ];
    allowVendoredSources = true;
    postPatch = ''
      # Unvendor
      find . -name \*.go -exec sed -i 's,".*Godeps/_workspace/src/,",g' {} \;

      # Remove old, unused migrations
      sed -i 's,&mg[01234].Migration{},nil,g' main.go
      sed -i '/mg[01234]/d' main.go
    '';
    preBuild = ''
      find go/src/"$goPackagePath" -name gx -prune -exec mv {} "$TMPDIR"/go/src/ \;
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
      "ipfs-6-to-7/migration"
      "mfsr"
      "stump"
    ];
  };

  fsync = buildFromGitHub {
    version = 6;
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
    version = 6;
    owner = "jlaffaye";
    repo = "ftp";
    rev = "fe787349a520687bb2d7fd2fbb2f3435e8479530";
    sha256 = "61711e52075ef8ea9f0d98e9278aaaab9836ff6857d3b75160183a3325c7aa23";
    date = "2018-10-11";
  };

  fuse = buildFromGitHub {
    version = 6;
    owner = "bazil";
    repo = "fuse";
    rev = "65cc252bf6691cb3c7014bcb2c8dc29de91e3a7e";
    date = "2018-04-21";
    sha256 = "0kf3v0fh736l5rw8yysssrw2z8glb7wdgfwqxr3pwng783xys36s";
    goPackagePath = "bazil.org/fuse";
    propagatedBuildInputs = [
      net
      sys
    ];
  };

  fwd = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "philhofer";
    repo   = "fwd";
    sha256 = "0z0z6f7lwbi1a6lw7xj3mmyxy0dmdgxlcids9wl1dgadmggvwb8f";
  };

  gabs = buildFromGitHub {
    version = 6;
    owner = "Jeffail";
    repo = "gabs";
    rev = "v1.1.1";
    sha256 = "da028dc862547727974399b6363bd824b460106b7f58f183ce949e4150558f64";
  };

  gateway = buildFromGitHub {
    version = 6;
    date = "2018-04-07";
    rev = "cbcf4e3f3baee7952fc386c8b2534af4d267c875";
    owner  = "jackpal";
    repo   = "gateway";
    sha256 = "18vggnjfhbw7axjp0ikwj5vps532bkrwn0qxsdgpn6i5db0r0swc";
  };

  gax-go = buildFromGitHub {
    version = 6;
    rev = "1ef592c90f479e3ab30c6c2312e20e13881b7ea6";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "0jhkq9w76c9hf3344rgxxn20pwic76pmvwmky2r382lsjba3masq";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
    date = "2018-07-02";
  };

  genproto = buildFromGitHub {
    version = 6;
    date = "2018-10-16";
    rev = "94acd270e44e65579b9ee3cdab25034d33fed608";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "dfa2de94c45a58ce4f8786e30743aa8a86bb25b782f8eec56a1c9ed0c3c16431";
    propagatedBuildInputs = [
      grpc
      net
      protobuf
    ];
  };

  genproto_for_grpc = genproto.override {
    subPackages = [
      "googleapis/rpc/status"
    ];
    propagatedBuildInputs = [
      protobuf
    ];
  };

  geoip2-golang = buildFromGitHub {
    version = 6;
    rev = "96f33b8f2d6434e8fc2f3cf751084acb5153cc80";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "838a69ec14607201caa2e9909504194a9a1449e123b1bb3b99fa976db818420e";
    propagatedBuildInputs = [
      maxminddb-golang
    ];
    date = "2018-10-14";
  };

  getopt = buildFromGitHub {
    version = 6;
    rev = "2b5b3bfb099b7da3e2f433966f8ab1d5803e0876";
    owner = "pborman";
    repo = "getopt";
    sha256 = "c0b02482ae1fbe9664fd6d080b1c5e2a8491ac36f2b5ef5c80a64b046a124d27";
    date = "2018-08-11";
  };

  gettext = buildFromGitHub {
    version = 6;
    rev = "v0.9";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "1zrxfzwlv04gadxxyn8whmdin83ij735bbggxrnf3mcbxs8svs96";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  gin = buildFromGitHub {
    version = 6;
    rev = "v1.3.0";
    owner = "gin-gonic";
    repo = "gin";
    sha256 = "cdadb9b904ade279f5216b09dc4e0af87a278d3394b4b2adbe91260f77f5b24b";
    excludedPackages = "example";
    propagatedBuildInputs = [
      json-iterator_go
      ugorji_go
      go-isatty
      protobuf
      sse
      validator_v8
      yaml_v2
    ];
  };

  ginkgo = buildFromGitHub {
    version = 6;
    rev = "v1.6.0";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "160a651a4x5wdafq8zcfpyk0qyl4cmk67dd15844i6sfh8qbj2vp";
    propagatedBuildInputs = [
      sys
      tail
    ];
  };

  gitmap = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "bep";
    repo = "gitmap";
    sha256 = "9b92b42be58b501152f19bc523767a659ed4e83a51c0832cab7dab71ec7b81eb";
  };

  gjson = buildFromGitHub {
    version = 6;
    owner = "tidwall";
    repo = "gjson";
    rev = "v1.1.3";
    sha256 = "9e62400fe9e536844cccce567b52f93c069ba0c281493ddf48e5c093b753c828";
    propagatedBuildInputs = [
      match
    ];
  };

  glob = buildFromGitHub {
    version = 6;
    rev = "e7a84e9525fe90abcda167b604e483cc959ad4aa";
    owner = "gobwas";
    repo = "glob";
    sha256 = "7559a854a8ecdfa695afa6a291786926c46ccbbc4de7b1524cb1a93a48a6da95";
    date = "2018-10-02";
  };

  gnostic = buildFromGitHub {
    version = 6;
    rev = "v0.2.0";
    owner = "googleapis";
    repo = "gnostic";
    sha256 = "16mff7gsnknknj28zn6ccklvrapydpjxh3wwdv6y3w2rk2zwps8q";
    excludedPackages = "tools";
    propagatedBuildInputs = [
      docopt-go
      protobuf
      yaml_v2
    ];
  };

  json-iterator_go = buildFromGitHub {
    version = 6;
    rev = "v1.1.5";
    owner = "json-iterator";
    repo = "go";
    sha256 = "a3284b3861968fe00fe2d773218503f2297bc10735142573094b2a0d3e0b5e7a";
    excludedPackages = "test";
    propagatedBuildInputs = [
      concurrent
      plz
      reflect2
    ];
  };

  namedotcom_go = buildFromGitHub {
    version = 6;
    rev = "08470befbe04613bd4b44cb6978b05d50294c4d4";
    owner = "namedotcom";
    repo = "go";
    sha256 = "09d3kvfsz09q2yaj0mgy06m691fvyl23x24q6dby5g3kfg2rc065";
    date = "2018-04-03";
    propagatedBuildInputs = [
      errors
    ];
  };

  siddontang_go = buildFromGitHub {
    version = 6;
    date = "2018-06-04";
    rev = "bdc77568d726a8702315ec4eafda030b6abc4f43";
    owner = "siddontang";
    repo = "go";
    sha256 = "05g46qmmabsmfnfvxzdzhkgv617mrc1z12rlxfsagnmv384pypvm";
  };

  ugorji_go = buildFromGitHub {
    version = 6;
    rev = "e5e69e061d4f7ee3a69b793cf9c1b41afe21918e";
    owner = "ugorji";
    repo = "go";
    sha256 = "03111bef9d6c56aa991c59958588119508f4ccee1074d2eab53063f33a7de0a5";
    goPackageAliases = [
      "github.com/hashicorp/go-msgpack"
    ];
    propagatedBuildInputs = [
      tools_for_text
    ];
    date = "2018-10-22";
  };

  go-acd = buildFromGitHub {
    version = 6;
    owner = "ncw";
    repo = "go-acd";
    rev = "887eb06ab6a255fbf5744b5812788e884078620a";
    date = "2017-11-20";
    sha256 = "0mfab334ls3m26wwh21rf40vslchi87g1cr41b81x802hj0mgddd";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  go-addr-util = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-addr-util";
    rev = "v2.0.6";
    sha256 = "a73f696937db518faa7fc4d152d90f18980d797e8ae193557e743a88a2d0e8d7";
    propagatedBuildInputs = [
      go-log
      go-ws-transport
      go-multiaddr
      go-multiaddr-net
      mafmt
    ];
  };

  go-ansiterm = buildFromGitHub {
    version = 6;
    owner = "Azure";
    repo = "go-ansiterm";
    rev = "d6e3b3328b783f23731bc4d058875b0371ff8109";
    date = "2017-09-29";
    sha256 = "18p4rr8f082m8q5ds6ba1m6h2r4bylldd6fx1r0v0kzryzilbqcn";
    buildInputs = [
      logrus
    ];
  };

  go-http-auth = buildFromGitHub {
    version = 6;
    owner = "abbot";
    repo = "go-http-auth";
    rev = "860ed7f246ff5abfdbd5c7ce618fd37b49fd3d86";
    sha256 = "c6844014edf9abd986378151136826b21119ea8c31adab2d46553adbbc408269";
    propagatedBuildInputs = [
      crypto
      net
    ];
    date = "2018-10-19";
  };

  go4 = buildFromGitHub {
    version = 6;
    date = "2018-08-09";
    rev = "417644f6feb5ed3a356ca5d6d8e3a3fac7dfd33f";
    owner = "camlistore";
    repo = "go4";
    sha256 = "f97bb6dd46d5878d5e0f53ab6d4134a058405a39d4e9f302e36fcab50e2a2f76";
    goPackagePath = "go4.org";
    goPackageAliases = [
      "github.com/camlistore/go4"
      "github.com/juju/go4"
    ];
    propagatedBuildInputs = [
      goexif
      google-api-go-client
      google-cloud-go
      oauth2
      net
      sys
    ];
  };

  gocapability = buildFromGitHub {
    version = 6;
    rev = "d98352740cb2c55f81556b63d4a1ec64c5a319c2";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "92313db58c2e7fdfa9b279b5a9147adcc513f5251c9d00d933c1084fdf415e48";
    date = "2018-09-16";
  };

  gocql = buildFromGitHub {
    version = 6;
    rev = "6832a796414d0414fbf83e36eec80a84e0dd6ade";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "0da49d31c41c50aecf7cdca71f10709ad666ba819ae47147eba6a648bdef8be5";
    propagatedBuildInputs = [
      inf_v0
      snappy
      go-hostpool
      net
    ];
    date = "2018-10-19";
  };

  godaemon = buildFromGitHub {
    version = 5;
    rev = "3d9f6e0b234fe7d17448b345b2e14ac05814a758";
    owner  = "VividCortex";
    repo   = "godaemon";
    sha256 = "0vxihy5d64ym7k7zragkbyvjbli4f4mg18kmhl5kl0bwfd7vpw9x";
    date = "2015-09-10";
  };

  godo = buildFromGitHub {
    version = 6;
    rev = "v1.6.0";
    owner  = "digitalocean";
    repo   = "godo";
    sha256 = "45ab02a5ad81a1349009db865b84b84c68f04c41fa28935194dd5da79105a55a";
    propagatedBuildInputs = [
      go-querystring
      http-link-go
      net
    ];
  };

  godotenv = buildFromGitHub {
    version = 6;
    rev = "v1.3.0";
    owner  = "joho";
    repo   = "godotenv";
    sha256 = "a7c790db16f2c7b8aaa4433731237712b0e7603d99a633520f31738ff7bce46c";
  };

  goendian = buildFromGitHub {
    version = 6;
    rev = "0f5c6873267e5abf306ffcdfcfa4bf77517ef4a7";
    owner  = "gxed";
    repo   = "GoEndian";
    sha256 = "1h05p9xlfayfjj00yjkggbwhsb3m52l5jdgsffs518p9fsddwbfy";
    date = "2016-09-16";
  };

  goexif = buildFromGitHub {
    version = 6;
    rev = "8d986c03457a2057c7b0fb0a48113f7dd48f9619";
    owner  = "rwcarlsen";
    repo   = "goexif";
    sha256 = "0njxp23iy7cc1zg3mlxiy9dkc21d8yf54ihnq6w47gx8zrj3l7z1";
    date = "2018-05-18";
  };

  gofuzz = buildFromGitHub {
    version = 6;
    rev = "24818f796faf91cd76ec7bddd72458fbced7a6c1";
    owner  = "google";
    repo   = "gofuzz";
    sha256 = "1ghcx5q9vsgmknl9954cp4ilgayfkg937c1z4m3lqr41fkma9zgi";
    date = "2017-06-12";
  };

  goid = buildFromGitHub {
    version = 6;
    rev = "b0b1615b78e5ee59739545bb38426383b2cda4c9";
    owner  = "petermattis";
    repo   = "goid";
    sha256 = "3e10446953d0947c36733dfa0ef2549554b7462de31dc44476da01e708e1969f";
    date = "2018-02-02";
  };

  gojsondiff = buildFromGitHub {
    version = 6;
    rev = "0525c875b75ca60b9e67ddc44496aa16f21066b0";
    owner  = "yudai";
    repo   = "gojsondiff";
    sha256 = "1bnxfr20dns1n1z7p80raiw99147pzj0547ywwn07hxzpa6s2ig8";
    date = "2018-05-04";
    propagatedBuildInputs = [
      urfave_cli
      go-diff
      golcs
    ];
    excludedPackages = "test";
  };

  gojsonpointer = buildFromGitHub {
    version = 6;
    rev = "4e3ac2762d5f479393488629ee9370b50873b3a6";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "245e95afa6aad97e38bf29c0c6b0ba99d0d357d735628c62e768a72bfbbb0ff2";
    date = "2018-01-27";
  };

  gojsonreference = buildFromGitHub {
    version = 6;
    rev = "bd5ef7bd5415a7ac448318e64f11a24cd21e594b";
    owner  = "xeipuuv";
    repo   = "gojsonreference";
    sha256 = "9b5e87a159c369c025c0b9ff46bcaa173a57c032c0c7d54d06cda46410935fbb";
    date = "2018-01-27";
    propagatedBuildInputs = [ gojsonpointer ];
  };

  gojsonschema = buildFromGitHub {
    version = 6;
    rev = "v1.0";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "05b7bfdd3fbd96e5d884e62a5952ea2aa1a5122dadde716926fe565b9831f707";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gomaasapi = buildFromGitHub {
    version = 6;
    rev = "8a8cec793ba70659ba95f1b9a491ba807169bfc3";
    date = "2018-09-19";
    owner = "juju";
    repo = "gomaasapi";
    sha256 = "bbcff63ab93f1ec9cfbb91170971e983fc5d7e3a7cbc3bdb51541e74ceb153c0";
    propagatedBuildInputs = [
      collections
      juju_errors
      loggo
      mgo_v2
      schema
      utils
      juju_version
    ];
  };

  gomail_v2 = buildFromGitHub {
    version = 6;
    rev = "81ebce5c23dfd25c6c67194b37d3dd3f338c98b1";
    date = "2016-04-11";
    owner = "go-gomail";
    repo = "gomail";
    sha256 = "0akjvnrwqipl67rjg0aab0wiqn904d4rszpscgkjw23i1h2h9v3y";
    goPackagePath = "gopkg.in/gomail.v2";
    propagatedBuildInputs = [
      quotedprintable_v3
    ];
  };

  gomemcache = buildFromGitHub {
    version = 6;
    rev = "bc664df9673713a0ccf26e3b55a673ec7301088b";
    date = "2018-07-10";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "110v9bia6wmg0q8l8jwhwf6xgvzjvmpiz28v1ymz0cmbc0n6wagc";
  };

  gomemcached = buildFromGitHub {
    version = 6;
    rev = "20e69a1ee160444d2663130ce853ac969aec4689";
    date = "2018-07-23";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "0lvkp1xhjnrnvgjy17ipc2m6nq36vyd8dq8bgl2g5lldnr9sip59";
    excludedPackages = "mocks";
    propagatedBuildInputs = [
      crypto
      errors
      goutils_gomemcached
    ];
  };

  gopacket = buildFromGitHub {
    version = 6;
    rev = "v1.1.15";
    owner = "google";
    repo = "gopacket";
    sha256 = "d6e86cb45252eae2a01dc2f5bae1c8ae889f14a2a8b90922d7e0709adab73feb";
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
    version = 6;
    rev = "0719c6b22f30132b0ae6c90b038e0d50992107b0";
    owner = "gophercloud";
    repo = "gophercloud";
    sha256 = "7d69ab97494695f3bfe05d6c80000a3fce3ffa5686dea549c90710323dcf8a1f";
    date = "2018-10-19";
    excludedPackages = "test";
    propagatedBuildInputs = [
      crypto
      yaml_v2
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 6;
    date = "2018-10-22";
    rev = "a14d6f8f54d771d98bc9f3e744bdfa7d83ab3300";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "fae2069c89691947c67a3ab99d5a7bd859b36ee4bfed3717d5c2e281e4a227a2";
    goPackagePath = "cloud.google.com/go";
    goPackageAliases = [
      "google.golang.org/cloud"
    ];
    propagatedBuildInputs = [
      btree
      debug
      gax-go
      genproto
      geo
      glog
      go-cmp
      google-api-go-client
      grpc
      martian
      net
      oauth2
      opencensus
      pprof
      protobuf
      sync
      text
      time
    ];
    postPatch = ''
      sed -i 's,bundler.Close,bundler.Stop,g' logging/logging.go
    '';
    excludedPackages = "\\(oauth2\\|readme\\|mocks\\|test\\)";
    meta.useUnstable = true;
  };

  google-cloud-go-compute-metadata = buildFromGitHub {
    inherit (google-cloud-go) rev date owner repo sha256 version goPackagePath goPackageAliases meta;
    subPackages = [
      "compute/metadata"
    ];
    propagatedBuildInputs = [
      net
    ];
  };

  goprocess = buildFromGitHub {
    version = 6;
    rev = "b497e2f366b8624394fb2e89c10ab607bebdde0b";
    date = "2016-08-26";
    owner = "jbenet";
    repo = "goprocess";
    sha256 = "12dibwgdi53dgfc5cv00f4d51xvgmi4xx1hhyz2djki2pp4vnkrf";
  };

  gops = buildFromGitHub {
    version = 6;
    rev = "f341a40f99ec27eb59f219922de4c5f8369251a1";
    owner = "google";
    repo = "gops";
    sha256 = "278a7f8ce6fe4687ddb09507af1011def1c8ab4c8d857c0aa662765807ad3e3e";
    propagatedBuildInputs = [
      keybase_go-ps
      gopsutil
      goversion
      osext
      treeprint
    ];
    meta.useUnstable = true;
    date = "2018-09-03";
  };

  goterm = buildFromGitHub {
    version = 5;
    rev = "c9def0117b24a53e86f6c4c942e4042090a4fe8c";
    date = "2018-03-07";
    owner = "buger";
    repo = "goterm";
    sha256 = "1a8s0q4riks8w1gcnczkxf71g7fk4ky3xwhbla7h142pxvz2qz1c";
    propagatedBuildInputs = [
      sys
    ];
  };

  gotty = buildFromGitHub {
    version = 6;
    rev = "cd527374f1e5bff4938207604a14f2e38a9cf512";
    date = "2012-06-04";
    owner = "Nvveen";
    repo = "Gotty";
    sha256 = "16slr2a0mzv2bi90s5pzmb6is6h2dagfr477y7g1s89ag1dcayp8";
  };

  goutils = buildFromGitHub {
    version = 6;
    rev = "e865a1461c8ac0032bd37e2d4dab3289faea3873";
    date = "2018-05-30";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "0grpp9grwl1mzl1zpf2f6mprdcyxq4lgjiabjhbldpc49ydlgkhh";
    buildInputs = [
      cbauth
      go-couchbase
      gomemcached
    ];
  };

  goutils_gomemcached = buildFromGitHub {
    inherit (goutils) rev date owner repo sha256 version;
    subPackages = [
      "logging"
      "scramsha"
    ];
    propagatedBuildInputs = [
      crypto
      errors
    ];
  };

  hlandau_goutils = buildFromGitHub {
    version = 5;
    rev = "0cdb66aea5b843822af6fdffc21286b8fe8379c4";
    date = "2016-07-22";
    owner = "hlandau";
    repo = "goutils";
    sha256 = "08nm9nxz21km6ivvvr7pg8758bdzrjp3i6hkkf1v051i1hvci7ws";
  };

  golang-lru = buildFromGitHub {
    version = 6;
    rev = "v0.5.0";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "f73d0b0dd8ed861d7652aa75c9f6304eb53dfb1a038357082b6df4604cb7e1df";
  };

  golang-petname = buildFromGitHub {
    version = 6;
    rev = "d3c2ba80e75eeef10c5cf2fc76d2c809637376b3";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "0shg5xfygvkqds0c38dqfk7ivay41xy4cxs8r3yws9lxp60cx0jb";
    date = "2017-09-21";
  };

  golang-text = buildFromGitHub {
    version = 6;
    rev = "048ed3d792f7104850acbc8cfc01e5a6070f4c04";
    owner  = "tonnerre";
    repo   = "golang-text";
    sha256 = "188nzg7dcr3xl8ipgdiks6h3wxi51391y4jza4jcbvw1z1mi7iig";
    date = "2013-09-25";
    propagatedBuildInputs = [
      pty
      kr_text
    ];
    goPackageAliases = [
      "github.com/kr/text"
    ];
    meta.useUnstable = true;
  };

  golang_protobuf_extensions = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "16vxlzihbfab5jl2a7v8jixiifmdc6g96h5wln3407rzxdyg9zl9";
    propagatedBuildInputs = [
      protobuf
    ];
  };

  golcs = buildFromGitHub {
    version = 6;
    rev = "ecda9a501e8220fae3b4b600c3db4b0ba22cfc68";
    date = "2017-03-16";
    owner = "yudai";
    repo = "golcs";
    sha256 = "183cdzwfi0wif082j6w09zr7446sa2kgg6bc7lrhdnh5nvlj3ly0";
  };

  goleveldb = buildFromGitHub {
    version = 6;
    rev = "6b91fda63f2e36186f1c9d0e48578defb69c5d43";
    date = "2018-10-12";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "5b80e03abe3efc22bea8f4ebc85c4c10e8681602eb6cfa1ed4992b53d208816c";
    propagatedBuildInputs = [
      ginkgo
      gomega
      snappy
    ];
  };

  gomega = buildFromGitHub {
    version = 6;
    rev = "v1.4.2";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "7efc0a6ff48e7ffe37cc43e0422bd555857d171abeb76616f3a80c553c992400";
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
      date = "2018-10-21";
    };
    rev = "a2651947f503a1793446d4058bb073a6fdf99e53";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 6;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "31d218314653565cbbab37a9a69144ae623ba4e748a96d7320f8d8da18ed9237";
    };
    buildInputs = [
      appengine
      genproto
      grpc
      net
      oauth2
      opencensus
      sync
    ];
  };

  goorgeous = buildFromGitHub {
    version = 6;
    rev = "dcf1ef873b8987bf12596fe6951c48347986eb2f";
    owner = "chaseadamsio";
    repo = "goorgeous";
    sha256 = "ed381b2e3a17fc988fa48ec98d244def3ff99c67c73dc54a97973ead031fb432";
    propagatedBuildInputs = [
      blackfriday
      sanitized-anchor-name
    ];
    meta.useUnstable = true;
    date = "2017-11-26";
  };

  gopass = buildFromGitHub {
    version = 6;
    date = "2017-01-09";
    rev = "bf9dde6d0d2c004a008c27aaee91170c786f6db8";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "1f1n1qzdbmpss1njljsp58zcvzp0fjkq8830pgwa4y7zi99y2198";
    propagatedBuildInputs = [
      crypto
      sys
    ];
  };

  gopsutil = buildFromGitHub {
    version = 6;
    rev = "v2.18.07";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "b0cd60213e3a8212c40067be6a7abddc3e9f9e92f0113c9d7ec9dac84316c353";
    propagatedBuildInputs = [
      sys
      w32
      wmi
    ];
  };

  goquery = buildFromGitHub {
    version = 6;
    rev = "v1.4.1";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "0rdv11jhgmipwyrqj8yh3cb9p10n60brcwg8sxa4s0q1zbrxwgpc";
    propagatedBuildInputs = [
      cascadia
      net
    ];
  };

  gosaml2 = buildFromGitHub {
    version = 6;
    rev = "v0.3.1";
    owner  = "russellhaering";
    repo   = "gosaml2";
    sha256 = "1xgqb375q6vbw3f97zp3yg9mvz4a220p4pircf84dxn272p8vl0k";
    excludedPackages = "test";
    propagatedBuildInputs = [
      etree
      goxmldsig
    ];
  };

  gotask = buildFromGitHub {
    version = 6;
    rev = "104f8017a5972e8175597652dcf5a730d686b6aa";
    owner  = "jingweno";
    repo   = "gotask";
    sha256 = "1r289cd3wjkxa4n3lwicd9f58czrn5q99zvf67yb15d5i18qsmbv";
    date = "2014-01-12";
    propagatedBuildInputs = [
      urfave_cli
      go-shellquote
    ];
  };

  goupnp = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "huin";
    repo   = "goupnp";
    sha256 = "8bfb44fb056de70a0113b3b9cc828156f0d1d381ddb1ea6ac3869fdbc043edc5";
    propagatedBuildInputs = [
      goutil
      gotask
      net
    ];
  };

  goutil = buildFromGitHub {
    version = 6;
    rev = "1ca381bf315033e89af3286fdec0109ce8d86126";
    owner  = "huin";
    repo   = "goutil";
    sha256 = "0f3p0aigiappv130zvy94ia3j8qinz4di7akxsm09f0k1cblb82f";
    date = "2017-08-03";
  };

  govalidator = buildFromGitHub {
    version = 6;
    rev = "f9ffefc3facfbe0caee3fea233cbb6e8208f4541";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "14ykmgbacxb8bpnwm6a30bmflk9dba283vfkgvm3mdcq2yzh4d2h";
    date = "2018-07-20";
  };

  goversion = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner = "rsc";
    repo = "goversion";
    sha256 = "0qadgddl9vfr13mqf7d8v5i016bdjlalfndr5rdzigqyks12465v";
    goPackagePath = "rsc.io/goversion";
  };

  govmomi = buildFromGitHub {
    version = 6;
    rev = "v0.19.0";
    owner = "vmware";
    repo = "govmomi";
    sha256 = "561164468bc3a054e77785f43c6cf99c0b22769101320bda321dc0c029cff39f";
    excludedPackages = "toolbox";
    propagatedBuildInputs = [
      pretty
      google_uuid
    ];
  };

  goxmldsig = buildFromGitHub {
    version = 6;
    rev = "7acd5e4a6ef74fe1b082c20f119556adf70c3944";
    owner  = "russellhaering";
    repo   = "goxmldsig";
    sha256 = "193b68c5s9mgz1zljjn8ly3arxydm7xp1xlx64hrv5psd9dnwnmy";
    date = "2018-04-30";
    propagatedBuildInputs = [
      clockwork
      etree
    ];
  };

  go-autorest = buildFromGitHub {
    version = 6;
    rev = "v11.2.2";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "c3efed7c9f9b27dcf066be5151074925b67cbf956b9bfbdc1db203109e193db8";
    propagatedBuildInputs = [
      crypto
      jwt-go
      utfbom
    ];
    excludedPackages = "\\(cli\\|cmd\\|example\\|tracing\\)";
  };

  go-bindata-assetfs = buildFromGitHub {
    version = 6;
    rev = "38087fe4dafb822e541b3f7955075cc1c30bd294";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "9289c19ecfe1ba4ac8e8339cce731f240f06498a14425bb5ec1e2e0fc77c88ab";
    date = "2018-02-23";
  };

  go-bits = buildFromGitHub {
    version = 6;
    owner = "dgryski";
    repo = "go-bits";
    date = "2018-01-13";
    rev = "bd8a69a71dc203aa976f9d918b428db9ac605f57";
    sha256 = "017bhvl223wcnj8z7as0dhxdf2xk20shkylzdcw9rnxgp0h2lc9v";
  };

  go-bitstream = buildFromGitHub {
    version = 6;
    owner = "dgryski";
    repo = "go-bitstream";
    date = "2018-04-13";
    rev = "3522498ce2c8ea06df73e55df58edfbfb33cfdd6";
    sha256 = "1cd737cln47bbhzz37467vhpprqwvjxmlg1fblqd5skr8115r3qc";
  };

  go-buffer-pool = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-buffer-pool";
    rev = "058210c5a0d042677367d923eb8a6dc072a15f7f";
    sha256 = "2d24b05d2d144c2c83339407001c333b366ec9c7313ab17d90846c4c1b5603ef";
    date = "2018-10-09";
  };

  go-buffruneio = buildFromGitHub {
    version = 6;
    owner = "pelletier";
    repo = "go-buffruneio";
    rev = "de1592c34d9c6055a32fc9ebe2b3ee50ca468ebe";
    sha256 = "8c19c2827d1f1984285f1347ae3b57e0c7b08bc5b471b65cdfee8e58e690e918";
    date = "2018-08-27";
  };

  go-cache = buildFromGitHub {
    version = 6;
    rev = "5633e0862627c011927fa39556acae8b1f1df58a";
    owner = "patrickmn";
    repo = "go-cache";
    sha256 = "f4039b793da58306898c1d359ecd00072d3d4eae291552caecb7c280512938a3";
    date = "2018-08-15";
  };

  go-checkpoint = buildFromGitHub {
    version = 6;
    date = "2017-10-09";
    rev = "1545e56e46dec3bba264e41fde2c1e2aa65b5dd4";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "19ym24jvrvvnk2hbkh3pm9knkpfarg1g44xqlq9zzn7abjd2fi01";
    propagatedBuildInputs = [
      go-cleanhttp
      hashicorp_go-uuid
    ];
  };

  go-cid = buildFromGitHub {
    version = 6;
    rev = "v0.9.0";
    owner = "ipfs";
    repo = "go-cid";
    sha256 = "7738ee5ada7b8b80ec2f872dd258df4de51129da9d1cc8057853c82c50481efb";
    propagatedBuildInputs = [
      go-multibase
      go-multihash
    ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 6;
    rev = "v0.5.0";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "57bae7bed4eb3923fc312786e2a0db4e1976826c16c22f06d5650dfaca0d9b3b";
  };

  go-clocksmith = buildFromGitHub {
    version = 6;
    rev = "c35da9bed550558a4797c74e34957071214342e7";
    owner  = "jedisct1";
    repo   = "go-clocksmith";
    sha256 = "1ylqkk82mkp8lhg0i1z0rzqkgdn6ws2rzz6222dd416irlfd994w";
    date = "2018-03-07";
  };

  go-cmp = buildFromGitHub {
    version = 6;
    rev = "875f8df8b7965f1eac1098d36d677f807ac0b49e";
    owner  = "google";
    repo   = "go-cmp";
    sha256 = "51f891fe3cda7dfe43189dedd77176c4fe0dde2c9105401c1e128770e618d22d";
    date = "2018-09-11";
  };

  go-conn-security = buildFromGitHub {
    version = 6;
    rev = "v0.1.14";
    owner = "libp2p";
    repo = "go-conn-security";
    sha256 = "14ffb1444b244bd6127299382caf0a17e097411e936ef56eded212ff35b579b4";
    propagatedBuildInputs = [
      go-libp2p-crypto
      go-libp2p-net
      go-libp2p-peer
    ];
  };

  go-conntrack = buildFromGitHub {
    version = 5;
    rev = "cc309e4a22231782e8893f3c35ced0967807a33e";
    owner = "mwitkow";
    repo = "go-conntrack";
    sha256 = "01rrhajlxn6mjim8h0pzhl00s1k6jvssach0r7y81nrx0i299gsn";
    date = "2016-11-29";
    excludedPackages = "example";
    propagatedBuildInputs = [
      net
      prometheus_client_golang
    ];
  };

  go-collectd = buildFromGitHub {
    version = 6;
    owner = "collectd";
    repo = "go-collectd";
    rev = "606bd390f38f050824c77208d6715ed59e3692ac";
    sha256 = "0y3p574si855x586wxvb47hswhcz6kch4yx7xpr7nkc7mx87b4xw";
    goPackagePath = "collectd.org";
    buildInputs = [
      grpc
      net
      #pkgs.collectd
      protobuf
    ];
    /*preBuild = ''
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
    '';*/
    date = "2017-10-25";
  };

  go-colorable = buildFromGitHub {
    version = 6;
    rev = "efa589957cd060542a26d2dd7832fd6a6c6c3ade";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "3db1581524e4081655a54e2c268484a38fc92ec0dd5905d29341a606c0102a93";
    propagatedBuildInputs = [
      go-isatty
    ];
    date = "2018-03-10";
  };

  go-connections = buildFromGitHub {
    version = 6;
    rev = "97c2040d34dfae1d1b1275fa3a78dbdd2f41cf7e";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "f3f01afb3f71ca2eccc5a2da32528ad7a05c6ac5b9b8f3e11c8efb291e8e681d";
    propagatedBuildInputs = [
      errors
      go-winio
      logrus
      net
      runc
    ];
    date = "2018-08-21";
  };

  go-couchbase = buildFromGitHub {
    version = 6;
    rev = "595f46701cbcad107f3571d9bc8db4cebbc95cf7";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "3ab7269a2026d20c49b87b0b850ccc4a1594d0efee942bf98dee266b8bd22a9b";
    date = "2018-10-19";
    goPackageAliases = [
      "github.com/couchbaselabs/go-couchbase"
    ];
    propagatedBuildInputs = [
      gomemcached
      goutils_gomemcached
    ];
    excludedPackages = "\\(perf\\|example\\)";
  };

  davidlazar_go-crypto = buildFromGitHub {
    version = 6;
    rev = "dcfb0a7ac018a248366f96bcd8a2f8c805d7b268";
    owner  = "davidlazar";
    repo   = "go-crypto";
    sha256 = "19ldvhzvxqby9ir0q7zhwp2c8irid5z1jkj1wycr9m5b4bc3r7ls";
    date = "2017-07-01";
    propagatedBuildInputs = [
      crypto
    ];
  };

  keybase_go-crypto = buildFromGitHub {
    version = 6;
    rev = "e696c8039bba3970bbf4f9c1cf745ee96a705656";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "c4c0e91296f33878e71edfc4c9bacbdaed0def06e65f1de9e66a3339ccbdcb7d";
    date = "2018-10-17";
    propagatedBuildInputs = [
      ed25519
    ];
  };

  go-daemon = buildFromGitHub {
    version = 6;
    rev = "v0.1.4";
    owner  = "sevlyar";
    repo   = "go-daemon";
    sha256 = "f60139ed7740608c98cc096ab1302f8791cf37e12a7c3d73888664389b1bea86";
    propagatedBuildInputs = [
      osext
    ];
  };

  go-datastore = buildFromGitHub {
    version = 6;
    rev = "v3.2.0";
    owner  = "ipfs";
    repo   = "go-datastore";
    sha256 = "39f7e28e1fec5e8e91415a6370a4828d589fb20ae028e24308b379e9bf262c48";
    propagatedBuildInputs = [
      go-ipfs-delay
      google_uuid
      goprocess
    ];
  };

  go-deadlock = buildFromGitHub {
    version = 6;
    rev = "d68e2bc52ae3291765881b9056f2c1527f245f1e";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "c75d5f1375ef5a07dfc1ac1f209850e0babc77b222a3a39a0493b0ae19898020";
    propagatedBuildInputs = [
      goid
    ];
    date = "2018-08-22";
  };

  go-diff = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner  = "sergi";
    repo   = "go-diff";
    sha256 = "1m8svyblsqc460pcanmmp3gvd7zlj8w9rxmgrw6grj0czjmwgg74";
  };

  go-discover = buildFromGitHub {
    version = 6;
    rev = "f9c9239562a8e21e5a37f1f2604d8f1c11bc3893";
    owner  = "hashicorp";
    repo   = "go-discover";
    sha256 = "43126a15835c25f3965f433f30f8a88483f576f4c3e120ed535c4b40580e5dfb";
    date = "2018-08-31";
    propagatedBuildInputs = [
      aliyungo
      aws-sdk-go
      go-homedir
      go-multierror
      godo
      google-api-go-client
      gophercloud
      govmomi
      kubernetes-api
      kubernetes-apimachinery
      kubernetes-client-go
      oauth2
      packngo
      softlayer-go
      triton-go
      vic
    ];
    postPatch = ''
      rm -r provider/azure
      sed -i '/azure"/d' discover.go
      rm -r provider/scaleway
      sed -i '/scaleway/d' discover.go
    '';
  };

  go-difflib = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "16pdn2qxymqjk3pm3mx8qminyq7p8fjdi7j53mmpmiq00wafm2xa";
  };

  go-digest = buildFromGitHub {
    version = 6;
    rev = "c9281466c8b2f606084ac71339773efd177436e7";
    owner  = "opencontainers";
    repo   = "go-digest";
    sha256 = "05xbs5hx3jlbqlgk14fisa2y5ymw0jmjyzc8p9g8iab6c59qvsdy";
    date = "2018-04-30";
    goPackageAliases = [
      "github.com/docker/distribution/digest"
    ];
  };

  go-dnsstamps = buildFromGitHub {
    version = 6;
    rev = "1e4999280f861b465e03e21e4f84d838f2f02b38";
    owner  = "jedisct1";
    repo   = "go-dnsstamps";
    sha256 = "02sqqqyrjxr0xk29i0gaakrhrv41plsng85p1rsdszmxvl8q181s";
    date = "2018-04-18";
  };

  go-dockerclient = buildFromGitHub {
    version = 6;
    date = "2018-10-16";
    rev = "623c4c4b51ec7507502197470dbfbcf77ae877b3";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "3e8fac63615c5dde4e37438c82a8ef176cad43ad0a4f28b7b279e70879eba0a8";
    propagatedBuildInputs = [
      go-ansiterm
      go-cleanhttp
      go-units
      go-winio
      gotty
      logrus
      moby_lib
      mux
      net
      sys
    ];
  };

  go-dot = buildFromGitHub {
    version = 6;
    rev = "b11f31f3f44fedd9966e6fc98af5bb52b71a42ee";
    owner  = "zenground0";
    repo   = "go-dot";
    sha256 = "7bf2d54ec2f621552c9b11a1555b54fb0e4832b8c0a68e7467ca0ede1144de79";
    date = "2018-01-30";
    meta.autoUpdate = false;
  };

  go-envparse = buildFromGitHub {
    version = 5;
    rev = "310ca1881b22af3522e3a8638c0b426629886196";
    owner  = "hashicorp";
    repo   = "go-envparse";
    sha256 = "1g9pp9i3za5rhs19y3k2z0bpbdh5zhx8djlbd6m9sd6sj9yc6w4x";
    date = "2018-01-19";
  };

  go-errors = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner  = "go-errors";
    repo   = "errors";
    sha256 = "1sv8im4hqjq6llx2scr0fzxv3q013m5gybfvp9kyzrs7kd9bdkcl";
  };

  go-events = buildFromGitHub {
    version = 6;
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
    version = 6;
    rev = "2de33835d10275975374b37b2dcfd22c9020a1f5";
    owner  = "dgryski";
    repo   = "go-farm";
    sha256 = "ff79d079a6f66bae4b53d1b1c7c8762553457afaa26d561ed92df4e295c34bca";
    date = "2018-01-09";
  };

  go-flags = buildFromGitHub {
    version = 6;
    rev = "9c49a3351d49777ccd40148b5cdf6f2998f51087";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "64a8baceea9a7f6afd5460cc5422a5315e0cc351f27fa69ea5429636ca3b8721";
    date = "2018-10-06";
  };

  go-floodsub = buildFromGitHub {
    version = 6;
    rev = "v0.9.36";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "fed22878f308ed306b6ae2b66557a4ea09b28f5c63e9dbbf25a367c3d5a74a90";
    propagatedBuildInputs = [
      go-libp2p-host
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-protocol
      go-log
      go-multiaddr
      gogo_protobuf
      timecache
    ];
  };

  go-flow-metrics = buildFromGitHub {
    version = 6;
    rev = "7e5a55af485341567f98d6847a373eb5ddcdcd43";
    owner  = "libp2p";
    repo   = "go-flow-metrics";
    sha256 = "a45158e2c8ba6e2792755ecd3e96f80444f8db3963eea574b82c49c12543cff6";
    date = "2018-09-06";
  };

  go-flowrate = buildFromGitHub {
    version = 6;
    rev = "cca7078d478f8520f85629ad7c68962d31ed7682";
    owner  = "mxk";
    repo   = "go-flowrate";
    sha256 = "0xypq6z657pxqj5h2mlq22lvr8g6wvpqza1a1fvlq85i7i5nlkx9";
    date = "2014-04-19";
  };

  go-fs-lock = buildFromGitHub {
    version = 6;
    rev = "v0.1.8";
    owner  = "ipfs";
    repo   = "go-fs-lock";
    sha256 = "24f551fe6410ebb60da41e334703d65ef5bfea97b13fef4ceb736e0704b324b6";
    propagatedBuildInputs = [
      go-ipfs-util
      go-log
      go4
    ];
  };

  go-getter = buildFromGitHub {
    version = 6;
    rev = "4bda8fa99001c61db3cad96b421d4c12a81f256d";
    date = "2018-08-09";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "bf220f3935480e5bdffaa61e881ec6069bf4896a95345ab3cb75b39ebfe13d5e";
    propagatedBuildInputs = [
      aws-sdk-go
      go-cleanhttp
      go-homedir
      go-netrc
      go-safetemp
      go-testing-interface
      go-version
      xz
    ];
  };

  go-gitignore = buildFromGitHub {
    version = 6;
    rev = "1.0.2";
    owner = "sabhiram";
    repo = "go-gitignore";
    sha256 = "175f924269ed85052f1f12c603acd0c62300f1e4198bf67aec3c216864a47b6b";
  };

  go-github = buildFromGitHub {
    version = 6;
    rev = "v18.2.0";
    owner = "google";
    repo = "go-github";
    sha256 = "90f2d305f34af8008958fee236141ae557047dc682a513f234fa9049d20d62fa";
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
    version = 6;
    date = "2017-01-28";
    rev = "256dc444b735e061061cf46c809487313d5b0065";
    owner = "ryanuber";
    repo = "go-glob";
    sha256 = "1alfqb04ajgcrdb2927zlxp7b981dix832hn3wikpih4zzhdzc0a";
  };

  go-grpc-middleware = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "grpc-ecosystem";
    repo = "go-grpc-middleware";
    sha256 = "137r442rmahahp5vpx4pvpwnhy0a3hwjg181bgr86af8a509xa6b";
    excludedPackages = "\\(testing\\|zap\\)";
    propagatedBuildInputs = [
      grpc
      logrus
      net
      opentracing-go
      protobuf
    ];
  };

  go-grpc-prometheus = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner = "grpc-ecosystem";
    repo = "go-grpc-prometheus";
    sha256 = "14y200andvlvj6fyxzrkivznzp09ir6sqzzzpzfwjv429zwjcy6l";
    propagatedBuildInputs = [
      grpc
      net
      prometheus_client_golang
    ];
  };

  go-grpc-sql = buildFromGitHub {
    version = 6;
    rev = "181d263025fb02a680c1726752eb27f3a2154e26";
    owner = "CanonicalLtd";
    repo = "go-grpc-sql";
    sha256 = "0al376z43y4aswx25794wn7i0yxsklalldys711799az4g01wl1j";
    date = "2018-07-11";
    propagatedBuildInputs = [
      errors
      CanonicalLtd_go-sqlite3
      grpc
      net
      protobuf
    ];
  };

  go-hclog = buildFromGitHub {
    version = 6;
    date = "2018-10-01";
    rev = "61d530d6c27f994fb6c83b80f99a69c54125ec8a";
    owner  = "hashicorp";
    repo   = "go-hclog";
    sha256 = "94f0cd06926e25bf32feb8a66e596354bddcc194b3bbc83df173c41afe8bf048";
  };

  go-hdb = buildFromGitHub {
    version = 6;
    rev = "v0.13.1";
    owner  = "SAP";
    repo   = "go-hdb";
    sha256 = "7620fd98eb2cf48c335c6632b8c5c9174225362ebe37490122f89541a3f6aa48";
    propagatedBuildInputs = [
      text
    ];
  };

  go-homedir = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "4c1732650974203f25b4e1b116eef6dca6cc8ac37305ac9bde96e334e2f252db";
    goPackageAliases = [
      "github.com/minio/go-homedir"
    ];
  };

  go-hostpool = buildFromGitHub {
    version = 6;
    rev = "e80d13ce29ede4452c43dea11e79b9bc8a15b478";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "09l9ryijsxcggrp28vx1gi2h5nlds4pxz4zf3lzjbcqg58vh7iax";
  };

  gohtml = buildFromGitHub {
    version = 6;
    owner = "yosssi";
    repo = "gohtml";
    rev = "97fbf36f4aa81f723d0530f5495a820ba267ae5f";
    date = "2018-01-30";
    sha256 = "c45c52494313ca9aa94b281d6f071c6eefec942c7a5826ede1f7e440c1227fd0";
    propagatedBuildInputs = [
      net
    ];
  };

  go-humanize = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "45ec84293c58e7e9d8bd2583fda07c2164e2cfc5a1cbfc0e4c28a97f971c1ee8";
  };

  go-i18n = buildFromGitHub {
    version = 6;
    rev = "fc57a7d765ba8b271515d588acd2f891bdc3d070";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "f7d1e5882e0a4aecfcfe4d30bab43d968cfbecdac633cf3d09ae9dd22dc7c469";
    excludedPackages = "example";
    propagatedBuildInputs = [
      go-toml
      text
      toml
      yaml_v2
    ];
    date = "2018-09-29";
  };

  go-immutable-radix = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "680a0ce30e88407ec66813faa6957defd903022025847684ec08ca4bcf30c387";
    propagatedBuildInputs = [
      golang-lru
    ];
  };

  go-ipfs-api = buildFromGitHub {
    version = 6;
    rev = "4857c98b7e16abaed1b66aaa5e4bcd9364001065";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "3c061ea083b9c3ae4374925b24b90b7dc2faa0ba0b83373ecbd7890ebe4b8371";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-homedir
      go-ipfs-files
      go-libp2p-metrics
      go-libp2p-peer
      go-multiaddr
      go-multiaddr-net
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2018-10-17";
  };

  go-ipfs-delay = buildFromGitHub {
    version = 6;
    rev = "v0.0.1";
    owner  = "ipfs";
    repo   = "go-ipfs-delay";
    sha256 = "54bbd6c9dc50afd0afbe57eabf755974c263587b1f1293d699df5ed0aeee6dff";
  };

  go-ipfs-files = buildFromGitHub {
    version = 6;
    rev = "90d206a6f3947f904673ebffd376a2dcbbd84942";
    owner  = "ipfs";
    repo   = "go-ipfs-files";
    sha256 = "e88eb9eedf5c641964db1094fb8f0c55eb52805691ac653fd768f636a72f34a7";
    date = "2018-10-17";
    propagatedBuildInputs = [
      sys
    ];
  };

  go-ipfs-util = buildFromGitHub {
    version = 6;
    rev = "v1.2.8";
    owner  = "ipfs";
    repo   = "go-ipfs-util";
    sha256 = "11zbmnqmp99jwssjrkvpmh3l4vn7pv31ys05qs5nl6snzc4h2ja1";
    propagatedBuildInputs = [
      base58
      go-multihash
    ];
  };

  go-isatty = buildFromGitHub {
    version = 6;
    rev = "3fb116b820352b7f0c281308a4d6250c22d94e27";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "5117691dae90c3c84672fa1a91d40555697ed7944f13719bc2efd3d2c989516e";
    propagatedBuildInputs = [
      sys
    ];
    date = "2018-08-30";
  };

  go-jmespath = buildFromGitHub {
    version = 6;
    rev = "c2b33e8439af944379acbdd9c3a5fe0bc44bd8a5";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "7dd00ab6b630ca5479ffd15fd482b4c05ebf97ed617847896be65ced3dac8ad7";
    date = "2018-02-06";
  };

  go-jose_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.1.2";
    owner = "square";
    repo = "go-jose";
    sha256 = "0cdvlhx38s5j4qyd09k3brl6jpiv0gmkxb2s4hdwqnpwdbc4dns5";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
  };

  go-jose_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.1.9";
    owner = "square";
    repo = "go-jose";
    sha256 = "850d1d61df671b452530ea428a1b660462bee99559d6efbceb5d0339a640c120";
    goPackagePath = "gopkg.in/square/go-jose.v2";
    buildInputs = [
      crypto
      urfave_cli
      kingpin_v2
    ];
  };

  go-keyspace = buildFromGitHub {
    version = 6;
    rev = "5b898ac5add1da7178a4a98e69cb7b9205c085ee";
    owner = "whyrusleeping";
    repo = "go-keyspace";
    sha256 = "10g8bj04l819p9494mhn23d8wcvs2jnrmm38zhm4s7l881rwn12n";
    date = "2016-03-22";
  };

  go-libp2p = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p";
    rev = "v6.0.19";
    sha256 = "1ab3eae5b722f57113fcea06ca369541a3405a893b03e930b6e56d152f2bb827";
    excludedPackages = "mock";
    propagatedBuildInputs = [
      goprocess
      go-ipfs-util
      go-log
      go-libp2p-circuit
      go-libp2p-crypto
      go-libp2p-host
      go-libp2p-interface-connmgr
      go-libp2p-interface-pnet
      go-libp2p-loggables
      go-libp2p-metrics
      go-libp2p-nat
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-libp2p-swarm
      go-libp2p-transport
      go-multiaddr
      go-multiaddr-dns
      go-multiaddr-net
      go-multistream
      go-semver
      go-smux-multiplex
      go-smux-multistream
      go-smux-yamux
      go-stream-muxer
      whyrusleeping_mdns
      gogo_protobuf
    ];
  };

  go-libp2p-circuit = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-circuit";
    rev = "v2.2.8";
    sha256 = "f2109a3433ffaa130aa3ed43fe2b252eea8b8eab838b19a5e608d184d3cc1bdb";
    propagatedBuildInputs = [
      go-addr-util
      go-log
      go-libp2p-crypto
      go-libp2p-host
      go-libp2p-interface-conn
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-swarm
      go-libp2p-transport
      go-maddr-filter
      go-multiaddr
      go-multiaddr-net
      go-multihash
      gogo_protobuf
    ];
  };

  go-libp2p-conn = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-conn";
    date = "2018-06-08";
    rev = "fd8ad28832460f1d5c05f9b33321d4dd8e85f61d";
    sha256 = "1w15s8pf9k9q5p4dp57g2ip0fckfqm8l48lr1akh3xf7ypfmh3yw";
    propagatedBuildInputs = [
      go-log
      go-temp-err-catcher
      goprocess
      go-addr-util
      go-libp2p-crypto
      go-libp2p-interface-conn
      go-libp2p-interface-pnet
      go-libp2p-loggables
      go-libp2p-peer
      go-libp2p-secio
      go-libp2p-transport
      go-maddr-filter
      go-msgio
      go-multiaddr
      go-multiaddr-net
      go-multistream
    ];
    meta.autoUpdate = false;
  };

  go-libp2p-consensus = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-consensus";
    rev = "v0.0.1";
    sha256 = "0ylz4zwpan2nkhyq9ckdclrxhsf86nmwwp8kcwi334v0491963fh";
  };

  go-libp2p-crypto = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-crypto";
    rev = "v2.0.1";
    sha256 = "57cb8a28c43d86e3fb97a451017e6fbe59861f891e07ca4b33642e64bcea1c18";
    propagatedBuildInputs = [
      btcd
      ed25519
      gogo_protobuf
      sha256-simd
    ];
  };

  go-libp2p-gorpc = buildFromGitHub {
    version = 6;
    owner = "hsanjuan";
    repo = "go-libp2p-gorpc";
    date = "2018-10-17";
    rev = "bda5f2cc09b8bf5f4452353f3b76ecfacc851129";
    sha256 = "c8efe1d1ccfa812abadc2ddf4f74f2267c88d5704cddcaafae2bd3345ca9bd8d";
    propagatedBuildInputs = [
      go-log
      go-libp2p-host
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-protocol
      go-multicodec
    ];
  };

  go-libp2p-gostream = buildFromGitHub {
    version = 6;
    owner = "hsanjuan";
    repo = "go-libp2p-gostream";
    date = "2018-10-17";
    rev = "0fd1009672b05a37b1aa206c981d4a23e0985d93";
    sha256 = "0da0e1f6299618edd4942faf5c94b962d909698e8bc42ec8b5f3e13b49c212d0";
    propagatedBuildInputs = [
      go-libp2p-host
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-protocol
    ];
  };

  go-libp2p-host = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-host";
    rev = "v3.0.14";
    sha256 = "7fb49add0fd4b132c34f49a8a260eaaa39823157df479de39499f8986ec95492";
    propagatedBuildInputs = [
      go-libp2p-interface-connmgr
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-multiaddr
      go-multistream
      go-semver
    ];
  };

  go-libp2p-http = buildFromGitHub {
    version = 6;
    owner = "hsanjuan";
    repo = "go-libp2p-http";
    date = "2018-10-17";
    rev = "09c6953618d112dfbf4f1bee15a6424f65c471ea";
    sha256 = "ba375dfbdfdf67302dd6eae5952ab919a58823df06ac84e170d7b3242031ea64";
    propagatedBuildInputs = [
      go-libp2p-gostream
      go-libp2p-host
      go-libp2p-peer
      go-libp2p-protocol
    ];
  };

  go-libp2p-interface-conn = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-interface-conn";
    date = "2018-06-08";
    rev = "c7cda99284db0bea441058da8fd1f1373c763ed6";
    sha256 = "0zavzm070pnn0d5bdzlvygiy2saysm8z9i8sccjqjrzz9kfld77s";
    propagatedBuildInputs = [
      go-ipfs-util
      go-libp2p-crypto
      go-libp2p-peer
      go-libp2p-transport
      go-maddr-filter
      go-multiaddr
    ];
  };

  go-libp2p-interface-connmgr = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-interface-connmgr";
    rev = "v0.0.20";
    sha256 = "bdf3e662dd0144e88e612462330d864ebb1f8f1e06d957e7a235910f33bd86cb";
    propagatedBuildInputs = [
      go-libp2p-net
      go-libp2p-peer
      go-multiaddr
    ];
  };

  go-libp2p-interface-pnet = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-interface-pnet";
    rev = "v3.0.0";
    sha256 = "08zmp4cf26fqrrlya393hxzcq5l75ih6mmak9hinvz44a0aza7b9";
    propagatedBuildInputs = [
      #go-libp2p-transport
    ];
  };

  go-libp2p-loggables = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-loggables";
    rev = "v1.1.23";
    sha256 = "309d1f9a1b59fab732cf0dd14452f995a828dfac7c483d0e2a3aa0d223c06a7a";
    propagatedBuildInputs = [
      go-log
      go-libp2p-peer
      go-multiaddr
      google_uuid
    ];
  };

  go-libp2p-metrics = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-metrics";
    rev = "v2.1.7";
    sha256 = "06d7653a8ad3923b22ce6690a137c23a5834a948e536307522d6ce91e20ae1d4";
    propagatedBuildInputs = [
      go-flow-metrics
      go-libp2p-peer
      go-libp2p-protocol
    ];
  };

  go-libp2p-nat = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-nat";
    rev = "v0.8.7";
    sha256 = "28738655d093fe2bd1f09cb348d4a7a32b81fe375221f48669c88a7bf39d6605";
    propagatedBuildInputs = [
      goprocess
      go-log
      go-multiaddr
      go-multiaddr-net
      go-nat
      go-notifier
    ];
  };

  go-libp2p-net = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-net";
    rev = "v3.0.14";
    sha256 = "c9d2e93b89c9acbcef0c430db86f82da75318a31e6f42d54adb76f698ea0b975";
    propagatedBuildInputs = [
      goprocess
      go-libp2p-crypto
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-multiaddr
      go-stream-muxer
    ];
  };

  go-libp2p-peer = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-peer";
    rev = "v2.4.0";
    sha256 = "863df3f2313a2c35436acec428476c5c6170b37bdcb8b933b372b65e1e57f73e";
    propagatedBuildInputs = [
      base58
      go-libp2p-crypto
      go-multihash
    ];
    excludedPackages = "test";
  };

  go-libp2p-peerstore = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-peerstore";
    rev = "v2.0.4";
    sha256 = "a2e6888921d108e4d621078894957511487a54f6f79c0dbe860a4992f323bdfb";
    excludedPackages = "test";
    propagatedBuildInputs = [
      go-buffer-pool
      go-datastore
      go-libp2p-crypto
      go-libp2p-peer
      go-log
      go-keyspace
      go-multiaddr
      go-multiaddr-net
      go-multihash
      golang-lru
      mafmt
    ];
  };

  go-libp2p-pnet = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-pnet";
    rev = "v3.0.4";
    sha256 = "ffa313e560aa76961a4d15dd37f0c7fd473fd28638852c5b866cbb436639e02f";
    propagatedBuildInputs = [
      crypto
      davidlazar_go-crypto
      go-libp2p-interface-pnet
      go-libp2p-transport
      go-msgio
      go-multicodec
    ];
  };

  go-libp2p-protocol = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-protocol";
    date = "2017-12-12";
    rev = "b29f3d97e3a2fb8b29c5d04290e6cb5c5018004b";
    sha256 = "d0ee8b905bab42feb2ca0d2ec84c185ffad524dd1b8d0bd6e67b5adff208fc45";
  };

  go-libp2p-pubsub = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-pubsub";
    rev = "v0.9.36";
    sha256 = "41afea6c561d1ef17448a2f546a2ab0436a78528fe25961a185f308d72670ba4";
    propagatedBuildInputs = [
      gogo_protobuf
    ];
  };

  go-libp2p-raft = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-raft";
    date = "2018-10-17";
    rev = "0f9dbb29fa9b9d6033cea904c5841022d0e50197";
    sha256 = "d4639e368b155f0f0140ff6f51da11255c59e3672b52544f40e10ab957249f02";
    propagatedBuildInputs = [
      go-libp2p-consensus
      go-libp2p-gostream
      go-libp2p-host
      go-libp2p-peer
      go-libp2p-protocol
      go-log
      go-multicodec
      raft
    ];
  };

  go-libp2p-secio = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-secio";
    rev = "v2.0.16";
    sha256 = "c0c4324c4cb1289f64af7854830dfdcf9dd09912982e9b9d8658d39af61e473b";
    propagatedBuildInputs = [
      crypto
      gogo_protobuf
      go-conn-security
      go-log
      go-libp2p-crypto
      go-libp2p-peer
      go-msgio
      go-multihash
      sha256-simd
    ];
  };

  go-libp2p-swarm = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-swarm";
    rev = "v3.0.20";
    sha256 = "39b2c6b0d5f4123cc48658281674e01295bf8ac6f44eae37a6e2855173ba93b4";
    propagatedBuildInputs = [
      go-log
      goprocess
      go-addr-util
      go-libp2p-conn
      go-libp2p-crypto
      go-libp2p-interface-conn
      go-libp2p-interface-pnet
      go-libp2p-loggables
      go-libp2p-metrics
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-libp2p-transport
      go-maddr-filter
      go-peerstream
      go-stream-muxer
      go-tcp-transport
      go-ws-transport
      go-multiaddr
      go-smux-multistream
      go-smux-spdystream
      go-smux-yamux
      multiaddr-filter
    ];
  };

  go-libp2p-transport = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-transport";
    rev = "v3.0.14";
    sha256 = "cd2a350246e3d4e587b82a43540b610642f99e2c866b1d92990553dc425fdb35";
    propagatedBuildInputs = [
      go-libp2p-net
      go-libp2p-peer
      go-log
      go-stream-muxer
    ];
    excludedPackages = "test";
  };

  go-libp2p-transport-upgrader = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-transport-upgrader";
    rev = "v0.1.15";
    sha256 = "b797511c1693c0c148bc3ef294775740cc1412316ac2414016f278f80c1c1efe";
    propagatedBuildInputs = [
      #go-conn-security
      go-log
      go-libp2p-interface-pnet
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-transport
      go-maddr-filter
      #go-multiaddr-net
      go-stream-muxer
      go-temp-err-catcher
    ];
  };

  go-libsass = buildFromGitHub {
    version = 6;
    owner = "wellington";
    repo = "go-libsass";
    rev = "615eaa47ef794d037c1906a0eb7bf85375a5decf";
    sha256 = "0zibgs0rb3i3rgyj885rwlp1rv2ijpqjqqakb0cxcsfv141ys6iv";
    buildInputs = [
      pkgs.libsass
    ];
    propagatedBuildInputs = [
      net
      spritewell
    ];
    buildFlags = [
      "-tags=dev"  # Needed to build against system libsass
    ];
    meta.useUnstable = true;
    date = "2018-06-24";
  };

  go-log = buildFromGitHub {
    version = 6;
    owner = "ipfs";
    repo = "go-log";
    rev = "v1.5.7";
    sha256 = "43f22e8d7a23a99aa283166ed84fab75682f47fbacca4285bd5762a69e295c33";
    propagatedBuildInputs = [
      go-colorable
      whyrusleeping_go-logging
      opentracing-go
      gogo_protobuf
    ];
  };

  whyrusleeping_go-logging = buildFromGitHub {
    version = 6;
    owner = "whyrusleeping";
    repo = "go-logging";
    date = "2017-05-15";
    rev = "0457bb6b88fc1973573aaf6b5145d8d3ae972390";
    sha256 = "1nvij6lrhm2smckxkdjm0y50xivc83bq2ymyd1xis0f2qr14x2r6";
  };

  go-logging = buildFromGitHub {
    version = 6;
    owner = "op";
    repo = "go-logging";
    date = "2016-03-15";
    rev = "970db520ece77730c7e4724c61121037378659d9";
    sha256 = "060h5p3qx1ik36p787p2cbzcj2cpl3hn4qj8jaslx6rwg2c161ik";
  };

  go-lxc_v2 = buildFromGitHub {
    version = 6;
    rev = "91c005a38eb9f825d22cf2bd61102c0c2fa1e93a";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "325d50764dae268b7a2ce715f10cbcfb228e67f4b15de21ed7c7fb11b2aef6d5";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2018-09-25";
  };

  go-lz4 = buildFromGitHub {
    version = 6;
    rev = "7224d8d8f27ef618c0a95f1ae69dbb0488abc33a";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1x5l4najgmmpm5hi00r5a1qzrmbzxm9iabjjnxmbxpnb05jbbsv2";
    date = "2016-09-24";
  };

  go-maddr-filter = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-maddr-filter";
    rev = "v1.1.9";
    sha256 = "1082i8rkx5i27bkc6dhvq2clyhqll1rjp310dim75pgayh1y1nys";
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-net
    ];
  };

  go-md2man = buildFromGitHub {
    version = 6;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "20f5889cbdc3c73dbd2862796665e7c465ade7d1";
    sha256 = "5626c7561787b1478a9f05dbe11a92133787c173da53e1363232f7275e5bad47";
    propagatedBuildInputs = [
      blackfriday
    ];
    meta.autoUpdate = false;
    date = "2018-01-19";
  };

  go-mega = buildFromGitHub {
    version = 6;
    date = "2018-08-17";
    rev = "854bf31d998b151cf5f94529c815bc4c67322949";
    owner = "t3rm1n4l";
    repo = "go-mega";
    sha256 = "1bc0f20e0abc05b9f45a7e1fd5280ef25ca7ed312510d0a347230666df1c0c33";
  };

  go-memdb = buildFromGitHub {
    version = 6;
    date = "2018-02-23";
    rev = "1289e7fffe71d8fd4d4d491ba9a412c50f244c44";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "553f470474e25ddd2856c3f6142ebe0fcea1426338257367ebb8f6ff4d2c93d6";
    propagatedBuildInputs = [
      go-immutable-radix
    ];
  };

  armon_go-metrics = buildFromGitHub {
    version = 6;
    date = "2018-09-17";
    rev = "f0300d1749da6fa982027e449ec0c7a145510c3c";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "8f29774cc8cda8b4b097669336d85302f67c0a7669e767048b3c65fa64d61d43";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
      go-immutable-radix
      prometheus_client_golang
    ];
  };

  docker_go-metrics = buildFromGitHub {
    version = 6;
    date = "2018-02-09";
    rev = "399ea8c73916000c64c2c76e8da00ca82f8387ab";
    owner = "docker";
    repo = "go-metrics";
    sha256 = "de50ab09fddf592dcd5c581e9ca54a2ef1a4207189f178df0b24637981925adb";
    propagatedBuildInputs = [
      prometheus_client_golang
    ];
    postPatch = ''
      grep -q 'lt.m.WithLabelValues(labels...)}' timer.go
      sed -i '/WithLabelValues/s,)},).(prometheus.Histogram)},' timer.go
    '';
  };

  rcrowley_go-metrics = buildFromGitHub {
    version = 6;
    rev = "3113b8401b8a98917cde58f8bbd42a1b1c03b1fd";
    date = "2018-10-16";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "08dc43d03c54144e7ebcfbd4a3695304f2dca3486081113aa85817b6393d1ca5";
    propagatedBuildInputs = [
      stathat
    ];
  };

  go-metro = buildFromGitHub {
    version = 6;
    date = "2015-06-07";
    rev = "d5cb643948fbb1a699e6da1426f0dba75fe3bb8e";
    owner = "dgryski";
    repo = "go-metro";
    sha256 = "5d271cba19ad6aa9b0aaca7e7de6d5473eb4a9e4b682bbb1b7a4b37cca9bb706";
    meta.autoUpdate = false;
  };

  go-minisign = buildFromGitHub {
    version = 6;
    date = "2018-05-16";
    rev = "f4dbde220b4f73d450949b9ba27fa941faa05a78";
    owner = "jedisct1";
    repo = "go-minisign";
    sha256 = "1h3xi13z72ffdas1n89rmnyjaisc16i4f69r5z3j7qpi2nmda6z8";
    propagatedBuildInputs = [
      crypto
    ];
  };

  go-mplex = buildFromGitHub {
    version = 6;
    rev = "v0.2.30";
    owner  = "libp2p";
    repo   = "go-mplex";
    sha256 = "82acc50ed8185dd6bfaadcbc0895fa401da4ada154bbdeddf57a9abd37e92f65";
    propagatedBuildInputs = [
      go-log
      go-msgio
    ];
  };

  go-msgio = buildFromGitHub {
    version = 6;
    rev = "v0.0.6";
    owner = "libp2p";
    repo = "go-msgio";
    sha256 = "884c9b7318652233a211e115566917d5ebad2728c43d7b16be9bf3bbf2502311";
  };

  go-mssqldb = buildFromGitHub {
    version = 6;
    rev = "4e0d7dc8888fbb59764060e99b7b68e77a6f9698";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "e8b2fbfc477a12400b392337253ad54bb77e158f0f2495c0eac3019cf3fa9af5";
    date = "2018-10-14";
    propagatedBuildInputs = [
      crypto
      google-cloud-go
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 6;
    rev = "v1.3.0";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "df129be83c288e5ec89400fdc8297881c5458a4f7bfbb0466b1026878c089be3";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-dns = buildFromGitHub {
    version = 6;
    rev = "v0.2.4";
    owner  = "multiformats";
    repo   = "go-multiaddr-dns";
    sha256 = "25389c8e7d9e531124f2e63cfdc09188fe4729df153721a00c6a8c716dff9130";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 6;
    rev = "v1.6.3";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "e79c398b882d4860b403ea9c1e46da3574e6c3c14fbf77c8604e3a32c00a9f96";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  go-multibase = buildFromGitHub {
    version = 6;
    rev = "v0.3.0";
    owner  = "multiformats";
    repo   = "go-multibase";
    sha256 = "2b4fe05f2a24c28129bab9a68c912d5cd8b3ba747f5e56db9267d1f1832421d0";
    propagatedBuildInputs = [
      base58
      base32
    ];
  };

  go-multicodec = buildFromGitHub {
    version = 6;
    rev = "v0.1.6";
    owner  = "multiformats";
    repo   = "go-multicodec";
    sha256 = "951f8d975ed79fe40b7f1e3f8fd9563808545414dcc260c0dfb2e812c159fcfd";
    propagatedBuildInputs = [
      cbor
      ugorji_go
      go-msgio
      gogo_protobuf
    ];
  };

  go-multicodec-packed = buildFromGitHub {
    version = 6;
    owner = "multiformats";
    repo = "go-multicodec-packed";
    date = "2018-02-01";
    rev = "9004b413b478e5a878e4a879358cce02e5df4995";
    sha256 = "3356daff49cc696ce807c9ed9dd3fd2ca4dc39cff177dbfd8131d85a19ae9ca8";
  };

  go-multierror = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "de8c40d499113b78e309408a06987dba8698fcd77f71f74ff97e94164cffb057";
    propagatedBuildInputs = [
      errwrap
    ];
  };

  go-multihash = buildFromGitHub {
    version = 6;
    rev = "97cdb562a04c6ef66d8ed40cd62f8fbcddd396d6";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "eaa319c3b3d53d9885da3e601e3bef415cbf8d41d56941535f4db7e342d47894";
    goPackageAliases = [
      "github.com/jbenet/go-multihash"
    ];
    propagatedBuildInputs = [
      base58
      blake2b-simd
      crypto
      hashland
      murmur3
      sha256-simd
    ];
    meta.useUnstable = true;
    date = "2018-10-11";
  };

  go-multiplex = buildFromGitHub {
    version = 6;
    rev = "v0.2.30";
    owner  = "whyrusleeping";
    repo   = "go-multiplex";
    sha256 = "afe3b7048e26c7911effc5640c487ca6234f91949fdb77f4f45cc572cbb17955";
    propagatedBuildInputs = [
      go-log
      go-mplex
      go-msgio
    ];
  };

  go-multistream = buildFromGitHub {
    version = 6;
    rev = "v0.3.9";
    owner  = "multiformats";
    repo   = "go-multistream";
    sha256 = "56d38bb88b6148dfbe32cff1b70e25df37f655a34c860ffbb01b5e6a243dbed7";
  };

  go-nat = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "fd";
    repo   = "go-nat";
    sha256 = "1cdkwkyv7sj33bzf5xpjx3m6cvig1mvxg4b0g5pi7ammw3syal60";
    propagatedBuildInputs = [
      gateway
      goupnp
      jackpal_go-nat-pmp
    ];
  };

  AudriusButkevicius_go-nat-pmp = buildFromGitHub {
    version = 6;
    rev = "452c97607362b2ab5a7839b8d1704f0396b640ca";
    owner  = "AudriusButkevicius";
    repo   = "go-nat-pmp";
    sha256 = "1za02f0pf9bl9x6skcdgd1r98ajrqdyvikayx4wjmhldfalnk0d5";
    date = "2016-05-22";
  };

  jackpal_go-nat-pmp = buildFromGitHub {
    version = 6;
    rev = "d89d09f6f3329bc3c2479aa3cafd76a5aa93a35c";
    owner  = "jackpal";
    repo   = "go-nat-pmp";
    sha256 = "7f97af754a9ede81e984ebb62870071ca4af21c0f3ca343b917268d55d478f9a";
    date = "2018-10-21";
  };

  go-nats = buildFromGitHub {
    version = 6;
    rev = "v1.6.0";
    owner = "nats-io";
    repo = "go-nats";
    sha256 = "50f9b824057951073d257328fde59c0277f3674abbcf77eddf11282b09b4c2c3";
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
    version = 6;
    rev = "v0.4.0";
    owner = "nats-io";
    repo = "go-nats-streaming";
    sha256 = "0v6vaxfw6ndpginhq56z99racnjxsrjww4sw53pzk2vq9wrdfkqi";
    propagatedBuildInputs = [
      go-nats
      nuid
      gogo_protobuf
    ];
  };

  go-netrc = buildFromGitHub {
    version = 6;
    owner = "bgentry";
    repo = "go-netrc";
    date = "2014-04-22";
    rev = "9fd32a8b3d3d3f9d43c341bfe098430e07609480";
    sha256 = "16qzlynvx0v6fjlpnc9mfbkvk1ch1r42p1ykaapgrli17mmb5cl3";
  };

  go-notifier = buildFromGitHub {
    version = 6;
    owner = "whyrusleeping";
    repo = "go-notifier";
    date = "2017-08-27";
    rev = "097c5d47330ff6a823f67e3515faa13566a62c6f";
    sha256 = "0syzw67lyy1prvcrlyfac6kxib6271lkrg8b389ll05jp47dp5w3";
    propagatedBuildInputs = [
      goprocess
    ];
  };

  go-observer = buildFromGitHub {
    version = 6;
    date = "2017-06-22";
    rev = "a52f2342449246d5bcc273e65cbdcfa5f7d6c63c";
    owner  = "opentracing-contrib";
    repo   = "go-observer";
    sha256 = "17mxbj220pispjk2601phnkkj64qxc6kq12kq4f1h41hdrl2jacv";
    propagatedBuildInputs = [
      opentracing-go
    ];
  };

  go-oidc = buildFromGitHub {
    version = 6;
    rev = "e860bd55bfa7d7cb35d30d26a167982584f616b0";
    date = "2017-10-20";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "24afc192d8b598af61460c28ad4ae4c4e700c483c5738d37b1aba2819f67891b";
    propagatedBuildInputs = [
      clockwork
      pkg
    ];
    meta.autoUpdate = false;
    excludedPackages = "example";
  };

  go-ole = buildFromGitHub {
    version = 6;
    rev = "7a0fa49edf48165190530c675167e2f319a05268";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "026qdad5xzmhgbfny9sph3gh53i91l03ayl8v8pcsrdmgh8wnizx";
    excludedPackages = "example";
    date = "2018-06-25";
  };

  go-os-rename = buildFromGitHub {
    version = 6;
    rev = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2";
    owner  = "jbenet";
    repo   = "go-os-rename";
    sha256 = "0s8yk3yyx6y49y31nj3cmb28xrmszrjsakg2ww6gldskzxnqca00";
    date = "2015-04-28";
  };

  go-ovh = buildFromGitHub {
    version = 6;
    rev = "c3e61035ea66f5c637719c90140da4e3ac3b1bf0";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "1jxp2xmwnw8pjj93xgcb5aga4qpq7p1dlb11zsapgkg6c1bq6j5w";
    date = "2018-07-17";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-peerstream = buildFromGitHub {
    version = 6;
    rev = "v2.1.5";
    owner  = "libp2p";
    repo   = "go-peerstream";
    sha256 = "1ghy0wi65s71jn55j0ll82dj5qg73brjh970j0gz3lnvk2m3dw7d";
    excludedPackages = "\\(example\\|test\\)";
    propagatedBuildInputs = [
      go-temp-err-catcher
      go-libp2p-protocol
      go-libp2p-transport
      go-stream-muxer
    ];
  };

  go-plugin = buildFromGitHub {
    version = 6;
    rev = "314501b665e0b2cc71bbd829783179fc38840a85";
    date = "2018-10-04";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "f954183964bd1e3604da94d6aa09377851ebc62bb35f90f154fb0ecf05ae1f11";
    propagatedBuildInputs = [
      go-hclog
      go-testing-interface
      grpc
      net
      protobuf
      run
      hashicorp_yamux
    ];
  };

  go-prompt = buildFromGitHub {
    version = 5;
    rev = "f0d19b6901ade831d5a3204edc0d6a7d6457fbb2";
    date = "2016-10-17";
    owner  = "segmentio";
    repo   = "go-prompt";
    sha256 = "08lf80hw2wlmahxbrbmpq1gs8ss9ixwc54zim33zw0hg98r4dsp4";
    propagatedBuildInputs = [
      gopass
    ];
  };

  go-proxyproto = buildFromGitHub {
    version = 5;
    date = "2018-02-02";
    rev = "5b7edb60ff5f69b60d1950397f7bde6171f1807d";
    owner  = "armon";
    repo   = "go-proxyproto";
    sha256 = "0b47i56ph4k7z02c8xw0wkcpvfs631zksgl78hli16vpmswh3qal";
  };

  go-ps = buildFromGitHub {
    version = 6;
    rev = "4fdf99ab29366514c69ccccddab5dc58b8d84062";
    date = "2017-03-09";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "1x70gc6y9licdi6qww1lkwx1wkwwkqylzhkfl0wpnizl8m7vpdmp";
  };

  keybase_go-ps = buildFromGitHub {
    version = 6;
    rev = "668c8856d9992f97248b3177d45743d2cc1068db";
    date = "2016-10-05";
    owner  = "keybase";
    repo   = "go-ps";
    sha256 = "0phx2zlxwmzsv2s1h891gps1hyy2wwl7w7wi7s2hgys076xcgiqf";
  };

  go-python = buildFromGitHub {
    version = 6;
    owner = "sbinet";
    repo = "go-python";
    date = "2018-08-07";
    rev = "17c9f530692bb11c325ea8f7d0917ad6cdac88b3";
    sha256 = "0f27ee0fbd6794445357be6f0706ff850166e13737b3a3e93ddb75c8a534b231";
    propagatedBuildInputs = [
      pkgs.python2Packages.python
    ];
  };

  go-querystring = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "2f6f7c1f4f3e2fc9a0eb8a820aaa1106888ab970a4fa81b15a11c8ac0aac445f";
  };

  go-radix = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "c6af58d97cd38609f60e8b6980558237bc454979b75b9be9faa55819704473a8";
  };

  go-resiliency = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "eapache";
    repo   = "go-resiliency";
    sha256 = "1m8vz7mgmkjfjr925dgmz30bxm7fl7rskan8j6bgy8dbsjwdskc8";
  };

  go-restful = buildFromGitHub {
    version = 6;
    rev = "v2.8.0";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "0vivpb1fi35a05zc12n6hqbh9ia9digiwqjg3jwmidhrw61mi7qa";
    propagatedBuildInputs = [
      json-iterator_go
    ];
  };

  go-retryablehttp = buildFromGitHub {
    version = 6;
    rev = "e651d75abec6fbd4f2c09508f72ae7af8a8b7171";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "11v7fwh4q587ynskas7d22f2715zqxk7f8zlsayrzaj1y962ayjx";
    date = "2018-07-18";
    propagatedBuildInputs = [
      go-cleanhttp
    ];
  };

  go-reuseport = buildFromGitHub {
    version = 6;
    rev = "v0.1.18";
    owner = "libp2p";
    repo = "go-reuseport";
    sha256 = "5a7a1e349bb04ce692d33fe810d570b22f2831568893aadd70386cd06ba42064";
    excludedPackages = "test";
    propagatedBuildInputs = [
      eventfd
      go-log
      libp2p_go-sockaddr
      sys
    ];
  };

  go-reuseport-transport = buildFromGitHub {
    version = 6;
    rev = "v0.1.10";
    owner = "libp2p";
    repo = "go-reuseport-transport";
    sha256 = "3c254e3ec7180e1dea4a1ef53f3a66aab5777c3ebed31f0acaa0862d8d198d53";
    excludedPackages = "test";
    propagatedBuildInputs = [
      go-log
      go-multiaddr
      go-multiaddr-net
      go-reuseport
    ];
  };

  go-rootcerts = buildFromGitHub {
    version = 6;
    rev = "6bb64b370b90e7ef1fa532be9e591a81c3493e00";
    owner = "hashicorp";
    repo = "go-rootcerts";
    sha256 = "1q6fkwji12hcnp90wsz506fkc9nxjvpzjz4fs6v6z52iba1zymbm";
    date = "2016-05-03";
    buildInputs = [
      go-homedir
    ];
  };

  go-runewidth = buildFromGitHub {
    version = 6;
    rev = "v0.0.3";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "e7054fcc1e574d83e410ec73c43761e7d052cc99f8f763a8323087639c4b13b8";
  };

  go-safetemp = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "go-safetemp";
    sha256 = "23ecace90ec78ed3834def8be5d7498d6e803e3cc5443756bfd95dbf36929f41";
  };

  go-semver = buildFromGitHub {
    version = 6;
    rev = "e214231b295a8ea9479f11b70b35d5acf3556d9b";
    owner  = "coreos";
    repo   = "go-semver";
    sha256 = "84eb26cdf3bfa7679321c7ae425c838652f2d4bdb400cf4ecdb7a89e58451aba";
    date = "2018-01-08";
  };

  go-shared = buildFromGitHub {
    version = 6;
    rev = "1ef04317652833067e47e2ee9815f1f254a7a1da";
    owner  = "pengsrc";
    repo   = "go-shared";
    sha256 = "1v1df9w104haws8s510h1k924js7zy9g403rpyyp1bwxr1vkikzk";
    propagatedBuildInputs = [
      gabs
    ];
    meta.useUnstable = true;
    date = "2018-07-18";
  };

  go-shellquote = buildFromGitHub {
    version = 6;
    rev = "95032a82bc518f77982ea72343cc1ade730072f0";
    owner  = "kballard";
    repo   = "go-shellquote";
    sha256 = "1sp0wyb56q03pnd2bdqsa267kx1rvfc51dvjnnghi4h6hrvr7vg6";
    date = "2018-04-28";
  };

  go-shellwords = buildFromGitHub {
    version = 6;
    rev = "f8471b0a71ded0ab910825ee2cf230f25de000f1";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "1f7jkn3bgncqf15diwzzpb74mlzgjwf4k9j74yzbqnfvpy1ypzgf";
    date = "2018-06-05";
  };

  go-shuffle = buildFromGitHub {
    version = 6;
    owner = "shogo82148";
    repo = "go-shuffle";
    date = "2018-02-18";
    rev = "27e6095f230d6c769aafa7232db643a628bd87ad";
    sha256 = "4584b8d5d714fc7599e3108726f3e5b5367174067114409b6d13057e387410e8";
  };

  go-smux-multiplex = buildFromGitHub {
    version = 6;
    rev = "v3.0.16";
    owner  = "whyrusleeping";
    repo   = "go-smux-multiplex";
    sha256 = "6664f1f42bb61b5d0d4923f359b6e7dfd546f8173864aa31f16750676303499a";
    propagatedBuildInputs = [
      go-stream-muxer
      go-multiplex
    ];
  };

  go-smux-multistream = buildFromGitHub {
    version = 6;
    rev = "v2.0.2";
    owner  = "whyrusleeping";
    repo   = "go-smux-multistream";
    sha256 = "faec9aa820a4579860aaa611006592540643a197725ab7b456263ca699eee731";
    propagatedBuildInputs = [
      go-stream-muxer
      go-multistream
    ];
  };

  go-smux-spdystream = buildFromGitHub {
    version = 6;
    rev = "a6182ff2a058b177f3dc7513fe198e6002f7be78";
    owner  = "whyrusleeping";
    repo   = "go-smux-spdystream";
    sha256 = "1kifzd34j5pcigl47ly5m0jzgl5z0kjk7sa5jfcd4jpx2h3anf2c";
    date = "2017-09-12";
    propagatedBuildInputs = [
      go-stream-muxer
      spdystream
    ];
  };

  go-smux-yamux = buildFromGitHub {
    version = 6;
    rev = "v2.0.6";
    owner  = "whyrusleeping";
    repo   = "go-smux-yamux";
    sha256 = "b608b9d59e0e1a75df84d8c38f46d975d2680408c618b7930214ed5555672010";
    propagatedBuildInputs = [
      go-stream-muxer
      whyrusleeping_yamux
    ];
  };

  go-snappy = buildFromGitHub {
    version = 6;
    rev = "d8f7bb82a96d89c1254e5a6c967134e1433c9ee2";
    owner  = "siddontang";
    repo   = "go-snappy";
    sha256 = "1zifpmzxn5659lvn7bxi2a3460jwax1sr566zzispsksawzxlx61";
    date = "2014-07-04";
  };

  hashicorp_go-sockaddr = buildFromGitHub {
    version = 6;
    rev = "6d291a969b86c4b633730bfc6b8b9d64c3aafed9";
    owner  = "hashicorp";
    repo   = "go-sockaddr";
    sha256 = "0fkcjb66i2rfbdnwry6j43p36nxkpb8mlc8z3abbk04y0ji6p9wd";
    date = "2018-03-20";
    propagatedBuildInputs = [
      mitchellh_cli
      columnize
      errwrap
      go-wordwrap
    ];
  };

  libp2p_go-sockaddr = buildFromGitHub {
    version = 6;
    rev = "v1.0.3";
    owner  = "libp2p";
    repo   = "go-sockaddr";
    sha256 = "1kam1g5lrv1h9z57qg935kyxadbn0kpwbbrbal892pl0yl4hcwaq";
    propagatedBuildInputs = [
      sys
    ];
  };

  go-spew = buildFromGitHub {
    version = 6;
    rev = "d8f796af33cc11cb798c1aaeb27a4ebc5099927d";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "62b9aa1e94b4456b6c2613790b490d73698d7f7dfd34e2966aa044138ed6134a";
    date = "2018-08-30";
  };

  go-sqlite3 = buildFromGitHub {
    version = 6;
    rev = "f3aa5ce89995fab8c7777f7821f689d9ac81c80f";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "35f8043c07149cb4e4a00f8998b939eaa86eadc662f4cb0400b9b3ad76649e4b";
    excludedPackages = "test";
    meta.useUnstable = true;
    date = "2018-10-21";
    propagatedBuildInputs = [
      goquery
    ];
  };

  CanonicalLtd_go-sqlite3 = buildFromGitHub {
    version = 6;
    rev = "4b194c2b1130b08d976c8b85de2be160ad8040af";
    owner  = "CanonicalLtd";
    repo   = "go-sqlite3";
    sha256 = "0x0l4bcgnsx5mvpyvm4g5y6z1azb36rainsj8hxixddsgxl62d7m";
    excludedPackages = "test";
    meta.useUnstable = true;
    date = "2018-05-07";
    propagatedBuildInputs = [
      errors
    ];
  };

  go-stdlib = buildFromGitHub {
    version = 6;
    rev = "07a764486eb10927e8cf38337918a40d430524ee";
    owner  = "opentracing-contrib";
    repo   = "go-stdlib";
    sha256 = "1vqah2m71z0950cqmp6kzmyj7aabjv8nwlg9qcmxhvpag4qpc4c0";
    date = "2018-07-02";
    propagatedBuildInputs = [
      opentracing-go
    ];
  };

  go-stream-muxer = buildFromGitHub {
    version = 6;
    rev = "v3.0.1";
    owner  = "libp2p";
    repo   = "go-stream-muxer";
    sha256 = "1j74wxm1ac9634wzqf809hi04a2l4s306452bbviyxblm9wmhshi";
  };

  go-syslog = buildFromGitHub {
    version = 6;
    date = "2017-08-29";
    rev = "326bf4a7f709d263f964a6a96558676b103f3534";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "0xn6ybw807nv4cniq6iqhjzyk4civv2j5lym2wsdzmff6vrbgq06";
  };

  go-systemd = buildFromGitHub {
    version = 6;
    rev = "c6f51f82210d9608a835763225a5e2a3c87583c6";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "2cc9abfbceed85b92d8023052bc8851c0e5af1cc7f1f8da890b3007588e5af53";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2018-10-12";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 version date;
    subPackages = [
      "journal"
    ];
  };

  go-tcp-transport = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-tcp-transport";
    rev = "v2.0.15";
    sha256 = "5b706591fa97703862b86a61d4de589ea3c4fc00a293d2bda21f71be738661e9";
    propagatedBuildInputs = [
      go-log
      go-libp2p-peer
      go-libp2p-transport
      go-libp2p-transport-upgrader
      go-multiaddr
      go-multiaddr-net
      go-reuseport
      go-reuseport-transport
      mafmt
    ];
  };

  go-temp-err-catcher = buildFromGitHub {
    version = 6;
    owner = "jbenet";
    repo = "go-temp-err-catcher";
    rev = "aac704a3f4f27190b4ccc05f303a4931fd1241ff";
    sha256 = "1kc54g07a979ak76ngfwssfwz09z3pp3iyhdh536yb26agkwi0nh";
    date = "2015-01-20";
  };

  go-testing-interface = buildFromGitHub {
    version = 6;
    owner = "mitchellh";
    repo = "go-testing-interface";
    rev = "v1.0.0";
    sha256 = "b5e0384c16c01f3a6949e656c97fbffbe35938830532604437af26d55e06c628";
  };

  go-tocss = buildFromGitHub {
    version = 6;
    owner = "bep";
    repo = "go-tocss";
    rev = "v0.5.0";
    sha256 = "d95cb1d36dbc8d8629fbd92d45005c425dd4c2f2ada8126d3c57f7357298c117";
    propagatedBuildInputs = [
      go-libsass
    ];
  };

  go-toml = buildFromGitHub {
    version = 6;
    owner = "pelletier";
    repo = "go-toml";
    rev = "81a861c69d25a841d0c4394f0e6f84bc8c5afae0";
    sha256 = "f2d1ff7b93dec4c7e856064a98120f6466b64aef5ab60fbd261dd1eb8b48a939";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2018-09-30";
  };

  go-units = buildFromGitHub {
    version = 6;
    rev = "v0.3.3";
    owner = "docker";
    repo = "go-units";
    sha256 = "03l2crcb056sadamm4yljzjw1jqzydjs0n7i4qbyzcyl3zgwnmvp";
  };

  go-unsnap-stream = buildFromGitHub {
    version = 6;
    rev = "9f0cb55181dd3a0a4c168d3dbc72d4aca4853126";
    owner = "glycerine";
    repo = "go-unsnap-stream";
    sha256 = "0fx4cd1b2rf71dmfhcvn0f100h4qas169wb6vs07k0h7w5x92sa7";
    date = "2018-03-23";
    propagatedBuildInputs = [
      snappy
    ];
  };

  go-update = buildFromGitHub {
    version = 6;
    rev = "8152e7eb6ccf8679a64582a66b78519688d156ad";
    owner = "inconshreveable";
    repo = "go-update";
    sha256 = "0rwxd9acgxqcz7wlv6fwcabkdicb6afyfvhqglic11cndcjapkd1";
    date = "2016-01-12";
  };

  hashicorp_go-uuid = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "8661e3a1b97f9960785ada6c296ccdd342d5c0018a5d21249966b0bf25ffde5e";
  };

  satori_go-uuid = buildFromGitHub {
    version = 6;
    rev = "8ccf5352a842c034b1a69f28c863aff9b1cdb116";
    owner  = "satori";
    repo   = "go.uuid";
    sha256 = "4804093f32623163b90c029aa36a2bc22ff6e9ee00bc6f9abc4e2f71cbb0f872";
    goPackageAliases = [
      "github.com/satori/uuid"
    ];
    meta.useUnstable = true;
    date = "2018-10-16";
  };

  go-version = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "2d488634cc0a05cde05a38301948644a369cbb48b5e3c10b889f0f9b114b8103";
  };

  go-windows-terminal-sequences = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner  = "konsorten";
    repo   = "go-windows-terminal-sequences";
    sha256 = "3353b0ea4139a1795fbd11b35e22e0af666ee25b53fa68cf745389092984f01a";
  };

  go-winio = buildFromGitHub {
    version = 6;
    rev = "v0.4.11";
    owner  = "Microsoft";
    repo   = "go-winio";
    sha256 = "7cb6cab7a28e4c37ccfea6cb1c583fdae59b6d00257d801545267623196bca2a";
    buildInputs = [
      sys
    ];
    # Doesn't build on non-windows machines
    postPatch = ''
      rm vhd/zvhd.go
    '';
  };

  go-wordwrap = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "mitchellh";
    repo   = "go-wordwrap";
    sha256 = "097edf913b269b3680daae8ce0c147cde2164a3e6c63a7acfcc71221478d7790";
  };

  go-ws-transport = buildFromGitHub {
    version = 6;
    rev = "v2.0.14";
    owner  = "libp2p";
    repo   = "go-ws-transport";
    sha256 = "9b3925bfa5865fc1f8c2c11195d846a9fef4209f46deec81939234a608909c9c";
    propagatedBuildInputs = [
      go-libp2p-peer
      go-libp2p-transport
      go-libp2p-transport-upgrader
      go-multiaddr
      go-multiaddr-net
      mafmt
      websocket
    ];
  };

  go-xerial-snappy = buildFromGitHub {
    version = 6;
    rev = "776d5712da21bc4762676d614db1d8a64f4238b0";
    owner  = "eapache";
    repo   = "go-xerial-snappy";
    sha256 = "88b0836a9d24c0bd89e1d5d4e6831c9b0575685061d2a0f4f15420509f41d193";
    date = "2018-08-14";
    propagatedBuildInputs = [
      snappy
    ];
  };

  go-zookeeper = buildFromGitHub {
    version = 6;
    rev = "c4fab1ac1bec58281ad0667dc3f0907a9476ac47";
    date = "2018-01-30";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "ccea1615d726d3f59aecf93d10d2bad9bcb95f04acc3c9adc23ed7dc0efd97ec";
  };

  gocertifi = buildFromGitHub {
    version = 6;
    owner = "certifi";
    repo = "gocertifi";
    rev = "ee1a9a0726d2ae45f54118cac878c990d4016ded";
    sha256 = "b84e4c60ebae83155f0019e19d03f17ff691c76abb69e13a23872c331b48b503";
    date = "2018-09-05";
  };

  goconfig = buildFromGitHub {
    version = 6;
    owner = "Unknwon";
    repo = "goconfig";
    rev = "ef1e4c783f8f0478bd8bff0edb3dd0bade552599";
    date = "2018-03-08";
    sha256 = "644314d34bca17991176d54f217d6c115ad258b7dae7a4667311d6730b811daf";
  };

  gorequest = buildFromGitHub {
    version = 6;
    owner = "parnurzeal";
    repo = "gorequest";
    rev = "8e3aed27fe49f7fdc765dad067845f600fc984e8";
    sha256 = "0s1gg9knh7qsmd7mggr062iwri1dwl5m2nkyqlxalf5yrcivdqhf";
    propagatedBuildInputs = [
      errors
      http2curl
      net
    ];
    date = "2017-10-15";
  };

  graceful_v1 = buildFromGitHub {
    version = 6;
    owner = "tylerb";
    repo = "graceful";
    rev = "v1.2.15";
    sha256 = "0bc3hb3g62q12kfm91h4szx8svdmpjn9qy7dbj3wrxzwmjzv0q60";
    goPackagePath = "gopkg.in/tylerb/graceful.v1";
    excludedPackages = "test";
  };

  grafana = buildFromGitHub {
    version = 6;
    owner = "grafana";
    repo = "grafana";
    rev = "v5.3.1";
    sha256 = "8c5cbe65dee669c67533c50829ca85fdef9718ced7d601bd48e4e843c4036d83";
    buildInputs = [
      aws-sdk-go
      binding
      urfave_cli
      clock
      color
      com
      core
      gojsondiff
      gomail_v2
      go-cache
      go-hclog
      go-isatty
      go-mssqldb
      go-spew
      go-plugin
      go-sqlite3
      go-version
      grafana_plugin_model
      gzip
      ini_v1
      ldap
      log15
      macaron_v1
      mail_v2
      mysql
      net
      oauth2
      opentracing-go
      pq
      prometheus_client_golang
      prometheus_client_model
      prometheus_common
      session
      shortid
      slug
      stack
      sync
      toml
      websocket
      xorm
      yaml_v2
    ];
    postPatch = ''
      rm -r pkg/tracing
      sed -e '/tracing\.Init/,+4d' -e '\#pkg/tracing#d' -i pkg/cmd/grafana-server/server.go
    '';
    excludedPackages = "test";
    postInstall = ''
      rm "$bin"/bin/build
    '';
  };

  grafana_plugin_model = buildFromGitHub {
    version = 6;
    owner = "grafana";
    repo = "grafana_plugin_model";
    rev = "84176c64269d8060f99e750ee8aba6f062753336";
    sha256 = "0k8qvm29rbdvawmdqpc3jc3qrd3yi2xzh4rrnd1r0ymq639vv9cz";
    date = "2018-05-18";
    propagatedBuildInputs = [
      go-plugin
      grpc
      net
      protobuf
    ];
  };

  graphite-golang = buildFromGitHub {
    version = 5;
    owner = "marpaia";
    repo = "graphite-golang";
    date = "2017-12-31";
    rev = "134b9af18cf31f936ebddbd11c03eead4d501601";
    sha256 = "13pywiz2jr835i0kd8msw8gl1aabrjswwh2vgr2q24pyc9vblgcn";
  };

  groupcache = buildFromGitHub {
    version = 6;
    date = "2018-09-24";
    rev = "6f2cf27854a4a29e3811b0371547be335d411b8b";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "e3a179c9e18172d4d780a8a47ef910b808e5eeed484c841c3738e9efd5882266";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub rec {
    version = 6;
    rev = "v1.10.1";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "65a812baf1d3eb6693d334e53d6cdec18779775763f92131187a3c8722bbbcce";
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
    # GRPC 1.11.0 is broken with swarmkit 2018-03-27
    meta.autoUpdate = false;
  };

  grpc_for_gax-go = grpc.override {
    propagatedBuildInputs = [
      genproto_for_grpc
      net
      protobuf
    ];
    subPackages = [
      "."
      "balancer"
      "balancer/base"
      "balancer/roundrobin"
      "codes"
      "connectivity"
      "credentials"
      "encoding"
      "encoding/proto"
      "grpclb/grpc_lb_v1"
      "grpclb/grpc_lb_v1/messages"
      "grpclog"
      "internal"
      "keepalive"
      "metadata"
      "naming"
      "peer"
      "resolver"
      "resolver/dns"
      "resolver/manual"
      "resolver/passthrough"
      "stats"
      "status"
      "tap"
      "transport"
    ];
  };

  grpc-gateway = buildFromGitHub {
    version = 6;
    rev = "v1.5.1";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "2c818f832714260b47273227e7f3b7184cf9596b252498fd799db1357ac172da";
    propagatedBuildInputs = [
      genproto
      glog
      grpc
      net
      protobuf
      yaml
    ];
  };

  grpc-websocket-proxy = buildFromGitHub {
    version = 6;
    rev = "830351dc03c6f07d625727d5f993a463babb20e1";
    owner = "tmc";
    repo = "grpc-websocket-proxy";
    sha256 = "1wknphrvfa0x5k6sml6fcx4835wq7pmlnxml9jcbdyl5h1d9ywzc";
    date = "2017-10-17";
    propagatedBuildInputs = [
      logrus
      net
      websocket
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

  gspt = buildFromGitHub {
    version = 6;
    owner = "erikdubbelboer";
    repo = "gspt";
    rev = "e39e726e09cc23d1ccf13b36ce10dbdb4a4510e0";
    sha256 = "1b17nyllj3pyhpshjngqyq3mpblmq9d1ijcb8wm5kqpm6fq5zgvd";
    date = "2018-07-11";
  };

  guid = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner = "marstr";
    repo = "guid";
    sha256 = "0i7dlyaxyhlhp6z3m6n29cjsjlb55cwcjvc0qb88r9f5ixgbrpy0";
  };

  gx = buildFromGitHub {
    version = 6;
    rev = "v0.14.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "8e6c2fe3bb950c12bb155109b79d282d6085eef0551776f0d69079451c7480de";
    propagatedBuildInputs = [
      urfave_cli
      go-gitignore
      go-homedir
      go-ipfs-api
      go-multiaddr
      go-multiaddr-net
      go-multihash
      json-filter
      progmeter
      semver
      stump
    ];
    excludedPackages = [
      "tests"
    ];
  };

  gx-go = buildFromGitHub {
    version = 6;
    rev = "v1.9.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "889d37e482dc26faec0dd44354cd109fb428cea2019eb58b77d6370b5ce96061";
    buildInputs = [
      urfave_cli
      fs
      go-homedir
      gx
      stump
    ];
  };

  gzip = buildFromGitHub {
    version = 6;
    date = "2016-02-22";
    rev = "cad1c6580a07c56f5f6bc52d66002a05985c5854";
    owner = "go-macaron";
    repo = "gzip";
    sha256 = "0kc7xqp9kafpp0dqlkmkqgz1d179j4dxahqwp1hd776qkaqhn9ii";
    propagatedBuildInputs = [
      compress
      macaron_v1
    ];
  };

  gziphandler = buildFromGitHub {
    version = 6;
    rev = "253f1acb9d9f896d86c313a3dc994c0b114f0e12";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "cf55be5367d48e36fc8f4b5291ca344bec505dc85944b50cb04b9f6c221f7025";
    date = "2018-08-20";
  };

  hashland = buildFromGitHub {
    version = 6;
    rev = "07375b562deaa8d6891f9618a04e94a0b98e2ee7";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "c70ea6068865fcc2cb7df1ebff0d7964a0a7a884918575ec445d3d57b45de4ec";
    goPackagePath = "leb.io/hashland";
    goPackageAliases = [
      "github.com/gxed/hashland"
    ];
    meta.autoUpdate = false;
    date = "2017-10-03";
    excludedPackages = "example";
    propagatedBuildInputs = [
      aeshash
      blake2b-simd
      cuckoo
      go-farm
      go-metro
      hrff
      whirlpool
    ];
  };

  hashland_for_aeshash = hashland.override {
    subPackages = [
      "nhash"
    ];
    propagatedBuildInputs = [ ];
  };

  handlers = buildFromGitHub {
    version = 6;
    owner = "gorilla";
    repo = "handlers";
    rev = "v1.4.0";
    sha256 = "6ea615ff5bd6b40764993b7854476bd782fc4edf8baffb3e1335781e87d5875d";
  };

  hashstructure = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "ea04c8ff8c94513e04928e61de1d9e364d7c70eaab0c7734be47428bdc46a3ca";
  };

  hcl = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "832a02fb7a49b648327bcf541ac6e5277c0035dfe334ead82bdd134316ee0794";
  };

  hdrhistogram = buildFromGitHub {
    version = 6;
    date = "2016-10-10";
    rev = "3a0bb77429bd3a61596f5e8a3172445844342120";
    owner  = "codahale";
    repo   = "hdrhistogram";
    sha256 = "02f2m6blg0bij0kc06r1zkhf088nlksfkdhd2lhyv7wh1963isxc";
    propagatedBuildInputs = [
      #mgo_v2
    ];
  };

  highwayhash = buildFromGitHub {
    version = 6;
    date = "2018-05-01";
    rev = "85fc8a2dacad36a6beb2865793cd81363a496696";
    owner  = "minio";
    repo   = "highwayhash";
    sha256 = "0737lhfhdgf5rgjv3gq55jglfdknvvmj30zvs81h0smk76wkd3s0";
    propagatedBuildInputs = [
      sys
    ];
  };

  hil = buildFromGitHub {
    version = 6;
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
    version = 6;
    owner = "retailnext";
    repo = "hllpp";
    date = "2018-03-08";
    rev = "101a6d2f8b52abfc409ac188958e7e7be0116331";
    sha256 = "1prk8yvr9i9dzj3r32hchrwbrm1h9j5z47acskncma3irbvnszxb";
  };

  holster = buildFromGitHub {
    version = 6;
    rev = "v2.2.1";
    owner = "mailgun";
    repo = "holster";
    sha256 = "975579ab7d5713f3bf13337fa75b56aeabd376c1a1de25f1b380368f727de619";
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
    version = 6;
    rev = "c180d57d286b385101c999a60087a40d7f48fc77";
    owner  = "gokyle";
    repo   = "hotp";
    sha256 = "1d5yn6xjclakdc5d4mg3izgjrs5klgbm1x0y85zpf2fsy94dh20h";
    date = "2016-02-18";
    propagatedBuildInputs = [
      rsc
    ];
  };

  hrff = buildFromGitHub {
    version = 6;
    rev = "757f8bd43e20ae62b376efce979d8e7082c16362";
    owner  = "tildeleb";
    repo   = "hrff";
    sha256 = "660e1161c0fad9377d24164ddab3d9baffd94947cbac06ef7d0147ec34efbb3d";
    goPackagePath = "leb.io/hrff";
    date = "2017-09-27";
    meta.autoUpdate = false;
  };

  http2curl = buildFromGitHub {
    version = 6;
    owner = "moul";
    repo = "http2curl";
    date = "2017-09-19";
    rev = "9ac6cf4d929b2fa8fd2d2e6dec5bb0feb4f4911d";
    sha256 = "17v1xp38rww73fj42zqgp4xi9r2h3clwhrp4n46hri69xm4hi4f1";
  };

  httpcache = buildFromGitHub {
    version = 6;
    rev = "9cad4c3443a7200dd6400aef47183728de563a38";
    owner  = "gregjones";
    repo   = "httpcache";
    sha256 = "28530455bf2c899496f725c789ee4732c49a676152f3200356d31e7d6f00e611";
    date = "2018-03-05";
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

  http-link-go = buildFromGitHub {
    version = 6;
    rev = "ac974c61c2f990f4115b119354b5e0b47550e888";
    owner  = "tent";
    repo   = "http-link-go";
    sha256 = "05zir2mh47n1mlrnxgahxplxnaib0248xijd26mfs4ws88507bv3";
    date = "2013-07-02";
  };

  httprequest_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.1.2";
    owner  = "go-httprequest";
    repo   = "httprequest";
    sha256 = "1xgiy4jmrbqyg9i9v5i93qqbzyiarbl2c6ic3p2gjcrd6pf228f2";
    goPackagePath = "gopkg.in/httprequest.v1";
    goPackageAliases = [
      "github.com/juju/httprequest"
    ];
    propagatedBuildInputs = [
      errgo_v1
      httprouter
      net
      tools
    ];
  };

  httprouter = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "8336da5f449ba34aa8af9cc13028e507c09d423e3980ab2e8a42959630555425";
  };

  httpunix = buildFromGitHub {
    version = 6;
    rev = "b75d8614f926c077e48d85f1f8f7885b758c6225";
    owner  = "tv42";
    repo   = "httpunix";
    sha256 = "03pz7s57v5hmy1hlsannj48zxy1rl8d4rymdlvqh3qisz7705izw";
    date = "2015-04-27";
  };

  hugo = buildFromGitHub {
    version = 6;
    owner = "gohugoio";
    repo = "hugo";
    rev = "v0.49.2";
    sha256 = "2ae4daea2ed406e0f3e366295f23c195e41b4547cc2ed546b9ed71a375677ce4";
    buildInputs = [
      ace
      afero
      amber
      blackfriday
      cast
      chroma
      cobra
      debounce
      emoji
      fsnotify
      fsync
      gitmap
      glob
      go-i18n
      go-immutable-radix
      go-tocss
      goorgeous
      hashstructure
      image
      imaging
      inflect
      jwalterweatherman
      locker
      mage
      mapstructure
      minify
      mmark
      net
      nitro
      pflag
      prose
      purell
      smartcrop
      sync
      tablewriter
      text
      toml
      viper
      websocket
      yaml_v2
    ];
  };

  idmclient = buildFromGitHub {
    version = 6;
    rev = "15392b0e99abe5983297959c737b8d000e43b34c";
    owner  = "juju";
    repo   = "idmclient";
    sha256 = "06fbsl1f2r2jrk9gfv9qm8yxczdm1azv66kvryzmf6r0i9kf6jxl";
    date = "2017-11-10";
    excludedPackages = "test";
    propagatedBuildInputs = [
      environschema_v1
      errgo_v1
      httprequest_v1
      macaroon_v2
      macaroon-bakery_v2
      names_v2
      net
      usso
      utils
    ];
  };

  image-spec = buildFromGitHub {
    version = 6;
    rev = "b6e51fa50549ee0bd5188494912a7f4c382cb0d4";
    owner  = "opencontainers";
    repo   = "image-spec";
    sha256 = "cd3c291f4d41ea93ea3463d4db171924d4df1e3e094554f1bd62477978e5b65e";
    propagatedBuildInputs = [
      errors
      go4
      go-digest
      gojsonreference
      gojsonschema
    ];
    date = "2018-10-11";
  };

  imaging = buildFromGitHub {
    version = 6;
    rev = "v1.5.0";
    owner  = "disintegration";
    repo   = "imaging";
    sha256 = "293b9d64f1ee01a48b7c802ef62dc6f78b31e8b1a132e35c6e772a67a7a9ea64";
    propagatedBuildInputs = [
      image
    ];
  };

  inf_v0 = buildFromGitHub {
    version = 6;
    rev = "v0.9.1";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "14v751j7wigydxmvvv075dfdb6ahd53rqrbfvx01b5va6kdnczjn";
    goPackagePath = "gopkg.in/inf.v0";
  };

  inflect = buildFromGitHub {
    version = 6;
    owner = "markbates";
    repo = "inflect";
    rev = "v1.0.3";
    sha256 = "2e89fe6d1e379c7a138444cc5a4b48893201b501706fb0bf72c1a20d288f1ec6";
    propagatedBuildInputs = [
      envy
    ];
  };

  influxdb = buildFromGitHub {
    version = 6;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.6.4";
    sha256 = "c88fb029f53cc143220493aeb0bf8b3dd7c6a4cd4e85c50711e8724accfa4755";
    propagatedBuildInputs = [
      bolt
      crypto
      encoding
      go-bits
      go-bitstream
      go-collectd
      go-isatty
      hllpp
      influxql
      jwt-go
      liner
      msgp
      opentracing-go
      pat
      prometheus_client_golang
      gogo_protobuf
      ratecounter
      roaring
      snappy
      sync
      sys
      text
      time
      toml
      treeprint
      usage-client
      cespare_xxhash
      yarpc
      zap
      zap-logfmt
    ];
    postPatch = /* Remove broken tests */ ''
      rm -rf services/collectd/test_client
    '';
  };

  influxdb_client = influxdb.override {
    subPackages = [
      "client"
      "models"
      "pkg/escape"
    ];
    propagatedBuildInputs = [
    ];
  };

  influxql = buildFromGitHub {
    version = 6;
    rev = "1cbfca8e56b6eaa120f5b5161e4f0d5edcc9e513";
    owner  = "influxdata";
    repo   = "influxql";
    sha256 = "407f356c2525bfa7959dbace2e33a992fff504e36133a181c8665154425051f8";
    date = "2018-09-25";
    propagatedBuildInputs = [
      gogo_protobuf
    ];
  };

  ini = buildFromGitHub {
    version = 6;
    rev = "v1.39.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "473b37b6acdd377a20a31b9f4d061451ea9121d63d6ee62161eae5ef520ce06f";
  };

  ini_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.39.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "c7e355fc9cfcd14c86379efd6250f8c513b8755cf29021761923e76a69d11fe0";
  };

  inject = buildFromGitHub {
    version = 6;
    date = "2016-06-27";
    rev = "d8a0b8677191f4380287cfebd08e462217bac7ad";
    owner = "go-macaron";
    repo = "inject";
    sha256 = "1yqbh7gbv1awlf231d5k6qy7aq2r808np643ih1pzjskmaln72in";
  };

  ipfs = buildFromGitHub {
    version = 6;
    rev = "v0.4.17";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "ab63c30ddae19473769407f19f5bf2fbbbcaa73b9f0a36f5e092f4e47bbe8bed";
    gxSha256 = "0fyxv04r55rmlpb6fxmrvdcl92vs4lxxh6ij42p47hpv7k2vcgp1";
    nativeBuildInputs = [
      gx-go.bin
    ];
    allowVendoredSources = true;
    excludedPackages = "test";
    meta.autoUpdate = false;
    postInstall = ''
      find "$bin"/bin -not -name ipfs\* -mindepth 1 -maxdepth 1 -delete
    '';
  };

  ipfs-cluster = buildFromGitHub {
    version = 6;
    rev = "v0.6.0";
    owner = "ipfs";
    repo = "ipfs-cluster";
    sha256 = "9c72677d290e27c9404d17754a5c4b0edab210d2f1e99da529dd8f2e5b042094";
    meta.autoUpdate = false;
    excludedPackages = "test";
    propagatedBuildInputs = [
      urfave_cli
      #go-cid
      #go-dot
      #go-floodsub
      #go-fs-lock
      #go-ipfs-api
      #go-libp2p
      #go-libp2p-consensus
      #go-libp2p-crypto
      #go-libp2p-host
      #go-libp2p-http
      #go-libp2p-interface-pnet
      #go-libp2p-gorpc
      #go-libp2p-gostream
      go-libp2p-peer
      #go-libp2p-peerstore
      #go-libp2p-pnet
      #go-libp2p-protocol
      #go-libp2p-raft
      go-log
      go-multiaddr
      go-multiaddr-dns
      go-multiaddr-net
      #go-multicodec
      go-ws-transport
      #mux
      #raft
      #raft-boltdb
    ];
  };

  ipfs-ds-convert = buildFromGitHub {
    version = 6;
    rev = "775510ea634911edb8567785c2c7bd31cd1c910f";
    date = "2018-06-30";
    owner = "ipfs";
    repo = "ipfs-ds-convert";
    sha256 = "962fe317131b37f9d6fee2d4c0258f41f6a1fc76d9c101d686f9e497e8ff3be0";
    gxSha256 = "1bmiinm5n4h7ygp8m0z157smhwkbzfwf4hki8s8kmf7ilrxwz1wy";
    nativeBuildInputs = [
      gx-go.bin
    ];
    propagatedBuildInputs = [
      # Workaround missing vendored dependency
      go-homedir
    ];
    meta.autoUpdate = false;
    allowVendoredSources = true;
  };

  jaeger-client-go = buildFromGitHub {
    version = 5;
    owner = "jaegertracing";
    repo = "jaeger-client-go";
    rev = "v2.12.0";
    sha256 = "1cvggvzj5ysjr7y6sbz20qf078w48rr8zfinb1cq2b5806yxvq6p";
    goPackagePath = "github.com/uber/jaeger-client-go";
    excludedPackages = "crossdock";
    nativeBuildInputs = [
      pkgs.thrift
    ];
    propagatedBuildInputs = [
      errors
      jaeger-lib
      net
      opentracing-go
      thrift
      zap
    ];
    postPatch = ''
      rm -r thrift-gen
      mkdir -p thrift-gen

      grep -q 'a.client.SeqId = 0' utils/udp_client.go
      sed -i '/a.client.SeqId/d' utils/udp_client.go

      grep -q 'EmitBatch(batch)' utils/udp_client.go
      sed \
        -e 's#EmitBatch(batch)#EmitBatch(context.TODO(), batch)#g' \
        -e '/"errors"/a"context"' \
        -i utils/udp_client.go

      grep -q 's.manager.GetSamplingStrategy(s.serviceName)' sampler.go
      sed \
        -e '/"math"/a"context"' \
        -e 's#GetSamplingStrategy(serviceName string)#GetSamplingStrategy(ctx context.Context,serviceName string)#' \
        -e 's#s.manager.GetSamplingStrategy(s.serviceName)#s.manager.GetSamplingStrategy(context.TODO(), s.serviceName)#' \
        -i sampler.go
    '';
    preBuild = ''
      unpackFile '${jaeger-idl.src}'
      for file in jaeger-idl*/thrift/*.thrift; do
        thrift --gen go:thrift_import="github.com/apache/thrift/lib/go/thrift",package_prefix="github.com/uber/jaeger-client-go/thrift-gen/" --out go/src/$goPackagePath/thrift-gen "$file"
      done
    '';
  };

  jaeger-idl = buildFromGitHub {
    version = 6;
    owner = "jaegertracing";
    repo = "jaeger-idl";
    rev = "c5ee6caa3cf2bbaeec6ad6c8595e7c5c73e54c00";
    sha256 = "0rbih18b6j1sx4pikwwway5qw5kjlay7fsj72z47zs58cciqsfri";
    date = "2018-02-01";
  };

  jaeger-lib = buildFromGitHub {
    version = 5;
    owner = "jaegertracing";
    repo = "jaeger-lib";
    rev = "v1.4.0";
    sha256 = "1siq6lzkykml33ad9i523ahlzzqy1hdm8ikzkbq2mvn9n3ijfiax";
    goPackagePath = "github.com/uber/jaeger-lib";
    excludedPackages = "test";
    propagatedBuildInputs = [
      hdrhistogram
      kit
      prometheus_client_golang
      tally
    ];
    postPatch = ''
      grep -q 'hv.WithLabelValues' metrics/prometheus/factory.go
      sed -i '/hv.WithLabelValues/s#),#).(prometheus.Histogram),#g' metrics/prometheus/factory.go
    '';
  };

  jose = buildFromGitHub {
    version = 5;
    owner = "SermoDigital";
    repo = "jose";
    rev = "803625baeddc3526d01d321b5066029f53eafc81";
    sha256 = "02ik4nmdnc3v04qgg3f06xgyinyzqa3vxg8zj13sa84vwfz1k9kw";
    date = "2018-01-04";
  };

  json-filter = buildFromGitHub {
    version = 6;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "01ljz4l1scfwa4w71fjl2clgnln3nkysm8dijp8qvn02a2yq3fq2";
  };

  json-patch = buildFromGitHub {
    version = 6;
    owner = "evanphx";
    repo = "json-patch";
    rev = "v4.1.0";
    sha256 = "1c7279ef33220adb0881661719e1c3af0fc91bd7e83921a61556dc618d21db6d";
    propagatedBuildInputs = [
      go-flags
    ];
  };

  jsonpointer = buildFromGitHub {
    version = 6;
    owner = "go-openapi";
    repo = "jsonpointer";
    rev = "v0.17.1";
    sha256 = "80fe5bd5802297acbbf540edc5661bf21e23995400076a9b7a8e5377a30a6710";
    propagatedBuildInputs = [
      swag
    ];
  };

  jsonreference = buildFromGitHub {
    version = 6;
    owner = "go-openapi";
    repo = "jsonreference";
    rev = "v0.17.1";
    sha256 = "b0cba0022f0a88706aee9aceab60c519fbe7aeb750187dd3d4c4b93119464de6";
    propagatedBuildInputs = [
      jsonpointer
      purell
    ];
  };

  jsonx = buildFromGitHub {
    version = 6;
    owner = "jefferai";
    repo = "jsonx";
    rev = "9cc31c3135eef39b8e72585f37efa92b6ca314d0";
    date = "2016-07-21";
    sha256 = "1h4y2g59qkjw1syim3lf69hmp1f6bk7s4xirw1qpc0rm5ji8blpl";
    propagatedBuildInputs = [
      gabs
    ];
  };

  jwalterweatherman = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "v1.0.0";
    sha256 = "be1825182a33061c111ae06ac54db4e9bc0e0d05795ab6eea97cb8d49ddd63d7";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
  };

  jwt-go = buildFromGitHub {
    version = 6;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "3af4c746e1c248ee8491a3e0c6f7a9cd831e95f8";
    sha256 = "997330523089fde0a4348969a1d9bfda955b873854554ebbaa247b9370fbc7bf";
    date = "2018-09-21";
  };

  gravitational_kingpin = buildFromGitHub {
    version = 6;
    rev = "52bc17adf63c0807b5e5b5d91350703630f621c7";
    owner = "gravitational";
    repo = "kingpin";
    sha256 = "1hal9vrx113pbz68k9z1pqbz8vaahgf93i9bb4iia2a57z53k7m7";
    propagatedBuildInputs = [
      template
      units
    ];
    meta.useUnstable = true;
    date = "2017-09-06";
  };

  kingpin = buildFromGitHub {
    version = 6;
    rev = "v2.2.6";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "00g6cnx6vl7yhhcy18q5im9wb2spsjp59hxmdqcaivha74zc6whp";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  kingpin_v2 = buildFromGitHub {
    version = 5;
    rev = "v2.2.6";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "0hphhyvvp5dmqzkb80wfxdir7dqf645gmppfqqv2yiswyl7d0cqh";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  kit = buildFromGitHub {
    version = 6;
    rev = "ec0cc13a9b00d1214c9b7ae63d7b750626b54c6d";
    owner = "go-kit";
    repo = "kit";
    sha256 = "02a5e7991c82e2a1fcd8bafa76850bb114e97f1f174ccdef946d4e5df76e564a";
    date = "2018-10-22";
  };

  kit_logging = kit.override {
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
    version = 6;
    rev = "843ad2d9b9ae703c74f2f43959e6ce0b24cc3185";
    owner  = "kubernetes";
    repo   = "api";
    sha256 = "5692701d6accbef9388c4427b35e531f37e3a1067e37bdef51ede3cf497db4c0";
    goPackagePath = "k8s.io/api";
    propagatedBuildInputs = [
      gogo_protobuf
      kubernetes-apimachinery
    ];
    meta.useUnstable = true;
    date = "2018-10-18";
  };

  kubernetes-apimachinery = buildFromGitHub {
    version = 6;
    rev = "60666be32c5de527b69dabe8e4400b4f0aa897de";
    owner  = "kubernetes";
    repo   = "apimachinery";
    sha256 = "a18a96e4c470779eb6ca1c03fd2a3cd88e98aa8c1afcb0bdfc75116dcb65b00a";
    goPackagePath = "k8s.io/apimachinery";
    excludedPackages = "\\(testing\\|testapigroup\\|fuzzer\\)";
    propagatedBuildInputs = [
      glog
      gofuzz
      go-flowrate
      go-spew
      golang-lru
      kubernetes-kube-openapi
      inf_v0
      json-iterator_go
      json-patch
      net
      gogo_protobuf
      reflect2
      spdystream
      yaml
    ];
    postPatch = ''
      rm -r pkg/util/uuid
    '';
    meta.useUnstable = true;
    date = "2018-10-15";
  };

  kubernetes-kube-openapi = buildFromGitHub {
    version = 6;
    rev = "90b54e673cf4f8ba61a75ad6ef90a69e8da13568";
    date = "2018-10-21";
    owner  = "kubernetes";
    repo   = "kube-openapi";
    sha256 = "9eb0b336693a06fb443d4237cb05bf8df3cd1395c5c24bd7a4377e0124ff0691";
    goPackagePath = "k8s.io/kube-openapi";
    subPackages = [
      "pkg/common"
      "pkg/util/proto"
    ];
    propagatedBuildInputs = [
      gnostic
      go-restful
      spec_openapi
      yaml_v2
    ];
  };

  kubernetes-client-go = buildFromGitHub {
    version = 6;
    rev = "982e3f55001f505adeeafb7f559affe3c7594420";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "d815fa418e6a99c4e370506d9eb47cfb2ae45cf0a355f25b919e5fd18f96ef4a";
    goPackagePath = "k8s.io/client-go";
    excludedPackages = "\\(test\\|fake\\)";
    propagatedBuildInputs = [
      crypto
      #diskv
      glog
      #gnostic
      go-autorest
      #gophercloud
      #groupcache
      httpcache
      kubernetes-api
      kubernetes-apimachinery
      mergo
      net
      oauth2
      pflag
      protobuf
      time
    ];
    meta.useUnstable = true;
    date = "2018-10-18";
  };

  ldap_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.5.1";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "0875caefacbb1078dd70e5de6b18912cf7d89c6feb9b21f27407be3d781fc63f";
    goPackagePath = "gopkg.in/ldap.v2";
    propagatedBuildInputs = [
      asn1-ber_v1
    ];
  };

  ldap = buildFromGitHub {
    version = 6;
    rev = "43d151a7f8ccb1e31bbbea09f1d3473eadf83b65";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "c61832477cc2714b5d26de42d432fa981f0f4eccd1e4b35c8f85980a41e68533";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [
      asn1-ber_v1
    ];
    date = "2018-10-22";
  };

  ledisdb = buildFromGitHub {
    version = 6;
    rev = "v0.6";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "1lys13h4w10gf9hvn1bm915mxxnxkrdmy88ajy9d59hglxj4sxzr";
    prePatch = ''
      dirs=($(find . -type d -name vendor | sort))
      echo "''${dirs[@]}" | xargs -n 1 rm -r
    '';
    subPackages = [
      "config"
      "ledis"
      "rpl"
      "store"
      "store/driver"
      "store/goleveldb"
      "store/leveldb"
      "store/rocksdb"
    ];
    propagatedBuildInputs = [
      siddontang_go
      go-toml
      net
      goleveldb
      mmap-go
      siddontang_rdb
    ];
  };

  lego = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner = "xenolf";
    repo = "lego";
    sha256 = "5b80bb58b5f6c09a13dbccc693790cf52b0da749386a1016e3ed36479f9224b1";
    buildInputs = [
      akamaiopen-edgegrid-golang
      auroradnsclient
      aws-sdk-go
      #azure-sdk-for-go
      urfave_cli
      crypto
      dns
      dnspod-go
      dnsimple-go
      go-autorest
      go-jose_v2
      go-ovh
      google-api-go-client
      linode
      memcache
      namedotcom_go
      ns1-go_v2
      oauth2
      net
      testify
      vultr
    ];
    postPatch = ''
      rm -r providers/dns/azure
      sed -i '/azure/d' providers/dns/dns_providers.go

      rm -r providers/dns/exoscale
      sed -i '/exoscale/d' providers/dns/dns_providers.go

      grep -q 'FormatInt(whoamiResponse.Data.Account.ID,' providers/dns/dnsimple/dnsimple.go
      sed -i 's#FormatInt(whoamiResponse.Data.Account.ID,#FormatInt(int64(whoamiResponse.Data.Account.ID),#' providers/dns/dnsimple/dnsimple.go
    '';
  };

  lemma = buildFromGitHub {
    version = 6;
    rev = "4214099fb348c416514bc2c93087fde56216d7b5";
    owner = "mailgun";
    repo = "lemma";
    sha256 = "0nyrryphjwn85xjr8s9rrnaqwys7fl7m4g7n30bfbw8ji54afvdq";
    date = "2017-06-19";
    propagatedBuildInputs = [
      crypto
      metrics
      timetools
      mailgun_ttlmap
    ];
  };

  libkv = buildFromGitHub {
    version = 6;
    rev = "458977154600b9f23984d9f4b82e79570b5ae12b";
    owner = "docker";
    repo = "libkv";
    sha256 = "23c1c66221eb25a1fddf17081dbef690a986e857916550d7e45bf16ef33d0760";
    date = "2018-09-12";
    excludedPackages = "\\(mock\\|testutils\\)";
    propagatedBuildInputs = [
      bbolt
      consul_api
      etcd_client
      go-zookeeper
    ];
  };

  libnetwork = buildFromGitHub {
    version = 6;
    rev = "d7b61745d16675c9f548b19f06fda80d422a74f0";
    owner = "docker";
    repo = "libnetwork";
    sha256 = "80e51a9ba9fb4db2a180b419af04c94a57348a4b7d95fd9a9c3b95d01a4ff634";
    date = "2018-10-12";
    subPackages = [
      "datastore"
      "discoverapi"
      "ipamutils"
      "types"
    ];
    propagatedBuildInputs = [
      libkv
      logrus
      sctp
    ];
  };

  libseccomp-golang = buildFromGitHub {
    version = 6;
    rev = "v0.9.0";
    owner = "seccomp";
    repo = "libseccomp-golang";
    sha256 = "0cpzyr5hqp9z2v0l2ismn89b0k91m8lnw34gl5na7khlq872w93c";
    buildInputs = [
      pkgs.libseccomp
    ];
  };

  lightstep-tracer-go = buildFromGitHub {
    version = 6;
    rev = "v0.15.6";
    owner  = "lightstep";
    repo   = "lightstep-tracer-go";
    sha256 = "37127c48f5afff09a3a215e4b6e0a2da16967c0bb38105dac1f0dae85979886c";
    propagatedBuildInputs = [
      genproto
      grpc
      net
      opentracing-go
      protobuf
    ];
  };

  liner = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner = "peterh";
    repo = "liner";
    sha256 = "392da49d019c02669a72724d0b535dd84b37b520e41b06274a2c727bdbd9150f";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  link = buildFromGitHub {
    version = 6;
    rev = "6d32b8d78d1e440948a1c461c5abcc6bf7881641";
    owner  = "peterhellberg";
    repo   = "link";
    sha256 = "18449lb5g7pad88ljl73mhb5nmlxc78dfq9a1fdiz13x185i784r";
    date = "2018-01-24";
  };

  linode = buildFromGitHub {
    version = 6;
    rev = "37e84520dcf74488f67654f9c775b9752c232dc1";
    owner = "timewasted";
    repo = "linode";
    sha256 = "05p94l2k9jnnsqm6plslb169n36b53r6hsl0jsp0msr4ig2n33vv";
    date = "2016-08-29";
  };

  locker = buildFromGitHub {
    version = 6;
    rev = "a6e239ea1c69bff1cfdb20c4b73dadf52f784b6a";
    owner = "BurntSushi";
    repo = "locker";
    sha256 = "19mnygpqdmd7l53y32z8sxdsdcvsdwnqkv2crhkp69sir5ryd08c";
    date = "2017-10-06";
  };

  lockfile = buildFromGitHub {
    version = 6;
    rev = "0ad87eef1443f64d3d8c50da647e2b1552851124";
    owner = "nightlyone";
    repo = "lockfile";
    sha256 = "1bi79i6arpwc2gs0cxmzcnlrlq8dxx1lcijy6ffjmqkwvb15h37l";
    date = "2018-06-18";
  };

  log15 = buildFromGitHub {
    version = 6;
    rev = "v2.14";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "d17a8a302fbf6a4e865abf252dbe2a211a554cc1c8643769e7c83f1c427fe8d5";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
      stack
      sys
    ];
  };

  kr_logfmt = buildFromGitHub {
    version = 6;
    rev = "b84e30acd515aadc4b783ad4ff83aff3299bdfe0";
    owner  = "kr";
    repo   = "logfmt";
    sha256 = "1p9z8ni7ijg0qxqyhkqr2aq80ll0mxkq0fk5mgsd8ly9l9f73mjc";
    date = "2014-02-26";
  };

  logfmt = buildFromGitHub {
    version = 6;
    rev = "v0.3.0";
    owner  = "go-logfmt";
    repo   = "logfmt";
    sha256 = "104vw0802vk9rmwdzqfqdl616q2g8xmzbwmqcl35snl2dggg5sia";
    propagatedBuildInputs = [
      kr_logfmt
    ];
  };

  lunny_log = buildFromGitHub {
    version = 6;
    rev = "v0.1";
    owner = "lunny";
    repo = "log";
    sha256 = "caddbeb4b2de9b42689900351a24be9d5524d9c19753b165321d9e641951d548";
  };

  loggo = buildFromGitHub {
    version = 6;
    rev = "584905176618da46b895b176c721b02c476b6993";
    owner = "juju";
    repo = "loggo";
    sha256 = "1w6f1gx9b73j0kvxzb2c26ypyic36djy01b6gm8a5jrjbcvlxc8b";
    date = "2018-05-24";
    propagatedBuildInputs = [
      ansiterm
    ];
  };

  logrus = buildFromGitHub {
    version = 6;
    rev = "4fabf2fffcecfd47f802869b7b92d75e43c5a095";
    owner = "sirupsen";
    repo = "logrus";
    sha256 = "f501fb1cfb457da985173409d1df55eb6a305d572d00cdf48d581a75c1350791";
    goPackageAliases = [
      "github.com/Sirupsen/logrus"
    ];
    propagatedBuildInputs = [
      crypto
      go-windows-terminal-sequences
      sys
    ];
    meta.useUnstable = true;
    date = "2018-10-21";
  };

  gravitational_logrus = buildFromGitHub {
    version = 6;
    rev = "8ab1e1b91d5f1a6124287906f8b0402844d3a2b3";
    owner = "gravitational";
    repo = "logrus";
    sha256 = "135eaac22c33f3ac73ec01ac1d2c439ac5878139cb2c77416ea5cda0d62c8316";
    goPackageAliases = [
      "github.com/sirupsen/logrus"
      "github.com/Sirupsen/logrus"
    ];
    postPatch = ''
      find . -name '*'.go -exec sed -i 's,sirupsen/logrus,gravitational/logrus,' {} \;
    '';
    propagatedBuildInputs = [
      crypto
      sys
    ];
    meta.autoUpdate = false;
    date = "2018-04-02";
  };

  logutils = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "1b4afe3f3d4a745196c329bc4cc339fd7d41fdfe7f4ec9a01645a48fa6aa672b";
  };

  lsync = buildFromGitHub {
    version = 6;
    rev = "f332c3883f63c75ea6c95eae3aec71a2b2d88b49";
    owner = "minio";
    repo = "lsync";
    sha256 = "0ifljlsl3f67hlkgzzrl6ffzwbxximw445v574ljd6nqs4j3c4rn";
    date = "2018-03-28";
  };

  lumberjack_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.1";
    owner  = "natefinch";
    repo   = "lumberjack";
    sha256 = "06k6f5gy2ba35z2dcmv62415frf7jbdcnxrlvwn1bky8q8zp4m1l";
    goPackagePath = "gopkg.in/natefinch/lumberjack.v2";
  };

  lxd = buildFromGitHub {
    version = 6;
    rev = "lxd-3.6";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "5ddf99b94dcad5805f2dad10c171859feee35387a873ca41a9ad36194557c482";
    postPatch = ''
      find . -name \*.go -exec sed -i 's,uuid.NewRandom(),uuid.New(),g' {} \;
    '';
    excludedPackages = "\\(test\\|benchmark\\)"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      pkgs.acl
      pkgs.lxc
    ];
    propagatedBuildInputs = [
      bolt
      candidclient
      cobra
      crypto
      dqlite
      environschema_v1
      errors
      gettext
      gocapability
      golang-petname
      gomaasapi
      go-colorable
      go-grpc-sql
      go-lxc_v2
      CanonicalLtd_go-sqlite3
      grpc
      idmclient
      macaroon-bakery_v2
      mux
      net
      google_uuid
      persistent-cookiejar
      pongo2
      protobuf
      raft
      raft-boltdb
      raft-http
      raft-membership
      testify
      tablewriter
      tomb_v2
      yaml_v2
      websocket
    ];
  };

  lz4 = buildFromGitHub {
    version = 6;
    rev = "v2.0.7";
    owner  = "pierrec";
    repo   = "lz4";
    sha256 = "e3d2abc0e34a70921f91e736adf26f9affff1d3c5898d90415152acb0b935aa8";
    propagatedBuildInputs = [
      profile
      pierrec_xxhash
    ];
  };

  macaroon-bakery_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.1.0";
    owner  = "go-macaroon-bakery";
    repo   = "macaroon-bakery";
    sha256 = "f4c69a1579e71a4171f476b2fa9c2a02187bc12e81563bf95db23515fa63444f";
    goPackagePath = "gopkg.in/macaroon-bakery.v2";
    excludedPackages = "\\(test\\|example\\)";
    propagatedBuildInputs = [
      crypto
      environschema_v1
      errgo_v1
      fastuuid
      httprequest_v1
      httprouter
      loggo
      macaroon_v2
      mgo_v2
      net
      protobuf
      webbrowser
    ];
  };

  macaroon_v2 = buildFromGitHub {
    version = 5;
    rev = "v2.0.0";
    owner  = "go-macaroon";
    repo   = "macaroon";
    sha256 = "1jlfv4s09q0i62vkwya4jbivfhy65qgyk6i971lscrxg5hffx3vn";
    goPackagePath = "gopkg.in/macaroon.v2";
    propagatedBuildInputs = [
      crypto
    ];
  };

  macaron_v1 = buildFromGitHub {
    version = 5;
    rev = "v1.3.1";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "181p251asm4vz56a87ah9xi1zpq6z095ybxrj4ybnwgrhrv4x8dj";
    goPackagePath = "gopkg.in/macaron.v1";
    propagatedBuildInputs = [
      com
      crypto
      ini_v1
      inject
    ];
  };

  mafmt = buildFromGitHub {
    version = 6;
    date = "2018-06-27";
    rev = "1dc32401ee9fdd3f6cdb3405ec984d5dae877b2a";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "13lj4njx1f97zhcanfbfccf8lm8819mzbi260qvibdxni6hsggym";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  mail_v2 = buildFromGitHub {
    version = 6;
    rev = "2.2.0";
    owner = "go-mail";
    repo = "mail";
    sha256 = "0xf504bi297w733pcjrxbh74ap5ylh0agqxblfwvzfm30x6jxpgi";
    goPackagePath = "gopkg.in/mail.v2";
    propagatedBuildInputs = [
      quotedprintable_v3
    ];
  };

  mage = buildFromGitHub {
    version = 6;
    rev = "v1.7.1";
    owner = "magefile";
    repo = "mage";
    sha256 = "c11d8ce34ba50f4f198bf2ff93c02a5fa557a98bdf5001aa73b0fe8462b15e43";
    excludedPackages = "testdata";
  };

  mapstructure = buildFromGitHub {
    version = 6;
    rev = "v1.1.2";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "f6a00fe78bc1982f00a4bd447929d3d4afe6b547e5fe225983462e2639869e19";
  };

  martian = buildFromGitHub {
    version = 6;
    rev = "v2.1.0";
    owner = "google";
    repo = "martian";
    sha256 = "93b7df259dfc5510404b7d92c0c091caa5d89bec3c7fd6d5cc7169babab2ee07";
    propagatedBuildInputs = [
      net
    ];
  };

  match = buildFromGitHub {
    version = 6;
    owner = "tidwall";
    repo = "match";
    date = "2017-10-02";
    rev = "1731857f09b1f38450e2c12409748407822dc6be";
    sha256 = "1ydj4jkyx89q3v2z4apj66vmfr5dcc227vg4a4izhca41mf11cbk";
  };

  maxminddb-golang = buildFromGitHub {
    version = 6;
    rev = "ed835b22606182ff576f244643e52b25b7d6c4e7";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "f3e64dba5ac8da7cf0572fb945dda732c3f16d4a0af9faa16eb15cfcf737c3f8";
    propagatedBuildInputs = [
      sys
    ];
    date = "2018-10-14";
  };

  mc = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "mc";
    rev = "7b69f0064d3cd55ec23bb2349d0cdf4b7f3e24b0";
    sha256 = "6ca93486c46727a961dbcb86fe1b0d337856c606093fc9cf256438eb6eb066a1";
    propagatedBuildInputs = [
      cli_minio
      color
      crypto
      go-colorable
      go-homedir
      go-humanize
      go-isatty
      go-version
      minio_pkg
      minio-go
      net
      notify
      pb
      profile
      text
      xattr
    ];
    meta.useUnstable = true;
    date = "2018-10-19";
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

  hashicorp_mdns = buildFromGitHub {
    version = 6;
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

  whyrusleeping_mdns = buildFromGitHub {
    version = 6;
    date = "2018-09-01";
    rev = "ef14215e6b30606f4ce84174ed7a644a05cb1af3";
    owner = "whyrusleeping";
    repo = "mdns";
    sha256 = "74b90e7d5c8c6827864c5c7054dec5d108edd40db7dffd1aa9a6e02850290710";
    propagatedBuildInputs = [
      dns
      net
    ];
  };

  memberlist = buildFromGitHub {
    version = 6;
    rev = "b195c8e4fcc6284fff1583fd6ab09e68ca207551";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "4424b680e59b021ff2a9027f19f7ed3e5510667e52d99180c48f2917ed6d9fbb";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
      hashicorp_go-sockaddr
      seed
    ];
    meta.useUnstable = true;
    date = "2018-08-09";
  };

  memcache = buildFromGitHub {
    version = 6;
    date = "2015-06-22";
    rev = "1031fa0ce2f20c1c0e1e1b51951d8ea02c84fa05";
    owner = "rainycape";
    repo = "memcache";
    sha256 = "0fqi1yy90dgf82l7zr8hgn4jp5r5gg7wr3bb62mpjy9431bdkw1a";
  };

  mergo = buildFromGitHub {
    version = 6;
    rev = "v0.3.6";
    owner = "imdario";
    repo = "mergo";
    sha256 = "cee174d315c324ebec758d171b9b18e58b75154e6f395c41f288bc3fa803ba7c";
  };

  mesh = buildFromGitHub {
    version = 6;
    rev = "61ba45522f8a5ac096d36674144357341b8ccea9";
    owner = "weaveworks";
    repo = "mesh";
    sha256 = "1qgw389yjf5208x6lpyvjzag55jh42qs8bgf2ai1xgjdnw75h6z9";
    date = "2018-04-16";
    propagatedBuildInputs = [
      crypto
    ];
  };

  metrics = buildFromGitHub {
    version = 6;
    date = "2017-07-14";
    rev = "fd99b46995bd989df0d163e320e18ea7285f211f";
    owner = "mailgun";
    repo = "metrics";
    sha256 = "0v7wmcjj4g04ggdcv6ncd4p7wprwmzjgld9c77w9yv6h4v7blnax";
    propagatedBuildInputs = [
      holster
      timetools
    ];
  };

  mgo_v2 = buildFromGitHub {
    version = 6;
    rev = "9856a29383ce1c59f308dd1cf0363a79b5bef6b5";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "088df5pkrd79psdsx81fib3pffnr6czxiv6iag489hnm66xl10kj";
    goPackagePath = "gopkg.in/mgo.v2";
    excludedPackages = "dbtest";
    buildInputs = [
      pkgs.cyrus-sasl
    ];
    date = "2018-07-05";
  };

  minheap = buildFromGitHub {
    version = 6;
    rev = "3dbe6c6bf55f94c5efcf460dc7f86830c21a90b2";
    owner = "mailgun";
    repo = "minheap";
    sha256 = "1d0j7vzvqizq56dxb8kcp0krlnm18qsykkd064hkiafwapc3lbyd";
    date = "2017-06-19";
  };

  minify = buildFromGitHub {
    version = 6;
    owner = "tdewolff";
    repo = "minify";
    rev = "v2.3.5";
    sha256 = "12vlfxkk729n1vsrj4yhji8xsys9x30k3dcxlrm7nqdiy9hbni6j";
    propagatedBuildInputs = [
      fsnotify
      go-humanize
      parse
      pflag
      try
    ];
  };

  minio = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "minio";
    rev = "586466584fbf14ce9c95cc15cadeb3cc426aeab4";
    sha256 = "1cddfd5c0ec67fe424fdc70d9b11df379c10bd216e74931aad5c14ed53e07c78";
    propagatedBuildInputs = [
      aliyun-oss-go-sdk
      amqp
      atime
      azure-sdk-for-go
      atomic
      blazer
      cli_minio
      color
      coredns
      cors
      crypto
      dsync
      elastic_v5
      etcd_client
      gjson
      go-bindata-assetfs
      go-homedir
      go-humanize
      go-nats
      go-nats-streaming
      go-prompt
      go-update
      go-version
      google-api-go-client
      google-cloud-go
      handlers
      highwayhash
      jwt-go
      lsync
      mc_pkg
      minio-go
      mux
      mysql
      notify
      paho-mqtt-golang
      pb
      pq
      profile
      prometheus_client_golang
      redigo
      klauspost_reedsolomon
      rpc
      sarama_v1
      sio
      sha256-simd
      skyring-common
      structs
      sys
      time
      triton-go
      yaml_v2
    ];
    meta.useUnstable = true;
    date = "2018-10-22";
  };

  # The pkg package from minio, for bootstrapping minio
  minio_pkg = minio.override {
    propagatedBuildInputs = [
      etcd_client
      gjson
      minio-go
      pb
      sha256-simd
      structs
      yaml_v2
    ];
    subPackages = [
      "pkg/madmin"
      "pkg/quick"
      "pkg/safe"
      "pkg/trie"
      "pkg/wildcard"
      "pkg/words"
    ];
  };

  minio-go = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "minio-go";
    rev = "31e3bbc8590bf72d763be83a191836f02eb61437";
    sha256 = "7c3bb0af51741eb9622db8bcfc5ec1d1954102a683e32efdfb68ec113e16ce0a";
    propagatedBuildInputs = [
      crypto
      go-homedir
      ini
      net
    ];
    meta.useUnstable = true;
    date = "2018-10-15";
  };

  mmap-go = buildFromGitHub {
    version = 6;
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "0bce6a6887123b67a60366d2c9fe2dfb74289d2e";
    sha256 = "0s4wdrflb0qscrf2yr00wm00sgjz9w6dcknyxxwr2zy4larli2nl";
    date = "2017-03-20";
  };

  mmark = buildFromGitHub {
    version = 6;
    owner = "miekg";
    repo = "mmark";
    rev = "4a113919b52e731d8886e79b19292535937b8ce2";
    sha256 = "529fa26f2552e4d5491b67b3847cac9960ab0dc1fd48fecc6b5c148bafa7c4bf";
    propagatedBuildInputs = [
      toml
    ];
    date = "2018-08-23";
  };

  moby = buildFromGitHub {
    version = 6;
    owner = "moby";
    repo = "moby";
    rev = "f7e5154f37a45dc2e576abbef404f3032e9823bf";
    date = "2018-10-18";
    sha256 = "6b7382c0b50902e19f23731c4b92c441b3716aa353823eb00c89a0a9cde083a2";
    goPackageAliases = [
      "github.com/docker/docker"
    ];
    postPatch = ''
      find . -name \*.go -exec sed -i 's,github.com/docker/docker,github.com/moby/moby,g' {} \;
    '';
    meta.useUnstable = true;
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
      "daemon/caps"
      "daemon/cluster/convert"
      "errdefs"
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
      "reference"
      "registry"
      "registry/resumable"
    ];
    propagatedBuildInputs = [
      continuity
      distribution_for_moby
      errors
      go-ansiterm
      go-connections
      go-digest
      go-units
      go-winio
      gocapability
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

  mongo-tools = buildFromGitHub {
    version = 6;
    rev = "r4.1.4";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "c8c356002865620ddc073d4ef22268ef86b12a104e102dd685d911a166f1b977";
    buildInputs = [
      pkgs.libpcap
    ];
    propagatedBuildInputs = [
      crypto
      escaper
      go-cache
      go-flags
      gopacket
      gopass
      mgo_v2
      openssl
      snappy
      termbox-go
      tomb_v2
    ];
    excludedPackages = "test";
    postPatch = ''
      mv vendor/src/github.com/10gen/llmgo "$NIX_BUILD_TOP"/llmgo
    '';
    preBuild = ''
      mkdir -p $(echo unpack/mgo*)/src/github.com/10gen
      mv llmgo unpack/mgo*/src/github.com/10gen
    '';
    extraSrcs = [ {
      goPackagePath = "github.com/10gen/llmgo";
      src = null;
    } ];

    # Mongodb incorrectly names all of their binaries main
    # Let's work around this with our own installer
    preInstall = ''
      mkdir -p $bin/bin
      while read b; do
        rm -f go/bin/main
        go install $buildFlags "''${buildFlagsArray[@]}" $goPackagePath/$b/main
        cp go/bin/main $bin/bin/$b
      done < <(find go/src/$goPackagePath -name main | xargs dirname | xargs basename -a)
      rm -r go/bin
    '';
  };

  mousetrap = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "inconshreveable";
    repo = "mousetrap";
    sha256 = "1isym805z5i57pknixzlp9rbzcrgxrzv2dw0a30ifx7pr4hy7zaa";
  };

  mow-cli = buildFromGitHub {
    version = 6;
    rev = "v1.0.4";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "1aqhcz4lyvqf3fcbpwakw7gfzdzcnf03l3dbz4wkvhxjp7n6xhh2";
  };

  ns1-go_v2 = buildFromGitHub {
    version = 6;
    rev = "028658c6d9be774b6d103a923d8c4b2715135c3f";
    owner  = "ns1";
    repo   = "ns1-go";
    sha256 = "4310eb61544414e3b9e7ad81939ca74e2938bb118601506b7dbee2d936ce4467";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2018-08-28";
  };

  msgp = buildFromGitHub {
    version = 6;
    rev = "f65876d3ea05943d6613bca6b8ed391843044bd4";
    owner  = "tinylib";
    repo   = "msgp";
    sha256 = "72e93f8622ffa608aefe23d18bbd597923299e2e47c4bb3a9414fb755b1571e4";
    propagatedBuildInputs = [
      fwd
      chalk
      tools
    ];
    date = "2018-09-12";
  };

  multiaddr-filter = buildFromGitHub {
    version = 6;
    rev = "e903e4adabd70b78bc9293b6ee4f359afb3f9f59";
    owner  = "whyrusleeping";
    repo   = "multiaddr-filter";
    sha256 = "0p8d06rm2zazq14ri9890q9n62nli0jsfyy15cpfy7wxryql84n7";
    date = "2016-05-16";
  };

  multibuf = buildFromGitHub {
    version = 6;
    rev = "565402cd71fbd9c12aa7e295324ea357e970a61e";
    owner  = "mailgun";
    repo   = "multibuf";
    sha256 = "1csjfl3bcbya7dq3xm1nqb5rwrpw5migrqa4ajki242fa5i66mdr";
    date = "2015-07-14";
  };

  multierr = buildFromGitHub {
    version = 6;
    rev = "ddea229ff1dff9e6fe8a6c0344ac73b09e81fce5";
    owner  = "uber-go";
    repo   = "multierr";
    sha256 = "bfbf15ad2df63e5788d60d64107de4c56e944b691f41fff4e932643c6312f291";
    goPackagePath = "go.uber.org/multierr";
    propagatedBuildInputs = [
      atomic
    ];
    date = "2018-01-22";
  };

  murmur3 = buildFromGitHub {
    version = 6;
    rev = "v1.1";
    owner  = "spaolacci";
    repo   = "murmur3";
    sha256 = "abe69b868ae70d966951fe3e6fc15216d711093811c7c55ac8241f55cf35a73c";
  };

  mux = buildFromGitHub {
    version = 6;
    rev = "v1.6.2";
    owner = "gorilla";
    repo = "mux";
    sha256 = "02sk53ygkjn41lag840al1cxfajrkkbf6s1mhlyh3xxl8nf9h202";
    propagatedBuildInputs = [
      context
    ];
  };

  mysql = buildFromGitHub {
    version = 6;
    rev = "v1.4.0";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "0c4p26hlm3lpaqmi2sxvnc6xhx9drhgrlkih3bvdczyby7dvlx3b";
    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';
  };

  names_v2 = buildFromGitHub {
    version = 6;
    date = "2018-06-21";
    rev = "fd59336b4621bc2a70bf96d9e2f49954115ad19b";
    owner = "juju";
    repo = "names";
    sha256 = "11kqj6ny0lr92wm52k4xaajy95kcdgmjh4sj8c7c9zq9jxg8fzw5";
    goPackagePath = "gopkg.in/juju/names.v2";
    propagatedBuildInputs = [
      juju_errors
      utils_for_names
    ];
  };

  net-rpc-msgpackrpc = buildFromGitHub {
    version = 6;
    date = "2015-11-16";
    rev = "a14192a58a694c123d8fe5481d4a4727d6ae82f3";
    owner = "hashicorp";
    repo = "net-rpc-msgpackrpc";
    sha256 = "1mnhdy4mj279q9sn3rmrpcz66fivv9grfkj73kia82vmxs78b6y8";
    propagatedBuildInputs = [
      ugorji_go
      go-multierror
    ];
  };

  netlink = buildFromGitHub {
    version = 6;
    rev = "d3a23fd178f1a0d9cf1f194af62864b1dfe02be5";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "38ff9b841cd2055b33b7caf9676011e9576547e3d6ba059abede609e28507ced";
    propagatedBuildInputs = [
      netns
      sys
    ];
    date = "2018-10-18";
  };

  netns = buildFromGitHub {
    version = 6;
    rev = "13995c7128ccc8e51e9a6bd2b551020a27180abd";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "1yvfg24j3hbqcidxhw27ifw6zgp7nrd9a27mmkyz4dl7lvn3jpxd";
    date = "2018-07-20";
  };

  nitro = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "nitro";
    rev = "24d7ef30a12da0bdc5e2eb370a79c659ddccf0e8";
    date = "2013-10-03";
    sha256 = "0207jgc4wpkp1867c0vanimvr3x1ksawb5xi8ilf5rq88jbdlx5v";
  };

  nodb = buildFromGitHub {
    version = 6;
    owner = "lunny";
    repo = "nodb";
    rev = "fc1ef06ad4af0da31cdb87e3fa5ec084c67e6597";
    date = "2016-06-21";
    sha256 = "0smrcavlglwsb15fqissgh9rs63cf5yqff68s1jxggmcnmw6cxhx";
    propagatedBuildInputs = [
      goleveldb
      lunny_log
      go-snappy
      toml
    ];
  };

  nomad = buildFromGitHub {
    version = 6;
    rev = "v0.8.6";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "9e2a78ac1870b484a218ca58bc0437194e102cad8173a7585820667dc48da19c";

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
      consul_api
      consul-template
      copystructure
      cors
      cronexpr
      crypto
      distribution_for_moby
      docker_cli
      go-checkpoint
      go-cleanhttp
      go-bindata-assetfs
      go-dockerclient
      go-envparse
      go-getter
      go-humanize
      go-immutable-radix
      go-lxc_v2
      go-memdb
      go-multierror
      go-plugin
      go-ps
      go-rootcerts
      hashicorp_go-sockaddr
      go-semver
      go-syslog
      go-testing-interface
      go-version
      hashicorp_go-uuid
      golang-lru
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
      open-golang
      prometheus_client_golang
      raft
      raft-boltdb
      rkt
      runc
      seed
      serf
      snappy
      spec_appc
      srslog
      sync
      sys
      tail
      kr_text
      time
      tomb_v1
      tomb_v2
      ugorji_go
      vault_api
      hashicorp_yamux
    ];

    excludedPackages = "\\(test\\|mock\\)";

    postPatch = ''
      find . -name \*.go -exec sed \
        -e 's,"github.com/docker/docker/reference","github.com/docker/distribution/reference",g' \
        -e 's,github.com/docker/docker/cli,github.com/docker/cli/cli,' \
        -e 's,.ParseNamed,.ParseNormalizedNamed,g' \
        -i {} \;

      # Remove test junk
      find . \( -name testutil -or -name testagent.go \) -prune -exec rm -r {} \;

      # Remove all autogenerate stuff
      find . -name \*.generated.go -delete
    '';

    #preBuild = ''
    #  pushd go/src/$goPackagePath
    #  go list ./... | xargs go generate
    #  popd
    #'';

    postInstall = ''
      rm "$bin"/bin/app
    '';
  };

  nomad_api = nomad.override {
    nativeBuildInputs = [
    ];
    buildInputs = [
    ];
    postPatch = ''
    '';
    preBuild = ''
    '';
    postInstall = ''
    '';
    subPackages = [
      "acl"
      "api"
      "api/contexts"
      "helper"
      "helper/args"
      "helper/flatmap"
      "helper/uuid"
      "nomad/structs"
    ];
    propagatedBuildInputs = [
      consul_api
      copystructure
      cronexpr
      crypto
      go-cleanhttp
      go-immutable-radix
      go-multierror
      go-rootcerts
      go-version
      ugorji_go
      golang-lru
      hashstructure
      hcl
      raft
    ];
  };

  notify = buildFromGitHub {
    version = 6;
    owner = "syncthing";
    repo = "notify";
    date = "2018-10-11";
    rev = "116c45bb5ad48777321e4984d1320d56889b6097";
    sha256 = "019d8ce892999fe6674ce74f78b84e364263a144e53f905feecac491572e9992";
    goPackageAliases = [
      "github.com/rjeczalik/notify"
    ];
    propagatedBuildInputs = [
      sys
    ];
  };

  nuid = buildFromGitHub {
    version = 6;
    rev = "3024a71c3cbe30667286099921591e6fcc328230";
    owner = "nats-io";
    repo = "nuid";
    sha256 = "0asvpxb1zjjxcg2737brj2vf0y7c46w3ciq43knwq6fx65dv3g6k";
    date = "2018-07-12";
  };

  objx = buildFromGitHub {
    version = 6;
    rev = "ef50b0de28773081167c97fc27cf29a0bf8b8c71";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "9a3a6f04a8597edfaaa1dd67f9f367bd4c1b8a1247979877acfd754d58f3d085";
    date = "2018-08-25";
  };

  oklog = buildFromGitHub {
    version = 6;
    rev = "v0.3.2";
    owner = "oklog";
    repo = "oklog";
    sha256 = "0idkybsskw18zw7gba17bmwcxdri0xn465b9hr02bc6gslg8vzvb";
    subPackages = [
      "pkg/group"
    ];
    propagatedBuildInputs = [
      run
    ];
  };

  oktasdk-go = buildFromGitHub {
    version = 6;
    owner = "chrismalek";
    repo = "oktasdk-go";
    rev = "c38de6febf6bc5d93004d830b0a8ad6a3423a725";
    date = "2018-09-10";
    sha256 = "3e795ca3d2dc158769c911a5ac3f3fcd5ac2c9cb8c519f75cb73555099f7b24a";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  opencensus = buildFromGitHub {
    version = 6;
    owner = "census-instrumentation";
    repo = "opencensus-go";
    rev = "96e75b88df843315da521168a0e3b11792088728";
    sha256 = "6ec89a9c4079f64a0410fcbafdff0ce33061f4c6c84f2b85ce035ec9f4cb9176";
    goPackagePath = "go.opencensus.io";
    subPackages = [
      "."
      "exemplar"
      "exporter/stackdriver/propagation"
      "internal"
      "internal/tagencoding"
      "plugin/ocgrpc"
      "plugin/ochttp"
      "plugin/ochttp/propagation/b3"
      "stats"
      "stats/internal"
      "stats/view"
      "tag"
      "trace"
      "trace/internal"
      "trace/propagation"
      "trace/tracestate"
    ];
    propagatedBuildInputs = [
      grpc
      net
    ];
    meta.useUnstable = true;
    date = "2018-10-22";
  };

  open-golang = buildFromGitHub {
    version = 6;
    owner = "skratchdot";
    repo = "open-golang";
    rev = "75fb7ed4208cf72d323d7d02fd1a5964a7a9073c";
    date = "2016-03-02";
    sha256 = "18rwj86iwsh417vzn5877lbx4gky2fxnp8840p663p924l0hz46s";
  };

  openid-go = buildFromGitHub {
    version = 6;
    owner = "yohcop";
    repo = "openid-go";
    rev = "cfc72ed89575fe6b1b7b880d537ba0c5e37f7391";
    date = "2017-09-01";
    sha256 = "0dp2nkqxcc5hqnw0p2y1ak6cxjhf51mzxy344igaqnpf5aydx0n6";
    propagatedBuildInputs = [
      net
    ];
  };

  openssl = buildFromGitHub {
    version = 6;
    date = "2018-04-27";
    rev = "58f60a8e59ba35b53e6821bda7003c4ea626dbf9";
    owner = "10gen";
    repo = "openssl";
    sha256 = "0j42fj00gxpx9psadanwj5fxz354gdzd9lnw7iv8f2drwja3md48";
    goPackageAliases = [
      "github.com/spacemonkeygo/openssl"
    ];
    buildInputs = [
      pkgs.openssl
    ];
    propagatedBuildInputs = [
      spacelog
    ];
  };

  opentracing-go = buildFromGitHub {
    version = 6;
    owner = "opentracing";
    repo = "opentracing-go";
    rev = "be550b025b433cdfa2f11efb962afa2ea3c4d967";
    sha256 = "ca45fb1f52d2520b50e59e59c146608bea0e3cfa97c0dc0e2e479b65463a3a48";
    goPackageAliases = [
      "github.com/frrist/opentracing-go"
    ];
    excludedPackages = "harness";
    propagatedBuildInputs = [
      net
    ];
    date = "2018-10-12";
  };

  osext = buildFromGitHub {
    version = 6;
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
    version = 6;
    rev = "be78767b3e392ce45ea73444451022a6fc32ad0d";
    owner = "pquerna";
    repo = "otp";
    sha256 = "f4f93d698f7ac8087e1a9af37a8fd7018bf47a16dd995b18810ed98db2e89aee";
    propagatedBuildInputs = [
      barcode
    ];
    date = "2018-08-13";
  };

  oxy = buildFromGitHub {
    version = 6;
    owner = "vulcand";
    repo = "oxy";
    date = "2016-07-23";
    rev = "db85f00cac5466def1f6f2667063e6e38c1fe606";
    sha256 = "5e3941f2116168854f012b731efda9b22f41118b8149dd220abe44f810e9a49e";
    goPackageAliases = [ "github.com/mailgun/oxy" ];
    propagatedBuildInputs = [
      hdrhistogram
      multibuf
      predicate
      timetools
      mailgun_ttlmap
    ];
    meta.autoUpdate = false;
  };

  packngo = buildFromGitHub {
    version = 6;
    owner = "packethost";
    repo = "packngo";
    date = "2018-10-22";
    rev = "7fd7ae44ec9b0c8b511afc7088a5281557e6708d";
    sha256 = "5f48b747e4387a94f2c2a5e67401a8f6d978cc4fc2e035e4e3a63a6f03154fb1";
  };

  paho-mqtt-golang = buildFromGitHub {
    version = 6;
    owner = "eclipse";
    repo = "paho.mqtt.golang";
    rev = "c95f2f508baf22ddc8625d0097b1ceb8abc508b3";
    sha256 = "84141af13843f04e51518c2cb4241db185e0e7216e46bb3dafef46f819efe001";
    propagatedBuildInputs = [
      net
    ];
    date = "2018-10-11";
  };

  parse = buildFromGitHub {
    version = 6;
    owner = "tdewolff";
    repo = "parse";
    rev = "v2.3.3";
    sha256 = "1zfbxxprld4mwddmxy9a1k87pvdxhws8zb9if4bw6z4nba9x25zi";
  };

  pat = buildFromGitHub {
    version = 6;
    owner = "bmizerany";
    repo = "pat";
    date = "2017-08-15";
    rev = "6226ea591a40176dd3ff9cd8eff81ed6ca721a00";
    sha256 = "00ykc2zv61zlw3ai22cvldc85ljs92wijkcn7ijj5bb2hmx773p4";
  };

  pb = buildFromGitHub {
    version = 6;
    owner = "cheggaaa";
    repo = "pb";
    date = "2018-10-17";
    rev = "751f9183c336d1bb8ef77beb95243f367d1d90e1";
    sha256 = "0dbd768ca6f6db898a7ef7bb8f28760e8e88926aa8bc5a0dd93b16e010799c50";
    propagatedBuildInputs = [
      go-runewidth
      sys
    ];
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 6;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.26";
    sha256 = "3d0c8b65886d44a2f99524495e939075b994e72d09705a2816cccf3797a525a8";
    goPackagePath = "gopkg.in/cheggaaa/pb.v1";
    propagatedBuildInputs = [
      go-runewidth
      sys
    ];
  };

  perks = buildFromGitHub {
    version = 6;
    date = "2018-03-21";
    owner  = "beorn7";
    repo   = "perks";
    rev = "3a771d992973f24aa725d07868b467d1ddfceafb";
    sha256 = "1k2szih4wj386wmh2z2kdhmr3iifl90jc856pnfx29ckyzz54zb8";
  };

  persistent = buildFromGitHub {
    version = 6;
    date = "2018-03-01";
    owner  = "xiaq";
    repo   = "persistent";
    rev = "cd415c64068256386eb46bbbb1e56b461872feed";
    sha256 = "13fb82bdf31a814e2171032cb5d35152ca2f3cf13dd2c882e8975862c5180ada";
  };

  persistent-cookiejar = buildFromGitHub {
    version = 6;
    date = "2017-10-26";
    owner  = "juju";
    repo   = "persistent-cookiejar";
    rev = "d5e5a8405ef9633c84af42fbcc734ec8dd73c198";
    sha256 = "06y2xzvhic8angzbv5pgwqh51k2m0s9f9flmdn9lzzzd677may9f";
    excludedPackages = "test";
    propagatedBuildInputs = [
      errgo_v1
      go4
      net
      retry_v1
    ];
  };

  pflag = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "pflag";
    rev = "v1.0.3";
    sha256 = "d824ebbdfa4d1f007dc69a2cfea54cf2dfaab634fe5bb25944cfaf5f58aab7aa";
    goPackageAliases = [
      "github.com/ogier/pflag"
    ];
  };

  pidfile = buildFromGitHub {
    version = 6;
    owner = "facebookgo";
    repo = "pidfile";
    rev = "f242e2999868dcd267a2b86e49ce1f9cf9e15b16";
    sha256 = "0qhn6c5ax28dz4c6aqib0wrsr6k3nbm2v4189f7ig6dads1npjhj";
    date = "2015-06-12";
    propagatedBuildInputs = [
      atomicfile
    ];
  };

  pkcs7 = buildFromGitHub {
    version = 6;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "8306686428a5fe132eac8cb7c4848af725098bd4";
    date = "2018-06-13";
    sha256 = "0ynpjh93cbw7i9ahx99i299g8f024yn9ca97vv99snd70zah50h8";
  };

  pkg = buildFromGitHub {
    version = 6;
    date = "2018-09-28";
    owner  = "coreos";
    repo   = "pkg";
    rev = "399ea9e2e55f791b6e3d920860dbecb99c3692f0";
    sha256 = "48d98f9433b7de0231c937edb88d49616fa6e984da1c9b53d7190a298497b4f7";
    propagatedBuildInputs = [
      crypto
      go-systemd_journal
      yaml_v1
    ];
  };

  plz = buildFromGitHub {
    version = 6;
    owner  = "v2pro";
    repo   = "plz";
    rev = "0.9.1";
    sha256 = "7793fed4caa02c1e2e97adb76a6a8eacf0089c14545986221905f07ce1c96326";
    excludedPackages = "\\(witch\\|test\\|dump\\)";
  };

  poly1305 = buildFromGitHub {
    version = 6;
    rev = "3fee0db0b63511234f7230da50b72414f6258f10";
    owner  = "aead";
    repo   = "poly1305";
    sha256 = "1vpvwd7jba946rcymb30r2cbzxbgrmfglglrw2vhvn1jmdwb8w71";
    date = "2018-07-17";
  };

  pongo2 = buildFromGitHub {
    version = 6;
    rev = "24195e6d38b06020d7a92c7b11960cf2e7cad2f2";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "8a23d361ec503875ab4d86851e8e91e55f2b3c1eed974ad74c98b40ca24f5d9c";
    date = "2018-08-09";
    propagatedBuildInputs = [
      juju_errors
    ];
  };

  pprof = buildFromGitHub {
    version = 6;
    rev = "baeddb81b1fb7ded58dd923de62d4710ffc6391f";
    owner  = "google";
    repo   = "pprof";
    sha256 = "ffadc8c0b1c7f33faa340999f6173767687b164d703b072f847dc6d159a39648";
    date = "2018-10-22";
    propagatedBuildInputs = [
      demangle
      readline
    ];
  };

  pq = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "lib";
    repo   = "pq";
    sha256 = "d8ef5595d8a6834ae571bbed3dbaf4dde2c2e09ca7b34ae67b198888579a0510";
  };

  predicate = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "vulcand";
    repo   = "predicate";
    sha256 = "0p35vp2vjhkrkni24l1gcm4c7dccllgd6f8v3cjs0gnmxf7zqfll";
    propagatedBuildInputs = [
      trace
    ];
  };

  pretty = buildFromGitHub {
    version = 6;
    rev = "73f6ac0b30a98e433b289500d779f50c1a6f0712";
    owner  = "kr";
    repo   = "pretty";
    sha256 = "1xwb1miy3q1i2jj2wr0640rbqfgfg5rxyzja6vscd1hqdy3rcqg5";
    date = "2018-05-06";
    propagatedBuildInputs = [
      kr_text
    ];
  };

  probing = buildFromGitHub {
    version = 6;
    rev = "0.0.1";
    owner  = "xiang90";
    repo   = "probing";
    sha256 = "0wjjml1dg64lfq4s1b6kqabz35pm02yfgc0nc8cp8y4aw2ip49vr";
  };

  procfs = buildFromGitHub {
    version = 6;
    rev = "185b4288413d2a0dd0806f78c90dde719829e5ae";
    date = "2018-10-05";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "60ad600e21011819c0cb93d661de48287a4f2b5deee534a61d3dddd7e97fbfe5";
  };

  profile = buildFromGitHub {
    version = 6;
    owner = "pkg";
    repo = "profile";
    rev = "057bc52a47ec3c79498dda63f4a6f8298725e976";
    sha256 = "5ccf522d33a83409b77e856c5ec24e2f4f4e9b9837d36b16c1bc141b436f9061";
    date = "2018-08-09";
  };

  progmeter = buildFromGitHub {
    version = 6;
    owner = "whyrusleeping";
    repo = "progmeter";
    rev = "f3e57218a75b913eff88d49a52c1debf9684ea04";
    sha256 = "1x8vg3cakdgj4rm8raax842l4lxkqys4r128zi0lrqbwndv8f96l";
    date = "2018-07-25";
  };

  prometheus = buildFromGitHub {
    version = 6;
    rev = "v2.4.3";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "70c320337a2298e4f83e0171b41ee9c8fca3e7be7739ebf644056c229492f30f";
    buildInputs = [
      aws-sdk-go
      cockroach
      cmux
      consul_api
      dns
      errors
      fsnotify_v1
      genproto
      go-autorest
      go-conntrack
      goleveldb
      gophercloud
      go-stdlib
      govalidator
      go-zookeeper
      google-api-go-client
      grpc
      grpc-gateway
      kingpin_v2
      kit_logging
      kubernetes-api
      kubernetes-apimachinery
      kubernetes-client-go
      net
      oauth2
      oklog
      opentracing-go
      prometheus_client_golang
      prometheus_client_model
      prometheus_common
      prometheus_tsdb
      gogo_protobuf
      snappy
      time
      cespare_xxhash
      yaml_v2
    ];
    postPatch = ''
      rm -r discovery/azure
      sed -i '/azure/d' discovery/config/config.go
      sed -e '/azure/d' -e '/Azure/,+2d' -i discovery/manager.go

      grep -q 'NodeLegacyHostIP' discovery/kubernetes/node.go
      sed \
        -e '/\.NodeLegacyHostIP/,+2d' \
        -e '\#"k8s.io/client-go/pkg/api"#d' \
        -i discovery/kubernetes/node.go

      grep -q 'k8s.io/client-go/pkg/apis' discovery/kubernetes/*.go
      sed \
        -e 's,k8s.io/client-go/pkg/apis,k8s.io/api,' \
        -e 's,k8s.io/client-go/pkg/api/v1,k8s.io/api/core/v1,' \
        -e 's,"k8s.io/client-go/pkg/api",api "k8s.io/api/core/v1",' \
        -i discovery/kubernetes/*.go
    '';
  };
  prometheus_pkg = prometheus.override {
    buildInputs = [
    ];
    propagatedBuildInputs = [
      cespare_xxhash
    ];
    subPackages = [
      "pkg/labels"
    ];
    postPatch = null;
  };

  prometheus_client_golang = buildFromGitHub {
    version = 6;
    rev = "v0.9.0";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "c109601bb604b39dcec7bf58ddddc80edee6c12e33249a65c3549cd8737b191d";
    propagatedBuildInputs = [
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      perks
    ];
  };

  prometheus_client_model = buildFromGitHub {
    version = 6;
    rev = "5c3871d89910bfb32f5fcab2aa4b9ec68e65a99f";
    date = "2018-07-12";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "18xqxkx89x03b0dqj2c13skc5fmi3vqv848vyad5clbnvyw0xirm";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 6;
    date = "2018-10-20";
    rev = "7e9e6cabbd393fc208072eedef99188d0ce788b6";
    owner = "prometheus";
    repo = "common";
    sha256 = "90f92b4c91f88ebdea6ef30d64d7dda93f69e7206703eadc3a0ece16370383b6";
    propagatedBuildInputs = [
      errors
      go-conntrack
      golang_protobuf_extensions
      httprouter
      logrus
      kit_logging
      kingpin_v2
      net
      prometheus_client_golang
      prometheus_client_model
      protobuf
      sys
      yaml_v2
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

  prometheus_tsdb = buildFromGitHub {
    version = 6;
    date = "2018-10-22";
    rev = "66b6b87cd4ce563d711da437734353c8320f0f60";
    owner = "prometheus";
    repo = "tsdb";
    sha256 = "4e9dd34f74d548a2a6f99eab005ace1b97e1a40bb0d4d38a64ae3d8fad22cd93";
    propagatedBuildInputs = [
      cespare_xxhash
      errors
      kingpin_v2
      kit_logging
      lockfile
      prometheus_client_golang
      sync
      sys
      ulid
    ];
  };

  properties = buildFromGitHub {
    version = 6;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.8.0";
    sha256 = "0wh1vdkzix8jqmkhsbiljxadfaf10yfnz81y0p9pjc9j80ibgv5f";
  };

  prose = buildFromGitHub {
    version = 6;
    owner = "jdkato";
    repo = "prose";
    rev = "a179b97cfa6fc3949fe1bcd21e01011bc17f4c2f";
    sha256 = "df90847bbe5c7f6a85d0f28550a822d03be3f01ceb95e94cc6f3af4e9902e351";
    propagatedBuildInputs = [
      urfave_cli
      go-shuffle
      sentences_v1
      stats
    ];
    date = "2018-10-22";
  };

  gogo_protobuf = buildFromGitHub {
    version = 6;
    owner = "gogo";
    repo = "protobuf";
    rev = "v1.1.1";
    sha256 = "1ramkldk142fpzmyl4j5nn62yb80424z8gqy5fcw41qprm9nsjm2";
    excludedPackages = "test";
  };

  pty = buildFromGitHub {
    version = 6;
    owner = "kr";
    repo = "pty";
    rev = "v1.1.3";
    sha256 = "fc97111aaa5a58f3c076abc60395ca649897ebb0ea40ebf5c5e0223e98696c50";
  };

  purell = buildFromGitHub {
    version = 6;
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "975f53781597ed779763b7b65566e74c4004d8de";
    sha256 = "dd4d05bef554587e80810917c5eac1c2f842d15fe4f6af2558a8bff20a946d05";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
    date = "2018-03-10";
  };

  qart = buildFromGitHub {
    version = 6;
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "1wka69q9yyryiyylrcwjnhv0mhlkk04b1nxzvhflbhqv1rz8y0g7";
  };

  qingstor-sdk-go = buildFromGitHub {
    version = 6;
    rev = "v2.2.15";
    owner  = "yunify";
    repo   = "qingstor-sdk-go";
    sha256 = "7ae32eed6b668f193edaa85e233448edc57c5a71cd6298443fed165382175a02";
    excludedPackages = "test";
    propagatedBuildInputs = [
      go-shared
      yaml_v2
    ];
  };

  queue = buildFromGitHub {
    version = 5;
    rev = "093482f3f8ce946c05bcba64badd2c82369e084d";
    owner  = "eapache";
    repo   = "queue";
    sha256 = "02wayp8qdqkqvhfc6h3pqp9xfma38ls9ldjwb2zcj3dm3y9rl025";
    date = "2018-02-27";
  };

  quotedprintable_v3 = buildFromGitHub {
    version = 6;
    rev = "2caba252f4dc53eaf6b553000885530023f54623";
    owner  = "alexcesaro";
    repo   = "quotedprintable";
    sha256 = "1vxbp1n7439gb3vwynqaxdqcv0xlkzzxv88mpcvhsshzbiqhb1cs";
    goPackagePath = "gopkg.in/alexcesaro/quotedprintable.v3";
    date = "2015-07-16";
  };

  rabbit-hole = buildFromGitHub {
    version = 6;
    rev = "7fa9b8b9bd6a453320511c9fdd67b216bb283188";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "0291e441f7a8fb8cbff050f55f5be22e823d816be5c7514d100f26b290c61f35";
    date = "2018-10-19";
  };

  radius = buildFromGitHub {
    version = 6;
    rev = "aae5d47e21a8f0022d118dd2cba63fc92c94cc73";
    date = "2018-10-22";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "404b6e074f921002da782980f1bf18647ee25d62a0a0dacb68400b455ed1d8d1";
    goPackagePath = "layeh.com/radius";
  };

  raft = buildFromGitHub {
    version = 6;
    date = "2018-08-23";
    rev = "82694fb663be3ffa7769961ee9a65e4c39ebbf2c";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "0b354cb978f1c2aa44022d8224ea2c9a3a36ac03b6bf27fdd434d2f81d58fbaa";
    meta.useUnstable = true;
    propagatedBuildInputs = [
      armon_go-metrics
      ugorji_go
    ];
    subPackages = [
      "."
    ];
  };

  raft-boltdb = buildFromGitHub {
    version = 6;
    date = "2017-10-10";
    rev = "6e5ba93211eaf8d9a2ad7e41ffad8c6f160f9fe3";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "0kircjb4ly26q9331pc45cdjhicm13zpgj4dq8azcxaj9gypd53g";
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft
    ];
  };

  raft-http = buildFromGitHub {
    version = 6;
    date = "2018-04-14";
    rev = "4c2dd679d3b46c11b250d63ae43467d4c4ab0962";
    owner  = "CanonicalLtd";
    repo   = "raft-http";
    sha256 = "0fi205a5liqav2hp4zm67wlpn6b65axrzp606zrcl70iv463l7dd";
    propagatedBuildInputs = [
      errors
      raft
      raft-membership
    ];
  };

  raft-membership = buildFromGitHub {
    version = 6;
    date = "2018-04-13";
    rev = "3846634b0164affd0b3dfba1fdd7f9da6387e501";
    owner  = "CanonicalLtd";
    repo   = "raft-membership";
    sha256 = "149wsy3lgsn2jzxl0sja4y8d1x9m5cpf97jl2zybgamxagc7jxy1";
    propagatedBuildInputs = [
      raft
    ];
  };

  ratecounter = buildFromGitHub {
    version = 6;
    owner = "paulbellamy";
    repo = "ratecounter";
    rev = "v0.2.0";
    sha256 = "0nivwcvpx1zsdysyn0ww3hl3ihayplh3hkw7qszmm9jii4ccrh9a";
  };

  ratelimit = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0kp5z5nfxv9wz75axl7s185mkxbjcf41blxn5rhpgcn9qvf8v1g6";
  };

  raven-go = buildFromGitHub {
    version = 6;
    date = "2018-10-18";
    rev = "d1aab6ee63f4a2cca2169c538eceba058cb976b7";
    owner  = "getsentry";
    repo   = "raven-go";
    sha256 = "e40507240dc5c471432a10e2a22a6742079bb065de0af66eae8e3ad4f8f4e799";
    propagatedBuildInputs = [
      errors
      gocertifi
    ];
  };

  rclone = buildFromGitHub {
    version = 6;
    owner = "ncw";
    repo = "rclone";
    date = "2018-10-20";
    rev = "c5ac96e9e7afd2e11b69233ed3671e8ad05d24a9";
    sha256 = "3c704e0605084c198d0da0451f0e16aef0510f7899e53c906b5168bfc7561bc7";
    propagatedBuildInputs = [
      aws-sdk-go
      bbolt
      cgofuse
      cobra
      crypto
      eme
      errors
      ftp
      fuse
      go-ansiterm
      go-acd
      go-cache
      go-daemon
      go-http-auth
      go-mega
      goconfig
      google-api-go-client
      net
      oauth2
      open-golang
      pflag
      qingstor-sdk-go
      sdnotify
      semver
      server
      sftp
      ssh-agent
      swift
      sys
      termbox-go
      testify
      text
      time
      times
      tree
    ];
    postPatch = ''
      # Azure-sdk-for-go does not provide a stable api
      rm -r backend/azureblob/
      sed -i backend/all/all.go \
        -e '/azureblob/d'

      # Dropbox doesn't build easily
      rm -r backend/dropbox/
      sed -i backend/all/all.go \
        -e '/dropbox/d'
      sed -i fs/hash/hash.go \
        -e '/dbhash/d'
    '';
    excludedPackages = "test";
    meta.useUnstable = true;
  };

  cupcake_rdb = buildFromGitHub {
    version = 6;
    date = "2016-11-07";
    rev = "43ba34106c765f2111c0dc7b74cdf8ee437411e0";
    owner = "cupcake";
    repo = "rdb";
    sha256 = "07gi5a9293y7lic7w5n6g5nckvhvx9xpny9sp7zsy2c2rjx1ij65";
  };

  siddontang_rdb = buildFromGitHub {
    version = 6;
    date = "2015-03-07";
    rev = "fc89ed2e418d27e3ea76e708e54276d2b44ae9cf";
    owner = "siddontang";
    repo = "rdb";
    sha256 = "0q2jpnjyr1gqjl50m3xwa3mqwryn14i9jcl7nwxw0yvxh6vlvnhh";
    propagatedBuildInputs = [
      cupcake_rdb
    ];
  };

  readline = buildFromGitHub {
    version = 6;
    owner = "chzyer";
    repo = "readline";
    date = "2018-06-03";
    rev = "2972be24d48e78746da79ba8e24e8b488c9880de";
    sha256 = "058bxjc72gpy1xpbkk2yw3pgwrxwjf2gyri3vs1r38ir0drlfqwx";
    excludedPackages = "example";
    propagatedBuildInputs = [
      sys
    ];
  };

  redigo = buildFromGitHub {
    version = 6;
    owner = "gomodule";
    repo = "redigo";
    date = "2018-10-12";
    rev = "b9037db4b8b9ef501f28279160ab1a73a2de59ec";
    sha256 = "c2111f05b4c5a741059bf384d13d289d710f0000abd8961e0ed33d9064231bc5";
    goPackageAliases = [
      "github.com/garyburd/redigo"
    ];
    meta.useUnstable = true;
  };

  redis_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.3.2";
    owner  = "go-redis";
    repo   = "redis";
    sha256 = "0cy5r0s4wzg39cxr2c06sg7pvivnxsdzh1340qimf3399bjz0i99";
    goPackagePath = "gopkg.in/redis.v2";
    propagatedBuildInputs = [
      bufio_v1
    ];
  };

  klauspost_reedsolomon = buildFromGitHub {
    version = 6;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2018-07-04";
    rev = "925cb01d65108f2c935e02fdb79ff4a055a4a20d";
    sha256 = "19ih0xqwccb8jw321q1ysla9zjbc3avd4wcclq99xzc0lyvdh83r";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  reflect2 = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner  = "modern-go";
    repo   = "reflect2";
    sha256 = "f1f8e5f47648759e324a76f757eacafd03605f10e2884a356da08305338f4cfc";
    propagatedBuildInputs = [
      concurrent
    ];
  };

  reflectwalk = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "9cd0ba2ae5a5d72a69d54c52f2c66e0913883d98d35350d946615d1d14f4c522";
  };

  regexp2 = buildFromGitHub {
    version = 6;
    rev = "v1.1.6";
    owner  = "dlclark";
    repo   = "regexp2";
    sha256 = "1jb5ln420ic5w719msd6sdyd5ck88fxj50wxy7g2lyirm1mklgsd";
  };

  resize = buildFromGitHub {
    version = 6;
    owner = "nfnt";
    repo = "resize";
    date = "2018-02-21";
    rev = "83c6a9932646f83e3267f353373d47347b6036b2";
    sha256 = "8858abac2b78ff43d0a4b321f99bb2c0d3c0ee57e3a2c42c7cc5492248d011dc";
  };

  retry_v1 = buildFromGitHub {
    version = 6;
    owner = "go-retry";
    repo = "retry";
    rev = "v1.0.2";
    sha256 = "0e44674a3c8ee021c9a8456d200b635a9fcc5703d5b6aaec806a8768066e27cf";
    goPackagePath = "gopkg.in/retry.v1";
  };

  rkt = buildFromGitHub {
    version = 6;
    owner = "rkt";
    repo = "rkt";
    rev = "03285a7db960311faf887452538b2b8ae4304488";
    sha256 = "bd4f802c1d7d5082c37a22e684fc51190d7f888e1acb908268c871d2fe0c652c";
    subPackages = [
      "api/v1"
      "networking/netinfo"
    ];
    propagatedBuildInputs = [
      cni
    ];
    meta.useUnstable = true;
    date = "2018-08-02";
  };

  roaring = buildFromGitHub {
    version = 6;
    rev = "v0.4.16";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "62ed3140190141211a2f622146db0f43a46482c741893a21ae491c642fb2e9ba";
    propagatedBuildInputs = [
      go-unsnap-stream
      msgp
    ];
  };

  rollinghash = buildFromGitHub {
    version = 6;
    rev = "v4.0.0";
    owner  = "chmduquesne";
    repo   = "rollinghash";
    sha256 = "9afccfcbd51c781bfde2be1441d55a2654cda6b3ae1f8556c50e080d08e7a2b9";
    propagatedBuildInputs = [
      bytefmt
    ];
  };

  roundtrip = buildFromGitHub {
    version = 6;
    owner = "gravitational";
    repo = "roundtrip";
    rev = "v1.0.0";
    sha256 = "0eb69c4331508e308540a5324084db39ff047a6a2d3371588e700b5609d9dd5a";
    propagatedBuildInputs = [
      trace
    ];
  };

  rpc = buildFromGitHub {
    version = 6;
    owner = "gorilla";
    repo = "rpc";
    rev = "8c377a27c011dc70523d7543809ab3182d2ef2b1";
    sha256 = "116a8d4b1eee9a2ab463b747849c616f35b91e189a5446399f92d2b95eeace6c";
    date = "2018-10-12";
  };

  rsc = buildFromGitHub {
    version = 6;
    owner = "mdp";
    repo = "rsc";
    date = "2016-01-31";
    rev = "90f07065088deccf50b28eb37c93dad3078c0f3c";
    sha256 = "1isnkr17k3h6bfvhhwdhdyprhmgsgm9zd9ir1x3yz5ym99w3di1i";
    buildInputs = [
      pkgs.qrencode
    ];
  };

  run = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner = "oklog";
    repo = "run";
    sha256 = "0m6zlr3dric91r1fina1ng26zj7zpq97rqmnxgxj5ylmw3ah3jw9";
  };

  runc = buildFromGitHub {
    version = 6;
    rev = "c2ab1e656e7af78bde396511be003b9903f004a3";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "c7fe14599f8eb1c172af783754f88b28da814132cb6d67bccb96c70d925451fc";
    propagatedBuildInputs = [
      urfave_cli
      console
      dbus
      errors
      filepath-securejoin
      fileutils
      go-systemd
      go-units
      gocapability
      libseccomp-golang
      logrus
      netlink
      protobuf
      runtime-spec
      selinux
      sys
    ];
    date = "2018-10-17";
  };

  runtime-spec = buildFromGitHub {
    version = 6;
    rev = "5806c35637336642129d03657419829569abc5aa";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "93ad07f04d82bb960704254c7204924129e392e5c4d29a14451f571a153f1323";
    buildInputs = [
      gojsonschema
    ];
    date = "2018-09-13";
  };

  safefile = buildFromGitHub {
    version = 5;
    owner = "dchest";
    repo = "safefile";
    rev = "855e8d98f1852d48dde521e0522408d1fe7e836a";
    date = "2015-10-22";
    sha256 = "0kpirwpndc7jy4plibbvz1yjbh10aa41a91jmsr7qixpif5m91zk";
  };

  sanitized-anchor-name = buildFromGitHub {
    version = 6;
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "86672fcb3f950f35f2e675df2240550f2a50762f";
    date = "2017-09-18";
    sha256 = "0sv8yfml115gd6wls4jnh9k476dlhhwkdk5x1dz5lypczv8w065v";
  };

  sarama = buildFromGitHub {
    version = 6;
    owner = "Shopify";
    repo = "sarama";
    rev = "v1.19.0";
    sha256 = "e42b901b9c66d81495bfcf05a4f5f0a193c8c8bb78e9b7529afff55cef61853c";
    propagatedBuildInputs = [
      go-resiliency
      go-spew
      go-xerial-snappy
      lz4
      queue
      rcrowley_go-metrics
    ];
  };

  sarama_v1 = buildFromGitHub {
    version = 6;
    owner = "Shopify";
    repo = "sarama";
    rev = "v1.19.0";
    sha256 = "cd10f43688d5830b2ff1644c1110175ad2b3e3f46fda041bbdb7578e47aea5c4";
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

  scaleway-sdk = buildFromGitHub {
    version = 6;
    owner = "nicolai86";
    repo = "scaleway-sdk";
    rev = "d749f7b83389f1afe19b81a610fad5ebb7a12744";
    sha256 = "0lp7a62h7d2arx8sfvacrvzqhpxwn9qyr8j5gs6lydyxvnq5lx9f";
    meta.useUnstable = true;
    date = "2018-04-01";
    goPackageAliases = [
      "github.com/nicolai86/scaleway-sdk/api"
    ];
    propagatedBuildInputs = [
      sync
    ];
  };

  schema = buildFromGitHub {
    version = 5;
    owner = "juju";
    repo = "schema";
    rev = "e4f08199aa80d3194008c0bd2e14ef5edc0e6be6";
    sha256 = "16drvgd3rgwda6wz6ivav9qrlzaasbjl8ardkkq9is4igxnjj1pg";
    date = "2018-01-09";
    propagatedBuildInputs = [
      utils
    ];
  };

  sctp = buildFromGitHub {
    version = 6;
    owner = "ishidawataru";
    repo = "sctp";
    rev = "07191f837fedd2f13d1ec7b5f885f0f3ec54b1cb";
    sha256 = "4ff89c03e31decd45b106e5c70d5250e131bd05162b1d42f55ba176231d85299";
    date = "2018-02-18";
    meta.autoUpdate = false;
  };

  sdnotify = buildFromGitHub {
    version = 6;
    rev = "d9becc38acbd785892af7637319e2c5e101057f7";
    owner = "okzk";
    repo = "sdnotify";
    sha256 = "17qisnf6jz0d5lx48l9vs1hm7jdcmzyq3hw4l0wfjq352gr8nil3";
    date = "2018-07-10";
  };

  seed = buildFromGitHub {
    version = 6;
    rev = "e2103e2c35297fb7e17febb81e49b312087a2372";
    owner = "sean-";
    repo = "seed";
    sha256 = "0hnkw8zjiqkyffxfbgh1020dgy0vxzad1kby0kkm8ld3i5g0aq7a";
    date = "2017-03-13";
  };

  selinux = buildFromGitHub {
    version = 6;
    rev = "077c8b6d1c18456fb7c792bc0de52295a0d1900e";
    owner = "opencontainers";
    repo = "selinux";
    sha256 = "9a2ff9286a190ad927c4da841d041e3c375c5944a84d7d8d1ee63ae283119783";
    date = "2018-10-18";
  };

  semver = buildFromGitHub {
    version = 6;
    rev = "3c1074078d32d767e08ab2c8564867292da86926";
    owner = "blang";
    repo = "semver";
    sha256 = "1gkyy1nms920q5j0pfpydx8n7kx5r10bhqxvyii9bvvf4gr3kiya";
    date = "2018-07-23";
  };

  sentences_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.0.6";
    owner = "neurosnap";
    repo = "sentences";
    sha256 = "1y42a5ynxrfs6bsipr7ysdw8vyfgwl4y7f739bziqfvpxrzg09ix";
    goPackagePath = "gopkg.in/neurosnap/sentences.v1";
  };

  serf = buildFromGitHub {
    version = 6;
    rev = "48d57945817366b5484d99353f1f33e990bd142d";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "774e8e538f1728510e0f464a34dc7cf3d0fb00507deb49cb30b69eb870654454";

    propagatedBuildInputs = [
      armon_go-metrics
      circbuf
      columnize
      go-syslog
      logutils
      mapstructure
      hashicorp_mdns
      memberlist
      mitchellh_cli
      ugorji_go
    ];
    meta.useUnstable = true;
    date = "2018-09-07";
  };

  server = buildFromGitHub {
    version = 6;
    rev = "1fd52c8552f108eccff6122276753fc1f24c49ed";
    owner = "goftp";
    repo = "server";
    sha256 = "dcbc218e8e3af20a5643232a3d665f6ef9b971f250c18f5395293352a7fcbf92";
    date = "2018-09-14";
    excludedPackages = "example";
  };

  service = buildFromGitHub {
    version = 6;
    rev = "b1866cf76903d81b491fb668ba14f4b1322b2ca7";
    owner  = "kardianos";
    repo   = "service";
    sha256 = "56f5f92d33857383afc129c498c22de2af0ca8f980e8601ec1362a124b46f2a3";
    date = "2018-09-10";
    propagatedBuildInputs = [
      osext
      sys
    ];
  };

  service_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.0.16";
    owner = "hlandau";
    repo = "service";
    sha256 = "0yqzpkb6frm6zpp6cq80qv2vjfwd5a4d19hn7qja6z98y1r839yw";
    goPackagePath = "gopkg.in/hlandau/service.v2";
    propagatedBuildInputs = [
      easyconfig_v1
      gspt
      svcutils_v1
      winsvc
    ];
  };

  session = buildFromGitHub {
    version = 6;
    rev = "b8e286a0dba8f4999042d6b258daf51b31d08938";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "0qjdlwjkfhdm33bxdym0bvgfp40sbbqak8ihsjnbgc83srdsp2y1";
    date = "2017-03-20";
    propagatedBuildInputs = [
      com
      gomemcache
      go-couchbase
      ini_v1
      ledisdb
      macaron_v1
      mysql
      nodb
      pq
      redis_v2
    ];
  };

  sftp = buildFromGitHub {
    version = 6;
    owner = "pkg";
    repo = "sftp";
    rev = "v1.8.3";
    sha256 = "9c6127861adab5e0512ce68b33d8fc8e3f238dcb352436111e1aff4b34faf1e3";
    propagatedBuildInputs = [
      crypto
      errors
      fs
    ];
  };

  sha256-simd = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "sha256-simd";
    date = "2018-10-05";
    rev = "51976451ce1942acbb55707a983ed232fa027110";
    sha256 = "0840cdd46675952e16cb085114b40c25e80130f88c47068600efd274ed705b2c";
  };

  shortid = buildFromGitHub {
    version = 5;
    owner = "teris-io";
    repo = "shortid";
    rev = "771a37caa5cf0c81f585d7b6df4dfc77e0615b5c";
    sha256 = "14wn8n6ap5f69np70h44h1gk0x8g8wr8wcsqjb7qcipnjib67rpc";
    date = "2017-10-29";
  };

  sio = buildFromGitHub {
    version = 6;
    date = "2018-03-27";
    rev = "6a41828a60f0ec95a159ce7921ca3dd566ebd7e3";
    owner  = "minio";
    repo   = "sio";
    sha256 = "0hvlh9mxzhcgrahp50mfgjz9fdszc2d6q0pymdjlb5p7zy1b1gq9";
    propagatedBuildInputs = [
      crypto
    ];
  };

  skyring-common = buildFromGitHub {
    version = 6;
    owner = "skyrings";
    repo = "skyring-common";
    date = "2016-09-29";
    rev = "d1c0bb1cbd5ed8438be1385c85c4f494608cde1e";
    sha256 = "1x1pdsm7n7acsszwzydqcv0qcq9f73rivgvh2dsi3s9dljxnnwiy";
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

  slug = buildFromGitHub {
    version = 6;
    rev = "v1.3.0";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "98554f9d868ab51b68783eb2deb5cec355502fc466a22da4d90afd9e2c34bcf9";
    propagatedBuildInputs = [
      macaron_v1
      unidecode
    ];
  };

  smartcrop = buildFromGitHub {
    version = 6;
    rev = "f6ebaa786a12a0fdb2d7c6dee72808e68c296464";
    owner  = "muesli";
    repo   = "smartcrop";
    sha256 = "7b67102129aa72b61e5f0b1a468efe79c13966573d4671ae2b24f81380491d38";
    date = "2018-02-28";
    propagatedBuildInputs = [
      image
      resize
    ];
  };

  softlayer-go = buildFromGitHub {
    version = 6;
    date = "2018-09-03";
    rev = "838aaaa2076827b70abc68aa1c1b143eea1238a8";
    owner = "softlayer";
    repo = "softlayer-go";
    sha256 = "db642dfcf0b742e93582cce0da73e21bc7b52ee8e3282180ce32e3af3b02a215";
    propagatedBuildInputs = [
      tools
      xmlrpc
    ];
  };

  spacelog = buildFromGitHub {
    version = 6;
    date = "2018-04-20";
    rev = "2296661a0572a51438413369004fa931c2641923";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "1b6v3kqva3m8abpahykzwqgs4w2zqjmcd6wh3sa5k80kji33ny5v";
    buildInputs = [
      flagfile
      sys
    ];
  };

  spdystream = buildFromGitHub {
    version = 6;
    rev = "bc6354cbbc295e925e4c611ffe90c1f287ee54db";
    owner = "docker";
    repo = "spdystream";
    sha256 = "1xj663cshf7cfm7kpd6zixij10lb2nvpv8h1h16g2vb9akyyvlx1";
    date = "2017-09-12";
    propagatedBuildInputs = [
      websocket
    ];
  };

  speakeasy = buildFromGitHub {
    version = 6;
    rev = "v0.1.0";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "0vm6q73kczfjllxsag6ighc23s96xkzs0ibrgpy021rlkjqskrcd";
  };

  spec_appc = buildFromGitHub {
    version = 6;
    rev = "v0.8.11";
    owner  = "appc";
    repo   = "spec";
    sha256 = "04af8rpiapriy0izsqx417f932868imbqh54gz2sj59b44p0xbcp";
    propagatedBuildInputs = [
      go4
      go-semver
      inf_v0
      net
      pflag
    ];
  };

  spec_openapi = buildFromGitHub {
    version = 6;
    rev = "v0.17.1";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "153b733b2ee8871490758953c79a074493aea10624cc70395f3da13c78d19f1c";
    propagatedBuildInputs = [
      jsonpointer
      jsonreference
      swag
    ];
  };

  spritewell = buildFromGitHub {
    version = 6;
    rev = "v0.5.0";
    owner  = "wellington";
    repo   = "spritewell";
    sha256 = "1b3c9jx9qx4mgbc13qspwhnxfi45v3gm9wb8w4myiwylhza68xh6";
  };

  srslog = buildFromGitHub {
    version = 6;
    rev = "a4725f04ec91af1a91b380da679d6e0c2f061e59";
    date = "2018-07-09";
    owner  = "RackSec";
    repo   = "srslog";
    sha256 = "0p59d3ls90mali2a6s9psbd8in99jlh19f5x7yqmydh15rgi0d71";
  };

  sse = buildFromGitHub {
    version = 6;
    rev = "22d885f9ecc78bf4ee5d72b937e4bbcdc58e8cae";
    date = "2017-01-09";
    owner  = "gin-contrib";
    repo   = "sse";
    sha256 = "0vr6bcgcs78qbz77hbdw404d0h1fq6dzbfq5zf21y45hgb79rl6s";
  };

  ssh-agent = buildFromGitHub {
    version = 6;
    rev = "v0.2.0";
    owner  = "xanzy";
    repo   = "ssh-agent";
    sha256 = "16saj4crp94n4lxs97q0hyahjwhyq8h4nmvslisqgxl6nfb6b6z3";
    propagatedBuildInputs = [
      crypto
    ];
  };

  stack = buildFromGitHub {
    version = 6;
    rev = "v1.8.0";
    owner = "go-stack";
    repo = "stack";
    sha256 = "be30fa94211acd58ff2b39c5a98601008b776f52bc76b3ec325aa099052e5b49";
  };

  stathat = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "stathat";
    repo = "go";
    sha256 = "88b7668ac68388e30afd6120a1af6b02a17de96adbb7ffaf7e3ba62739506b07";
  };

  stats = buildFromGitHub {
    version = 6;
    rev = "db72e6cae808b936b0c01fd330ff1fcd2c86c95e";
    owner = "montanaflynn";
    repo = "stats";
    sha256 = "c45248c9a44aa0c1d20a869d8c62ec1a2f0a8e95399e03c80afe005544a36f68";
    date = "2018-09-11";
  };

  structs = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "0624a8c6e0c0ad48fb1092c1e3446e48940d36047ae34598079ab7feca1ba62d";
  };

  stump = buildFromGitHub {
    version = 6;
    date = "2016-06-11";
    rev = "206f8f13aae1697a6fc1f4a55799faf955971fc5";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "024gilapc226id7a6zh5c1cfgfqxayhqn0h8m5l9p5lb2va5bzmd";
  };

  suture = buildFromGitHub {
    version = 6;
    rev = "v3.0.0";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "9a374272203ca87260d2ff87ff42428f0fb9961c1c13874e469966ba7a8168ee";
  };

  svcutils_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.0.10";
    owner  = "hlandau";
    repo   = "svcutils";
    sha256 = "12liac8vqcx04aqw5gwdywz89fg8327nkx0zrw7iw133pb20mf7v";
    goPackagePath = "gopkg.in/hlandau/svcutils.v1";
    buildInputs = [
      pkgs.libcap
    ];
  };

  swag = buildFromGitHub {
    version = 6;
    rev = "v0.17.1";
    owner = "go-openapi";
    repo = "swag";
    sha256 = "c911a082661ebf8a7310b337b06b056789d1d52d276cd90ba4229885f33e5eb5";
    propagatedBuildInputs = [
      easyjson
      yaml_v2
    ];
  };

  swarmkit = buildFromGitHub {
    version = 6;
    rev = "7b752320d7955480939a514f7f5d686273c05bdf";
    owner = "docker";
    repo = "swarmkit";
    sha256 = "bd62bf9ec070e0c3a8d78ddd1d35e6ce622dc2ea8c9a7a840df1c402b69c89e6";
    date = "2018-10-22";
    subPackages = [
      "api"
      "api/deepcopy"
      "api/equality"
      "api/genericresource"
      "api/naming"
      "ca"
      "ca/keyutils"
      "ca/pkcs8"
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
      crypto
      errors
      etcd_for_swarmkit
      go-digest
      go-events
      go-grpc-prometheus
      go-memdb
      docker_go-metrics
      gogo_protobuf
      grpc
      logrus
      net
    ];
    postPatch = ''
      find . \( -name \*.pb.go -or -name forward.go \) -exec sed -i {} \
        -e 's,metadata\.FromContext,metadata.FromIncomingContext,' \
        -e 's,metadata\.NewContext,metadata.NewOutgoingContext,' \;
    '';
  };

  swift = buildFromGitHub {
    version = 6;
    rev = "v1.0.42";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "d8e0e8b6a7b9705029d6a5bb8915bcf53a5e11f17352fe9c13686ec9115021d5";
  };

  syncthing = buildFromGitHub rec {
    version = 6;
    rev = "v0.14.51";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "1399d54442cda221700342653c89f4a4a07a81506646702203d3158ba7cb6e68";
    buildFlags = [ "-tags noupgrade" ];
    nativeBuildInputs = [
      gogo_protobuf.bin
      pkgs.protobuf-cpp
    ];
    buildInputs = [
      AudriusButkevicius_cli
      crypto
      du
      errors
      gateway
      geoip2-golang
      glob
      go-deadlock
      go-lz4
      AudriusButkevicius_go-nat-pmp
      go-shellquote
      gogo_protobuf
      goleveldb
      groupcache
      ldap_v2
      net
      notify
      pq
      prometheus_client_golang
      qart
      rcrowley_go-metrics
      rollinghash
      sha256-simd
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
      pushd go/src/$goPackagePath >/dev/null

      mkdir -p vendor/${gogo_protobuf.goPackagePath}
      unpackFile ${gogo_protobuf.src}
      mv protobuf-*/* vendor/${gogo_protobuf.goPackagePath}
      rm -r protobuf-*

      mkdir -p vendor/${xdr.goPackagePath}
      unpackFile ${xdr.src}
      mv xdr-*/* vendor/${xdr.goPackagePath}
      rm -r xdr-*

      go list ./... | xargs go generate
      rm -r vendor
      popd >/dev/null
    '';
  };

  tablewriter = buildFromGitHub {
    version = 6;
    rev = "be2c049b30ccd4d3fd795d6bf7dce74e42eeedaa";
    date = "2018-09-12";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "e19d8ad0322c1148f578b32df1ff05819f8f8728d3fdb80fb46c7bed414fe5bc";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  tail = buildFromGitHub {
    version = 6;
    rev = "a1dbeea552b7c8df4b542c66073e393de198a800";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "03dnzzp9ip48qlakis6gyknjhgybvn19w7gbbpwijp5nldsyyxn6";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
    ];
    date = "2018-05-14";
  };

  tally = buildFromGitHub {
    version = 5;
    rev = "v3.3.2";
    owner  = "uber-go";
    repo   = "tally";
    sha256 = "133bymqshc65cdc01wwxq2dncjkdfqbqp57ssbcpjjxgy3kpda26";
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      clock
    ];
  };

  tar-utils = buildFromGitHub {
    version = 6;
    rev = "8c6c8ba81d5c71fd69c0f48dbde4b2fb422b6dfc";
    date = "2018-05-09";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "1ygx7fgqk4mrbqq0nm880qkfpq95viqviaa89x9mbavp84ylqd9a";
  };

  teleport = buildFromGitHub {
    version = 6;
    rev = "v3.0.1";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "d2a21f3231ea1b5a76db2b1f1fbd53d5697703b014900a1cf5a92e5b8700c1a6";
    nativeBuildInputs = [
      pkgs.protobuf-cpp
      gogo_protobuf.bin
      pkgs.zip
    ];
    buildInputs = [
      aws-sdk-go
      bolt
      configure
      clockwork
      crypto
      etcd_client
      etree
      form
      genproto
      json-iterator_go
      go-oidc
      go-semver
      gops
      gosaml2
      goxmldsig
      grpc
      grpc-gateway
      hdrhistogram
      hotp
      httprouter
      gravitational_kingpin
      lemma
      gravitational_logrus
      kubernetes-apimachinery
      moby_lib
      net
      osext
      otp
      oxy
      predicate
      prometheus_client_golang
      protobuf
      pty
      roundtrip
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
    excludedPackages = "\\(suite\\|fixtures\\|test\\|mock\\)";
    meta.autoUpdate = false;
    postPatch = ''
      # Only used for tests
      rm lib/auth/helpers.go
      # Make sure we regenerate this
      rm lib/events/slice.pb.go
      # We don't need integration test stuff
      rm -r integration
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
    postFixup = ''
      pushd go/src/$goPackagePath/web/dist >/dev/null
      zip -r "$NIX_BUILD_TOP"/assets.zip .
      popd >/dev/null
      cat assets.zip >>"$bin"/bin/teleport
      zip -A "$bin"/bin/teleport
    '';
  };

  template = buildFromGitHub {
    version = 6;
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "17d1mby8cmxz50pv20r4dhdw01dkkamljng556kf35ls0jg9p9wp";
    date = "2016-04-05";
  };

  termbox-go = buildFromGitHub {
    version = 6;
    rev = "b66b20ab708e289ff1eb3e218478302e6aec28ce";
    date = "2018-08-19";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "3179cca4a0e596d5fae3b6b1adf7223f8e0056d58d135a8005b9e1e9ef254d3e";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 6;
    rev = "v1.2.2";
    owner = "stretchr";
    repo = "testify";
    sha256 = "16qr6c3xgaqw12np96bcjx3a9a34sywy2bm6linj3i8svl162lgq";
    propagatedBuildInputs = [
      go-difflib
      go-spew
      objx
    ];
  };

  kr_text = buildFromGitHub {
    version = 6;
    rev = "v0.1.0";
    owner = "kr";
    repo = "text";
    sha256 = "0r81r9hp788gd5ydxnli5iwnb5z3l7fj8z2dn1a77zw9a168drvx";
    propagatedBuildInputs = [
      pty
    ];
  };

  thrift = buildFromGitHub {
    version = 6;
    rev = "cd829a0b9a5c66203b63350fa029589669ec43f6";
    owner  = "apache";
    repo   = "thrift";
    sha256 = "395227f2a9154c27edb1f017d0425a699bfa051255cd6be90a7f4fb2dbc716c8";
    subPackages = [
      "lib/go/thrift"
    ];
    propagatedBuildInputs = [
      net
    ];
    date = "2018-10-19";
  };

  timecache = buildFromGitHub {
    version = 6;
    rev = "cfcb2f1abfee846c430233aef0b630a946e0a5a6";
    owner = "whyrusleeping";
    repo = "timecache";
    sha256 = "0qbvvn1b3wp797116d0gsgx2ws6w5dy5l1mffxq1sf4jbpmxx56i";
    date = "2016-09-11";
  };

  times = buildFromGitHub {
    version = 6;
    rev = "d25002f62be22438b4cd804b9d3c8db1231164d0";
    date = "2017-02-15";
    owner  = "djherbis";
    repo   = "times";
    sha256 = "046yb83vwa6r5xhrm70bz6dwzja3zw0l9yvv77kdhx5nagfhhc3j";
  };

  timetools = buildFromGitHub {
    version = 6;
    rev = "f3a7b8ffff474320c4f5cc564c9abb2c52ded8bc";
    date = "2017-06-19";
    owner = "mailgun";
    repo = "timetools";
    sha256 = "0kjrg9l3w7znm26anbb655ncgw0ya2lcjry78lk77j08a9hmj6r2";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  tomb_v2 = buildFromGitHub {
    version = 6;
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
    version = 6;
    date = "2014-10-24";
    rev = "dd632973f1e7218eb1089048e0798ec9ae7dceb8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "17ij7zjw58949hrjmq4kjysnd7cqrawlzmwafrf4msxi1mylkk7q";
    goPackagePath = "gopkg.in/tomb.v1";
  };

  toml = buildFromGitHub {
    version = 6;
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.3.1";
    sha256 = "1c6750e1ed455ca82eb2a1ad8b0feb2d5a721e95661a542be6165c6ef9d2b264";
    goPackageAliases = [
      "github.com/burntsushi/toml"
    ];
  };

  trace = buildFromGitHub {
    version = 6;
    owner = "gravitational";
    repo = "trace";
    rev = "1.1.5";
    sha256 = "1vf6czm9yi1lw9cjxjch5kcq7bnl0lw5apmzzx7hp9lxqcsxchqw";
    propagatedBuildInputs = [
      clockwork
      grpc
      gravitational_logrus
      net
    ];
    postPatch = ''
      sed \
        -e 's,metadata\.FromContext,metadata.FromIncomingContext,' \
        -e 's,metadata\.NewContext,metadata.NewOutgoingContext,' \
        -i trail/trail.go
    '';
  };

  tree = buildFromGitHub {
    version = 6;
    rev = "3cf936ce15d6100c49d9c75f79c220ae7e579599";
    owner  = "a8m";
    repo   = "tree";
    sha256 = "1viwc3d8fd441hrmvxdvrkpd5qnwr1bci2krkad6wg0j023cbw9x";
    date = "2018-03-21";
  };

  treeprint = buildFromGitHub {
    version = 6;
    rev = "d6fb6747feb6e7cfdc44682a024bddf87ef07ec2";
    owner  = "xlab";
    repo   = "treeprint";
    sha256 = "0x1qqjkh5hw54vw7zzz5b3fpmzy1zzl5f4vch0imgdgybsmkarsz";
    date = "2018-06-16";
  };

  triton-go = buildFromGitHub {
    version = 6;
    rev = "1.3.1";
    owner  = "joyent";
    repo   = "triton-go";
    sha256 = "07md2gh4r00m14skzia09frca00pvzwywkjfvwcw85f0wyr6dvx4";
    subPackages = [
      "."
      "authentication"
      "client"
      "compute"
      "errors"
      "storage"
    ];
    propagatedBuildInputs = [
      crypto
      errors
    ];
  };

  try = buildFromGitHub {
    version = 6;
    rev = "9ac251b645a2628ef89dbd2986987cc1299408ff";
    owner  = "matryer";
    repo   = "try";
    sha256 = "0bx0bsm9m2jqn52clvhrndrqlw4xwkv662rybdc6ylpigcihnljd";
    date = "2016-12-28";
  };

  gravitational_ttlmap = buildFromGitHub {
    version = 6;
    owner = "gravitational";
    repo = "ttlmap";
    rev = "91fd36b9004c1ee5a778739752ea1aba5638c03a";
    sha256 = "02babvj8xj4s6njrjd14l1il1zl35bfxkrb77bfslvv3wfz66b15";
    propagatedBuildInputs = [
      clockwork
      minheap
      trace
    ];
    meta.useUnstable = true;
    date = "2017-11-16";
  };

  mailgun_ttlmap = buildFromGitHub {
    version = 6;
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
    version = 6;
    rev = "v1.0.0";
    owner = "tstranex";
    repo = "u2f";
    sha256 = "b50bad26adb53caead67bc2d4621f3617d43be7eade519d7884ccb2fc84e20e7";
  };

  ulid = buildFromGitHub {
    version = 6;
    rev = "v1.3.1";
    owner = "oklog";
    repo = "ulid";
    sha256 = "4898782daeb2153af628d569315b08d308f23d5ef82bcdd718a2c14eb742fcec";
    propagatedBuildInputs = [
      getopt
    ];
  };

  unidecode = buildFromGitHub {
    version = 6;
    rev = "cb7f23ec59bec0d61b19c56cd88cee3d0cc1870c";
    owner = "rainycape";
    repo = "unidecode";
    sha256 = "0pp6ip8fxwc96l667yskzr7qz7cas5z51a7arqq3hr30awd7zj5s";
    date = "2015-09-07";
  };

  units = buildFromGitHub {
    version = 6;
    rev = "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a";
    owner = "alecthomas";
    repo = "units";
    sha256 = "11y8v2djk33kw0fc21wvcm0s329n3y9n2nldma5n23rfrwzdz6kq";
    date = "2015-10-22";
  };

  urlesc = buildFromGitHub {
    version = 6;
    owner = "PuerkitoBio";
    repo = "urlesc";
    rev = "de5bf2ad457846296e2031421a34e2568e304e35";
    sate = "2015-02-08";
    sha256 = "0knsqhv2fykspzk1gkl15h0a71x40z472fydq4n4wsh720a60560";
    date = "2017-08-10";
  };

  usage-client = buildFromGitHub {
    version = 6;
    owner = "influxdata";
    repo = "usage-client";
    date = "2016-08-29";
    rev = "6d3895376368aa52a3a81d2a16e90f0f52371967";
    sha256 = "15krz9ws44zcf4q7nckxyppayvyxh731fwfb1hvsqzra1hrs7a9p";
  };

  usso = buildFromGitHub {
    version = 6;
    rev = "5b79b358f4bb6735c1b00f6ad051c07c1a1a03e9";
    owner = "juju";
    repo = "usso";
    sha256 = "1gxdyailrrd0y4ssk9wmf4awm9lymlj6781yr46i7gfybsj5n2j4";
    date = "2016-04-18";
    propagatedBuildInputs = [
      errgo_v1
      openid-go
    ];
  };

  utils = buildFromGitHub {
    version = 6;
    rev = "bf9cc5bdd62dabc40b7f634b39a5e2dc44d44c45";
    owner = "juju";
    repo = "utils";
    sha256 = "803ecc850504e770427d880fa43124482e8d63e9c717d08570b486a927f21ef4";
    date = "2018-08-20";
    subPackages = [
      "."
      "cache"
      "clock"
      "keyvalues"
      "set"
    ];
    propagatedBuildInputs = [
      crypto
      errgo_v1
      juju_errors
      loggo
      names_v2
      net
      yaml_v2
    ];
  };

  utils_for_names = utils.override {
    subPackages = [
      "."
      "clock"
    ];
    propagatedBuildInputs = [
      crypto
      juju_errors
      loggo
      net
      yaml_v2
    ];
  };

  utfbom = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "dimchansky";
    repo = "utfbom";
    sha256 = "0pw0zqjigrh0l8nmml81jqn6ahhvrzbbh733q59qi949h1kjhjgh";
  };

  google_uuid = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "google";
    repo = "uuid";
    sha256 = "fcbf8184883fb4a00379cb629f1b11fda6962501d4b0221cbf5931e2c3cbf05b";
    goPackageAliases = [
      "github.com/pborman/uuid"
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner = "pborman";
    repo = "uuid";
    sha256 = "4b16544df98e87f8a17d0d01fe32ba3ae945562543e69b8ac983a51c6f6f7274";
  };

  validator_v8 = buildFromGitHub {
    version = 6;
    rev = "v8.18.2";
    owner = "go-playground";
    repo = "validator";
    sha256 = "0jrzaz3cjakh6zqma94ac4ff021nv7qbpklhvg1467ms9ndfaj9l";
    goPackagePath = "gopkg.in/go-playground/validator.v8";
  };

  vault = buildFromGitHub {
    version = 6;
    rev = "v0.11.3";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "a940d2bd67a6a9941f779f143805863ebd66870ba9413e81f3339d52e024dfdd";

    nativeBuildInputs = [
      pkgs.protobuf-cpp
      protobuf.bin
    ];

    buildInputs = [
      armon_go-metrics
      aws-sdk-go
      columnize
      cockroach-go
      color
      complete
      consul_api
      copystructure
      crypto
      duo_api_golang
      errwrap
      errors
      etcd_client
      go-bindata-assetfs
      go-cache
      go-cleanhttp
      go-colorable
      keybase_go-crypto
      go-errors
      go-github
      go-glob
      go-hclog
      go-hdb
      go-homedir
      go-memdb
      go-mssqldb
      go-multierror
      go-plugin
      go-proxyproto
      go-radix
      go-rootcerts
      go-semver
      go-version
      hashicorp_go-sockaddr
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
      mapstructure
      mgo_v2
      mitchellh_cli
      mysql
      net
      #nomad_api
      oauth2
      oktasdk-go
      otp
      pkcs7
      pq
      protobuf
      gogo_protobuf
      rabbit-hole
      radius
      reflectwalk
      snappy
      structs
      swift
      sys
      kr_text
      triton-go
      vault-plugin-auth-azure
      vault-plugin-auth-centrify
      vault-plugin-auth-gcp
      vault-plugin-auth-kubernetes
      yaml
    ];

    postPatch = ''
      rm -r physical/azure
      sed -i '/physAzure/d' command/commands.go
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
      "helper/consts"
      "helper/hclutil"
      "helper/jsonutil"
      "helper/parseutil"
      "helper/strutil"
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
      go-glob
      go-multierror
      go-retryablehttp
      go-rootcerts
      hashicorp_go-sockaddr
      hcl
      lz4
      mapstructure
      net
      snappy
      time
    ];
  };

  vault_for_plugins = vault.override {
    subPackages = [
      "api"
      "helper/certutil"
      "helper/compressutil"
      "helper/consts"
      "helper/errutil"
      "helper/jsonutil"
      "helper/locksutil"
      "helper/logging"
      "helper/mlock"
      "helper/parseutil"
      "helper/password"
      "helper/pluginutil"
      "helper/policyutil"
      "helper/salt"
      "helper/strutil"
      "helper/wrapping"
      "logical"
      "logical/framework"
      "logical/plugin"
      "logical/plugin/pb"
      "physical"
      "physical/inmem"
      "version"
    ];
    nativeBuildInputs = [
    ];
    buildInputs = [
    ];
    preBuild = ''
    '';
    propagatedBuildInputs = [
      crypto
      errwrap
      go-cleanhttp
      go-glob
      go-hclog
      go-multierror
      go-plugin
      go-radix
      go-rootcerts
      go-version
      golang-lru
      grpc
      hashicorp_go-uuid
      hashicorp_go-sockaddr
      hcl
      jose
      mapstructure
      net
      protobuf
      snappy
      sys
    ];
  };

  vault-plugin-auth-azure = buildFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault-plugin-auth-azure";
    rev = "d75e09c45e50144d92d5fa0d711996b4ac98c1e4";
    sha256 = "14ad7d7a28471c8551c1a2a9e2515125e3ba5905405e6b3104345ae984ca80d6";
    date = "2018-08-16";
    propagatedBuildInputs = [
      azure-sdk-for-go
      errwrap
      go-autorest
      go-cleanhttp
      go-oidc
      oauth2
      vault_for_plugins
    ];
  };

  vault-plugin-auth-centrify = buildFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault-plugin-auth-centrify";
    rev = "66b0a34a58bffb678532d5a5d6d6ae2eb0206563";
    sha256 = "6df66b4c7039d443a48cf745950f2c314772dd2258881be0fb208a1622c7acdd";
    date = "2018-08-16";
    propagatedBuildInputs = [
      cloud-golang-sdk
      go-cleanhttp
      go-hclog
      vault_for_plugins
    ];
  };

  vault-plugin-auth-gcp = buildFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault-plugin-auth-gcp";
    rev = "d57adfb30a2e65659bdb83e632a6d4e6690e2e86";
    sha256 = "f422f991177120569e56c73af8b25092f616d64baf3c0fac682fd8acd2c60645";
    date = "2018-10-12";
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
    version = 6;
    owner = "hashicorp";
    repo = "vault-plugin-auth-kubernetes";
    rev = "8bfe988b36157168563f726887da232af94ee87f";
    sha256 = "c9089c8863cabe457b452cafb3c5144035b30fe9195948ce91c6c0aa267fb382";
    date = "2018-08-16";
    propagatedBuildInputs = [
      go-cleanhttp
      go-hclog
      go-multierror
      jose
      kubernetes-api
      kubernetes-apimachinery
      mapstructure
      vault_for_plugins
    ];
  };

  juju_version = buildFromGitHub {
    version = 5;
    owner = "juju";
    repo = "version";
    rev = "b64dbd566305c836274f0268fa59183a52906b36";
    sha256 = "0s42sxll6k4k50i2fv3dh3l6iirwpa3mv1nzliawdk0nxgwqdvgn";
    date = "2018-01-08";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  vic = buildFromGitHub {
    version = 6;
    owner = "vmware";
    repo = "vic";
    rev = "v1.4.3";
    sha256 = "5589e5ed35e0c0bdec6ede5275a1d16113c576671120087d250f046e5fa24dbb";
    subPackages = [
      "pkg/vsphere/tags"
    ];
    propagatedBuildInputs = [
      errors
      govmomi
      logrus
    ];
  };

  viper = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "viper";
    rev = "v1.2.1";
    sha256 = "dad8b80204c1f05dbbb244ae94705e16c2a5a9d83b7695dae601004d00587188";
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

  vtclean = buildFromGitHub {
    version = 6;
    rev = "2d01aacdc34a083dca635ba869909f5fc0cd4f41";
    owner  = "lunixbochs";
    repo   = "vtclean";
    sha256 = "13scvqsi1ay4yx84s4r00bdsy70rv4c6p57x4d6bbivjm8bj2pd6";
    date = "2018-06-21";
  };

  vultr = buildFromGitHub {
    version = 6;
    rev = "5673d2d7d620dd96f9e51b478efb3f5d6aa0d613";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "98984816ebed7e71a95f2ebd214a171a7937772aff283f35c6a9dc53c1d46057";
    propagatedBuildInputs = [
      crypto
      mow-cli
      ratelimit
    ];
    date = "2018-10-15";
  };

  w32 = buildFromGitHub {
    version = 6;
    rev = "bb4de0191aa41b5507caa14b0650cdbddcd9280b";
    owner = "shirou";
    repo = "w32";
    sha256 = "1shbj8zkz0mqr47iij8v6wm2zdznml9pafhj4g2njg093yxw998l";
    date = "2016-09-30";
  };

  webbrowser = buildFromGitHub {
    version = 6;
    rev = "efb9432b2bcb671b0cf2237468e209d10e2ac373";
    owner  = "juju";
    repo   = "webbrowser";
    sha256 = "42b3273133bdea901c762cc244341191477e04ef72f9ad2c8b607a13b4dfcaab";
    date = "2018-09-07";
  };

  websocket = buildFromGitHub {
    version = 6;
    rev = "v1.4.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "ff7ee8a460ed865c2f68fc9349aa9a5df423e58f4582785d783f12cea592d181";
  };

  whirlpool = buildFromGitHub {
    version = 6;
    rev = "c19460b8caa623b49cd9060e866f812c4b10c4ce";
    owner = "jzelinskie";
    repo = "whirlpool";
    sha256 = "09lgsrf0fig8m5ac81flxp6jg1dz6vnym6az2b9w5af2j59n1lil";
    date = "2017-06-03";
  };

  winsvc = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "btcsuite";
    repo = "winsvc";
    sha256 = "0j7d58dhgyv3mi1fkxy6q90yqyh85mc8daraj0ndj3gpxk78n83v";
  };

  wmi = buildFromGitHub {
    version = 6;
    rev = "b12b22c5341f0c26d88c4d66176330500e84db68";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "0iz3iv3cz1kn09990g7282kqdpvxa8s183vikxcv5xh3n1wjym2l";
    buildInputs = [
      go-ole
    ];
    date = "2018-07-25";
  };

  yaml = buildFromGitHub {
    version = 6;
    rev = "c7ce16629ff4cd059ed96ed06419dd3856fd3577";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "5bad3891ded136d86f9dd2844619813e0aac4080b1bee4364c7eb5171378547a";
    propagatedBuildInputs = [
      yaml_v2
    ];
    date = "2018-08-20";
  };

  yaml_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.2.1";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "0w1gan4v27nh2g90qsy9c1blrk3hbnprchr679xvjsa8d02m3mh4";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yaml_v1 = buildFromGitHub {
    version = 6;
    rev = "9f9df34309c04878acc86042b16630b0f696e1de";
    date = "2014-09-24";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "03bax5w4li71im848k789iih9pjh6ajgvnfi4s8im9limnfrj34c";
    goPackagePath = "gopkg.in/yaml.v1";
  };

  hashicorp_yamux = buildFromGitHub {
    version = 6;
    date = "2018-10-12";
    rev = "2f1d1f20f75d5404f53b9edf6b53ed5505508675";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "8fa0616142d39b0f1a5dd5b501a4538ec8a735a5cd78ea66a0e27956bf3d1950";
    goPackageAliases = [
      "github.com/influxdata/yamux"
    ];
  };

  whyrusleeping_yamux = buildFromGitHub {
    version = 6;
    rev = "v1.1.2";
    owner  = "whyrusleeping";
    repo   = "yamux";
    sha256 = "1e55becddc6080e3ca77e46a611cef8308c20be50fbe53cdfc1a4aed87fe0b6f";
  };

  yarpc = buildFromGitHub {
    version = 6;
    rev = "v0.0.1";
    owner = "influxdata";
    repo = "yarpc";
    sha256 = "1xbnsc46l3fkgn8yih3z39zy0mzcdgsx8xrz3pim45izs3vnqsp3";
    excludedPackages = "test";
    propagatedBuildInputs = [
      gogo_protobuf
      hashicorp_yamux
    ];
  };

  xattr = buildFromGitHub {
    version = 6;
    rev = "v0.3.1";
    owner  = "pkg";
    repo   = "xattr";
    sha256 = "0papznpzyfpzsp06i17q0ddvqfddgp5lfigfvlzhn602mpcc4sc1";
    propagatedBuildInputs = [
      sys
    ];
  };

  xdr = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "f7f25accb8c0508958e490a9e8bad41a72acb26c0d63714be17a825dce6e3f00";
  };

  xlog = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner  = "hlandau";
    repo   = "xlog";
    sha256 = "106gc5cpxavpxndkb516fvy4zn81h0jp9wvzxss4f9pvdi3zxvwd";
    propagatedBuildInputs = [
      go-isatty
      ansicolor
    ];
  };

  xmlrpc = buildFromGitHub {
    version = 6;
    rev = "ce4a1a486c03a3c6e1816df25b8c559d1879d380";
    owner  = "renier";
    repo   = "xmlrpc";
    sha256 = "09s4fvc1f7d95fqs74y13x2h05xd9qc39xvwn3w687glni3r06ah";
    date = "2017-07-08";
    propagatedBuildInputs = [
      text
    ];
  };

  xorm = buildFromGitHub {
    version = 6;
    rev = "v0.7.0";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "0l31wyp38n4apaag85q5xdhpkabws4kffmkqbcs0z3vj2vyzvxmb";
    propagatedBuildInputs = [
      builder
      core
    ];
  };

  xsecretbox = buildFromGitHub {
    version = 6;
    rev = "7a679c0bcd9a5bbfe097fb7d48497bc06d17be76";
    owner  = "jedisct1";
    repo   = "xsecretbox";
    sha256 = "0kwmwl4ivnkcv3pqv8j5b6f5jmk4c3yjarvlv1wl130ygikby4a0";
    date = "2018-05-08";
    propagatedBuildInputs = [
      chacha20
      crypto
      poly1305
    ];
  };

  cespare_xxhash = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "cespare";
    repo   = "xxhash";
    sha256 = "eb0f6ea619c68b8b76f9fd4e92ae203cec893d53cc90ad505b61590ca419173a";
  };

  pierrec_xxhash = buildFromGitHub {
    version = 6;
    rev = "be086f0f67405de2fac6bc563bf8d0f22fa2a6b2";
    owner  = "pierrec";
    repo   = "xxHash";
    sha256 = "363c65025215ca3db35e43327c58fcb6e9441b45d131fcb2eda2e9d7e4808446";
    date = "2018-09-09";
  };

  xz = buildFromGitHub {
    version = 6;
    rev = "636d36a76670e6c700f22fd5f4588679ff2896c4";
    owner  = "ulikunitz";
    repo   = "xz";
    sha256 = "1wkqjkpz681kf0d1vyd9k9phqh8vqkv9cb2m1j0l6s461r4p5idz";
    date = "2018-07-03";
  };

  zap = buildFromGitHub {
    version = 6;
    rev = "v1.9.1";
    owner  = "uber-go";
    repo   = "zap";
    sha256 = "24d22f384df30e7fe181880280d43cb5564ccbb8f99d3f5f7b7cfae5b778b480";
    goPackagePath = "go.uber.org/zap";
    goPackageAliases = [
      "github.com/uber-go/zap"
    ];
    propagatedBuildInputs = [
      atomic
      multierr
    ];
  };

  zap-logfmt = buildFromGitHub {
    version = 6;
    rev = "v1.2.0";
    owner  = "jsternberg";
    repo   = "zap-logfmt";
    sha256 = "2223faeb76b4f09d2dbdf1decab30c2ca3706980d3d25ed9ede1070ee3ad48e9";
    propagatedBuildInputs = [
      zap
    ];
  };

  zipkin-go-opentracing = buildFromGitHub {
    version = 6;
    rev = "v0.3.4";
    owner  = "openzipkin";
    repo   = "zipkin-go-opentracing";
    sha256 = "0yk259qzrxfzqv6lwfv8r3d77lrdhk6nih65n8yi46ymn2hp1qrm";
    propagatedBuildInputs = [
      go-observer
      logfmt
      net
      opentracing-go
      gogo_protobuf
      sarama
      thrift
    ];
  };
}; in self
