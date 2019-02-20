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
    rev = "v1.4.0";
    owner = "golang";
    repo = "appengine";
    sha256 = "d52acf180b99991e43162d016ab0c8152ea7cd40de142f4a0e73d9df26dacf0b";
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
    rev = "88cd9dd988180f169da22900364b4d6c4ba341dd";
    date = "2019-02-19";
    owner = "golang";
    repo = "build";
    sha256 = "1ddb81ff354200ddb1d766084db82f70f9c3771251f61aade52c45efc8aa874f";
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
    rev = "a4c6cb3142f211c99e4bf4cd769535b29a9b616f";
    date = "2019-02-19";
    owner = "golang";
    repo = "crypto";
    sha256 = "617f52d219350adc3c3602ccecfb81abfaef02b64d7f1bce0232a8035c773619";
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
    rev = "66907db09dddf0cf61d67b6e4e64ef99f71e90e2";
    date = "2018-11-13";
    owner = "golang";
    repo = "debug";
    sha256 = "B0qmjZSyy1lZIg4J4kfFdSl6p3ABx3Y+HYGikTBrNFc=";
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
    rev = "ef4a1470e0dc5915f2f5fa04a28eeab72c6936a4";
    date = "2019-02-09";
    owner = "golang";
    repo = "image";
    sha256 = "f2232fe346ceb95d291289baa5ee21b2f3a733e6138f8f1aa2d126f4b13692e8";
    goPackagePath = "golang.org/x/image";
    propagatedBuildInputs = [
      text
    ];
  };

  net = buildFromGitHub {
    version = 6;
    rev = "3a22650c66bd7f4fb6d1e8072ffd7b75c8a27898";
    date = "2019-02-13";
    owner = "golang";
    repo = "net";
    sha256 = "7da92ae3f2251c7f7a85750a5915c46f22eb186a21eac77b1833a7d94c8a4b4a";
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
    rev = "4b83411ed2b36bd4e3302e9b1d3c973fb1ba24db";
    date = "2019-02-19";
    owner = "golang";
    repo = "oauth2";
    sha256 = "663abe614d78bd2667ba5f87e7834f3d2ce6480d927d2dd89b7208e085743117";
    goPackagePath = "golang.org/x/oauth2";
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };

  protobuf = buildFromGitHub {
    version = 6;
    rev = "c823c79ea1570fb5ff454033735a8e68575d1d0f";
    owner = "golang";
    repo = "protobuf";
    sha256 = "c2f1c868394d12d5f2cef44d5f897725f1c53bcd6dcb2ef0b89ad9bb0990e31e";
    goPackagePath = "github.com/golang/protobuf";
    excludedPackages = "\\(test\\|conformance\\)";
    meta.useUnstable = true;
    date = "2019-02-05";
  };

  snappy = buildFromGitHub {
    version = 6;
    rev = "v0.0.1";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "d20d4f0ad879e377b4b2a984215b8f9253aa1c71c22a9dee0b3bba97b7076ad4";
  };

  sync = buildFromGitHub {
    version = 6;
    rev = "37e7f081c4d4c64e13b10787722085407fe5d15f";
    date = "2018-12-21";
    owner  = "golang";
    repo   = "sync";
    sha256 = "6b6ffa62ac9b30116062ca8a602f9d590bcd27fd44f6cc1f2e72f3b6291efab5";
    goPackagePath = "golang.org/x/sync";
    propagatedBuildInputs = [
      net
    ];
  };

  sys = buildFromGitHub {
    version = 6;
    rev = "90b0e4468f9980bf79a2290394adaf7f045c5d24";
    date = "2019-02-19";
    owner  = "golang";
    repo   = "sys";
    sha256 = "afde4f2e9af6d22ad5a89583f680bdf170c159d42c0ee1cb550f80d99e917c46";
    goPackagePath = "golang.org/x/sys";
  };

  text = buildFromGitHub {
    version = 6;
    rev = "6c92c7dc7f53607809182301b96e4cc1975143f1";
    owner = "golang";
    repo = "text";
    sha256 = "2dff1a09a2282375caf3e4aa9ecea9f8bf391d721c3fea3ac19d64bebbb1cf04";
    goPackagePath = "golang.org/x/text";
    excludedPackages = "\\(cmd\\|test\\)";
    buildInputs = [
      tools_for_text
    ];
    date = "2019-02-13";
  };

  time = buildFromGitHub {
    version = 6;
    rev = "85acf8d2951cb2a3bde7632f9ff273ef0379bcbd";
    date = "2018-11-08";
    owner  = "golang";
    repo   = "time";
    sha256 = "69sxwpfSlpLm7P2IjmUH9hp0jPfFLDkzkCdBltWmoh8=";
    goPackagePath = "golang.org/x/time";
    propagatedBuildInputs = [
      net
    ];
  };

  tools = buildFromGitHub {
    version = 6;
    rev = "9394956cfdc50651347ab69dbde09af8a8e24776";
    date = "2019-02-19";
    owner = "golang";
    repo = "tools";
    sha256 = "e09df1223a0f0317067dcd242711f745fa5da3e82c11dda3ad3e9171bd320cbf";
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
      "go/internal/packagesdriver"
      "go/loader"
      "go/packages"
      "go/ssa"
      "go/ssa/ssautil"
      "go/types/typeutil"
      "imports"
      "internal/fastwalk"
      "internal/gopathwalk"
      "internal/module"
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

  aes12 = buildFromGitHub {
    version = 6;
    rev = "cd47fb39b79f867c6e4e5cd39cf7abd799f71670";
    owner  = "lucas-clemente";
    repo   = "aes12";
    sha256 = "fdaec460020ca543833c03b083d34cf4fbff1fb50b672e27d03e4a711c7ec675";
    date = "2017-10-27";
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
    rev = "v1.2.1";
    sha256 = "bba81a04e5aa4f6862b1904da64779979a72953ce5d7a799922d6d98b64613a4";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  akamaiopen-edgegrid-golang = buildFromGitHub {
    version = 6;
    owner = "akamai";
    repo = "AkamaiOPEN-edgegrid-golang";
    rev = "v0.7.3";
    sha256 = "658b74ed4838f733634801fb505afae07c98d5770e06e8059a91193fbd220f24";
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
    rev = "v0.16.1";
    sha256 = "951d20c8b86ba1158af194fed7545b18d4ce3cd3de6bc82e67e4f676bbfcf614";
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
    rev = "d63bb8a98464b4827854046afb30db95b3efea3d";
    date = "2019-02-08";
    sha256 = "d46eeea104590c71f70afa939e8fdaeed8f91a916b20825b2fa1959be2c23d7b";
    propagatedBuildInputs = [
      protobuf
      text
    ];
  };

  aliyun-oss-go-sdk = buildFromGitHub {
    version = 6;
    rev = "1.9.4";
    owner  = "aliyun";
    repo   = "aliyun-oss-go-sdk";
    sha256 = "ca2e81bd9a60ebdede79615824c0ef2f077fbb4c7cf471bf58621d7b809e1299";
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
    rev = "a314942b2fd9dde7a3f70ba3f1062848ce6eb392";
    date = "2018-12-05";
    sha256 = "OcWTrW6LX50M72ZIlQ7cT60Zm/eU2pkVFDjOZSYH2Rs=";
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
    rev = "v1.3";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "XSInaX7RFEErIKMjY4cbqC+fT1Z0xlCjFATRkJriKHg=";
    goPackagePath = "gopkg.in/asn1-ber.v1";
  };

  atime = buildFromGitHub {
    version = 6;
    owner = "djherbis";
    repo = "atime";
    rev = "2d569978378562c466df74eda2d82900f435c5f4";
    sha256 = "1uK1ZbMSlQOrXPcHg0tGD3yhdtBfwX4vX1vnR+4Sw5M=";
    date = "2018-10-27";
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
    rev = "v1.17.1";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "6ee2cf3fcb0afc1f6286fe269774e2ce176aae0c8991553882de41504e25fc68";
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
    rev = "v25.0.0";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "4699e1f41363498ae1c072d85fa64c73f53134584c956113e592b808d0413162";
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
    rev = "v2.1.1";
    sha256 = "1bb9b5a117cee0f3c04f19577365673fe825b2aab89f02e5dae5b7405af932ce";
    propagatedBuildInputs = [
      net
    ];
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

  bbolt = buildFromGitHub {
    version = 6;
    rev = "v1.3.2";
    owner  = "coreos";
    repo   = "bbolt";
    sha256 = "99a6e5f0cf906fee301ace969dc758048fefda4be82ff2c1fba4394e04e3ce6e";
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
    date = "2019-02-13";
    rev = "306aecffea325e97f513b3ff0cf7895a5310651d";
    sha256 = "693577fb46100ae64edce09664904f92ace5f07eecc9ae54c05bca79e63c8b13";
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
    rev = "v0.3.4";
    owner  = "go-xorm";
    repo   = "builder";
    sha256 = "a45505588b9dfd2f94d804b87f1b7a25b9a3a1616fba390da382db276ace1841";
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
    rev = "v1.0.0";
    owner  = "CanonicalLtd";
    repo   = "candidclient";
    sha256 = "1JitLEGQPLGiGPhUgbNF1c/0MQ9BEwMnD3cikrstZc0=";
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
    rev = "v1.3.0";
    sha256 = "OchCvql6GjggRxibFcfaYABNA9pWmq7y9bUx30DNGds=";
    buildInputs = [
      jwalterweatherman
    ];
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
    rev = "b94e044bb51ec8f5a7232c71b1ed05dbe4da96ce";
    owner  = "cloudflare";
    repo   = "cfssl";
    sha256 = "0806d85e894277b200ef36e1cb3e548e349048e51ebbce21712170715317fec6";
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
    date = "2018-12-13";
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
    rev = "b5ccb8dc322b914484924caf4463d601a64382f7";
    owner  = "alecthomas";
    repo   = "chroma";
    sha256 = "fc337177e352efe6a54d954b87bbdb10acefb4febd80c3c44f0f5f5558f5bdb6";
    excludedPackages = "cmd";
    propagatedBuildInputs = [
      fnmatch
      regexp2
    ];
    meta.useUnstable = true;
    date = "2019-02-08";
  };

  circbuf = buildFromGitHub {
    version = 6;
    date = "2019-02-14";
    rev = "5111143e8da2e98b4ea6a8f32b9065ea1821c191";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "9e4a6d9a7c8d408873e5f2a73908cfbf40f3d428a4f06d43e486919364296c9c";
  };

  circonus-gometrics = buildFromGitHub {
    version = 6;
    rev = "v2.2.6";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "3caf4e34c043f8322a4fea4dedc60411618836c8985717c54d94f79002d544d4";
    propagatedBuildInputs = [
      circonusllhist
      errors
      go-retryablehttp
      httpunix
    ];
  };

  circonusllhist = buildFromGitHub {
    version = 6;
    rev = "v0.1.3";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "y9ebdl1xCOrm8oUxPWdF35QQHoRqXm7gew/87i3Svi4=";
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
    rev = "v18.09.1";
    owner = "docker";
    repo = "cli";
    sha256 = "b3d9b7422da5ce09d14c7c2015eef763ea5bf600d81b0a725d42fb1ccac0e109";
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
    rev = "62fb9bc030d14f92c58df3c1601e50a0e445edef";
    owner = "jonboulle";
    repo = "clockwork";
    sha256 = "9808f8a11752f25fe8d6da61ed36b407db498bfc0d56fd3bdd2d35e1943972da";
    date = "2019-01-14";
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
    version = 6;
    rev = "8a8ea3c53959009183d7914522833c1ed8835020";
    owner = "soheilhy";
    repo = "cmux";
    sha256 = "H0zlrwih21eeOzQpoCC1C0cSgoLXh12nxAYiHwNU9+g=";
    goPackageAliases = [
      "github.com/cockroachdb/cmux"
    ];
    propagatedBuildInputs = [
      net
    ];
    date = "2018-10-25";
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
    rev = "7547e83b2d85fd1893c7d76916f67689d761fecb";
    sha256 = "4a826c28f23b0a022a1f2f08a2415382ebbf0c2fb1fa0aea70242a4d110263e4";
    propagatedBuildInputs = [
      go-homedir
      go-md2man
      mousetrap
      pflag
      viper
      yaml_v2
    ];
    meta.useUnstable = true;
    date = "2019-01-09";
  };

  cockroach = buildFromGitHub {
    version = 6;
    rev = "provisional_201901161553_v2.1.4";
    owner  = "cockroachdb";
    repo   = "cockroach";
    sha256 = "3f41eec2432bde6ad0903a38f6c973e33eaab0917588c8e2482a267e78126cb4";
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
    rev = "v1.2.1";
    owner  = "posener";
    repo   = "complete";
    sha256 = "To4y98f9hs1AVeT6nRwUWhqnHgDd5xSnooGwi6ORYJg=";
    propagatedBuildInputs = [
      go-multierror
    ];
  };

  compress = buildFromGitHub {
    version = 6;
    rev = "v1.4.1";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "4Glve85XypZbgbB966kLglG8VmKmgJBuU3mnSCk218Q=";
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
    rev = "v1.4.2";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "b075bccf5bc0bea182ac9b1d87cf45efc97a9bbb785f43176d6418afe181cb81";
    excludedPackages = "test";

    propagatedBuildInputs = [
      armon_go-metrics
      circbuf
      columnize
      copystructure
      coredns
      crypto
      dns
      errors
      go-bindata-assetfs
      go-checkpoint
      go-cleanhttp
      go-connections
      go-control-plane
      go-discover
      go-memdb
      go-multierror
      go-plugin
      go-radix
      go-rootcerts
      hashicorp_go-sockaddr
      go-syslog
      go-testing-interface
      go-version
      golang-lru
      gogo_googleapis
      gopsutil
      hashicorp_go-uuid
      grpc
      gziphandler
      hashstructure
      hcl
      hil
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      net
      net-rpc-msgpackrpc
      prometheus_client_golang
      protobuf
      gogo_protobuf
      raft-boltdb
      raft
      reflectwalk
      serf
      sys
      testify
      kr_text
      time
      ugorji_go
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

      grep -q 'dns.ErrTruncated' agent/dns.go
      sed -i 's,err == nil || err == dns.ErrTruncated,err == nil,' agent/dns.go
    '';
  };

  consul_api = consul.override {
    propagatedBuildInputs = [
      go-cleanhttp
      armon_go-metrics
      go-rootcerts
      hashicorp_go-uuid
      go-version
      mapstructure
      raft
      serf
      kr_text
      hashicorp_yamux
    ];
    subPackages = [
      "agent/consul/autopilot"
      "api"
      "command/flags"
      "lib"
      "tlsutil"
      "version"
    ];
  };

  consulfs = buildFromGitHub {
    version = 6;
    rev = "v0.2.1";
    owner = "bwester";
    repo = "consulfs";
    sha256 = "2fc5c3f40e2c1585080d5b60af585c095f5519c2e569b607e34b9858fafe9d78";
    buildInputs = [
      consul_api
      fuse
      logrus
      net
    ];
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
    rev = "004b46473808b3e7a4a3049c20e4376c91eb966d";
    owner = "containerd";
    repo = "continuity";
    sha256 = "OE/qXUggfMR59yXYjkC0lap6lxwdKsvdFQsKOvIJykU=";
    date = "2018-12-03";
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
    rev = "v0.6.2";
    owner = "go-xorm";
    repo = "core";
    sha256 = "d8d7abab12bd8a06b0805ccd7783f1d269d8e691198f1fbf3d69d80d51f3632b";
  };

  coredns = buildFromGitHub {
    version = 6;
    rev = "v1.3.1";
    owner = "coredns";
    repo = "coredns";
    sha256 = "56c5d0e325ecfc11e71320b317098fc9451a2af70f21276190e94275c20b3d79";
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
    rev = "0da02118eaa37aa89aea6776b464a4ad00990af1";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "ad966a8acb4d4117d4b91c00a1c2c11eb625a3c8fe8dbb51ad0b88c5ae3d6b2c";
    excludedPackages = "testdata";
    date = "2019-01-10";
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
    rev = "v5.0.1";
    owner = "godbus";
    repo = "dbus";
    sha256 = "fdd74cY36iV1ISY6mCltZtmvssQrQz0pbvYhmQNwKWk=";
  };

  debounce = buildFromGitHub {
    version = 6;
    rev = "bf07a0f9e25545ee1b5974845f70185f91b72a00";
    owner  = "bep";
    repo   = "debounce";
    sha256 = "60d59e7bbff56e0b0b7bec15d5c50350d0056fc5e397f271ae760680d9c09660";
    meta.useUnstable = true;
    date = "2019-02-02";
  };

  demangle = buildFromGitHub {
    version = 6;
    date = "2018-11-02";
    rev = "5e5cf60278f657d30daa329dd0e7e893b6b8f027";
    owner = "ianlancetaylor";
    repo = "demangle";
    sha256 = "3yP6Ogy31GzSUDr7L1P7x/xuaM3uK78zH69qusE9g2g=";
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
    rev = "b75069ef13a1de846c0cdf964f5917f5b00c1a47";
    owner = "docker";
    repo = "distribution";
    sha256 = "f83061ccaceb60ade3690bb8e424565b5e6e46c38fb8068becdb29cc543c4b91";
    meta.useUnstable = true;
    date = "2019-01-17";
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
    version = 6;
    rev = "0.4";
    owner  = "jedisct1";
    repo   = "dlog";
    sha256 = "54b6cf08154e35a894484239b7bb05da3ef0d4c5921bf84225aa3c7ae09c1bba";
    propagatedBuildInputs = [
      go-syslog
      sys
    ];
  };

  dms = buildFromGitHub {
    version = 6;
    rev = "8af4925bffb5f3d9456a00bc5c3f2dcf2b4a0f2e";
    owner  = "anacrolix";
    repo   = "dms";
    sha256 = "ea3bdab1138f9f1b93b468335bc00d0dde90e19b78df6f8c92cca099d488edea";
    date = "2018-01-17";
    subPackages = [
      "dlna"
      "soap"
      "ssdp"
      "upnp"
      "upnpav"
    ];
    propagatedBuildInputs = [
      net
    ];
  };

  dns = buildFromGitHub {
    version = 6;
    rev = "v1.1.4";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "ce1214c2a6d4ea372ee7f2e10474f81e88cd8557f2c770e52abb7cfa64033dbc";
    propagatedBuildInputs = [
      crypto
      net
      sys
    ];
  };

  dnscrypt-proxy = buildFromGitHub {
    version = 6;
    rev = "2.0.19";
    owner  = "jedisct1";
    repo   = "dnscrypt-proxy";
    sha256 = "HRkv+ijdUyjK1aU3c2Ad3bBjCUAuI537SyYaWAvzt3Q=";
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
    rev = "v0.22.0";
    owner  = "dnsimple";
    repo   = "dnsimple-go";
    sha256 = "q+qeCuYJfNNIMhnVI9D1TnTDc3ebvJ3pn0rAfe/CxlI=";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  dnspod-go = buildFromGitHub {
    version = 6;
    rev = "v0.2.0";
    owner = "decker502";
    repo = "dnspod-go";
    sha256 = "74a06b4bf80cf3d03810fe2b30fe2c20a30c9e6cf4d10a781e60298f452e7452";
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
    rev = "v0.2.5";
    owner  = "CanonicalLtd";
    repo   = "dqlite";
    sha256 = "cY0ATqmJTfag2w15znJAWuJdQWnUSfYu0ceATn/CibA=";
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
    version = 6;
    owner = "minio";
    repo = "dsync";
    date = "2019-01-31";
    rev = "fb604afd87b2a095432c17af2dda742960ef111e";
    sha256 = "2a320be7088309849170771618978e8090501af769d39bed360fb2941f39b1b2";
  };

  du = buildFromGitHub {
    version = 6;
    rev = "v1.0.1";
    owner  = "calmh";
    repo   = "du";
    sha256 = "00l7y5f2si43pz9iqnfccfbx6z6wni00aqc6jgkj1kwpjq5q9ya4";
  };

  duo_api_golang = buildFromGitHub {
    version = 6;
    date = "2019-01-07";
    rev = "539434bf0d45b72d40995439b1e813d005ea1bc3";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "6a37da132d4edeef298a3b1372802b827b96eb0395ce84514107d56c2446a3ad";
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
    rev = "v5.0.79";
    sha256 = "6743a1a0f7d7682d4b2689ae4445cac90ecea3e69b5a46ac915894b22046de89";
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
    rev = "a78f675a47f083b671da2ef1b81967b41c2e71c8";
    sha256 = "a72e198e8052ef57aba7347dad21d7be6ce9f7c516b650ca74a685b93be42837";
    excludedPackages = "website";
    propagatedBuildInputs = [
      bolt
      go-isatty
      persistent
      sys
    ];
    meta.useUnstable = true;
    date = "2019-01-30";
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
    rev = "v2.1.0";
    sha256 = "cd65d13cb7aff4d2cccca919d8abc9b39362f29f0a796e7857b914e097ba4a6e";
    excludedPackages = "cmd";
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
    rev = "v1.6.15";
    sha256 = "8d4d4dc59d04f737e17f26a4d73b9dfeb86c85cbb39c5c3ac70f743716dd5ade";
    excludedPackages = "packrd";
    propagatedBuildInputs = [
      godotenv
      go-homedir
      go-internal
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
    rev = "089d3ea4e4d597bd98acac068193d341983326a3";
    sha256 = "hT3ojDnT7e9WGQDD38JTz6qGirQSdcc/V10IWT6X+NA=";
    date = "2018-11-18";
  };

  errors = buildFromGitHub {
    version = 6;
    owner = "pkg";
    repo = "errors";
    rev = "v0.8.1";
    sha256 = "06a8e71a93eca73fed50fc02d9352118f5a4c6a0bc1dd4d0fd62e9389ff78ae1";
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
    rev = "8c228d692bfa516e1c0977922f061b9a0fb1ae0f";
    sha256 = "21e4ba351e78097986970168501c64cab719092167de01e67225cd70455318b6";
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
      google_uuid
      yaml
      zap

      pkgs.libpcap
    ];

    excludedPackages = "\\(test\\|benchmark\\|example\\|bridge\\)";
    meta.useUnstable = true;
    date = "2019-02-19";
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
      google_uuid
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
    rev = "b008cbda3fd60f494a3733a34c2b8cea5baebaf9";
    sha256 = "81cf4b9313274f07d1ae6be315da7627f49f2f69f461b47c2973684d38e355b3";
    date = "2019-02-01";
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
    rev = "v1.0.0";
    owner  = "rogpeppe";
    repo   = "fastuuid";
    sha256 = "0f5cd948e2c5eec38c28d27aafa927c3ff9971783d5a86c6c82ab2025c26b29c";
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
    rev = "8019e6774408f0ef24753bccba660ae36ff4038d";
    sha256 = "ecd7b6029c14f16342c9713f38f6bdc5562a7bd219b8b669e3d15ac1f48137f7";
    date = "2019-01-26";
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
    rev = "v1.2.0";
    sha256 = "6e776e8ed7c42e94bb96f7734d102c12d7cd28291309e15cc7f69534f72cc8ef";
  };

  gateway = buildFromGitHub {
    version = 6;
    rev = "v1.0.5";
    owner  = "jackpal";
    repo   = "gateway";
    sha256 = "ZOJcGBL8OpBswUF2EXJtRcYrk/D6pKpP3L26i5LvlUg=";
  };

  gax-go = buildFromGitHub {
    version = 6;
    rev = "v2.0.3";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "7023aeb5517d3ebbcbae2fd1bfd28d441460cdbcfbb168044d8e3d9240317c73";
    propagatedBuildInputs = [
      grpc
      net
    ];
  };

  genny = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner = "cheekybits";
    repo = "genny";
    sha256 = "6aa87b574ec8f5831711e5e7b6cbd2f7ac5954e49a9a533d04efb95b912f4e20";
    subPackages = [
      "generic"
    ];
  };

  genproto = buildFromGitHub {
    version = 6;
    date = "2019-02-19";
    rev = "082222b4a5c572e33e82ee9162d1352c7cf38682";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "4d1cf3cdc7885d54f9683e33c2543e7012941bdcfdb1a9c86ee67359709a4063";
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
    rev = "7402d34a12a86832e3faea504d412c319b3bf1a1";
    owner = "pborman";
    repo = "getopt";
    sha256 = "dd758a6c91e0282be528d259707b44c0087631dc2ffa4979d14cc47825801a7c";
    date = "2019-01-30";
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
    rev = "v1.7.0";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "Ec37fkGIFTKGaNbaeU5h6LiGLYC4398QB0EDTgWpesE=";
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
    rev = "v1.1.5";
    sha256 = "22748a6e5b1781e7080278e0151232ffa66df836f44144f5173058d4e6afc1be";
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
    rev = "d55a06a32dc7468c645ac01d93d37d4dd47ca062";
    owner = "googleapis";
    repo = "gnostic";
    sha256 = "9a74943f3deee57b6b7bc9303b867891ceea2cc2fd4ddd5679f697c220a8db83";
    excludedPackages = "tools";
    propagatedBuildInputs = [
      docopt-go
      protobuf
      tools_for_text
      yaml_v2
    ];
    date = "2019-01-17";
  };

  json-iterator_go = buildFromGitHub {
    version = 6;
    rev = "5bc93205020f6311d7e4a34f82c5616a18ec35e5";
    owner = "json-iterator";
    repo = "go";
    sha256 = "554ebe5df83ff0dc1faeb0a6228b0852a6c7a0a1cfab9db9bdb7565c652d0925";
    excludedPackages = "test";
    propagatedBuildInputs = [
      concurrent
      plz
      reflect2
    ];
    date = "2019-02-08";
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
    rev = "v1.1.2";
    owner = "ugorji";
    repo = "go";
    sha256 = "3e46f01dac8eb0dc90c482c493a1e4c1a2c19d5dae49c030734918273cc40274";
    goPackageAliases = [
      "github.com/hashicorp/go-msgpack"
    ];
    propagatedBuildInputs = [
      tools_for_text
    ];
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
    date = "2018-11-09";
    rev = "00e24f1b25994999399dee600cb8f35a45f519dc";
    owner = "camlistore";
    repo = "go4";
    sha256 = "7RMoTsSKvB6ea65EozANdSCXm11nZlLZMnLfSKPIQKY=";
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
    rev = "8516aabb0f993b6c0d88b66d46e54a90d622671d";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "76ce3d12424fbd729bdb2860593aef5a9085e9e49b2062b565a743eea6536fb2";
    propagatedBuildInputs = [
      inf_v0
      snappy
      go-hostpool
      net
    ];
    date = "2019-01-26";
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
    rev = "v1.7.3";
    owner  = "digitalocean";
    repo   = "godo";
    sha256 = "73d7c824dcba0fc16733e918efbe884582ff980010d6be32d908098ccba9653e";
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
    rev = "b1fd11e07dc5bc0d2ca3b79d28cbdf3c6d186247";
    owner  = "rwcarlsen";
    repo   = "goexif";
    sha256 = "936ad4e8eecf7c30bf7d7aa0e028e117ac6a94ce5bc73e380b38b10ef1665768";
    date = "2019-01-07";
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
    rev = "v1.1.0";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "6b7f20885c0604da322b7fad859e002dea1f105cfb401038996d15d852dcce42";
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
    rev = "5125a94a666c83cb9b7a60907833cd320b84c20f";
    date = "2018-11-22";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "JOFMmAt/3mbq3sT/wVoXJDr1V9jewmD7XwN0TstaOVs=";
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
    rev = "dcc6e84aef1b6713accea7d7d7252ad2bc0e7034";
    owner = "gophercloud";
    repo = "gophercloud";
    sha256 = "d0f68b3549c33539df6fa5ee42babc39b4ca8ffb76c5688cb5ca0ab2fccfc743";
    date = "2019-02-16";
    excludedPackages = "test";
    propagatedBuildInputs = [
      crypto
      yaml_v2
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 6;
    date = "2019-02-14";
    rev = "f23c43891e43fa5323eb751293c177f0a4196b1a";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "4e5311eb9a678833d631e62602339f42df8bf25bea5a7b7cf99c2c75a7ea88a4";
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
    excludedPackages = "\\(oauth2\\|readme\\|mocks\\|test\\|cloud.google.com/go$\\)";
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
    rev = "9fda3b87c7b32caeeb2974e7cc2e71e60a597fdf";
    owner = "google";
    repo = "gops";
    sha256 = "ea8ac6e949f847cf39e627ef099fea6e516458608892514204ad5ab6d6ac0ec1";
    propagatedBuildInputs = [
      keybase_go-ps
      gopsutil
      goversion
      osext
      treeprint
    ];
    meta.useUnstable = true;
    date = "2019-01-25";
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
    rev = "c182affec369e30f25d3eb8cd8a478dee585ae7d";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "9f90267f326ae3e25e46c7f231641a345535d355dd7ce2f4a4924bf00fad10a8";
    propagatedBuildInputs = [
      protobuf
    ];
    date = "2018-12-31";
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
    rev = "2f17a3356c6616cbfc4ae4c38147dc062a68fb0e";
    date = "2019-02-03";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "4c74147984c7a445c79ff4d7115c4ad1d81590d2720afa1f51793b490c88726c";
    propagatedBuildInputs = [
      ginkgo
      gomega
      snappy
    ];
  };

  gomega = buildFromGitHub {
    version = 6;
    rev = "v1.4.3";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "A/LkPsU7cAT5DPAkKHLjjFncTn/PKpsj5SbihFQ9Vnc=";
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
    };
    rev = "v0.1.0";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 6;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "1fcdc04526dd2ca0e6771fb93c8a118713fa99d00ff214dc0845970dfacc7b5e";
    };
    propagatedBuildInputs = [
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
    rev = "v2.19.01";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "7d9d6f5ffbb2be80a707acc18478728d097128d3d057a017c5f3e20cbb0a85be";
    propagatedBuildInputs = [
      sys
      w32
      wmi
    ];
  };

  goquery = buildFromGitHub {
    version = 6;
    rev = "v1.5.0";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "/hkH+xLT/w0xf7U6wLFP0MkJA7ikk8V/wI+BmlSqAWE=";
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
    rev = "v0.20.0";
    owner = "vmware";
    repo = "govmomi";
    sha256 = "8e7fe6700dc0090d1fa1a8ac2f99c9549165b6cb14d79b071fd67a3dd69b7be2";
    excludedPackages = "toolbox";
    propagatedBuildInputs = [
      pretty
      google_uuid
    ];
  };

  gox = buildFromGitHub {
    version = 6;
    rev = "9cc487598128d0963ff9dcc51176e722788ec645";
    owner  = "mitchellh";
    repo   = "gox";
    sha256 = "0e44f2b1e58b4198bfaad47cccfacd6aea0391e21c06e876d37ec0d4262b675c";
    date = "2018-10-25";
    propagatedBuildInputs = [
      go-version
      iochan
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
    rev = "v11.4.0";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "2f22fd345c2237be03c4c7c9ee0ca0d0a89654aa70a75d5ca3c9885e61613d7b";
    propagatedBuildInputs = [
      #crypto
      jwt-go
      opencensus
      opencensus-exporter-ocagent
      #utfbom
    ];
    subPackages = [
      "autorest"
      "autorest/adal"
      "autorest/azure"
      "autorest/date"
      "logger"
      "tracing"
    ];
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
    rev = "v0.1.3";
    sha256 = "a244c3c297b811251553a1cfe42c2ac8bfc7de3b45b3f4abc974fd66000887a8";
  };

  go-buffruneio = buildFromGitHub {
    version = 6;
    owner = "pelletier";
    repo = "go-buffruneio";
    rev = "25c428535bd3f55a16f149a9daebd3fa4c5a562b";
    sha256 = "0e070bcc3727b835d8caff6079a4a9aa14bc9d14ba0f72478b6cc992f5757dd8";
    date = "2019-01-03";
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
    rev = "v0.5.0";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "97d1f42c7d03dc920722431061da4d43ce584ae3fe4a1c5ca49f48d8a49cd8cf";
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
    rev = "77b690bf6c1049022bf199e25da3927a56d0a60d";
    owner  = "google";
    repo   = "go-cmp";
    sha256 = "c7b65c0c47789be6938cf5ec3cc274c46e8db315814fdc67b297cf17af5e29ce";
    date = "2019-02-17";
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
    rev = "f80706d1e115f0e4a6cbd8bf7c5cddf99d836495";
    sha256 = "SQ2p7J6z0I+QylZw4b7sLfQBjhEDH8mb0uFzzUyYtzw=";
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
    date = "2018-10-25";
  };

  go-colorable = buildFromGitHub {
    version = 6;
    rev = "v0.1.0";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "846415c182a1b65deabc9a98d2ece69ba5faf6223b43ccdab30be06bdcda6f38";
    propagatedBuildInputs = [
      go-isatty
    ];
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

  go-control-plane = buildFromGitHub {
    version = 6;
    rev = "2137d919632883e52e7786f55f0f84e52a44fbf3";
    owner  = "envoyproxy";
    repo   = "go-control-plane";
    sha256 = "71564ead00e4ec41c38614d573b7d673e67475709ec9032050d541580fbf8978";
    subPackages = [
      "envoy/api/v2"
      "envoy/api/v2/auth"
      "envoy/api/v2/cluster"
      "envoy/api/v2/core"
      "envoy/api/v2/endpoint"
      "envoy/api/v2/listener"
      "envoy/api/v2/route"
      "envoy/config/filter/accesslog/v2"
      "envoy/config/filter/network/ext_authz/v2"
      "envoy/config/filter/network/tcp_proxy/v2"
      "envoy/service/auth/v2alpha"
      "envoy/service/discovery/v2"
      "envoy/type"
      "pkg/util"
    ];
    propagatedBuildInputs = [
      gogo_googleapis
      grpc
      net
      gogo_protobuf
      protoc-gen-validate
    ];
    meta.autoUpdate = false;
    date = "2018-09-24";
  };

  go-couchbase = buildFromGitHub {
    version = 6;
    rev = "d904413d884d1fb849e2ad8834619f661761ef57";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "abc05c364c2ddbdfa1081086b8392898e0e23a93045e8b1c4beb6bf42d632409";
    date = "2019-01-17";
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
    rev = "255a5089e85a475b944ad3c159af0de73fbe66b1";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "gFBoUjcoDbQzS1svW8iYWNA7zWL5zlpxK0YQMyEzwAs=";
    date = "2018-11-27";
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
    rev = "5dc88f41ca59ce157900a9942b2059ef084e6f81";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "1f7d1a6e851a223dcb5625987acbefca1d5043edbb4a77e5f7b14e973ea824be";
    propagatedBuildInputs = [
      goid
    ];
    date = "2019-01-30";
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
    rev = "e88f86e24f50958cc7722c601dfbca6b50dd1df4";
    owner  = "hashicorp";
    repo   = "go-discover";
    sha256 = "c68a62b76ef5c3cb96ff566d59a8f0be32bb9d8ad5f40aadfe79a2c8bbd61e2f";
    date = "2019-01-17";
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
    rev = "5d4384ee4fb2527b0a1256a821ebfc92f91efefc";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "8b726179937ac508695fd9b2c2e568a5cf7eafa86505d20fa58b4f0c072f7f5c";
    date = "2018-12-26";
  };

  go-digest = buildFromGitHub {
    version = 6;
    rev = "4eb64ca734023ea9a10c70ff11dc0e3f69d38482";
    owner  = "opencontainers";
    repo   = "go-digest";
    sha256 = "b45c1b92788d6ac345a162eb4d4da99af3be3d0be5da35f6c6be2b8e25c06e40";
    date = "2019-01-29";
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
    date = "2019-01-23";
    rev = "f1de6adc0e8070bde9823548fedb4855d096b8d8";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "8aa84bda6118db7bc43ccc2a7b20a47ebe2ab601fe5dd0f54eb9db1676ba706c";
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
    rev = "3adb47b1fb0f6d9efcc5051a6c62e2e413ac85a9";
    owner  = "dgryski";
    repo   = "go-farm";
    sha256 = "71a6c13bb53eb1ecdb545cb5bcb7e2950f0c0d1e8426fb16103dda37b032cc37";
    date = "2019-01-04";
  };

  go-flags = buildFromGitHub {
    version = 6;
    rev = "c0795c8afcf41dd1d786bebce68636c199b3bb45";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "278b0ab1432671182894a07bc673c51e3a56c5ff5484a60a90c20a1f8745b76b";
    date = "2018-12-21";
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
    rev = "v1.0.1";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "16469e3b059a1ce23532bcbe14f96936765899c75a21c90ff6045d6848d2eb26";
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
    rev = "v21.0.1";
    owner = "google";
    repo = "go-github";
    sha256 = "7469e8fe0b2e774f460a6eb6cce25d761be3ee2914dd05b5a8d41bf0342024d2";
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
    rev = "v1.0.0";
    owner = "ryanuber";
    repo = "go-glob";
    sha256 = "a89c530d084237d2e615bd3db0ce8f0d44ebdc2c7639bc44853731a6d3140cdf";
  };

  go-grpc-middleware = buildFromGitHub {
    version = 6;
    rev = "f849b5445de4819127e123ca96ba0eeb62b5e479";
    owner = "grpc-ecosystem";
    repo = "go-grpc-middleware";
    sha256 = "7c07d8796b8e6c74a5855222bd8e46e579ff08db051207ff18a90ecd4f06d7a5";
    excludedPackages = "\\(testing\\|zap\\)";
    propagatedBuildInputs = [
      grpc
      logrus
      net
      opentracing-go
      protobuf
    ];
    date = "2019-01-18";
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
    rev = "v0.7.0";
    owner  = "hashicorp";
    repo   = "go-hclog";
    sha256 = "e0e01f103cccfd1b3104bbf2f13a443ef75f75537852dd91c14152e75420198b";
  };

  go-hdb = buildFromGitHub {
    version = 6;
    rev = "v0.13.2";
    owner  = "SAP";
    repo   = "go-hdb";
    sha256 = "749decaa17573da1400590a80f76614deb7b8c00588a75a96de80593a2aa7285";
    propagatedBuildInputs = [
      text
    ];
  };

  go-homedir = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "bba358f0f2e02658deec68edaf66d881f56fdd1d4d2d3a99bc7410c36a2f96b9";
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
    rev = "9b7db94d32d9901e7ad2488fddf91f7b9fcc36c8";
    date = "2019-01-28";
    sha256 = "e8e14a7f0c78884309950de0dbcdf3090b1f65ce933a42341eb71d03da5a3d96";
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
    rev = "7a73c96f2026ad7c4b56c7a323fb1466374589a5";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "14321f91322a9df7b0c80c2553e50e93fa82c3a62b6f3565e01386c3610f1784";
    excludedPackages = "example";
    propagatedBuildInputs = [
      go-toml
      text
      toml
      yaml_v2
    ];
    date = "2019-01-06";
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

  go-internal = buildFromGitHub {
    version = 6;
    rev = "v1.2.2";
    owner  = "rogpeppe";
    repo   = "go-internal";
    sha256 = "a4e5dc24b968e5e821fde3a21d0445df41c741858c076a3eb8bc915a4e414702";
    excludedPackages = "test";
  };

  go-ipfs-api = buildFromGitHub {
    version = 6;
    rev = "b87a51132cbcfc47da594e9f39f9edb4b720570e";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "4e9bb3c1cf97c7fd897e204f625b780af812f3d5e9e3be3713d77e8c172500ea";
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
    date = "2019-02-19";
  };

  go-ipfs-delay = buildFromGitHub {
    version = 6;
    rev = "70721b86a9a82e1fb77dbdfe9db3f10407fe2e87";
    owner  = "ipfs";
    repo   = "go-ipfs-delay";
    sha256 = "9XZTHdp1RVwDciBGrNaRDOXy2IghyCDUoBvsC9T988Q=";
    date = "2018-11-09";
  };

  go-ipfs-files = buildFromGitHub {
    version = 6;
    rev = "b9ab5987284914bf7c73b9c450b2ae6777051a3d";
    owner  = "ipfs";
    repo   = "go-ipfs-files";
    sha256 = "c15656069849d27003c23faf64ced88bd8e34531993f7d0cb369a2a4acea334d";
    date = "2019-02-11";
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
    rev = "v2.2.2";
    owner = "square";
    repo = "go-jose";
    sha256 = "18ec91a409bb2d1ac1b0b0546bae617939cefc9c8c0227744f9850cfcfab19c2";
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
    rev = "v2.0.5";
    sha256 = "51f5170fbe998217f2e8d5da9981d1a945d09ba62112aa6be7ecd9e0e6119ed5";
    propagatedBuildInputs = [
      btcd
      crypto
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
    rev = "v3.0.15";
    sha256 = "vD3+J+WHJuZsxejIJ6hcq8YaMQJ5v6YjaTMs0ldJNQE=";
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
    rev = "v2.0.6";
    sha256 = "zbCdhR2o2bX6UHAt3e+3rscX6CcKQaEcjNq7pgJgKeY=";
    excludedPackages = "test";
    propagatedBuildInputs = [
      base32
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
    rev = "v3.0.15";
    sha256 = "s0F0Zxkwu6HuDpEeVGdABX0BMrcfm5/iWaEmPMNWGL4=";
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
    rev = "v0.1.16";
    sha256 = "x5xZ8s4KlEKa0k6WKw9mf2SKigvKaIMrZdtfQVdnQcw=";
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
    rev = "f870eaa15594bb64b1908df39d0812704f0ceb8f";
    sha256 = "7f9606fb293d8c0a30316b2b7df62bc5d3d8da6b4dd3ac01ff04972d7196b75e";
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
    date = "2019-02-12";
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
    rev = "7c910f8a5edc8a569ffcd0c7c1f3ea56d73adab7";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "a32198747eb02afe152de09f21753e71279c661f6b4abda4a502049155a42a2a";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2018-12-27";
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
    rev = "v1.1.10";
    sha256 = "BKDMD50+M+LimQAxyv2Sr0BxuH19gltVIlzXUKUT3gk=";
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
    date = "2019-02-05";
    rev = "55a226cf41da689fcd9dfd32e0920641caf93a43";
    owner = "t3rm1n4l";
    repo = "go-mega";
    sha256 = "b4b3e0663ef3e0ab7ff86d1a05b761ee9f38e77f668f7553ff11c80028f57993";
    propagatedBuildInputs = [
      crypto
    ];
  };

  go-memdb = buildFromGitHub {
    version = 6;
    date = "2018-11-08";
    rev = "032f93b25becbfd6c3bb074a1049d98b7e105440";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "em1H7gQAUcmQefFP2SI800jSmSVe4HO3JPdPu61CjyI=";
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
    date = "2018-12-18";
    rev = "b84716841b82eab644a0c64fc8b42d480e49add5";
    owner = "docker";
    repo = "go-metrics";
    sha256 = "5eda4b8be5fc1c3c349a02119fad768c9606d06623b8bb6e2aa0ff41cacf2069";
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
    rev = "b04fd42d99522cbe36d6d5c4b5b706bf28d2f21a";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "f517def795367a746959f7eb9a597cc6f70015cc7e7405be61292b1f39641295";
    date = "2019-01-21";
    propagatedBuildInputs = [
      crypto
      google-cloud-go
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 6;
    rev = "v1.4.0";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "0c80272f4653f94b4ecc6fad9488000c875f92f850826f2a8bc3d35c9e93a9b2";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-dns = buildFromGitHub {
    version = 6;
    rev = "v0.2.5";
    owner  = "multiformats";
    repo   = "go-multiaddr-dns";
    sha256 = "xlXm0ublMxHRiS7RsiNjvzjquwFE8MvpPSCQrKxwlrk=";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 6;
    rev = "v1.7.1";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "1c419dea7e1a8a06d633407c9d30a1884d5420b8aae76816bfa113d8c8762179";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-dns
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
    rev = "8366cb240ab23e9810a2b420dc75c80ab990c39b";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "1d4ae3cfe925b620e7f83304b2af29b4da80b7dcfb316a38f2bd3ff39150ed55";
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
    date = "2019-02-19";
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
    rev = "v1.7.0";
    owner = "nats-io";
    repo = "go-nats";
    sha256 = "d7e0a75ec499b9280b52ab1acab23a828096f0d77df030afa3b96fdb3e76ebb3";
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
    rev = "a0e3aee6fce1a77efe4024df3280416e9d99bb98";
    owner = "nats-io";
    repo = "go-nats-streaming";
    sha256 = "5924dc92ac4f9c659324f8a4d127789be818750ea197d80b50295a55b5c850b8";
    propagatedBuildInputs = [
      go-nats
      nuid
      gogo_protobuf
    ];
    date = "2019-01-09";
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
    rev = "v1.2.2";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "5e3afb9a4e19ad62183949e9df7754ec61d6dcd3aac1697791a5dc281f13980e";
    excludedPackages = "example";
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
    rev = "ba5adb4cf0148a3dbdbd30586f075266256a77b1";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "yRaYGRAjNlFPgNAsO55sQc7VfiWn60YYDD2DCwEfQO0=";
    date = "2018-11-09";
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
    rev = "b838ffee39ce7c7c38226c1413aa4ecae61b4d27";
    date = "2019-02-12";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "a031db9b7cc6adb0587469afd5cca2ad7b12d1943434751d2dcf52850e943f0c";
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
    date = "2019-01-18";
    rev = "5561e0f6d23833c825a57e025596f9bcd3a468d6";
    sha256 = "c5b25f23802438c07abcf728ca732b98e9af4e6fd0d02fbe2612dfad5f5cd462";
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
    rev = "487be0453c7b062bff8dcd0ca2570f09e780a9e2";
    owner  = "eapache";
    repo   = "go-resiliency";
    sha256 = "c1fa270777236c5358f16dcffc534ed5717dfd697e995d29ca74e3b084037f77";
    date = "2018-12-14";
  };

  go-restful = buildFromGitHub {
    version = 6;
    rev = "v2.9.0";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "275a547213100fc837bd60bf50185fd7f9e4de65b57de82553ad949c4516e3ed";
    propagatedBuildInputs = [
      json-iterator_go
    ];
  };

  go-retryablehttp = buildFromGitHub {
    version = 6;
    rev = "v0.5.2";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "7a6d1b41c889143a67690e77190fddfa39b8b06e32df976ec9bebea78205d43d";
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
    rev = "v1.0.0";
    owner = "hashicorp";
    repo = "go-rootcerts";
    sha256 = "0ec78110a9e5fef03493a36d38906db815873182314f8ead7e882e941a6078eb";
    buildInputs = [
      go-homedir
    ];
  };

  go-runewidth = buildFromGitHub {
    version = 6;
    rev = "v0.0.4";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "ce07c78fec2574c5ebe00864306731080c5fc256f1d0c45cd456b7cd34f7c5e7";
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
    rev = "1999055a4a14e23c8c441fbbfbbd2635998fd71a";
    owner  = "pengsrc";
    repo   = "go-shared";
    sha256 = "3281d3a1f6517dbedccb41643d01b924b02fda16b3283a748f03dbf60e45405f";
    propagatedBuildInputs = [
      gabs
    ];
    meta.useUnstable = true;
    date = "2019-01-31";
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
    rev = "3c0603ff9671145648171317c30371d805656003";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "SJgVtbPGHH+3gAz7z231rDyRwSqQANfLATAQzqnQJhs=";
    date = "2018-10-23";
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
    rev = "v1.0.1";
    owner  = "hashicorp";
    repo   = "go-sockaddr";
    sha256 = "74c0af9f1ce23308a03b18b6d6dc6e14012f1b58e4d9022976ac70dc7da50243";
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
    rev = "3fa1c550ffa69b74dc4bfd5109b4e218f32c87cf";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "aae02edba08643e21b6c8a5010f411ed47af222c12b9902e5bd9c85b5b6a92b6";
    excludedPackages = "test";
    meta.useUnstable = true;
    date = "2019-01-04";
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
    rev = "77df8e8e70b403c6b13c0fffaa4867c9044ff4e9";
    owner  = "opentracing-contrib";
    repo   = "go-stdlib";
    sha256 = "1c1da1e77ff184895cc8330335fb4a69e8566cb3d95a3fc1be96b1c468ae4b4d";
    date = "2018-12-22";
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
    rev = "v1.0.0";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "14101cade509359b7d9ac90d1402071347c6d69b72c22690bdcc67683253ebe1";
  };

  go-systemd = buildFromGitHub {
    version = 6;
    rev = "93d5ec2c7f76e57b4f3cb9fa4ee4e3ea43f3e5c9";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "bdf90758abcd4b2e3c2c87f4b5bc9ac273174ad3e324885c976365207f87934e";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2019-02-12";
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
    rev = "v0.6.0";
    sha256 = "IK3vS8XcUKf5v8bpuiXABxbDMnI2WvYGIZFIdKGx7IU=";
    propagatedBuildInputs = [
      go-libsass
    ];
  };

  go-toml = buildFromGitHub {
    version = 6;
    owner = "pelletier";
    repo = "go-toml";
    rev = "27c6b39a135b7dc87a14afb068809132fb7a9a8f";
    sha256 = "LPMPqahQ/r0MUOeecqF202KVmBrzypevidAFzviweUM=";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2018-11-24";
  };

  go-units = buildFromGitHub {
    version = 6;
    rev = "2fb04c6466a548a03cb009c5569ee1ab1e35398e";
    owner = "docker";
    repo = "go-units";
    sha256 = "1Z6/w/pFzhMUeDbUr6HONyK/PIoskOh9pMeOqZur82k=";
    date = "2018-10-30";
  };

  go-unsnap-stream = buildFromGitHub {
    version = 6;
    rev = "f9677308dec2b35e76737f9713df328ad11b1fea";
    owner = "glycerine";
    repo = "go-unsnap-stream";
    sha256 = "da656f3a180102a4cfdb432cea8eee82e3c1ff5809f3a63abc83698ce8cc7664";
    date = "2018-12-21";
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
    rev = "v1.0.1";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "63223c41ef00a48bd1a580e2d0c0948861b981392d9dc89b489ed31fae9514ec";
  };

  satori_go-uuid = buildFromGitHub {
    version = 6;
    rev = "b2ce2384e17bbe0c6d34077efa39dbab3e09123b";
    owner  = "satori";
    repo   = "go.uuid";
    sha256 = "W5Z+dwAJfuMiy2Z/5tXoEJvAeD7cTxZJ9rJPBeOQO4I=";
    goPackageAliases = [
      "github.com/satori/uuid"
    ];
    meta.useUnstable = true;
    date = "2018-10-28";
  };

  go-version = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "c6cc684378e9007ca23434104b18c03ca78c2a6a7ba125f68cc2d9b3cb2c13dc";
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
    rev = "v2.0.15";
    owner  = "libp2p";
    repo   = "go-ws-transport";
    sha256 = "/iZvRO5MjYysTissifs/Hxfnv2IPFK4CSy5X3lkG8jw=";
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
    rev = "abcd5707844888d7088866f25df3a7a2ac337dc4";
    sha256 = "b5f39e188e345821442dce132d3240097429742088efa9293b0b8768dbb502f0";
    date = "2019-01-05";
  };

  goconfig = buildFromGitHub {
    version = 6;
    owner = "Unknwon";
    repo = "goconfig";
    rev = "56bd8ab186196b5203e3b8e17057a04a65153003";
    date = "2018-11-05";
    sha256 = "LRNAkWXe6736TXtyTPkH/ylRGgmb62MhITZvG7Ul67w=";
  };

  gorequest = buildFromGitHub {
    version = 6;
    owner = "parnurzeal";
    repo = "gorequest";
    rev = "b0604454e3c35c21d4c86e4771dc1e24c896cdd3";
    sha256 = "e42784055ea45ccd67917e2620ce3cb2edaab33fe5159e3dc13e00c10c6a82f5";
    propagatedBuildInputs = [
      errors
      http2curl
      net
    ];
    date = "2019-01-14";
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
    rev = "v5.4.3";
    sha256 = "643b3db73624cdda8112eb3feace90a749f1fece20a24818a7b06556732ad0f7";
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
    date = "2019-01-29";
    rev = "5b532d6fd5efaf7fa130d4e859a2fde0fc3a9e1b";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "431eedda44fd97cb8c379ec8285bb2bcd8093d7b930daa1f2cee53f0ccc469d8";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub rec {
    version = 6;
    rev = "v1.18.0";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "8123baaff36d67c3541a03e1db8b5373726cb7d1937ba9326d7f177e81a9c4ab";
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
      sys
    ];
  };

  grpc-gateway = buildFromGitHub {
    version = 6;
    rev = "v1.7.0";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "e01d02a307e2683756132bdf44b14040453a3a6333390de01e42d679b665822d";
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
    rev = "0ad062ec5ee553a48f6dbd280b7a1b5638e8a113";
    owner = "tmc";
    repo = "grpc-websocket-proxy";
    sha256 = "2e5cd99ac00b3a9f2ab3b04f291a388c549936104aaa7f2ee50c882826d6ceff";
    date = "2019-01-09";
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
    rev = "e68493906b8382891943ddc9960cb9c6ecd1a1f0";
    sha256 = "d88aafcefdc00e95b60af5ec7c4d1db117654a685aa09693f3578926717fbcd8";
    date = "2019-01-25";
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
    rev = "v0.14.1";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "G+8zz6NHw6pHSvXTq3mEPdIG7RUf4g3lEf4zIptR+gI=";
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
    postInstall = ''
      mkdir -p "$bin"/nix-support
      cp '${../all-pkgs/b/build-go-package/gx.sh}' "$bin/nix-support/setup-hook"
    '';
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
    rev = "v1.1.0";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "cd7c3974cf5a0dc2d591f70846a3f10310220b8ead47f8d8f33dc25e3c56b642";
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
    date = "2019-01-31";
    rev = "02ca4b43caa3297fbb615700d8800acc7933be98";
    owner  = "minio";
    repo   = "highwayhash";
    sha256 = "8aff5d7ddb008cd71f37367de1f84c9e4022c5e41ab4d8dab95669471f582179";
    propagatedBuildInputs = [
      sys
    ];
  };

  hil = buildFromGitHub {
    version = 6;
    date = "2019-02-12";
    rev = "97b3a9cdfa9349086cfad7ea2fe3165bfe3cbf63";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "05db840918691954f28cf9afe2ae2924153678885d3065cb8ed05dd7b908d8e9";
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
    rev = "v2.3.2";
    owner = "mailgun";
    repo = "holster";
    sha256 = "c5a6e604a77e0a652cefd393d91f2ac4ef0751ea3e2725aa8fc540d9c45e65ab";
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
    rev = "faeffb3553568c6ecaa9c103c09dea941ca9c570";
    sha256 = "e44e2e990ebeb684f0193fb03fb848a589b1995cec1b550344bfcf108d390ecd";
    date = "2018-12-27";
  };

  httpcache = buildFromGitHub {
    version = 6;
    rev = "3befbb6ad0cc97d4c25d851e9528915809e1a22f";
    owner  = "gregjones";
    repo   = "httpcache";
    sha256 = "61e6ca853240c07abf4cca084cd38fee488855ffeff4c94a9ad288c21f4b25d4";
    date = "2019-02-12";
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
    rev = "v1.1.3";
    owner  = "go-httprequest";
    repo   = "httprequest";
    sha256 = "0fb181c945287b2ff3bbafc0e2286fd5f846ffc5747af2d6de1026bd09fc5d89";
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
    rev = "v0.54.0";
    sha256 = "24f0731eaab34fe2c736441824303ea40202b1a07383b88f881bed5fb2e47ea6";
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
      errors
      fsnotify
      fsync
      gitmap
      glob
      go-i18n
      go-immutable-radix
      go-isatty
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
    postPatch = ''
      grep -q 'ebouncer, _, _ = debounce.New' commands/commandeer.go
      sed -i 's#ebouncer, _, _ = debounce.New#ebouncer = debounce.New#' commands/commandeer.go
    '';
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
    rev = "befc3cba3ffdf76e2f72f52a248a20a2727cc4c9";
    owner  = "opencontainers";
    repo   = "image-spec";
    sha256 = "98eb6e64d5fb4faec88d7f764928750b9aef5d6532f1db251257f3afe6a57026";
    propagatedBuildInputs = [
      errors
      go4
      go-digest
      gojsonreference
      gojsonschema
    ];
    date = "2019-01-20";
  };

  imaging = buildFromGitHub {
    version = 6;
    rev = "v1.6.0";
    owner  = "disintegration";
    repo   = "imaging";
    sha256 = "6e4add95a122669b86e0f0903c1a5b0916fa380234873a274d79c0821370b318";
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
    rev = "v1.0.4";
    sha256 = "64g2kZCfjwB1TyUcZIcB5jDZbvjSrvh3BVfDdLtkPLI=";
    propagatedBuildInputs = [
      envy
    ];
  };

  influxdb = buildFromGitHub {
    version = 6;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.7.3";
    sha256 = "20bb778336d5d515bdc843554e8f8690a6108151721793910001b102a3d7f86d";
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
    rev = "v1.42.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "2dbe9efe405adab92628ed05bec60de884ccd50db7f898f98b2e7e66224804fc";
  };

  ini_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.41.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "d3c54ec9c56341667a38de23a58cbfa208c260ee09654caab6197145c047ed52";
  };

  inject = buildFromGitHub {
    version = 6;
    date = "2016-06-27";
    rev = "d8a0b8677191f4380287cfebd08e462217bac7ad";
    owner = "go-macaron";
    repo = "inject";
    sha256 = "1yqbh7gbv1awlf231d5k6qy7aq2r808np643ih1pzjskmaln72in";
  };

  iochan = buildFromGitHub {
    version = 6;
    rev = "v1.0.0";
    owner  = "mitchellh";
    repo   = "iochan";
    sha256 = "e91e0a9a73c341c486ee5025e04344f55f9f3cba505a971997fa1bb205322004";
  };

  ipfs = buildFromGitHub {
    version = 6;
    rev = "fd51d4c37a74b3e14e6c7a114d2fe13d2ea14c86";
    date = "2019-01-30";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "7024f8b66ee538be5421709c50022c5e52d98e7581669b94152ebfd154dda78b";
    gxSha256 = "6688a42ca0423b634ac3b4db86a8c466c064599ab4ed160360a31c5d1643e9ee";
    nativeBuildInputs = [
      gx-go.bin
    ];
    # HACK: needed for quic-go
    propagatedBuildInputs = [
      aes12
      crypto
      genny
      golang-lru
      mint
      quic-go-certificates
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
    rev = "v0.9.0";
    owner = "ipfs";
    repo = "ipfs-cluster";
    sha256 = "ecbe3f6ac5a5429c88ad56af5ac37de9481312a36cde09ccfa2ef76b64a912f0";
    gxSha256 = "fa62adb139a3aac29d151a57224b2f89f269be24125c5a297de5fa6388938914";
    meta.autoUpdate = false;
    excludedPackages = "test";
    nativeBuildInputs = [
      gx-go.bin
    ];
    allowVendoredSources = true;
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
    rev = "v0.18.0";
    sha256 = "8598fee19c0eb7ac5437f1198c206d21e606fed93db3a4184f310601223b2298";
    propagatedBuildInputs = [
      swag
    ];
  };

  jsonreference = buildFromGitHub {
    version = 6;
    owner = "go-openapi";
    repo = "jsonreference";
    rev = "v0.18.0";
    sha256 = "bfe27be1e4e58308e4326e9e560673fdeb6d7f42bbc080d2c35b17c1af1ae397";
    propagatedBuildInputs = [
      jsonpointer
      purell
    ];
  };

  jsonx = buildFromGitHub {
    version = 6;
    owner = "jefferai";
    repo = "jsonx";
    rev = "v1.0.0";
    sha256 = "d0f01205a8dcb17c8efa265503917f37eac54c8fce6559c359e3ef889df690cc";
    propagatedBuildInputs = [
      gabs
    ];
  };

  jwalterweatherman = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "94f6ae3ed3bceceafa716478c5fbf8d29ca601a1";
    sha256 = "0991020bb0df31bf8a25fd010920b836028b47df4434a06ba2dff4319a90df02";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
    meta.useUnstable = true;
    date = "2018-10-28";
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
    rev = "742f2714c145075a68df26ccc25bc05545310f3a";
    owner = "gravitational";
    repo = "kingpin";
    sha256 = "5adaee68b5b3b7845cd9d3cba43bc18a435dd0cad4d35cb082112a633fc35ca7";
    propagatedBuildInputs = [
      template
      units
    ];
    meta.useUnstable = true;
    date = "2019-01-30";
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
    rev = "v0.8.0";
    owner = "go-kit";
    repo = "kit";
    sha256 = "W0VZXFNnUF8xQY4vJMYbaSEaRnyQKhxj5RsnAPR0Shs=";
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
    rev = "35c66765f3ca7e0c4a7972e4a2ad3c9753361819";
    owner  = "kubernetes";
    repo   = "api";
    sha256 = "51f5287e76e3b56d13438080192f44820feede6e6ba31b225444de2afc8a17d7";
    goPackagePath = "k8s.io/api";
    propagatedBuildInputs = [
      gogo_protobuf
      kubernetes-apimachinery
    ];
    meta.useUnstable = true;
    date = "2019-02-19";
  };

  kubernetes-apimachinery = buildFromGitHub {
    version = 6;
    rev = "f05b8decd79cf55449e1e5b2cc9f14496ba6b942";
    owner  = "kubernetes";
    repo   = "apimachinery";
    sha256 = "6a5e4c10a3c18ce9a74f6af61dcab0b8b8c0a9ab749252a3b6a5a79e373697d8";
    goPackagePath = "k8s.io/apimachinery";
    excludedPackages = "\\(testing\\|testapigroup\\|fuzzer\\)";
    propagatedBuildInputs = [
      glog
      gofuzz
      go-flowrate
      go-spew
      golang-lru
      kubernetes-klog
      kubernetes-kube-openapi
      kubernetes-yaml
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
    date = "2019-02-16";
  };

  kubernetes-kube-openapi = buildFromGitHub {
    version = 6;
    rev = "ea82251f3668f8c1bde607fa6e20e5bf36e576a4";
    date = "2019-02-15";
    owner  = "kubernetes";
    repo   = "kube-openapi";
    sha256 = "4cd7c9491ca4dbab3675e0b1a7639e76a986b1a563bacc765d7f30e39ed93896";
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
    rev = "0c67a1f23ff9b6db00723652c1c45cdff65b5591";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "2d8d46e296e88265efa38cede22e9e42caf6d5d1b9a09d54ae387fa13aa8e031";
    goPackagePath = "k8s.io/client-go";
    excludedPackages = "\\(test\\|fake\\)";
    propagatedBuildInputs = [
      crypto
      diskv
      gnostic
      go-autorest
      go-spew
      gophercloud
      groupcache
      httpcache
      kubernetes-api
      kubernetes-apimachinery
      kubernetes-klog
      kubernetes-utils
      mergo
      net
      oauth2
      pflag
      protobuf
      time
    ];
    meta.useUnstable = true;
    date = "2019-02-19";
  };

  kubernetes-klog = buildFromGitHub {
    version = 6;
    rev = "4265a957921369ee7dc18b400a1f2bfee30553f4";
    owner  = "kubernetes";
    repo   = "klog";
    sha256 = "166a7e4301123c13f8a52cc9cb7f1c25595644aa9519bc420b80cbe0f22b3e6e";
    goPackagePath = "k8s.io/klog";
    meta.useUnstable = true;
    date = "2019-02-13";
    propagatedBuildInputs = [
      logr
    ];
  };

  kubernetes-utils = buildFromGitHub {
    version = 6;
    rev = "cdba02414f767c89d729b1b9e61d9891f4e82b35";
    owner  = "kubernetes";
    repo   = "utils";
    sha256 = "253bf73d0e667e6ced927010705a576b0f151aaa3dfe8d715a17567fb037c276";
    goPackagePath = "k8s.io/utils";
    meta.useUnstable = true;
    date = "2019-02-12";
    propagatedBuildInputs = [
      go-spew
      kubernetes-klog
    ];
  };

  kubernetes-yaml = buildFromGitHub {
    version = 6;
    rev = "199c9c29c4e4f08dc72163605467ab691a004022";
    owner  = "kubernetes-sigs";
    repo   = "yaml";
    sha256 = "2caf828852f06772591ba2d07dab489de3eb235b81e029623cc10ece09aeedb8";
    goPackagePath = "sigs.k8s.io/yaml";
    meta.useUnstable = true;
    date = "2019-02-04";
    propagatedBuildInputs = [
      yaml_v2
    ];
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
    rev = "v3.0.1";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "81069caf1f2756589644eda3a67c9194741b835a16bb1898ad6f74b2146ceff3";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [
      asn1-ber_v1
    ];
  };

  ledisdb = buildFromGitHub {
    version = 6;
    rev = "becf5f38d37357a670b491d3795714ad0056893f";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "mB+BVncFYUahmw5uNqPzBHK8Sobm7vvO0RudQPbbjC0=";
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
    date = "2018-10-29";
  };

  lego = buildFromGitHub {
    version = 6;
    rev = "v2.1.0";
    owner = "xenolf";
    repo = "lego";
    sha256 = "16c09a6ac809fbe8a90442ff8e15a1a24df2e9b7b2d410ec7326bd43d3b2b92c";
    buildInputs = [
      #akamaiopen-edgegrid-golang
      #auroradnsclient
      aws-sdk-go
      #azure-sdk-for-go
      urfave_cli
      crypto
      dns
      dnspod-go
      dnsimple-go
      #go-autorest
      go-jose_v2
      go-ovh
      google-api-go-client
      linode
      #memcache
      #namedotcom_go
      ns1-go_v2
      oauth2
      net
      #testify
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
    rev = "d8d4c8cf03d7d036a76d5470553cd8753e522a99";
    owner = "docker";
    repo = "libnetwork";
    sha256 = "d37ae601db2d00d23069200d8b7543e315dd651134851ce5473f650ae165e751";
    date = "2019-01-28";
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
    rev = "9b91929be50d62b6748357e9cf8359d7a948abd5";
    owner  = "peterhellberg";
    repo   = "link";
    sha256 = "f8e04f99769364a6b59b27f1008ec0ad7370e601a7fa0c1384dbf7a63f763729";
    date = "2019-01-24";
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
    rev = "v0.4.0";
    owner  = "go-logfmt";
    repo   = "logfmt";
    sha256 = "MrFpoHJEaFCV6y1AnoZq3JpbRHCCBpwey08GwhE74Io=";
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

  logr = buildFromGitHub {
    version = 6;
    rev = "v0.1.0";
    owner = "go-logr";
    repo = "logr";
    sha256 = "7f684c49883c48985e9f5bb14f2df2f470f73d6c8e171b936a9004590e584850";
  };

  logrus = buildFromGitHub {
    version = 6;
    rev = "cdb2f3857cfba7388d28dfe38316b0a39e694215";
    owner = "sirupsen";
    repo = "logrus";
    sha256 = "c9303e3939aa286a4632bd5bbcd6da29fed54792d68e478f951ee78a17ca3ae0";
    goPackageAliases = [
      "github.com/Sirupsen/logrus"
    ];
    propagatedBuildInputs = [
      crypto
      go-windows-terminal-sequences
      sys
    ];
    excludedPackages = "testutils";
    meta.useUnstable = true;
    date = "2019-02-10";
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
    rev = "lxd-3.9";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "0a1ffa7fc0e5276a16b9a69ec279211a576c737bb838b9c31de2ed3a7f2e3e90";
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
    rev = "v2.0.8";
    owner  = "pierrec";
    repo   = "lz4";
    sha256 = "6ae4a9620e5b97589dfb0db9742e56901372dadfe4915794bacf0237babdc42a";
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
    version = 6;
    rev = "v2.1.0";
    owner  = "go-macaroon";
    repo   = "macaroon";
    sha256 = "2506e0f9a1a6f0c39fe688216929e54e94dd91a14e9985be4ec6a0346b4ddac1";
    goPackagePath = "gopkg.in/macaroon.v2";
    propagatedBuildInputs = [
      crypto
    ];
  };

  macaron_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.3.2";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "a3a1c6aca94285bf04b2916fe556074201b15e92b1ac8c3af2ebde4a9792b585";
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
    rev = "v1.2.8";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "3J8aK1ES7wDP3aQy1uPoBftcfIDrfAWOvxHFKlbrYzc=";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  mail_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.3.1";
    owner = "go-mail";
    repo = "mail";
    sha256 = "18OxsfU5IytdBYrS4liotUrFsOCXEN9odBJqq2Yk5MU=";
    goPackagePath = "gopkg.in/mail.v2";
    propagatedBuildInputs = [
      quotedprintable_v3
    ];
  };

  mage = buildFromGitHub {
    version = 6;
    rev = "v1.8.0";
    owner = "magefile";
    repo = "mage";
    sha256 = "216047ffb02c52f97970273a77ef821e66b550d3771b0a9d40d8368c86cdcf89";
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
    rev = "v1.0.1";
    sha256 = "9MiFmBkpcjxMBaodgw7B0qWCFBwGznsCI00YJQEhjco=";
  };

  maxminddb-golang = buildFromGitHub {
    version = 6;
    rev = "31672ba7a68affbd201a4c909a72a0484fb1a2f0";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "cd77e01308bcd93cd23b45f8b8fd21f6c9a99e38eb57e000da66b07dd745614a";
    propagatedBuildInputs = [
      sys
    ];
    date = "2018-12-20";
  };

  mc = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "mc";
    rev = "57faed27254e54783a3724c450515027ea755ab5";
    sha256 = "968649b21b0dbd7703e78400f149195f7b3322bfcebfccf57a09b38ffac07b20";
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
    date = "2019-02-01";
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
    rev = "v1.0.0";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "d7fae84bbd6d9e9bfde7c8d5c5fbec56f01e77d631a6d90f416a0ff4d4e072a7";
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
    rev = "b38abf62d7f3ce5225722cd62a90cfb098e02519";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "f5aaca154f2a85ffbe7e2e3c34c9e8c9306aa2536f8e89e45d8e9922296be768";
    propagatedBuildInputs = [
      btree
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
      hashicorp_go-sockaddr
      seed
    ];
    meta.useUnstable = true;
    date = "2019-02-04";
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
    rev = "v0.3.7";
    owner = "imdario";
    repo = "mergo";
    sha256 = "b6759d28f12875fdd83dfe1aaa3cf1406986f0de8189b4a4e8dd2f0115235318";
  };

  mesh = buildFromGitHub {
    version = 6;
    rev = "d4a110823e88dfd185768e7eb60c6f3d604cef7c";
    owner = "weaveworks";
    repo = "mesh";
    sha256 = "a4af4d36dd32980676715ff0b11ee281b06bf48df2a9cb2e05d683e6de6d5313";
    date = "2019-01-07";
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
    rev = "v2.3.8";
    sha256 = "5gYILR37k4Mue7hDsWRRxWDvvPNV8koXCCgj5h7Lvuo=";
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
    rev = "32a6dd1dd69aa95463594081f34cbac72bc6002c";
    sha256 = "c005002c996704a863c56ba274eb8d7d29fbbbc41d65d46783232c919c84ca8c";
    propagatedBuildInputs = [
      aliyun-oss-go-sdk
      amqp
      atime
      azure-sdk-for-go
      atomic
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
    date = "2019-02-01";
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
    rev = "c8a261de75c1a9a9ece4dcc0c81ff6db525bcf27";
    sha256 = "acbcd7c6819d7879fc4cf746195c77ff98c48b19990734bdcd25d2c42cb15798";
    propagatedBuildInputs = [
      crypto
      go-homedir
      ini
      net
    ];
    meta.useUnstable = true;
    date = "2019-01-31";
  };

  mint = buildFromGitHub {
    version = 6;
    owner = "bifurcation";
    repo = "mint";
    rev = "824af65410658916142a7600349144e1289f2110";
    sha256 = "6e6694e0b2a58d722f0e99063838894b2fdf6fe99f760f87c214819ef54f26b4";
    date = "2018-11-04";
    propagatedBuildInputs = [
      crypto
      net
    ];
    meta.autoUpdate = false;
  };

  mmap-go = buildFromGitHub {
    version = 6;
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "v1.0.0";
    sha256 = "9cc14700bf87da1e7e01554982b352888fe78b2258743f694d4793171d82c0f5";
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
    rev = "87903f2fb56bc08e8ec0d8b70b988029d08aae55";
    date = "2019-01-31";
    sha256 = "9e8801fa39a902d0b926b39528a4071e4bff8a3db280cff53dd14f0ffb1923f8";
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
    rev = "r4.1.7";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "2223ed2ea332652f8cca3f2390c057987272d70ea502023d928120033f4fc3d1";
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
    rev = "d9c41c7c90d99b076732ee72a657577128d610da";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "cefb8ee95ac213de343764657c00a7973821b3aabf99d937c2a317da0cb03e03";
    date = "2019-01-27";
  };

  ns1-go_v2 = buildFromGitHub {
    version = 6;
    rev = "a57b2a18aab64f935372576088e673f8b7fba967";
    owner  = "ns1";
    repo   = "ns1-go";
    sha256 = "aa9811294014399b03860abeb966e9f8c210864e67dba25c8828f96e185d1126";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2018-12-11";
  };

  msgp = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner  = "tinylib";
    repo   = "msgp";
    sha256 = "0aa9967603a1448720f32a0a6126712b96a44bc804ebdf93b8cd6076a197224c";
    propagatedBuildInputs = [
      fwd
      chalk
      tools
    ];
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
    rev = "v1.7.0";
    owner = "gorilla";
    repo = "mux";
    sha256 = "0a43bf95cac7544b7dab0f4f20d1ac9448edb1259f707d9ac31dd59ed55d0679";
    propagatedBuildInputs = [
      context
    ];
  };

  mysql = buildFromGitHub {
    version = 6;
    rev = "v1.4.1";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "TO8iApg+S0SKkGMySmaJcQXvVNYD7xm9clZ5wn+vCRw=";
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
    rev = "b9cafe4a8544a27110dad06be07d48bbe5f292dd";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "eb50e6fb5eaf9f7990e609f587767db17583e8239446279ecc7674715e913675";
    propagatedBuildInputs = [
      netns
      sys
    ];
    date = "2019-02-06";
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
    rev = "v0.8.7";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "2c38185b82564244baeb3f694531c14a0055e1365c516c52e57c1078bb049fc9";

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
    date = "2018-11-07";
    rev = "4e389ea6c0d84e6195eb585ffaf62c8c143306ae";
    sha256 = "MViEpG5Bt3A+d6ml7A38kkrJDa3g7MsnW4pnUAUAaoA=";
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
    rev = "c61a9dfcced1815e7d40e214d00d1a8669a9f58c";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "0be60ed98d352552fe38e988a19325398711dc22668ffedfac98b861592b6cba";
    date = "2019-02-11";
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
    rev = "3430665dfaa0211a813c56550abf530009b01fb7";
    date = "2018-12-12";
    sha256 = "e58cc3e75bdb570f127892cbf454358592f3254f2b14ac4ed4c85d50845858c2";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  opencensus = buildFromGitHub {
    version = 6;
    owner = "census-instrumentation";
    repo = "opencensus-go";
    rev = "57c09932883846047fd542903575671cb6b75070";
    sha256 = "81334c919f89cc525949e0f21efd7e83112d30f2029b8fd08381fc5c206da3d5";
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
      "plugin/ochttp/propagation/tracecontext"
      "resource"
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
      golang-lru
      grpc
      net
    ];
    meta.useUnstable = true;
    date = "2019-02-14";
  };

  opencensus-exporter-ocagent = buildFromGitHub {
    version = 6;
    owner = "census-ecosystem";
    repo = "opencensus-go-exporter-ocagent";
    rev = "5a6e73f487e155ca74647bf2acdcf88e09133e2a";
    sha256 = "5cc8e430309fd83bc851c897969580bbe9c2f3f5993bdad8e575892a2a18c70f";
    goPackagePath = "contrib.go.opencensus.io/exporter/ocagent";
    propagatedBuildInputs = [
      google-api-go-client
      grpc
      opencensus
      opencensus-proto
      protobuf
    ];
    meta.useUnstable = true;
    date = "2019-02-19";
  };

  opencensus-proto = buildFromGitHub {
    version = 6;
    owner = "census-instrumentation";
    repo = "opencensus-proto";
    rev = "ca9d8b3463d73d67d2aac257cb3bf53a26c353e8";
    sha256 = "a1a70806efb68dfc3792eaf21ca6e771e1d1a6b297bc4e2dac99ed85f4fe05c1";
    propagatedBuildInputs = [
      grpc
      grpc-gateway
      net
      protobuf
    ];
    meta.useUnstable = true;
    date = "2019-02-19";
  };

  open-golang = buildFromGitHub {
    version = 6;
    owner = "skratchdot";
    repo = "open-golang";
    rev = "a2dfa6d0dab6634ecf39251031a3d52db73b5c7e";
    date = "2019-01-04";
    sha256 = "dec5bf65cfb353056422731ef19ad2e2f4a10ac52893307f753f4a7249b33c60";
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
    date = "2019-01-29";
    rev = "fc9a1d560ec3549c695198fe39b9de7f89a7503d";
    owner = "10gen";
    repo = "openssl";
    sha256 = "b5c861cf2592c556759a44da75ec41753a250fb23ad70ceb31df37908a16ad02";
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
    rev = "25a84ff92183e2f8ac018ba1db54f8a07b3c0e04";
    sha256 = "b92071aa3e34cfe7110b288a9c55b9bc7b8fcd0dc78e3a5845c070bbeecf7ae2";
    goPackageAliases = [
      "github.com/frrist/opentracing-go"
    ];
    excludedPackages = "harness";
    propagatedBuildInputs = [
      net
    ];
    date = "2019-02-18";
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
    rev = "v1.1.0";
    owner = "pquerna";
    repo = "otp";
    sha256 = "ef3cde14b777c9bf5073e6cc35ffdfb7c8e4078bc98ea2dee5329cae1a138e20";
    propagatedBuildInputs = [
      barcode
    ];
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
    date = "2019-02-13";
    rev = "caf7bb8cb1044343747215c54e45a01dbb41c8a2";
    sha256 = "9c19c63771b40fdecd3a80bfd3f0870e44dba2d48c1703aa9f07795459e463fa";
  };

  paho-mqtt-golang = buildFromGitHub {
    version = 6;
    owner = "eclipse";
    repo = "paho.mqtt.golang";
    rev = "cb7eb9363b4469c601b1a714447653b720e4e43a";
    sha256 = "1117cc9c56cc312c54fe2cb230e2eb84361c29f5dae88b5d8f7d27b23f591adb";
    propagatedBuildInputs = [
      net
    ];
    date = "2019-01-17";
  };

  parse = buildFromGitHub {
    version = 6;
    owner = "tdewolff";
    repo = "parse";
    rev = "v2.3.5";
    sha256 = "Z4IadvE6clYX8adbS06EM0ve5iGK7IVw1G+hk+0W8Qw=";
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
    date = "2018-12-10";
    rev = "1cc5bbe20449079337944d56292c7383510c534c";
    sha256 = "2VITmhziIuIhR+348CedMqdTtAgaPGGajiqTjCnF61c=";
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
    rev = "v1.0.27";
    sha256 = "dENcHZwT4CgwRoPmpbTqT+TmUUtSogi/Nz9PPKCXSsQ=";
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
    date = "2018-11-18";
    owner  = "xiaq";
    repo   = "persistent";
    rev = "6bf9d6baeece01e175dbca0f906b69cde703004c";
    sha256 = "8b3RXDc9ciCIGfR7yzRPsouNN0SHLa4qbZucn/Kftng=";
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
    rev = "79872a7b27692599b259dc751bed8b03581dd0de";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "11ffad78850d55bfa5f1ed057f432443702e4dc285f34df0cb8f64abb952a722";
    date = "2018-12-25";
    propagatedBuildInputs = [
      juju_errors
    ];
  };

  pprof = buildFromGitHub {
    version = 6;
    rev = "b421f19a5c07fe0eb5b553c4c3d681fdfcb80f26";
    owner  = "google";
    repo   = "pprof";
    sha256 = "a8029784e3e67e2dbc34def743423e53dcf705181e77a32f19ec03bcb9b7d2de";
    date = "2019-02-08";
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
    rev = "0.0.2";
    owner  = "xiang90";
    repo   = "probing";
    sha256 = "8ce6a0ffbb306460fb2a82f34ae921a67e0ba42f6906d52764df028bc7076c64";
  };

  procfs = buildFromGitHub {
    version = 6;
    rev = "e4d4a2206da023361ed100d85c5f2cf9c8364e9f";
    date = "2019-02-19";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "6082b1191527b384254b8aef767bbfdd0d9d285571993f005f6fc0038f24f251";
    propagatedBuildInputs = [
      sync
    ];
  };

  profile = buildFromGitHub {
    version = 6;
    owner = "pkg";
    repo = "profile";
    rev = "22592cc4bae3572d59be8852c6980023e4c9dec5";
    sha256 = "xOdcgC1vS/ZwUYRORy7ZtJeGG0yUPuLlMqsZ6f3+8s0=";
    date = "2018-10-28";
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
    rev = "v2.7.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "021aab815cf1ff1f3cbcc37a2f81797e99d20a1f7d9291edd0fab672412bba5e";
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
    rev = "v0.9.2";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "o0Ne4ssYdQF4pSvt5RsJexmBiT9Y2bWFxxdn7ZTIAQE=";
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
    rev = "fd36f4220a901265f90734c3183c5f0c91daa0b8";
    date = "2019-01-29";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "4db01781a31a9611aff8371c826580055261b475b7c5569624943ccc98d256e1";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 6;
    rev = "v0.2.0";
    owner = "prometheus";
    repo = "common";
    sha256 = "9817bc5ffa19682232eeb8996135685b4e8bf3d10d972e0c0c8859d062855540";
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
    rev = "v0.4.0";
    owner = "prometheus";
    repo = "tsdb";
    sha256 = "30488a2ef01a95b3cf383c218a1733065a7a274c708d58e36f490903f394d01b";
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
    rev = "7757cc9fdb852f7579b24170bcacda2c7471bb6a";
    sha256 = "e8b503a76e15c1539e5f7d49aa2cc20cb456384701292126fb8efc1433bcfb62";
    date = "2019-01-10";
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
    rev = "v1.2.1";
    sha256 = "3aacb732ee91214ec3e16a677fd964f4566d722c3355058269bad57b1df64dd8";
    excludedPackages = "test";
  };

  protoc-gen-validate = buildFromGitHub {
    version = 6;
    owner = "lyft";
    repo = "protoc-gen-validate";
    rev = "v0.0.13";
    sha256 = "d08ef27b568b9dd9f334613f5d5f440ef9db8cfbe307a4901e2b6477d864a873";
    subPackages = [
      "validate"
    ];
    propagatedBuildInputs = [
      protobuf
    ];
  };

  gogo_googleapis = buildFromGitHub {
    version = 6;
    owner = "gogo";
    repo = "googleapis";
    rev = "v1.1.0";
    sha256 = "7BPw7Meyi3kX+rShjnDh5tfljlPbLy9ykA0TUzBt2u0=";
    propagatedBuildInputs = [
      gogo_protobuf
    ];
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
    rev = "v1.1.1";
    sha256 = "430db031ef6762c1d569c01d3eceae8b84e211517d4f295d53ad96473313dbe3";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
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

  quic-go-certificates = buildFromGitHub {
    version = 6;
    rev = "d2f86524cced5186554df90d92529757d22c1cb6";
    owner  = "lucas-clemente";
    repo   = "quic-go-certificates";
    sha256 = "bc83ffb6875d999d72d6e45b3eea8e120e5e4ef8ac8a1cc8b7af655189aead0c";
    date = "2016-08-23";
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
    rev = "0f678f03961722d8a9c8a510eee833eb60d7ec96";
    date = "2019-01-18";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "bd37f01b9217ca2e019d6dcc4500839fc242d2a40a37646b05e64d5b4b40c132";
    goPackagePath = "layeh.com/radius";
  };

  raft = buildFromGitHub {
    version = 6;
    date = "2019-01-04";
    rev = "9c733b2b7f53115c5ef261a90ce912a1bb49e970";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "2b8588bc114ee7cefcd2ace8002a6647bbadb6ebac5aa61e09fe48291882887e";
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
    rev = "v0.2.0";
    owner  = "getsentry";
    repo   = "raven-go";
    sha256 = "jZK5DYj0EGgU/kELxF+vmi4teI9EuCkary74xkcnrCo=";
    propagatedBuildInputs = [
      errors
      gocertifi
    ];
  };

  rclone = buildFromGitHub {
    version = 6;
    owner = "ncw";
    repo = "rclone";
    date = "2019-02-18";
    rev = "8f4ea77c07a1703b93d76439cfa32349501522cd";
    sha256 = "0bd2f086e080fe416813793cb7c8903181addaafb0910459b6b748fe49e49664";
    propagatedBuildInputs = [
      aws-sdk-go
      bbolt
      cgofuse
      cobra
      crypto
      dms
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
      sync
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
    date = "2019-02-19";
    rev = "4632c21b4f9e4bfb9d976ec42c0fdf84cc717f47";
    sha256 = "4f58f59687abc9d3742715a0978080144d29ca278cd7a9d2f2451e031e9523d7";
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
    date = "2018-12-18";
    rev = "8885f3a1c73882e6f11b766242c69a1eb8f44b28";
    sha256 = "d0d37bf4dcc4f5f784a508d8c517622a406862eecf9723b1451bcbff6051f346";
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
    rev = "3f2e299233626d2773c6eae78308bcff5bf618a7";
    sha256 = "d22cbc7e449d5d2227badb9e48fabb9343de62faa2a41f44460fb57acf2ba1f0";
    subPackages = [
      "api/v1"
      "networking/netinfo"
    ];
    propagatedBuildInputs = [
      cni
    ];
    meta.useUnstable = true;
    date = "2019-01-31";
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
    rev = "5b08e7332f981ce85879010363601c2e19696f7f";
    sha256 = "vsU6HImfKEQ61ModGwu08iFiYhTjV+OC8kN8tG2OIiY=";
    date = "2018-10-24";
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
    version = 6;
    rev = "v1.0.0";
    owner = "oklog";
    repo = "run";
    sha256 = "0m6zlr3dric91r1fina1ng26zj7zpq97rqmnxgxj5ylmw3ah3jw9";
  };

  runc = buildFromGitHub {
    version = 6;
    rev = "751f18de2af90495e9c5665b95bfc7adf66ddd57";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "f4647af1465c5c15cf913a59178581a585f9c520b66b6cd89b9656dd7ab268f9";
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
    date = "2019-02-15";
  };

  runtime-spec = buildFromGitHub {
    version = 6;
    rev = "29686dbc5559d93fb1ef402eeda3e35c38d75af4";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "5f85d89ad19d1dd28d650c89992bd417536424f1fc11a38677a3dbeb3458326a";
    buildInputs = [
      gojsonschema
    ];
    date = "2019-02-07";
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
    rev = "v1.0.0";
    sha256 = "893ddf44818cfec38f5a208b9ce05d4d665d16c5187424c6475b0ce75c633e8d";
  };

  sarama = buildFromGitHub {
    version = 6;
    owner = "Shopify";
    repo = "sarama";
    rev = "v1.20.1";
    sha256 = "85dbd8b630cfe3c5ead1909e275de198f0b790eecf9369aa5792d855409ef172";
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
    rev = "v1.20.1";
    sha256 = "c648918d0b6883c98701d565d370aca053376f4d86c5622a7e10472b365a174a";
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
    version = 6;
    owner = "juju";
    repo = "schema";
    rev = "64a6158e90710d0a16c6bd3cf0a6be6b2e80193c";
    sha256 = "0063a6f12718cda7e035291457cf30a5691db34b65e6bab5fb757a2a7ccb1168";
    date = "2018-12-10";
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
    rev = "v1.1";
    owner = "opencontainers";
    repo = "selinux";
    sha256 = "3836c48c75d03789265f67d8e0ac67e6d61a8a2eae2a093792b78b967f563311";
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
    rev = "b89a09ebd4b1b570e0076d5097272e67c10ac4f6";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "7c6b5ed84c8b694f5c1b87acf4208ff5361f811e3dcc90eefa78d56537720b03";

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
    excludedPackages = "depreqs";
    meta.useUnstable = true;
    date = "2019-01-24";
  };

  server = buildFromGitHub {
    version = 6;
    rev = "88de73f463afc77e1410b843e85bde37b5e261eb";
    owner = "goftp";
    repo = "server";
    sha256 = "751843cabac80646ffc52d359a150b021eb9e5f41280ac4b8003acf6685a96ba";
    date = "2019-01-11";
    excludedPackages = "example";
  };

  service = buildFromGitHub {
    version = 6;
    rev = "4c239ee84e7bb93441b1b6a3f2db62d40e0e6cbd";
    owner  = "kardianos";
    repo   = "service";
    sha256 = "5gg15BiBNX8cTHlZqIOhncnH8gZifIfxFQm0NWYlPxY=";
    date = "2018-11-15";
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
    rev = "0a0a789bf1934e55fde19629869caa015a40c525";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "b7982114e20237f09508e3641772b85521a870eec3505b524f62d2554bac23c0";
    date = "2019-01-31";
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
    rev = "v1.10.0";
    sha256 = "5cb38692e216d7a7733e46199ec43ac465511ffd11c399b59030920c152dc352";
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
    date = "2019-01-31";
    rev = "2d45a736cd16732fe6a57563cc20d8b035193e58";
    sha256 = "c3afc51a19dea8fb3cd57c2c7506cc6f2f4e73ff04c575b78e52092222b4f520";
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
    date = "2019-01-18";
    rev = "035b4ef8c449ba2ba21ec143c91964e76a1fb68c";
    owner  = "minio";
    repo   = "sio";
    sha256 = "6ccdc8f7d854ddebb54f7d9d6ae1fb69b200211c5230bfcfdf446b5c33e35d5f";
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
    rev = "v1.4.2";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "8f10dd23bd84c14f074d1aeba2bee31843fe17f7d064ada2ec4f39d698d00f60";
    propagatedBuildInputs = [
      macaron_v1
      unidecode
    ];
  };

  smartcrop = buildFromGitHub {
    version = 6;
    rev = "548bbf0c0965feac4997e1b51c96764f30dba677";
    owner  = "muesli";
    repo   = "smartcrop";
    sha256 = "WdGmrjQiuOMNT0TXWANjjdEU4Nx0fLZCbxdqFJzUoMw=";
    date = "2018-10-30";
    propagatedBuildInputs = [
      image
      resize
    ];
  };

  softlayer-go = buildFromGitHub {
    version = 6;
    date = "2019-01-07";
    rev = "a40f6fdd659fe88efd2020e932905ceb4d496db7";
    owner = "softlayer";
    repo = "softlayer-go";
    sha256 = "806d3005e0c7ad547414f3836c3bc00c559a5838558d32b982969e8893ffcd93";
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
    rev = "6480d4af844c189cf5dd913db24ddd339d3a4f85";
    owner = "docker";
    repo = "spdystream";
    sha256 = "MOfBkwZl5karQLmqlamo8/5S3jIVxxLzrv2+Wm5iCis=";
    date = "2018-10-23";
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
    rev = "v0.18.0";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "9824a012b625923e3be7ee4f4a283a2e53146569d98bc267b326cbbbae5bd36c";
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
    rev = "a7658810eb745c2f22927282dea478278103a897";
    date = "2019-01-25";
    owner  = "gin-contrib";
    repo   = "sse";
    sha256 = "7e30edb0ba9f54bbbf84a78a3d073798f524c3afc5af28a573eaea1c93897155";
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
    rev = "v0.5.0";
    owner = "montanaflynn";
    repo = "stats";
    sha256 = "9533704900e34792cc733e198cd0d17ebc39e505d8f282e61d5af301dd7f277c";
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
    rev = "v3.0.2";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "9432e9491fe2fbde2fec18979cc3c713a9217dc01445e2d87aa6816905c8e178";
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
    rev = "v0.18.0";
    owner = "go-openapi";
    repo = "swag";
    sha256 = "5c6ea44cd87da0712f2df33f7e46e66f9550e17c1328064efa01e92952b84198";
    propagatedBuildInputs = [
      easyjson
      yaml_v2
    ];
  };

  swarmkit = buildFromGitHub {
    version = 6;
    rev = "1a0ebd43b2d156983a695f90e56f4ecba6ced902";
    owner = "docker";
    repo = "swarmkit";
    sha256 = "2b49765910d5af928e26667e08bbd2480fa03ffc99d77ecae19a4a3df559ac78";
    date = "2019-01-31";
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
    rev = "v1.0.44";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "f87f1d2b8e48a5f7065e7dfa9e7d4811f9c5b87975a75f4488ce793b3cc8095b";
  };

  syncthing = buildFromGitHub rec {
    version = 6;
    rev = "v1.0.0";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "ea9412f1b50322dffa08745f0c2a848c59012de3868ba659e589de77293c7251";
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
    rev = "v0.0.1";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "1TcgVJmIeBceIoGjqDGug2LIvsRlrGDUqfRRquTbm6c=";
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
    rev = "02980233997d87bbda048393d47b4d453f7a398d";
    date = "2019-01-21";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "bf911ceeebdef148936900d51b06fff86000ff7228cb63e48f03b7936f77899c";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 6;
    rev = "v1.3.0";
    owner = "stretchr";
    repo = "testify";
    sha256 = "0e5855420443abba9b41145abd24f40b951b428f696bc62a19e13a16deed171f";
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
    rev = "v0.12.0";
    owner  = "apache";
    repo   = "thrift";
    sha256 = "ec5aa18eb72e78303d683490ca0b21345c6b7216bc52c501921175325dd9788f";
    subPackages = [
      "lib/go/thrift"
    ];
    propagatedBuildInputs = [
      net
    ];
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
    rev = "v1.2.0";
    owner  = "djherbis";
    repo   = "times";
    sha256 = "d8baa201222603fda9696b827806b101b67493a017695b37d41bb641ee509588";
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
    rev = "6a0b80129de45f91880d18428b95fab29df91d7e";
    owner  = "a8m";
    repo   = "tree";
    sha256 = "d832b3f9163bf205a6ca256b01d3282b7ab25b4002260e14958c8d776ea8727d";
    date = "2018-12-22";
  };

  treeprint = buildFromGitHub {
    version = 6;
    rev = "a009c3971eca89777614839eb7f69abed3ea3959";
    owner  = "xlab";
    repo   = "treeprint";
    sha256 = "8ZdFTsVKqOzc/mdVvfiJCNPUFj6qZImC4Fh4bwW5XUs=";
    date = "2018-11-12";
  };

  triton-go = buildFromGitHub {
    version = 6;
    rev = "51ffac55286911651992b9327fb9c8a7e9aae665";
    owner  = "joyent";
    repo   = "triton-go";
    sha256 = "441dd954e034c36e916a739c9ae76c1fe107b2d3511ee9c8e4a3b1b090f1fef5";
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
    date = "2019-01-12";
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
    rev = "v1.1.0";
    owner = "google";
    repo = "uuid";
    sha256 = "+mq9CzgLZX+BM2/7Ozq4YTTBTvBGtN+VGCuI5J8zIzU=";
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
    rev = "v1.0.3";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "3a1ad539d0564af7f0ccc594066dd34e1cff64d976be21ee70762a6a85b09ebf";

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
    rev = "4c0b46069a2293d5a6ca7506c8d3e0c4a92f3dbc";
    sha256 = "DLrZ+vxdT1zJydzgDUmhRm2I1CSYPqXElhil2/J6/qQ=";
    date = "2018-12-07";
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
    rev = "4d63bbfe6fcf0363a2ea2c273846e88b95d85089";
    sha256 = "71430df1c937aa18cb0948ec0a6c5395b87c29d68b80986427064583ba66cc29";
    date = "2018-12-10";
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
    rev = "091d9e5d5fabce920533eff31ad778778992a671";
    sha256 = "Ng/aj0kS0HiI1YVDopi1XtjM/VsO1j1278rK4VTlgDM=";
    date = "2018-11-30";
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
    rev = "v1.5.0";
    sha256 = "660e52e2ee6872f4b49701f69a90e4e893f4d052751ebedd8beb3a0e6a0aac33";
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
    rev = "v1.3.1";
    sha256 = "qdi+ZuqQ8b+4npvwhj4xeQPcCJDQbzn6MrmAJxjD0uM=";
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
    rev = "882c666acc57cfc9fb3ccd8132655609092eb4af";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "6538541b64f53e920c55f4e2c7f51b169592026637fdf41fe02fa474765714ca";
    propagatedBuildInputs = [
      crypto
      mow-cli
      ratelimit
    ];
    date = "2018-12-27";
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
    rev = "e0a55b97c70558c92ce14085e41b35a894e93d3d";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "dc59c236deb8d77402a2ce12a10043b6343aa20d7e29e62e4bc4da0aa2e3c9fc";
    buildInputs = [
      go-ole
    ];
    date = "2018-12-12";
  };

  yaml = buildFromGitHub {
    version = 6;
    rev = "25d852aebe32c875e9c044af3eef9c7dc6bc777f";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "3e490638a8788f02b7895f2f91a989b2cd1259934210bf687744b0718ef9146b";
    propagatedBuildInputs = [
      yaml_v2
    ];
    date = "2019-02-12";
  };

  yaml_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.2.2";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "VMTehpEiY9xZJ3meFj41dRQ3vsK4AA5I7QdCkR9og2E=";
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
    rev = "v0.4.0";
    owner  = "pkg";
    repo   = "xattr";
    sha256 = "WXQ2ufsqGoJ6JEWeh73cqnNLVscBOhaUH8ArY0GjllQ=";
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
    rev = "v0.7.1";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "qnrztrO6xkfvSfwuJkHzbNk1SnWH8wDDQ7ZElXLXfuU=";
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
    rev = "v2.0.0";
    owner  = "cespare";
    repo   = "xxhash";
    sha256 = "d3b9fdf83a8f8725bb5b985db33ed89dbba65fbb02e073f8dd35dc1dbd885df3";
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
    rev = "v0.5.5";
    owner  = "ulikunitz";
    repo   = "xz";
    sha256 = "rOexv21Vg+ldc1IFx+Yw1cod0QMT5oLniEAFinGI+Z4=";
  };

  zap = buildFromGitHub {
    version = 6;
    rev = "d2a364dac1d9b70c651d9f47381c5912361e5596";
    owner  = "uber-go";
    repo   = "zap";
    sha256 = "87550151bd331737a03cd96ca93cc13fd8b7a30c72f68de8165a1aaf59dfae63";
    goPackagePath = "go.uber.org/zap";
    goPackageAliases = [
      "github.com/uber-go/zap"
    ];
    propagatedBuildInputs = [
      atomic
      multierr
    ];
    date = "2019-02-15";
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
    rev = "v0.3.5";
    owner  = "openzipkin";
    repo   = "zipkin-go-opentracing";
    sha256 = "51ce1afd288583d9667060c6dca3a0cd1488c53d4eb55f2cd8d444588eadee74";
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
