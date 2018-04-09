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

      gx --verbose install --global

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
    rev = "ad39d7fab7c60b2493fdc318c3d2cdb2128f92a4";
    owner = "golang";
    repo = "appengine";
    sha256 = "1h53si54p23zb3xli2r295nlv5m64b27dk5gbj8q21dd6ys4gh0n";
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
    date = "2018-03-29";
  };

  build = buildFromGitHub {
    version = 6;
    rev = "d742befa4d77dfd9df38a87d5d0fc1ee138ccf3f";
    date = "2018-04-02";
    owner = "golang";
    repo = "build";
    sha256 = "03q56497nm4nrinpm2nxaf1dyz7n6k2av4r688h8iy3n2cylg0hv";
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
    rev = "12892e8c234f4fe6f6803f052061de9057903bb2";
    date = "2018-03-30";
    owner = "golang";
    repo = "crypto";
    sha256 = "1yq5iwf7isia31xjfc0zz5qjg82iq8sidqhbligqf0gxgmc4rn39";
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
    rev = "cfd153439062f213d135e4c340ef07ca3e0f34ba";
    date = "2018-03-27";
    owner = "golang";
    repo = "debug";
    sha256 = "17cmnrixx5yagayifi3nicz757zrsmn4ff936rl5h959qzqmw4yy";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
  };

  exp = buildFromGitHub {
    version = 6;
    rev = "8460e604b9de9da5834c9f198cadf9dca4b05cac";
    owner = "golang";
    repo = "exp";
    sha256 = "06cwid9f8f24aijp85nki8m5ajs0lwjxqq5d19kmhr12m71z24l5";
    date = "2018-03-21";
    goPackagePath = "golang.org/x/exp";
    subPackages = [
      "ebnf"
    ];
  };

  geo = buildFromGitHub {
    version = 5;
    rev = "fb250ae94fbe10f86b4f1a9b70a19925da3410b9";
    owner = "golang";
    repo = "geo";
    sha256 = "1dc9a0w8k8id8d0h35ns1ijxigbcj0qgd0wcbhi7xxr6r8hadwv7";
    date = "2018-03-12";
  };

  glog = buildFromGitHub {
    version = 3;
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-26";
    owner = "golang";
    repo = "glog";
    sha256 = "15jy6gcnn4cq6r56nbxja1yn662q7qaj6n6ykzsz3hykql5j8h11";
  };

  image = buildFromGitHub {
    version = 5;
    rev = "f3a9b89b59def9194717c1d0bd4c0d08fa1afa7b";
    date = "2018-03-14";
    owner = "golang";
    repo = "image";
    sha256 = "0sr3l3y064jlnfz32ha1scd3fgaykxmwgkyc081lf72lnz9zahby";
    goPackagePath = "golang.org/x/image";
    propagatedBuildInputs = [
      text
    ];
  };

  net = buildFromGitHub {
    version = 6;
    rev = "b68f30494add4df6bd8ef5e82803f308e7f7c59c";
    date = "2018-03-30";
    owner = "golang";
    repo = "net";
    sha256 = "0cki85k2l9xv2c96kx7y95zq1zvfav0kp0f0lrcljxsp200c1mj5";
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
    version = 5;
    rev = "fdc9e635145ae97e6c2cb777c48305600cf515cb";
    date = "2018-03-14";
    owner = "golang";
    repo = "oauth2";
    sha256 = "0b76r2g4f8axyjhi7g6wzda7fs834agaggbm8mb7qvvlp92nmnlp";
    goPackagePath = "golang.org/x/oauth2";
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };

  protobuf = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner = "golang";
    repo = "protobuf";
    sha256 = "1mif0cx6gi9308nyr935s8d564w2m6v012h3qflhi0jnzg3dmgx9";
    goPackagePath = "github.com/golang/protobuf";
    excludedPackages = "test";
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
    version = 5;
    rev = "1d60e4601c6fd243af51cc01ddf169918a5407ca";
    date = "2018-03-14";
    owner  = "golang";
    repo   = "sync";
    sha256 = "1msv6dknh2r4z6lak7fp877748374wvcjw41x1ndxzjqvdqh1bgx";
    goPackagePath = "golang.org/x/sync";
    propagatedBuildInputs = [
      net
    ];
  };

  sys = buildFromGitHub {
    version = 6;
    rev = "378d26f46672a356c46195c28f61bdb4c0a781dd";
    date = "2018-03-29";
    owner  = "golang";
    repo   = "sys";
    sha256 = "0hzmj20asx5j8f2k7kszq4mz84qpxphmq1v068m67mza5bv79f9k";
    goPackagePath = "golang.org/x/sys";
  };

  text = buildFromGitHub {
    version = 5;
    rev = "v0.3.0";
    owner = "golang";
    repo = "text";
    sha256 = "0jh3hnpnnp61h2p2sk1kq804m6iaxqsnrnllvxws4ni8k0rqp8cy";
    goPackagePath = "golang.org/x/text";
    excludedPackages = "\\(cmd\\|test\\)";
    buildInputs = [
      tools_for_text
    ];
  };

  time = buildFromGitHub {
    version = 5;
    rev = "26559e0f760e39c24d730d3224364aef164ee23f";
    date = "2018-03-14";
    owner  = "golang";
    repo   = "time";
    sha256 = "1aiq4glbjd0xlrcr4gp39xdy70ni4f86ak1pyfr50dl33wqb0qdw";
    goPackagePath = "golang.org/x/time";
    propagatedBuildInputs = [
      net
    ];
  };

  tools = buildFromGitHub {
    version = 6;
    rev = "ac136b6c2db7c4d43955e4bc7174db36dc0539c0";
    date = "2018-04-01";
    owner = "golang";
    repo = "tools";
    sha256 = "0vkbwh9c74182f4cy4phj371vhrrzdll8nzkyi4zy7jbw8xv6538";
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

  tools_for_text = tools.override {
    buildInputs = [ ];
    subPackages = [
      "go/ast/astutil"
      "go/buildutil"
      "go/loader"
    ];
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
    meta.autoUpdate = false;
    propagatedBuildInputs = [
      hashland_for_aeshash
    ];
  };

  afero = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "afero";
    rev = "v1.1.0";
    sha256 = "1vrqjw92044nf3zlzipsqys18jcmmwxr263w311dhs0nqv33ndp6";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  alertmanager = buildFromGitHub {
    version = 6;
    owner = "prometheus";
    repo = "alertmanager";
    rev = "v0.14.0";
    sha256 = "0fsgsv15xz4i27ppwcjrra8sby6a8myl5nhkh9x8y4gkakmk8pv6";
    propagatedBuildInputs = [
      backoff
      errors
      golang_protobuf_extensions
      satori_go-uuid
      kingpin
      kit
      mesh
      net
      oklog
      prometheus_pkg
      prometheus_common
      prometheus_client_golang
      gogo_protobuf
      cespare_xxhash
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
    rev = "39745192ce9045d198ca2003b493ea29b3f7d9d3";
    date = "2018-03-30";
    sha256 = "1v99ihwld0dkh7zvyjkw4k1h4z3iwb4sfxnrlfs84sqpfr2wfqx9";
    propagatedBuildInputs = [
      protobuf
    ];
  };

  aliyun-oss-go-sdk = buildFromGitHub {
    version = 6;
    rev = "1.8.0";
    owner  = "aliyun";
    repo   = "aliyun-oss-go-sdk";
    sha256 = "06bk77jxdr2k5f0ix45ag5chvp3pqga6adb75ca6zlppds6r5g5v";
  };

  amber = buildFromGitHub {
    version = 3;
    owner = "eknkc";
    repo = "amber";
    rev = "cdade1c073850f4ffc70a829e31235ea6892853b";
    date = "2017-10-10";
    sha256 = "0mhwv2l4dmj384ly0kb4rnyksz33h0c8drqxbhzvmhxvbb2qrglc";
  };

  amqp = buildFromGitHub {
    version = 5;
    owner = "streadway";
    repo = "amqp";
    rev = "8e4aba63da9fc5571e01c6a45dc809a58cbc5a68";
    date = "2018-03-15";
    sha256 = "0h3dv3wybnllnjm1am4ac7y6kga33sy878cd11xrpmm5l6nmkzsd";
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

  atime = buildFromGitHub {
    version = 6;
    owner = "djherbis";
    repo = "atime";
    rev = "89517e96e10b93292169a79fd4523807bdc5d5fa";
    sha256 = "0m2s1qqcd1j32i4mxfcxm8r087v5rpf2qp5y49wng8i1qk9jmgzc";
    date = "2017-02-15";
  };

  atomic = buildFromGitHub {
    version = 3;
    owner = "uber-go";
    repo = "atomic";
    rev = "v1.3.1";
    sha256 = "14gxdchkiizv0ncrj1fi4ylchhz3c2kvvri1vx11h06r4ydydq5n";
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
    rev = "v1.13.26";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "0gwz0s0la79xaann7pvwrj6hxfcs49vy9aisqidwyyhkm61x7xfa";
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
    rev = "v15.0.0";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "0f32kh53xm0g6k1hi3qaawsbjb1s8vwcw0acf5p3j33ij0s2a4jp";
    subPackages = [
      "storage"
      "version"
    ];
    propagatedBuildInputs = [
      go-autorest
      satori_go-uuid
      guid
    ];
  };

  b = buildFromGitHub {
    version = 5;
    date = "2018-01-15";
    rev = "35e9bbe41f07452a183c517a5fc5f3c9f45eaa0f";
    owner  = "cznic";
    repo   = "b";
    sha256 = "06dpjjcrjx45bkhl29jp4gjh674g01dyhbzcjhyvqald2b3fjzla";
    excludedPackages = "example";
  };

  backoff = buildFromGitHub {
    version = 6;
    owner = "cenkalti";
    repo = "backoff";
    rev = "v2.0.0";
    sha256 = "0pm2q8j2lj5a21b0aqw4n0j7avvzijvf2jpgdxiji1d8yh8znsc5";
    propagatedBuildInputs = [
      net
    ];
  };

  barcode = buildFromGitHub {
    version = 5;
    owner = "boombuler";
    repo = "barcode";
    rev = "3c06908149f740ca6bd65f66e501651d8f729e70";
    sha256 = "0mjyx8s76n4xzmmqfp2hr7sa1hlafvcigxfhil31ck8b9di0g5za";
    date = "2018-03-15";
  };

  base32 = buildFromGitHub {
    version = 3;
    owner = "whyrusleeping";
    repo = "base32";
    rev = "c30ac30633ccdabefe87eb12465113f06f1bab75";
    sha256 = "1q1z4zqmdbrjy61vbc28k01acdyrg9r0i095yf7q07c9xb5jffg7";
    date = "2017-08-28";
  };

  base58 = buildFromGitHub {
    version = 5;
    rev = "c1bdf7c52f59d6685ca597b9955a443ff95eeee6";
    owner  = "mr-tron";
    repo   = "base58";
    sha256 = "0c7w1kif0vw68617ac7hsaxlq5v2s71byhd0wxjmvirkyi447jjx";
    date = "2017-12-18";
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
    version = 3;
    owner = "alecthomas";
    repo = "binary";
    rev = "6e8df1b1fb9d591dfc8249e230e0a762524873f3";
    date = "2017-11-01";
    sha256 = "142c56kfyivib7z9bpfdh2qc2kmhwh03fypxxv60wz7l6idr6jrw";
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
    version = 6;
    owner = "russross";
    repo = "blackfriday";
    rev = "v1.5.1";
    sha256 = "959a36690c3687eed66672cd7befecd88dd3a3fa7e84ce2b6387288894ebcdfa";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
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
    rev = "af9db2027c98c61ecd8e17caa5bd265792b9b9a2";
    owner  = "coreos";
    repo   = "bbolt";
    sha256 = "0zwkc4sjxvi19qhfyq4lbmq8lxqjbqwhlylfgh52b6r32mlavpwg";
    date = "2018-03-18";
    buildInputs = [
      sys
    ];
  };

  bolt = buildFromGitHub {
    version = 5;
    rev = "fd01fc79c553a8e99d512a07e8e0c63d4a3ccfc5";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "05ma1sn604hs6smr8alzx6nfzfi289ixxzknj0p73miwdfpz9299";
    buildInputs = [
      sys
    ];
    date = "2018-03-02";
  };

  btcd = buildFromGitHub {
    version = 5;
    owner = "btcsuite";
    repo = "btcd";
    date = "2018-02-20";
    rev = "2be2f12b358dc57d70b8f501b00be450192efbc3";
    sha256 = "0pqvncwzx3nsx39a7ch0qqwyfjs9l2n6j4lkkzfh688d1818y7ba";
    subPackages = [
      "btcec"
    ];
  };

  btree = buildFromGitHub {
    version = 5;
    rev = "e89373fe6b4a7413d7acd6da1725b83ef713e6e4";
    owner  = "google";
    repo   = "btree";
    sha256 = "0z6w5z9pi4psvrpami5k65pqg7hnv3gykzyw82pr3gfa2vwabj3m";
    date = "2018-01-24";
  };

  builder = buildFromGitHub {
    version = 6;
    rev = "a9b7ffcca3f0c6445c4e3b1bf72c01578817a6c3";
    owner  = "go-xorm";
    repo   = "builder";
    sha256 = "10q3205lydfm7vdykrgc3rpc8yqsxl06p4gykkws2g6dwzw6sd82";
    date = "2018-03-22";
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
    version = 3;
    date = "2014-06-18";
    rev = "567b2bfa514e796916c4747494d6ff5132a1dfce";
    owner  = "go-bufio";
    repo   = "bufio";
    sha256 = "16brclx5znbfx7h9ny47j1d3dsxvq9w0g4qww8hdlig1hyarqy0n";
    goPackagePath = "gopkg.in/bufio.v1";
  };

  bytefmt = buildFromGitHub {
    version = 5;
    date = "2018-01-08";
    rev = "b31f603f5e1e047fdb38584e1a922dcc5c4de5c8";
    owner  = "cloudfoundry";
    repo   = "bytefmt";
    sha256 = "0lfh31x7h83xhrr1l2rcs6r021d1cizsrzy6cpi5m7yhsgk8c2vj";
    goPackagePath = "code.cloudfoundry.org/bytefmt";
    goPackageAliases = [
      "github.com/cloudfoundry/bytefmt"
    ];
  };

  cachecontrol = buildFromGitHub {
    version = 5;
    owner = "pquerna";
    repo = "cachecontrol";
    rev = "525d0eb5f91d30e3b1548de401b7ef9ea6898520";
    date = "2018-03-06";
    sha256 = "1ncpir8cj55s5qs2ss9y4w9ch4q9blnvsy1i4sc73g6kmsd0bxma";
  };

  cascadia = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner  = "andybalholm";
    repo   = "cascadia";
    sha256 = "16xpfqiazm9xjmnrhp63dwjhkb3rpcwhzmcjvjlkrdqwc5pflqk3";
    propagatedBuildInputs = [
      net
    ];
  };

  cast = buildFromGitHub {
    version = 5;
    owner = "spf13";
    repo = "cast";
    rev = "v1.2.0";
    sha256 = "0kzhnlc6iz2kdnhzg0kna1smvnwxg0ygn3zi9mhrm4df9rr19320";
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
    version = 3;
    owner = "whyrusleeping";
    repo = "cbor";
    rev = "63513f603b11583741970c5045ea567130ddb492";
    sha256 = "1xx3k25pywx3rbijfx6lgm8spzralm619cl3pk1ijpz2s265y0ld";
    date = "2017-10-05";
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
    version = 6;
    owner = "google";
    repo = "certificate-transparency-go";
    rev = "6a268963d0b18a8eceaa1b39e6b58fafb1aa29a1";
    date = "2018-03-29";
    sha256 = "0gibzd8x4hyx86ls9284m5h7bzgq6akzkkps5410gd4qqvyppz8g";
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
    rev = "1.3.2";
    owner  = "cloudflare";
    repo   = "cfssl";
    sha256 = "10bs7zd9nfmpjssa2smwfy17dis4dcdb27mbc55fprqyfzx7fysn";
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
    rev = "v1.0.4";
    owner  = "billziss-gh";
    repo   = "cgofuse";
    sha256 = "1s7hj5qglfvxn89zvh29zvi1qlv245dwyxmz64siwd4r5nzgaxk8";
    buildInputs = [
      pkgs.fuse_2
    ];
  };

  chacha20 = buildFromGitHub {
    version = 6;
    rev = "e0d4ab3067da29fbce5b60445bed6d54c41c3c62";
    owner  = "aead";
    repo   = "chacha20";
    sha256 = "1vxr3rw1j56npmr2asd824pm9zm6cyn9llg4l804nb8j14lzixrg";
    date = "2018-03-25";
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
    version = 6;
    rev = "51d250fe8b89b78eab66df76070df6cc78f54641";
    owner  = "alecthomas";
    repo   = "chroma";
    sha256 = "15sgxwlr8a9xh8xxgvbnx4a8i80p51rzl0imwz2zkc4qwy8bh3gc";
    excludedPackages = "cmd";
    propagatedBuildInputs = [
      fnmatch
      regexp2
    ];
    meta.useUnstable = true;
    date = "2018-04-02";
  };

  circbuf = buildFromGitHub {
    version = 3;
    date = "2015-08-27";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "1g4rrgv936x8mfdqsdg3gzz79h763pyj03p76pranq9cpvzg3ws2";
  };

  circonus-gometrics = buildFromGitHub {
    version = 5;
    rev = "v2.1.1";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "0sfp3x7h7pzf21cwcvh00f2fbrynxmdbgwp0g9xwc8720c2j0f95";
    propagatedBuildInputs = [
      circonusllhist
      errors
      go-retryablehttp
      httpunix
    ];
  };

  circonusllhist = buildFromGitHub {
    version = 5;
    date = "2018-01-04";
    rev = "1e65893c445875524c5610f2a58aef24e30ef98a";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "13xwxbkr8zrmzkgayds4qs61vn06bd8g32fw1yk320zis0a9kxvr";
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
    version = 6;
    date = "2018-03-28";
    rev = "eb4a4fe9b91c2b1f04a90c2f165521d55fad53dd";
    owner = "docker";
    repo = "cli";
    sha256 = "1q86cwn21m0jryf2v1dlcn7q9f07wip16vkk6zhp76nsr5x3f39k";
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
      moby_lib
      go-units
    ];
  };

  mitchellh_cli = buildFromGitHub {
    version = 5;
    date = "2018-03-16";
    rev = "b068abc08c994321eafd9fd500d0704cb6defcb1";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "0vwnmsgk3jac8zfbxcfy5mswf9z0rhakz6hbi07ypyhyk2iwp6p2";
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
    version = 3;
    owner = "benbjohnson";
    repo = "clock";
    rev = "7dc76406b6d3c05b5f71a86293cbcf3c4ea03b19";
    date = "2016-12-15";
    sha256 = "14b21633wnja9rc8ygk17aqil0z3sda82ljwwvnikb48nhjy792a";
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
    version = 2;
    rev = "v0.1.0";
    owner = "jonboulle";
    repo = "clockwork";
    sha256 = "1hwdrck8k4nxdc0zpbd4hbxsyh8xhip9k7d71cv4ziwlh71sci5g";
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
    version = 3;
    rev = "cb4cd0e12ce960e860bebf9ac4a13b68908039e9";
    owner = "containernetworking";
    repo = "cni";
    sha256 = "c34627f605fd58904fcd56baeb05fb7170017475581cddabd2e3b0fe22dfccb9";
    subPackages = [
      "pkg/types"
    ];
    meta.autoUpdate = false;
  };

  cobra = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "cobra";
    rev = "4dab30cb33e6633c33c787106bafbfbfdde7842d";
    sha256 = "03fny5s8d01r7ghjx86nfbdh9qdnp4mwhkwk5fi1y0f2lrfm2h18";
    propagatedBuildInputs = [
      go-homedir
      go-md2man
      mousetrap
      pflag
      viper
      yaml_v2
    ];
    meta.useUnstable = true;
    date = "2018-03-31";
  };

  cockroach = buildFromGitHub {
    version = 6;
    rev = "v1.1.7";
    owner  = "cockroachdb";
    repo   = "cockroach";
    sha256 = "0lxcnvnd9fl6ddh7g683agp3z6i3rqcy1r4djsv0ywp1fyx5y9pr";
    subPackages = [
      "pkg/util/httputil"
      "pkg/util/protoutil"
      "pkg/util/syncutil"
    ];
    propagatedBuildInputs = [
      errors
      go-deadlock
      grpc-gateway
      gogo_protobuf
    ];
  };

  cockroach-go = buildFromGitHub {
    version = 5;
    rev = "59c0560478b705bf9bd12f9252224a0fad7c87df";
    owner  = "cockroachdb";
    repo   = "cockroach-go";
    sha256 = "1jfjmgaslclzkswn9phdxp30kmyhzkxyd1d9dcpwcri9r1bkygkg";
    date = "2018-02-12";
    propagatedBuildInputs = [
      pq
    ];
  };

  color = buildFromGitHub {
    version = 5;
    rev = "v1.6.0";
    owner  = "fatih";
    repo   = "color";
    sha256 = "15hz4n6x4avca02gr0kr19qkicdvlmw1dxzswgv763nh4pfb1chh";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
    ];
  };

  colorstring = buildFromGitHub {
    version = 3;
    rev = "8631ce90f28644f54aeedcb3e389a85174e067d1";
    owner  = "mitchellh";
    repo   = "colorstring";
    sha256 = "1x6mlyhpxkl8r3h4nafnv0k9wxm9csqdgd8msmyz00ahpxwga3k7";
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
    version = 5;
    rev = "v1.1.1";
    owner  = "posener";
    repo   = "complete";
    sha256 = "0bb2bkclyszbpyf59rcyzl1h3nr8kra956145jz8qyibk7vpz9xx";
    propagatedBuildInputs = [
      go-multierror
    ];
  };

  compress = buildFromGitHub {
    version = 6;
    rev = "5fb1f31b0a61e9858f12f39266e059848a5f1cea";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "06y8pmqs7282g802r6p5h5zzbari4pwsrp0vbs13s2w9c9r20ixi";
    propagatedBuildInputs = [
      cpuid
      crc32
    ];
    date = "2018-04-02";
  };

  concurrent = buildFromGitHub {
    version = 5;
    rev = "1.0.3";
    owner  = "modern-go";
    repo   = "concurrent";
    sha256 = "0s0jzhcwbnqinx9pxbfk0fsc6brb7j716pvssr60gv70k7052lcn";
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

  console = buildFromGitHub rec {
    version = 6;
    rev = "cb7008ab3d8359b78c5f464cb7cf160107ad5925";
    owner = "containerd";
    repo = "console";
    sha256 = "0cc56pf92rdcbb7dw6qm64m50hhvqf6v5cbhrp26n9lpajcpp72s";
    date = "2018-03-07";
    propagatedBuildInputs = [
      errors
      sys
    ];
  };

  consul = buildFromGitHub rec {
    version = 5;
    rev = "v1.0.6";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "1bxaf02j4ih8b3m7pszyz6mg2s46s7jzhxliisahlr160szv4chr";
    excludedPackages = "test";

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
      hashicorp_go-sockaddr
      go-syslog
      go-testing-interface
      go-version
      golang-lru
      golang-text
      google-api-go-client
      gopsutil
      hashicorp_go-uuid
      grpc
      hcl
      hil
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      net
      net-rpc-msgpackrpc
      oauth2
      raft-boltdb
      raft
      scada-client
      time
      ugorji_go
      hashicorp_yamux
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
  };

  consul_api = buildFromGitHub {
    inherit (consul) rev owner repo sha256 version;
    propagatedBuildInputs = [
      go-cleanhttp
      go-rootcerts
      serf
      hashicorp_yamux
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
    rev = "v0.19.4";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "0n0d4hrpv5hspwalix30w219fv3ln1m6gnypp4r2l6yna8prfz45";

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
    version = 3;
    rev = "v1.1";
    owner = "gorilla";
    repo = "context";
    sha256 = "17qagayvacgq3vwhslq7zn4qabdb12vlfymya0v6c87h4yb6yr8w";
  };

  continuity = buildFromGitHub {
    version = 6;
    rev = "3e8f2ea4b190484acb976a5b378d373429639a1a";
    owner = "containerd";
    repo = "continuity";
    sha256 = "0491kilzza6fcfwcb67dbc66cmn07762v1c64avfb2pikfx5c20j";
    date = "2018-03-22";
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
    version = 3;
    date = "2017-05-25";
    rev = "d23ffcb85de31694d6ccaa23ccb4a03e55c1303f";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "1fg0jzz54d0xmkfh2gxk42bd3bcfci1h498bqf05rq576blbpcld";
    propagatedBuildInputs = [ reflectwalk ];
  };

  core = buildFromGitHub {
    version = 6;
    rev = "0177c08cee8834c6aa53764e9d6a5f1ffb2c74f7";
    owner = "go-xorm";
    repo = "core";
    sha256 = "1r23g3fqm5m4rh9m7sk6x2x46lm1py8nxmssw8nqlrfvvdni7d7b";
    date = "2018-03-22";
  };

  cors = buildFromGitHub {
    version = 5;
    owner = "rs";
    repo = "cors";
    rev = "v1.3.0";
    sha256 = "1vrzp3hij6h39lfnzhl8zdklwnzbppchwkf81h3y9ifyx8blly01";
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
    version = 6;
    rev = "30e450625213468c7ec31fec6102dab6504adcc9";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "0i2fvkap8nvqm4bmrkjjwzw5hsbrjj1al86rf4il4dsivwh2pjrl";
    excludedPackages = "testdata";
    date = "2018-03-24";
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
    meta.autoUpdate = false;
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
    version = 3;
    owner = "dchest";
    repo = "cssmin";
    rev = "fb8d9b44afdc258bfff6052d3667521babcb2239";
    date = "2015-12-10";
    sha256 = "0nqngx6h1664kyw2iis87g2lv96jjiic1z2g74a187bm2p2wjsxq";
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
    rev = "58352f4407cb8530de39c000a4db8a198b14a982";
    owner = "godbus";
    repo = "dbus";
    sha256 = "13rm1imgciv4rnbklwhki5plnxs3yg9xmw4cshqibg77hh0db1hc";
    date = "2018-03-28";
  };

  decimal = buildFromGitHub {
    version = 3;
    rev = "9ca7f51822d222ae4e246f070f9aad863599bd1a";
    owner  = "shopspring";
    repo   = "decimal";
    sha256 = "15dpbzrvzmrw7dcpnx028jkr7if551arv6aianzc6l0sqmgl1hrg";
    date = "2017-11-08";
  };

  demangle = buildFromGitHub {
    version = 3;
    date = "2016-09-27";
    rev = "4883227f66371e02c4948937d3e2be1664d9be38";
    owner = "ianlancetaylor";
    repo = "demangle";
    sha256 = "1fx4lz9gwps99ck0iskdjm0l3pnqr306h4w7578x3ni2vimc0ahy";
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
    version = 5;
    rev = "0646ccaebea1ed1539efcab30cae44019090093f";
    owner  = "peterbourgon";
    repo   = "diskv";
    sha256 = "1fvw9rk4x3lvavv6agj1ycsvnqa819fi31xjglwmddxil7avdcjb";
    propagatedBuildInputs = [
      btree
    ];
    date = "2018-03-12";
  };

  distribution = buildFromGitHub {
    version = 6;
    rev = "83389a148052d74ac602f5f1d62f86ff2f3c4aa5";
    owner = "docker";
    repo = "distribution";
    sha256 = "0nx795g4rskwzgy47g1xzqzbkp71hrh4c2ff1wzaxwz1szhcnndi";
    meta.useUnstable = true;
    date = "2018-03-27";
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
    rev = "v1.0.5";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0480h89rp2byp03jccr0xymhz6fy2vnafgxbvn7xmvd1lyq3il6m";
    propagatedBuildInputs = [
      crypto
      net
    ];
  };

  dnscrypt-proxy = buildFromGitHub {
    version = 6;
    rev = "2.0.8";
    owner  = "jedisct1";
    repo   = "dnscrypt-proxy";
    sha256 = "1bhry3qwrxr46951in13nfygfbw78inh44f95z9v7gk9c5if6wqi";
    propagatedBuildInputs = [
      cachecontrol
      crypto
      dlog
      dns
      ewma
      godaemon
      go-clocksmith
      go-immutable-radix
      go-minisign
      go-systemd
      golang-lru
      lumberjack_v2
      pidfile
      safefile
      service
      toml
      xsecretbox
    ];
  };

  dnsimple-go = buildFromGitHub {
    version = 5;
    rev = "v0.16.0";
    owner  = "dnsimple";
    repo   = "dnsimple-go";
    sha256 = "0vfqw98zxg8s99pci8y0n3ln71kk61l5ggzf2nnxa4dlbs017vjc";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  dnspod-go = buildFromGitHub {
    version = 6;
    rev = "40850790e8481211074ecf8473b9c020896202d5";
    owner = "decker502";
    repo = "dnspod-go";
    sha256 = "05ynzsg0vy2jal5l10r3wva0dma5qjm0gyx10n6x67jl81ysjwwf";
    date = "2018-03-31";
    propagatedBuildInputs = [
      json-iterator_go
    ];
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
    version = 5;
    rev = "ee0de3bc6815ee19d4a46c7eb90f829db0e014b1";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "1y66riv7rw266vq043lp79l77jarfyi4dy9p43maxgsk9bwyh71i";
    date = "2018-01-11";
  };

  dqlite = buildFromGitHub {
    version = 6;
    rev = "9334841532709c77fc79e13a08408694e4bb3616";
    owner  = "CanonicalLtd";
    repo   = "dqlite";
    sha256 = "0mybas9369a5lyib7588xgj6dcxrpiy5fzlr829c9jm1yxs9sac7";
    date = "2018-03-29";
    excludedPackages = "testdata";
    propagatedBuildInputs = [
      errors
      fsm
      CanonicalLtd_go-sqlite3
      protobuf
      raft
    ];
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
    version = 5;
    owner = "minio";
    repo = "dsync";
    date = "2018-01-24";
    rev = "439a0961af700f80db84cc180fe324a89070fa65";
    sha256 = "02nq7jk3hcxxs60r09kfmzc1xfk2qsn4ahp79fcvlvzq6xi46rvz";
  };

  du = buildFromGitHub {
    version = 2;
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
    rev = "v1.0.16";
    sha256 = "0ncv0i7s65sqlm0jwi9dz19y2yn7zlfxbpg1s3xxvslmg53hlvfk";
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
    rev = "8b799c424f57fa123fc63a99d6383bc6e4c02578";
    date = "2018-03-23";
    sha256 = "1al6gscpjfvynxachblja850lb2lml4fq4wc0b8x6gdixd48k5lp";
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
    version = 5;
    rev = "v0.9.12";
    owner  = "exoscale";
    repo   = "egoscale";
    sha256 = "1c6nbgl5r7wcb7y3sij70avrrchnlr4z1srqwckmjflyhi5rfdkv";
    propagatedBuildInputs = [
      copier
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
    version = 5;
    owner = "olivere";
    repo = "elastic";
    rev = "v5.0.66";
    sha256 = "1la8d6aa938rj7b368jp1qn7rmdlqwrf7m1sj4j5h1539prrpgd1";
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
    rev = "bac2d37023099ecb1636801be30e108aa290df2f";
    sha256 = "1va48wj7yhsp2mcp83sg9br592s7ic9fpz182q847v5hwwdphna2";
    propagatedBuildInputs = [
      bolt
      go-isatty
      persistent
      sys
    ];
    meta.useUnstable = true;
    date = "2018-03-30";
  };

  eme = buildFromGitHub {
    version = 3;
    owner = "rfjakob";
    repo = "eme";
    rev = "2222dbd4ba467ab3fc7e8af41562fcfe69c0d770";
    date = "2017-10-28";
    sha256 = "1saazrhj3jg4bkkyiy9l3z5r7b3gxmvdwxz0nhxc86czk93bdv8v";
    meta.useUnstable = true;
  };

  emoji = buildFromGitHub {
    version = 3;
    owner = "kyokomi";
    repo = "emoji";
    rev = "2e9a9507333f3ee28f3fab88c2c3aba34455d734";
    sha256 = "1x7h2yx4h4jkyw6hk74m60zy5yzkfd1qzjqbgmd5n60v81rj91kw";
    date = "2017-11-21";
  };

  encoding = buildFromGitHub {
    version = 2;
    owner = "jwilder";
    repo = "encoding";
    date = "2017-02-09";
    rev = "27894731927e49b0a9023f00312be26733744815";
    sha256 = "0sha9ghh6i9ca8bkw7qcjhppkb2dyyzh8zm760y4yi9i660r95h4";
  };

  environschema_v1 = buildFromGitHub {
    version = 3;
    owner = "juju";
    repo = "environschema";
    rev = "7359fc7857abe2b11b5b3e23811a9c64cb6b01e0";
    sha256 = "1z3527vn918hbqjbmx5ncpym3jb99pj4kf9fmx3yfd0q5pgp7byz";
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
    rev = "v1.6.2";
    sha256 = "1ihjdwjm323byzi8a7a29k4502pbdin0qxgn9z6hpi5hp85jxpwb";
    propagatedBuildInputs = [
      godotenv
      go-homedir
    ];
  };

  errgo_v1 = buildFromGitHub {
    version = 3;
    owner = "go-errgo";
    repo = "errgo";
    rev = "442357a80af5c6bf9b6d51ae791a39c3421004f3";
    sha256 = "11js1zci1wzagk2f6y53qg58x3y3iz3kcmi2044y94l37j6cbcni";
    date = "2016-12-22";
    goPackagePath = "gopkg.in/errgo.v1";
  };

  juju_errors = buildFromGitHub {
    version = 3;
    owner = "juju";
    repo = "errors";
    rev = "c7d06af17c68cd34c835053720b21f6549d9b0ee";
    sha256 = "0dxr8xkqd14zbvrbq9nz6zk0n2ki5s90gkgwhf47swgwr6107kn2";
    date = "2017-07-03";
  };

  errors = buildFromGitHub {
    version = 5;
    owner = "pkg";
    repo = "errors";
    rev = "816c9085562cd7ee03e7f8188a1cfd942858cded";
    sha256 = "1szqq12n3wc0r2yayvkdfa429zv05csvzlkfjjwnf1p4h1v084y2";
    date = "2018-03-11";
  };

  errwrap = buildFromGitHub {
    version = 3;
    date = "2014-10-28";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "0b7wrwcy9w7im5dyzpwbl1bv3prk1lr5g54ws8lygvwrmzfi479h";
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
    rev = "2aa3decc38793a04f31c0ad3cb19c67f2e7c7a1e";
    sha256 = "0kamnm955v48p4lan6s12kwd5lc5wk85hy6438qyf25yxbp7pbxh";
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
    date = "2018-04-02";
  };

  etcd_client = etcd.override {
    subPackages = [
      "auth/authpb"
      "client"
      "clientv3"
      "clientv3/balancer"
      "clientv3/concurrency"
      "etcdserver/api/v3rpc/rpctypes"
      "etcdserver/etcdserverpb"
      "mvcc/mvccpb"
      "pkg/logutil"
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
      go-humanize
      go-semver
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
    version = 3;
    owner = "beevik";
    repo = "etree";
    rev = "v1.0.0";
    sha256 = "0j56c7xqz8nm8nf4104b8y0gwqr2hg5y2fgp25w27h8b3xdmx8gd";
  };

  eventfd = buildFromGitHub {
    version = 3;
    owner = "gxed";
    repo = "eventfd";
    rev = "80a92cca79a8041496ccc9dd773fcb52a57ec6f9";
    date = "2016-09-16";
    sha256 = "0wqlyis4v3zfij34p4m6f0ji2jmpaby16qll17h2kp0372qsj6z3";
    propagatedBuildInputs = [
      goendian
    ];
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

  fastuuid = buildFromGitHub {
    version = 3;
    date = "2015-01-06";
    rev = "6724a57986aff9bff1a1770e9347036def7c89f6";
    owner  = "rogpeppe";
    repo   = "fastuuid";
    sha256 = "1q04xarwz0f2jlhz3d9myxx8ikrbynj5pyhhcsz25dc56kc2gpfz";
  };

  filepath-securejoin = buildFromGitHub {
    version = 6;
    rev = "v0.2.1";
    owner  = "cyphar";
    repo   = "filepath-securejoin";
    sha256 = "0sz7cppgh5zyqdmkdih3i69yaixi3kks37yzw15g4algk0dyx0yk";
    propagatedBuildInputs = [
      errors
    ];
  };

  fileutil = buildFromGitHub {
    version = 5;
    date = "2018-01-08";
    rev = "6a051e75936f623600b67c2b1116b6b6c0ffb936";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "1yrx76i4y4gxrz4vaaqq6f0yaj6y1mr8zb27x38584bg7zmbx256";
    buildInputs = [
      mathutil
    ];
  };

  fileutils = buildFromGitHub {
    version = 3;
    date = "2017-11-03";
    rev = "7d4729fb36185a7c1719923406c9d40e54fb93c7";
    owner  = "mrunalp";
    repo   = "fileutils";
    sha256 = "0b2ba3bvx1pwbywq395nkgsvvc1rihiakk8nk6i6drsi6885wcdz";
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
    version = 3;
    date = "2013-11-11";
    rev = "2788f0dbd16903de03cb8186e5c7d97b69ad387b";
    owner  = "kr";
    repo   = "fs";
    sha256 = "1pllnjm1q96fl3pp62c38jl97pvcrzmb8k641aqndik3794n9x71";
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
    version = 5;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.7";
    sha256 = "0r0lw5wfs2jfksk13zqbz2f9i5l25x7kpcyjx2iwd4sc9h0fwgm8";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsnotify_v1 = buildFromGitHub {
    version = 5;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.7";
    sha256 = "19j58cdxnydx8nad708syyasriwz4l97rjf1qs4b1jv0g8az9paj";
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
    version = 6;
    owner = "jlaffaye";
    repo = "ftp";
    rev = "dab20533986eea5319103b6ab4318418deb7f79c";
    sha256 = "1qfb1a6fs4yl9szdcg49sv79jazd5wf3xbyg8acch5fwghmbi4pq";
    date = "2018-03-22";
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
    rev = "44cbc27138518b15305cb3eef220d04f2d641b9b";
    sha256 = "0f1yqfk16xb11zliqclwjb24hg5jgr507awri21d3bzdi1ravlwp";
    date = "2017-10-15";
  };

  gateway = buildFromGitHub {
    version = 3;
    date = "2016-05-22";
    rev = "edad739645120eeb82866bc1901d3317b57909b1";
    owner  = "calmh";
    repo   = "gateway";
    sha256 = "0544gd2ic2fvq1jjxsz6wfh1xgb4x51my148h282xzmxd509d3jr";
    goPackageAliases = [
      "github.com/jackpal/gateway"
    ];
  };

  gax-go = buildFromGitHub {
    version = 6;
    rev = "de2cc08e690b99dd3f7d19937d80d3d54e04682f";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "0ygshjd9l3rvk2wwgnpaiwkf8x02si0sgfdxkjrzdqkb0lig3lal";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
    date = "2018-03-29";
  };

  genproto = buildFromGitHub {
    version = 6;
    date = "2018-03-23";
    rev = "ab0870e398d5dd054b868c0db1481ab029b9a9f2";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "1qvvh1hybzwjv4xlrly6irvdr2fbqryzraq8s8gkaf93cj4yzlx9";
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
    version = 5;
    rev = "v1.2.1";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "0g2g7mhwp5abjrp2x3jn736230jkvfz154922kpzjwyc2i34ynly";
    propagatedBuildInputs = [
      maxminddb-golang
    ];
  };

  getopt = buildFromGitHub {
    version = 5;
    rev = "7148bc3a4c3008adfcab60cbebfd0576018f330b";
    owner = "pborman";
    repo = "getopt";
    sha256 = "0bdxna6rgvzxaxfmsfgrjh83mmpc7i9b5k48x2kb54nr44w4bd4q";
    date = "2017-01-12";
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
    version = 6;
    rev = "03ffd3f46debf00c49ed76d5dbb564ef4839adfe";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "1ggn59zwaix21zli0nszyx7dyfjl9zxlbdcgga4z5clwxlfzsjav";
    buildInputs = [
      sys
    ];
    date = "2018-03-21";
  };

  gitmap = buildFromGitHub {
    version = 6;
    rev = "012701e8669671499fc43e9792335a1dcbfe2afb";
    date = "2018-04-02";
    owner = "bep";
    repo = "gitmap";
    sha256 = "13q9wx6yhcfb78lafb098ccxnrrv5bagb5h1hny9gp4l0nxpk5ki";
  };

  gjson = buildFromGitHub {
    version = 5;
    owner = "tidwall";
    repo = "gjson";
    rev = "v1.1.0";
    sha256 = "0ywwacvfphyrbj579xj45phnxka6j2mpw8ryvnl1xh51vxm7rk1l";
    propagatedBuildInputs = [
      match
    ];
  };

  glob = buildFromGitHub {
    version = 5;
    rev = "v0.2.3";
    owner = "gobwas";
    repo = "glob";
    sha256 = "15vhdakfzbjbz2l7b480db28p4f1srz2bipigcjdjyp8pm98rkd9";
  };

  gmsm = buildFromGitHub {
    version = 3;
    rev = "v1.1";
    owner = "tjfoc";
    repo = "gmsm";
    sha256 = "10pygy31wfcfq2gxi3r3zmqybaw4agmch8r3siiyyps92bhjzzrx";
    propagatedBuildInputs = [
      crypto
    ];
  };

  gnostic = buildFromGitHub {
    version = 6;
    rev = "6d7ae43a9ae94f90ed9912252530d97039049c66";
    owner = "googleapis";
    repo = "gnostic";
    sha256 = "19hjq5dnz1wz7y6bpx9cli4gixdsxdvwcifvdywv3xyhk1l3fsfq";
    excludedPackages = "tools";
    propagatedBuildInputs = [
      docopt-go
      protobuf
      yaml_v2
    ];
    date = "2018-03-17";
  };

  json-iterator_go = buildFromGitHub {
    version = 6;
    rev = "1.1.3";
    owner = "json-iterator";
    repo = "go";
    sha256 = "13adq3nj1knms75d9i822kki2pvd070hn31g2yr0dbsrd3kbfdbm";
    excludedPackages = "test";
    propagatedBuildInputs = [
      concurrent
      plz
      reflect2
    ];
  };

  namedotcom_go = buildFromGitHub {
    version = 6;
    rev = "44c1cb60c15ed15dfee83396e33cc10bf989cda4";
    owner = "namedotcom";
    repo = "go";
    sha256 = "1r5n5rwdqnyf4lwpw8lln8i9b1v9xkn957lvzs8i35rb7d1sawwb";
    date = "2018-01-23";
    propagatedBuildInputs = [
      errors
    ];
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
    version = 5;
    rev = "v1.1";
    owner = "ugorji";
    repo = "go";
    sha256 = "1ig3v0cky0xggs7q5ibrdk2gr8dpg2422kjnf9zq1g9hr6aqvs7b";
    goPackageAliases = [
      "github.com/hashicorp/go-msgpack"
    ];
  };

  go-acd = buildFromGitHub {
    version = 3;
    owner = "ncw";
    repo = "go-acd";
    rev = "887eb06ab6a255fbf5744b5812788e884078620a";
    date = "2017-11-20";
    sha256 = "14b1fsxnkxf70sli2lg613qx1mfsl093ddwshyczr6fx8j6j084y";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  go-addr-util = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-addr-util";
    rev = "a9d6b939b59796c4933f56a8e628d6682d8d2a05";
    date = "2018-02-01";
    sha256 = "0y8p748jg7wim6gc5adyzrys9fippxb5v49qa39xhvy11j30ff0k";
    propagatedBuildInputs = [
      go-log
      go-ws-transport
      go-multiaddr
      go-multiaddr-net
      mafmt
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

  go-http-auth = buildFromGitHub {
    version = 5;
    owner = "abbot";
    repo = "go-http-auth";
    rev = "v0.4.0";
    sha256 = "0bdn2n332zsylc3rjgb7aya5z8wrn5d1zx3j40wjsiinv1z3zbl4";
    propagatedBuildInputs = [
      crypto
      net
    ];
  };

  go4 = buildFromGitHub {
    version = 6;
    date = "2018-03-19";
    rev = "e6a7f04a962e05f288f348eec6de20fe93b6b292";
    owner = "camlistore";
    repo = "go4";
    sha256 = "0ayi29s2yd13579r9s6nmh5jvf8q1y9bhf9wrv5g1idhvna0ljvf";
    goPackagePath = "go4.org";
    goPackageAliases = [
      "github.com/camlistore/go4"
      "github.com/juju/go4"
    ];
    propagatedBuildInputs = [
      google-api-go-client
      google-cloud-go
      oauth2
      net
      sys
    ];
  };

  gocapability = buildFromGitHub {
    version = 5;
    rev = "33e07d32887e1e06b7c025f27ce52f62c7990bc0";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "1igpbfw1k6ixy3x525xgw69q7cxibzbb9baxdxqc1gf5h2j2bbnp";
    date = "2018-02-23";
  };

  gocql = buildFromGitHub {
    version = 6;
    rev = "12e3a8c05db483441932e84ab6c35c339fb01de7";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "0x5phhdf2hyp6fma8kwxkc78xpgyglb4f1q0lb17rw8rlx7idils";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2018-03-20";
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
    version = 5;
    rev = "v1.1.3";
    owner  = "digitalocean";
    repo   = "godo";
    sha256 = "1wi2iqwjs89lzqk942xpnp1m3dg8kcpnjhrlnfljr19gyxnkwhvz";
    propagatedBuildInputs = [
      go-querystring
      http-link-go
      net
    ];
  };

  godotenv = buildFromGitHub {
    version = 5;
    rev = "v1.2.0";
    owner  = "joho";
    repo   = "godotenv";
    sha256 = "181qygpfk3hzbdrsh9imcbh25zmnywkkxdcjb6sm7923akin93z4";
  };

  goendian = buildFromGitHub {
    version = 3;
    rev = "0f5c6873267e5abf306ffcdfcfa4bf77517ef4a7";
    owner  = "gxed";
    repo   = "GoEndian";
    sha256 = "1h05p9xlfayfjj00yjkggbwhsb3m52l5jdgsffs518p9fsddwbfy";
    date = "2016-09-16";
  };

  gofuzz = buildFromGitHub {
    version = 3;
    rev = "24818f796faf91cd76ec7bddd72458fbced7a6c1";
    owner  = "google";
    repo   = "gofuzz";
    sha256 = "1ghcx5q9vsgmknl9954cp4ilgayfkg937c1z4m3lqr41fkma9zgi";
    date = "2017-06-12";
  };

  gohistogram = buildFromGitHub {
    version = 3;
    rev = "v1.0.0";
    owner  = "VividCortex";
    repo   = "gohistogram";
    sha256 = "02bikhfr47gp4ww9mmz9pz6q4g6293z0fn8kd83kn0i12x0s8b2l";
  };

  goid = buildFromGitHub {
    version = 5;
    rev = "b0b1615b78e5ee59739545bb38426383b2cda4c9";
    owner  = "petermattis";
    repo   = "goid";
    sha256 = "17wnw44ff0fsfr2c87g35m3bfm4makr0xyixfcv7r56hadll841y";
    date = "2018-02-02";
  };

  gojsondiff = buildFromGitHub {
    version = 3;
    rev = "e21612694bdd50975f93cd5eaccb457477128e28";
    owner  = "yudai";
    repo   = "gojsondiff";
    sha256 = "0q42kycm8mkchg78j8rlwjd8qb5d6cb0v3iv204vd6wiidyh76a6";
    date = "2017-11-26";
    propagatedBuildInputs = [
      urfave_cli
      go-diff
      golcs
    ];
    excludedPackages = "test";
  };

  gojsonpointer = buildFromGitHub {
    version = 5;
    rev = "4e3ac2762d5f479393488629ee9370b50873b3a6";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "1whgpgxjp9v8wxi8qqimsxbx7l4rpaqcdh19pww7xndalsprapi4";
    date = "2018-01-27";
  };

  gojsonreference = buildFromGitHub {
    version = 5;
    rev = "bd5ef7bd5415a7ac448318e64f11a24cd21e594b";
    owner  = "xeipuuv";
    repo   = "gojsonreference";
    sha256 = "1fszjc86996d0r6xbiy06b05ffhpmay4dzxrq0jw0sf3b6hqfplv";
    date = "2018-01-27";
    propagatedBuildInputs = [ gojsonpointer ];
  };

  gojsonschema = buildFromGitHub {
    version = 5;
    rev = "8bcffc811467a5f691810420385be6e66b35a317";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "07kzlzk82w3g839nmvzjaq9a0qhs8iwvsvpw1v6cqkv0qg2lrl0m";
    date = "2018-02-07";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gomaasapi = buildFromGitHub {
    version = 5;
    rev = "663f786f595ba1707f56f62f7f4f2284c47c0f1d";
    date = "2017-12-05";
    owner = "juju";
    repo = "gomaasapi";
    sha256 = "0fsck2i8izzv195gaw23ba1b30sr9vs7a49yix1mpxcjx2bfshwk";
    propagatedBuildInputs = [
      juju_errors
      loggo
      mgo_v2
      schema
      utils
      juju_version
    ];
  };

  gomail_v2 = buildFromGitHub {
    version = 3;
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
    version = 2;
    rev = "1952afaa557dc08e8e0d89eafab110fb501c1a2b";
    date = "2017-02-08";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "1h1sjgjv4ay6y26g25vg2q0iawmw8fnlam7r66qiq0hclzb72fcn";
  };

  gomemcached = buildFromGitHub {
    version = 6;
    rev = "47e71ca62c98944eb8983c8a2c5780d41c8321f2";
    date = "2018-03-27";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "1d78i3nh6kk80mhfcdkc7iycjgmf13d4pk4cq7si62wf7397d937";
    excludedPackages = "mocks";
    propagatedBuildInputs = [
      crypto
      errors
      goutils_gomemcached
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
    version = 6;
    rev = "3ff109d28762ddc1560994a051fab6b1146c6dbf";
    owner = "gophercloud";
    repo = "gophercloud";
    sha256 = "1zxkgp67zd6vgg7bsyz87zg7bwlv216qbyy3ay05lwybfn0wkzpx";
    date = "2018-04-02";
    excludedPackages = "test";
    propagatedBuildInputs = [
      crypto
      yaml_v2
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 6;
    date = "2018-03-30";
    rev = "6cd8fd08c73b5a9065920f4b2128562506e062cf";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "1v5mry66vv502lc970xyim834fjg8b326lqvsvvyn0rc4lgjzjvl";
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
    version = 5;
    rev = "160b358b10d6123169a895090938b088c8f78dc9";
    owner = "google";
    repo = "gops";
    sha256 = "1801jscwn4amqjf9fv1f4s364z1wg91wm96c4a6cq9l7vm5whlxf";
    propagatedBuildInputs = [
      keybase_go-ps
      gopsutil
      goversion
      osext
      treeprint
    ];
    meta.useUnstable = true;
    date = "2018-03-11";
  };

  goredis = buildFromGitHub {
    version = 3;
    rev = "760763f78400635ed7b9b115511b8ed06035e908";
    date = "2015-03-24";
    owner = "siddontang";
    repo = "goredis";
    sha256 = "0aqjid0i649s1h4wi704hvf6yfyzjp8c06vng43pp0r4vyi27b5z";
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
    version = 3;
    rev = "bcd34c9993f899273c74baaa95e15386cd97b6e7";
    date = "2017-12-04";
    owner = "franela";
    repo = "goreq";
    sha256 = "1j2283fmx3d870kgffnr7gjkbzxaf57a58whv4aar7hs10sj9hx5";
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
    version = 2;
    rev = "cd527374f1e5bff4938207604a14f2e38a9cf512";
    date = "2012-06-04";
    owner = "Nvveen";
    repo = "Gotty";
    sha256 = "16slr2a0mzv2bi90s5pzmb6is6h2dagfr477y7g1s89ag1dcayp8";
  };

  goutils = buildFromGitHub {
    version = 5;
    rev = "a8bc32b8203a49358563f1d2aa4db5dbfaff06b0";
    date = "2018-03-09";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "14fd9kkf4fxm1zmbfki0lx2vlrs4xg4cqfx66is4qz4hk6qgb78j";
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
    version = 5;
    date = "2018-02-01";
    rev = "0fb14efe8c47ae851c0034ed7a448854d3d34cf3";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "0v3md1h33bisx1dymp1zmy48kikkrjpz5qg7i37zckdlabq5220m";
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
    version = 3;
    rev = "v1.0.0";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "10gbh8lfcsvfs0a5fbr8rfl3s375bb4l2890h2v4qm3yf5d7mz6x";
    propagatedBuildInputs = [
      protobuf
    ];
  };

  golcs = buildFromGitHub {
    version = 3;
    rev = "ecda9a501e8220fae3b4b600c3db4b0ba22cfc68";
    date = "2017-03-16";
    owner = "yudai";
    repo = "golcs";
    sha256 = "183cdzwfi0wif082j6w09zr7446sa2kgg6bc7lrhdnh5nvlj3ly0";
  };

  goleveldb = buildFromGitHub {
    version = 6;
    rev = "714f901b98fdb3aa954b4193d8cbd64a28d80cad";
    date = "2018-03-31";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "0kpcr7pnwgypsgv49rxpvky5phhr5g9sj813f5hyzdzzy7rakw5l";
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
    version = 5;
    rev = "v1.3.0";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "12pb6x5inhi0gldnv9l3zn8ldz6l7anb9amqgqlx06z5pbckcp1l";
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
      date = "2018-04-02";
    };
    rev = "3072d9cd7f79a11909b84fdb7c9c8b9e60a57fbd";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 6;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "15q1yym4vll8bxlzg43lhhnf4q9gjygg2x17vci0n4ycfbdzrcjv";
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
    version = 5;
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
    version = 6;
    rev = "v2.18.03";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "0581723600anvr0ppl67rimgr5iii0xpdn42ak7n84yzlnqdbfr1";
    propagatedBuildInputs = [
      sys
      w32
      wmi
    ];
  };

  goquery = buildFromGitHub {
    version = 6;
    rev = "v1.4.0";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "04awz9ci1mx3a3fczg1nqjyhzgryiqz4bpy5aysfjblbk3jcl9mx";
    propagatedBuildInputs = [
      cascadia
      net
    ];
  };

  gosaml2 = buildFromGitHub {
    version = 5;
    rev = "23b0b0ca2f48c03b6d7ec6c655aca00fc1347571";
    owner  = "russellhaering";
    repo   = "gosaml2";
    sha256 = "0fbd6zjvm6g0dxhdy487cjpicmzv9n2vq6ib81i5cca3dpn64mim";
    date = "2018-03-06";
    excludedPackages = "test";
    propagatedBuildInputs = [
      etree
      goxmldsig
    ];
  };

  goskiplist = buildFromGitHub {
    version = 3;
    rev = "2dfbae5fcf46374f166f8969cb07e167f1be6273";
    owner  = "ryszard";
    repo   = "goskiplist";
    sha256 = "1znb1ldiffvvlakisi9k24xj2rlglyd696gc3zpys6dbl906ywvs";
    date = "2015-03-12";
  };

  gotask = buildFromGitHub {
    version = 3;
    rev = "104f8017a5972e8175597652dcf5a730d686b6aa";
    owner  = "jingweno";
    repo   = "gotask";
    sha256 = "0anv7mxsihy9y8g0fin93afs380b0j9hjsay6y9y0f72cmry68ql";
    date = "2014-01-12";
    propagatedBuildInputs = [
      urfave_cli
      go-shellquote
    ];
  };

  goupnp = buildFromGitHub {
    version = 5;
    rev = "167b9766e52022410644dfc64e8aadd57ee36858";
    owner  = "huin";
    repo   = "goupnp";
    sha256 = "0acc8s4vzyqh48bk6lrlhz1z6d758xmqcn64wwng5ylb4nzvgy5s";
    date = "2018-03-15";
    propagatedBuildInputs = [
      goutil
      gotask
      net
    ];
  };

  goutil = buildFromGitHub {
    version = 3;
    rev = "1ca381bf315033e89af3286fdec0109ce8d86126";
    owner  = "huin";
    repo   = "goutil";
    sha256 = "0f3p0aigiappv130zvy94ia3j8qinz4di7akxsm09f0k1cblb82f";
    date = "2017-08-03";
  };

  govalidator = buildFromGitHub {
    version = 6;
    rev = "7d2e70ef918f16bd6455529af38304d6d025c952";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "16isnqzdjmn0nflh8jbfylskq1aajinga4gcrr36gsmj51jm22sy";
    date = "2018-03-19";
  };

  goversion = buildFromGitHub {
    version = 5;
    rev = "bbd79cf837be9f342f4c1147be1e519ca25fdea3";
    owner = "rsc";
    repo = "goversion";
    sha256 = "0i525f7x4sck3z2iwpsc1ay8z58a320bbkcb9pv9cy01yrxsd5kr";
    goPackagePath = "rsc.io/goversion";
    date = "2018-03-09";
  };

  goxmldsig = buildFromGitHub {
    version = 5;
    rev = "a348271703b2f18f06407858abd235ccbfebf33f";
    owner  = "russellhaering";
    repo   = "goxmldsig";
    sha256 = "1b9in0xvkp8a1341pncz1mngswg7rrsgxli911k8abggnv6hw6cp";
    date = "2018-01-22";
    propagatedBuildInputs = [
      clockwork
      etree
    ];
  };

  go-autorest = buildFromGitHub {
    version = 6;
    rev = "v10.5.0";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "1rcn6d10k1fsa5ys0vm2sqgiifi89vlrfr7d85irm6ys9z5abjzz";
    propagatedBuildInputs = [
      crypto
      jwt-go
      utfbom
    ];
    excludedPackages = "\\(cli\\|cmd\\|example\\)";
  };

  go-bindata-assetfs = buildFromGitHub {
    version = 5;
    rev = "38087fe4dafb822e541b3f7955075cc1c30bd294";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "1aw8gk3hybhyxjsmnhhli94hc3r43xrwx71kx344mfp1rygc32cj";
    date = "2018-02-23";
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
    version = 5;
    owner = "pelletier";
    repo = "go-buffruneio";
    rev = "e2f66f8164ca709d4c21e815860afd2024e9b894";
    sha256 = "05jmk93x2g6803qz6sbwdm922s04hb6k6bqpbmbls8yxm229wid1";
    date = "2018-01-19";
  };

  go-cache = buildFromGitHub {
    version = 3;
    rev = "v2.1.0";
    owner = "patrickmn";
    repo = "go-cache";
    sha256 = "16kdcibb8z4bnjr27nlv2y8piz3yri2q9srn872q50ny0f1yj8ib";
  };

  go-checkpoint = buildFromGitHub {
    version = 3;
    date = "2017-10-09";
    rev = "1545e56e46dec3bba264e41fde2c1e2aa65b5dd4";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "0gq3z0fqwff36bf60vs5yjrcnp57w4h72ap5wgfkmlg7m0y3pn3m";
    propagatedBuildInputs = [
      go-cleanhttp
      hashicorp_go-uuid
    ];
  };

  go-cid = buildFromGitHub {
    version = 5;
    date = "2018-01-20";
    rev = "078355866b1dda1658b5fdc5496ed7e25fdcf883";
    owner = "ipfs";
    repo = "go-cid";
    sha256 = "00wbwvbkqcrzcw1ppjynfq6xyzjkiaj3lwhc1sxhrrmk5przx3f7";
    propagatedBuildInputs = [
      go-multibase
      go-multihash
    ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 5;
    date = "2017-12-18";
    rev = "d5fe4b57a186c716b0e00b8c301cbd9b4182694d";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "0w3k7b7pqzd5w92l9ag8g6snbb53vkxnngk9k48zkjv7ljifgfl1";
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
    version = 5;
    rev = "v0.2.0";
    owner  = "google";
    repo   = "go-cmp";
    sha256 = "0zrjxqmwnigyg2087rsdpzqv4rx3v39lylzhs1x5l812kw1sprhs";
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
    version = 5;
    rev = "efa589957cd060542a26d2dd7832fd6a6c6c3ade";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "14ra2300d9j1jg90anfxq0pck3x3hj22cb2flmaic2744hamic9x";
    propagatedBuildInputs = [
      go-isatty
    ];
    date = "2018-03-10";
  };

  go-connections = buildFromGitHub {
    version = 5;
    rev = "7395e3f8aa162843a74ed6d48e79627d9792ac55";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "1556r9w8xh4am4xsl2lf681xqipjfhjhnx2krb40lnqq3dy6m8lc";
    propagatedBuildInputs = [
      errors
      go-winio
      logrus
      net
      runc
    ];
    date = "2018-02-28";
  };

  go-couchbase = buildFromGitHub {
    version = 6;
    rev = "e60219b65313ccee85f9417032af8574f24c0fe4";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "0i0pyk1sm498vw3z587x9i6r6slx6sryikq471lcc09f5viqac08";
    date = "2018-03-27";
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
    version = 3;
    rev = "dcfb0a7ac018a248366f96bcd8a2f8c805d7b268";
    owner  = "davidlazar";
    repo   = "go-crypto";
    sha256 = "1hza8ikvhqp74qhydi7fndcn4j1049g698cbm1jv4xg2gz0mlcdx";
    date = "2017-07-01";
    propagatedBuildInputs = [
      crypto
    ];
  };

  keybase_go-crypto = buildFromGitHub {
    version = 6;
    rev = "d11a37f123888ff060339f516e392032dfcb98ff";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "1y19s77mrvsbs7bjjfy5c6ild9l8668z44abpl6vkra4h1hmvv48";
    date = "2018-03-29";
    propagatedBuildInputs = [
      ed25519
    ];
  };

  go-daemon = buildFromGitHub {
    version = 5;
    rev = "v0.1.3";
    owner  = "sevlyar";
    repo   = "go-daemon";
    sha256 = "15nvjr1lx3fi8q4110c8b0nii25m9sy5ayp2yvgry9m94dspkyf6";
    propagatedBuildInputs = [
      osext
    ];
  };

  go-deadlock = buildFromGitHub {
    version = 5;
    rev = "v0.2.0";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "1nldi10i6yjl1vh526y4v6y13j6a1245vwg39xnr0zmalima9siq";
    propagatedBuildInputs = [
      goid
    ];
  };

  go-diff = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner  = "sergi";
    repo   = "go-diff";
    sha256 = "1m8svyblsqc460pcanmmp3gvd7zlj8w9rxmgrw6grj0czjmwgg74";
  };

  go-discover = buildFromGitHub {
    version = 5;
    rev = "8f2af0ac44208783caab4dd65462ffb965229c60";
    owner  = "hashicorp";
    repo   = "go-discover";
    sha256 = "0arn9grs6bbs3yzavrriyanp63pvnpk3f3jv0qy61dnph4mm25ww";
    date = "2018-02-08";
    propagatedBuildInputs = [
      aliyungo
      aws-sdk-go
      #azure-sdk-for-go
      #go-autorest
      godo
      google-api-go-client
      gophercloud
      oauth2
      #scaleway-sdk
      softlayer-go
    ];
    postPatch = ''
      rm -r provider/azure
      sed -i '/azure"/d' discover.go
      rm -r provider/scaleway
      sed -i '/scaleway/d' discover.go
    '';
  };

  go-difflib = buildFromGitHub {
    version = 3;
    rev = "v1.0.0";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "1ypgp0akc22spz4j87cx9pih5wbvbsrk31sli3crjzfgbll5hx4i";
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
    version = 6;
    date = "2018-03-30";
    rev = "eb4b27262d9a41d4004d101c32e0598782a39415";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "14ckm6gm1lqa6jfiynsjxg7w9zsz571pbni70bmdkjgm71px5i26";
    propagatedBuildInputs = [
      go-cleanhttp
      go-units
      go-winio
      moby_lib
      mux
      net
    ];
  };

  go-dot = buildFromGitHub {
    version = 5;
    rev = "2b09569d6c5d777422931d44ea5d79b10e726d19";
    owner  = "zenground0";
    repo   = "go-dot";
    sha256 = "0hw87g77yhii1sdfl2fz9692rxbrnzyxycs0a7wyl22d0jd82m62";
    date = "2018-01-17";
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
    rev = "v1.7.3";
    owner  = "ethereum";
    repo   = "go-ethereum";
    sha256 = "03a52n47gacc1z9f9z6lpvcs00bqz5iy2h6lhmw5zcbdlgm164vs";
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
    version = 5;
    rev = "2de33835d10275975374b37b2dcfd22c9020a1f5";
    owner  = "dgryski";
    repo   = "go-farm";
    sha256 = "09c44b7igw7lxnr0in9z4yiqag54wssd4xr5hllhgys0fw1fcskx";
    date = "2018-01-09";
  };

  go-flags = buildFromGitHub {
    version = 6;
    rev = "v1.4.0";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0b4qbq5cjm6cgi4nbpxzgznm3v2c237bz1xznhkwrdhwx5nfgy8w";
  };

  go-floodsub = buildFromGitHub {
    version = 5;
    rev = "7f3ecddf94b54d1bc2021735fcb1803aabb4661a";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "1bjxw5fj8skffajy6095rhkz2925ql01w1lwaw83ymkl3cw964dn";
    date = "2018-03-07";
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

  go-flow-metrics = buildFromGitHub {
    version = 5;
    rev = "3b3bcfcf78f2dc0e85be13ef3c3adc64cc5a9347";
    owner  = "libp2p";
    repo   = "go-flow-metrics";
    sha256 = "06lw18smzsg5ci6rbdwm5lixcw73z67gix4lk72fw9ixkp055vwx";
    date = "2017-12-27";
  };

  go-flowrate = buildFromGitHub {
    version = 3;
    rev = "cca7078d478f8520f85629ad7c68962d31ed7682";
    owner  = "mxk";
    repo   = "go-flowrate";
    sha256 = "0xypq6z657pxqj5h2mlq22lvr8g6wvpqza1a1fvlq85i7i5nlkx9";
    date = "2014-04-19";
  };

  go-fs-lock = buildFromGitHub {
    version = 6;
    rev = "ce9819a999925cbe4ec0358abcd4f0a5409c8dfb";
    owner  = "ipfs";
    repo   = "go-fs-lock";
    sha256 = "0gzl1ijh0s4ac7m075cxah99gcbviycdql0rzlfwg50glwqry53w";
    date = "2018-03-29";
    propagatedBuildInputs = [
      go-ipfs-util
      go-log
      go4
    ];
  };

  go-getter = buildFromGitHub {
    version = 5;
    rev = "64040d90d4ab861e7e833d689dc76a0f176d8dec";
    date = "2018-02-26";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "18h217l4gs6j1g4wb09d7a3cj8iprvxcdfmjypzqbqbg2dnfpayz";
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
    version = 6;
    rev = "1.0.1";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "06f042dpfahzf424lqjj0xidiw4sv1zgbl37jyl0hvw506ajzswd";
  };

  go-github = buildFromGitHub {
    version = 5;
    rev = "v15.0.0";
    owner = "google";
    repo = "go-github";
    sha256 = "1sh1xv3bkmdan9xrkx64p81krpgv5mlxx16bgda8vji05kbjzb2v";
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

  go-grpc-sql = buildFromGitHub {
    version = 6;
    rev = "534b56d0c689ed437e6cff44868964d45d3ec85c";
    owner = "CanonicalLtd";
    repo = "go-grpc-sql";
    sha256 = "027spji0307f37f9qpm5ryqbmr89grzwffgl17zwbf4x71vjfffr";
    date = "2018-03-23";
    propagatedBuildInputs = [
      errors
      CanonicalLtd_go-sqlite3
      grpc
      net
      protobuf
    ];
  };

  go-grpc-prometheus = buildFromGitHub {
    version = 6;
    rev = "ceb68d03a48324d1127453e8c4288821adb87e3e";
    owner = "grpc-ecosystem";
    repo = "go-grpc-prometheus";
    sha256 = "1cf44zj966bx9bwipgym042kxxky1vdgrglzq8wra05kabc5s6y0";
    propagatedBuildInputs = [
      grpc
      net
      prometheus_client_golang
    ];
    date = "2018-03-24";
  };

  go-hclog = buildFromGitHub {
    version = 6;
    date = "2018-04-02";
    rev = "69ff559dc25f3b435631604f573a5fa1efdb6433";
    owner  = "hashicorp";
    repo   = "go-hclog";
    sha256 = "04nm5h3yaym6syj84x2d7rkx723npxdjq67y4ihqn0mali8zibwx";
  };

  go-hdb = buildFromGitHub {
    version = 6;
    rev = "v0.11.0";
    owner  = "SAP";
    repo   = "go-hdb";
    sha256 = "0wdc1yw3k7902l7rdkvh01sx1kh3iqxx222maqiapiva0vs9gvcw";
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
    goPackageAliases = [
      "github.com/minio/go-homedir"
    ];
  };

  hailocab_go-hostpool = buildFromGitHub {
    version = 3;
    rev = "e80d13ce29ede4452c43dea11e79b9bc8a15b478";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "1faz9sjnffkd7jsklnk5c7xq799928ff4gcb98sy6c69fmykhwc7";
  };

  gohtml = buildFromGitHub {
    version = 5;
    owner = "yosssi";
    repo = "gohtml";
    rev = "97fbf36f4aa81f723d0530f5495a820ba267ae5f";
    date = "2018-01-30";
    sha256 = "1l3z4b0l1r7pw7njcn3s5jafrvvf3h3ny7989flrmjhk8d4m4p64";
    propagatedBuildInputs = [
      net
    ];
  };

  go-humanize = buildFromGitHub {
    version = 3;
    rev = "bb3d318650d48840a39aa21a027c6630e198e626";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "1apy3hdqlk1ix6r3xaqrj5y7zpq3081lnij13jk7kcd32mskhx4p";
    date = "2017-11-11";
  };

  go-i18n = buildFromGitHub {
    version = 3;
    rev = "v1.10.0";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "031l584ilgvv7mvi4pn7lcc7wlb2lz2wia2gl0l6r4baxsraj3j3";
    buildInputs = [
      go-toml
      yaml_v2
    ];
  };

  go-immutable-radix = buildFromGitHub {
    version = 5;
    date = "2018-01-29";
    rev = "7f3cd4390caab3250a57f30efdb2a65dd7649ecf";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1gxfip1sxbp6c0mmmhqmydrw360xhhgyvkph8nxrhkq0b3xbfvqs";
    propagatedBuildInputs = [
      golang-lru
    ];
  };

  go-ipfs-api = buildFromGitHub {
    version = 6;
    rev = "d204576299ddab1140d043d0abb0d9b60a8a5af4";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "036nyx4dgdybvnljdph8yaxsb2x3a26dv5v74416k7m11falp7fx";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-floodsub
      go-homedir
      go-ipfs-cmdkit
      go-libp2p-peer
      go-libp2p-pubsub
      go-multiaddr
      go-multiaddr-net
      go-multipart-files
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2018-03-26";
  };

  go-ipfs-cmdkit = buildFromGitHub {
    version = 6;
    rev = "0d133c2ef2c201caa250587b4ed1790d0f207659";
    owner  = "ipfs";
    repo   = "go-ipfs-cmdkit";
    sha256 = "0yvgxbgmq6hrh62mamm1ciikj55bmsb3n90cfrql4rgwmjz6l2zk";
    date = "2018-03-27";
    propagatedBuildInputs = [
      go-ipfs-util
      sys
    ];
  };

  go-ipfs-util = buildFromGitHub {
    version = 5;
    rev = "9ed527918c2f20abdf0adfab0553cd87db34f656";
    owner  = "ipfs";
    repo   = "go-ipfs-util";
    sha256 = "00d8zv07i92fnmdd07368cmk8in8p6daxnkkzgf1cmm09765zi82";
    date = "2018-01-02";
    propagatedBuildInputs = [
      base58
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
    version = 5;
    rev = "c2b33e8439af944379acbdd9c3a5fe0bc44bd8a5";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "1v8brdfm1fwvsi880v3hb77vdqqq4wpais3kaz8nbcmnrbyh1gih";
    date = "2018-02-06";
  };

  go-jose_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.1.1";
    owner = "square";
    repo = "go-jose";
    sha256 = "1xcrg6gpq0vvx6j4fmr0697m4702cnqa8aqljxy883501m04p0ij";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
  };

  go-jose_v2 = buildFromGitHub {
    version = 6;
    rev = "v2.1.6";
    owner = "square";
    repo = "go-jose";
    sha256 = "1mjjgkqzpd181h5qkag0jqrrmbj0zrb3aizhw7jjzklvdvx2wrq2";
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

  go-libp2p = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p";
    date = "2018-03-30";
    rev = "91411f2ebff404261654e0f7250ad594d9ea89dc";
    sha256 = "0ag71jb0i5al9861hzrdq9b55c8fnvd4f94ndm8d9h0pbjdykhxl";
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
    date = "2018-03-30";
    rev = "e20638587d44b800489fc461da07b893af9760f8";
    sha256 = "0jps7pgp4f4wpgh1sczjm8is8gvhmib2kxy9qmn50sb8kj3grbs0";
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
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-conn";
    date = "2018-02-14";
    rev = "8058ec7c7d8d3834119a164005482ea696f028e4";
    sha256 = "142kay93lkk6q2a990ivffhxcfrva1x5g17r1nbvf9m7xh5n127d";
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
  };

  go-libp2p-connmgr = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-connmgr";
    date = "2017-10-08";
    rev = "ea96e1a2edfffd630a0ec7af5380eed3b13bfeeb";
    sha256 = "0j1d1r8r1x8v2fm2hqnrrfn3m2a745f4f7z6ccikxa3ysy2gw6bb";
    propagatedBuildInputs = [
      go-libp2p-interface-connmgr
      go-libp2p-net
      go-libp2p-peer
      go-log
      go-multiaddr
    ];
  };

  go-libp2p-consensus = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-consensus";
    rev = "v0.0.1";
    sha256 = "0ylz4zwpan2nkhyq9ckdclrxhsf86nmwwp8kcwi334v0491963fh";
  };

  go-libp2p-crypto = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-crypto";
    date = "2018-03-18";
    rev = "18915b5467c77ad8c07a35328c2cab468667a4e8";
    sha256 = "1s5yy9p0kgxlrlcyvkjh5wl04gkpsvjcm9gy7rzk1kvvwvz2paly";
    propagatedBuildInputs = [
      btcd
      ed25519
      gogo_protobuf
      sha256-simd
    ];
  };

  go-libp2p-gorpc = buildFromGitHub {
    version = 5;
    owner = "hsanjuan";
    repo = "go-libp2p-gorpc";
    date = "2018-03-13";
    rev = "d7dc00d3972108e819f20400228d680c5c0e098f";
    sha256 = "0xdxa393qzk32iahyrzwbpbsk1mbil5p45ndmgzlxqr6y2wgxks9";
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
    version = 5;
    owner = "hsanjuan";
    repo = "go-libp2p-gostream";
    date = "2018-03-13";
    rev = "3d5cedd5b41b0126cd6323238ebd657973dbc10f";
    sha256 = "1icfkj8b2hhwkd6mnmf62hfwlsyi1bz93r1z4lkhdfdmahypj900";
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
    date = "2018-03-30";
    rev = "e9d58839c95837b733102954920ebbff72c69fc5";
    sha256 = "14l441pvrdj61ynxr1vv040kxn4zgpndbms5n5smfdvn08xrjv0f";
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
    date = "2018-03-14";
    rev = "658d66adf1ca9c79c909042935f0a9d2b576a552";
    sha256 = "0r5a03hai8w3nlxnjfx4a56604y7jcwhi9i7vnsl9xvm81zrf8fr";
    propagatedBuildInputs = [
      go-libp2p-gostream
      go-libp2p-host
      go-libp2p-peer
      go-libp2p-protocol
    ];
  };

  go-libp2p-interface-conn = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-interface-conn";
    date = "2018-02-01";
    rev = "0635e022759c738c55b7769cc6307506946089b9";
    sha256 = "009cwcziz686ysbxzjrgf58hz9ldaxylcl598rymr56r46lz6bmv";
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
    date = "2018-03-30";
    rev = "8ba060b3c75a9b7b01ea213d8802ee5c84dde68a";
    sha256 = "054m6xh47lrvfi18ylqps1iaj076n9i26qzkwcld468ia9k1if0g";
    propagatedBuildInputs = [
      go-libp2p-net
      go-libp2p-peer
      go-multiaddr
    ];
  };

  go-libp2p-interface-pnet = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-interface-pnet";
    date = "2018-03-09";
    rev = "6ea0626616ac1d34c6375a20fd1f48fc9a607a4d";
    sha256 = "1fa0vaj1mmy5pzj3d0i48i5r7w8liy0psknxwp2hz9fpkvswi6ys";
    propagatedBuildInputs = [
      go-libp2p-transport
    ];
  };

  go-libp2p-loggables = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-loggables";
    date = "2018-02-01";
    rev = "7a534896f9574b69081fa4e3a192270465719ced";
    sha256 = "108rrr9d9xwjsvcjh5f1grbafbn4mxwv3cijmjffh9pwfvrndfcl";
    propagatedBuildInputs = [
      go-log
      go-libp2p-peer
      go-multiaddr
      satori_go-uuid
    ];
  };

  go-libp2p-metrics = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-metrics";
    date = "2018-03-30";
    rev = "1fcfeaed47fa227c959c57cce7c983983dd0e889";
    sha256 = "1x6vwvx944z9b0cdx37yfalp52rs0wbrib1ca79582jfixbch1bq";
    propagatedBuildInputs = [
      go-flow-metrics
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-protocol
      go-libp2p-transport
    ];
  };

  go-libp2p-nat = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-nat";
    date = "2018-02-01";
    rev = "469319376dce9de8de967a034bf579b4ae7be44d";
    sha256 = "0mr0rp17xajvabn3d1c6s1bls9p4f0i1ya37plmrajf55w2jihyb";
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
    date = "2018-03-30";
    rev = "efcfaff497d0007eb472424afb7b022774b8b925";
    sha256 = "06sdq4j8wrs1fav7vdpi1q6s32x9iqqzl9h7jlbsi0381m37fd53";
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
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-peer";
    date = "2018-03-22";
    rev = "da74849e053d3a8c1750b2f88a70ad39d357c957";
    sha256 = "1fz79z9clih5x0k083ixj7q60afqi9g72zzx3qw9m3yag0g7y8cz";
    propagatedBuildInputs = [
      base58
      go-ipfs-util
      go-libp2p-crypto
      go-log
      go-multicodec-packed
      go-multihash
    ];
  };

  go-libp2p-peerstore = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-peerstore";
    date = "2018-02-01";
    rev = "2c122745dcc9c03c80b0203ce89c445ace6aa596";
    sha256 = "1h7yx4c3rcylz6jxmiaf29zh5w6lwik2fsbhqvq0yrm0bk1cp1nb";
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

  go-libp2p-pnet = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-pnet";
    date = "2018-03-08";
    rev = "a5146b44a71cee9cac2138e83b3e3b74c5006910";
    sha256 = "0a4brn6ar7kz71r6nkywh5fdvb1hiryv0v31wnwg3qdnsqfr86fs";
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
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-protocol";
    date = "2017-12-12";
    rev = "b29f3d97e3a2fb8b29c5d04290e6cb5c5018004b";
    sha256 = "0igw13rdynkvwvb0p38vvljdbyjz316chbhdrargwhmbbf88pvnh";
  };

  go-libp2p-pubsub = buildFromGitHub {
    version = 3;
    owner = "libp2p";
    repo = "go-libp2p-pubsub";
    date = "2017-11-18";
    rev = "a031ab4d1b8142714eec946acb7033abafade3d7";
    sha256 = "037y9pfjjzjv5psrhjd9j3nlqqigsfm8xgz6c57i27p799hisifq";
    propagatedBuildInputs = [
      gogo_protobuf
    ];
  };

  go-libp2p-raft = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-raft";
    date = "2018-03-28";
    rev = "203844b488fc32b550069d9a7eebaac060a19961";
    sha256 = "08x5zn7z1lcxaf8r8zavlkbf3079w9hh5f6nkszkw5jcy1p2gamj";
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
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-secio";
    date = "2018-02-01";
    rev = "437de218ca1fc65dfbf7b2b084519665bbaf7781";
    sha256 = "0cybcix96mimrxnnxcjnv8r0c8z4ns3dbc6azbv7zraf0iwigwxf";
    propagatedBuildInputs = [
      crypto
      gogo_protobuf
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
    date = "2018-03-30";
    rev = "b9fb1d413744ac7fd7e72743750da84d3f3b9afe";
    sha256 = "0awyf4mvagj2hclzffvgvdhcp1jiaflg097y5324hfasihwhkn7q";
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
    version = 5;
    owner = "libp2p";
    repo = "go-libp2p-transport";
    date = "2018-02-01";
    rev = "7f67e6aa68aa4b679c21179d32ab08d77a149cef";
    sha256 = "1q4i3j0rw0cdclclsfrbgy5ybml1f5xvf479zp431mz544v21frr";
    propagatedBuildInputs = [
      go-log
      go-multiaddr
      go-multiaddr-net
      go-stream-muxer
      mafmt
    ];
  };

  go-log = buildFromGitHub {
    version = 6;
    owner = "ipfs";
    repo = "go-log";
    date = "2018-03-27";
    rev = "4b54e7d2460df21c1c2d345af2337f91bfc938ca";
    sha256 = "10h8a5hpj5gd0mvszjccscfdr0vndgfhryh9br25rxnannhhy7vn";
    propagatedBuildInputs = [
      go-colorable
      whyrusleeping_go-logging
      opentracing-go
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
    version = 5;
    rev = "2660c429a942a4a21455765c7046dde612c1baa7";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "1yhhj2yg6y90qbjgx7kvwig6j2kxvh4fddgyizrkw6rhcwrvmgqb";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2018-02-27";
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
    version = 5;
    owner = "libp2p";
    repo = "go-maddr-filter";
    date = "2018-01-20";
    rev = "3c9947befbb92277cc5f85057d387097debc4139";
    sha256 = "13kmkyr2b7gq79d0dgcx4jmrlib5c8wafzk21blfdqqikhwnj79r";
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-net
    ];
  };

  go-md2man = buildFromGitHub {
    version = 5;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "20f5889cbdc3c73dbd2862796665e7c465ade7d1";
    sha256 = "35496b5131a0ff05762877236dedfa91145e36af71b1cac46904e9b1b615c2ff";
    propagatedBuildInputs = [
      blackfriday
    ];
    meta.autoUpdate = false;
    date = "2018-01-19";
  };

  go-memdb = buildFromGitHub {
    version = 5;
    date = "2018-02-23";
    rev = "1289e7fffe71d8fd4d4d491ba9a412c50f244c44";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "0pp9slppy3xrnjnz0mpnyskx0czrr523mk89436dn04gk0wmhr8y";
    propagatedBuildInputs = [
      go-immutable-radix
    ];
  };

  armon_go-metrics = buildFromGitHub {
    version = 5;
    date = "2018-02-21";
    rev = "783273d703149aaeb9897cf58613d5af48861c25";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "00kdq4ya43i1x8kyfjfsrq37vnm3dspvb76mad3xi33khwpczwqh";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
      go-immutable-radix
      prometheus_client_golang
    ];
  };

  docker_go-metrics = buildFromGitHub {
    version = 5;
    date = "2018-02-09";
    rev = "399ea8c73916000c64c2c76e8da00ca82f8387ab";
    owner = "docker";
    repo = "go-metrics";
    sha256 = "1nssja0pjqr41ggpiwc9f4ha9w9f9ajrq7jqbk6jsnfzzl4snl6y";
    propagatedBuildInputs = [
      prometheus_client_golang
    ];
    postPatch = ''
      grep -q 'lt.m.WithLabelValues(labels...)}' timer.go
      sed -i '/WithLabelValues/s,)},).(prometheus.Histogram)},' timer.go
    '';
  };

  rcrowley_go-metrics = buildFromGitHub {
    version = 5;
    rev = "8732c616f52954686704c8645fe1a9d59e9df7c1";
    date = "2018-01-25";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "04c79d1zxhizv0r9g39q5h994gsb3vlshhxqlcrdw7bkjp3ghr3v";
    propagatedBuildInputs = [
      stathat
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

  go-minisign = buildFromGitHub {
    version = 5;
    date = "2018-01-13";
    rev = "f404c079ea5f0d4669fe617c553651f75167494e";
    owner = "jedisct1";
    repo = "go-minisign";
    sha256 = "0qal80nfb8hrwvf7mk1ybrg21fmpv7w457pk7v3a1dvmm4fgwpjp";
    propagatedBuildInputs = [
      crypto
    ];
  };

  go-msgio = buildFromGitHub {
    version = 5;
    rev = "d82125c9907e1365775356505f14277d47dfd4d6";
    owner = "libp2p";
    repo = "go-msgio";
    sha256 = "1ivm7hx807ifj5xq4dzp0dx19jn0qyk1alw6dm17al6qajqscy8b";
    date = "2017-12-11";
  };

  go-mssqldb = buildFromGitHub {
    version = 6;
    rev = "2e93935aa9096273693401939a61fb8a9b2c9d14";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "0zrri11am0s4q7887mcf641hrxynpr9mlvw4gksgvhap8y86cqji";
    date = "2018-03-30";
    buildInputs = [
      crypto
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 5;
    rev = "123a717755e0559ec8fda308019cd24e0a37bb07";
    date = "2018-01-20";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "0fy4ys8qvzsyg2z7ljm25d0wgjnxzfp502b2qmmmlxvn17l25brn";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-dns = buildFromGitHub {
    version = 6;
    rev = "c3d4fcd3cbaf54a24b0b68f1461986ede1d59859";
    date = "2018-03-27";
    owner  = "multiformats";
    repo   = "go-multiaddr-dns";
    sha256 = "0gl4q9cvbnq3s53k1668gj796s1if55xmrl31v3rblx2wa547rr2";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 5;
    rev = "97d80565f68c5df715e6ba59c2f6a03d1fc33aaf";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "1481gjng97kvbmhk6ia4zns9nyijal5ip40l35jni53sg9d7ra0a";
    date = "2018-03-08";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  go-multibase = buildFromGitHub {
    version = 5;
    rev = "dfd5076869faca5aed2886dcba60b44a0d0e9c01";
    date = "2017-12-18";
    owner  = "multiformats";
    repo   = "go-multibase";
    sha256 = "1aahbmz3k54i0lsnhjzk9n3x5xq28xz78azd4b0pqzg6fyx9cdbz";
    propagatedBuildInputs = [
      base58
      base32
    ];
  };

  go-multicodec = buildFromGitHub {
    version = 5;
    rev = "1ae531d4677a68bd114737a4e1f39fa12a384fb0";
    date = "2018-02-08";
    owner  = "multiformats";
    repo   = "go-multicodec";
    sha256 = "1h4wr9dz8zr6ggblvsfvvsccg6d29n54lqk8q0xl6460xyfnh23k";
    propagatedBuildInputs = [
      cbor
      ugorji_go
      go-msgio
      gogo_protobuf
    ];
  };

  go-multicodec-packed = buildFromGitHub {
    version = 5;
    owner = "multiformats";
    repo = "go-multicodec-packed";
    date = "2018-02-01";
    rev = "9004b413b478e5a878e4a879358cce02e5df4995";
    sha256 = "1a4wmqcmmn1ih7yxnxzirwwxr91czp9rvvf90zl6qsfc97zxlmik";
  };

  go-multierror = buildFromGitHub {
    version = 3;
    date = "2017-12-04";
    rev = "b7773ae218740a7be65057fc60b366a49b538a44";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "1imymwg4z8ba59d7846s1n4w1jba72k5yppv8qdwylq4bpd48nfd";
    propagatedBuildInputs = [
      errwrap
    ];
  };

  go-multihash = buildFromGitHub {
    version = 5;
    rev = "265e72146e710ff649c6982e3699d01d4e9a18bb";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "05a3hk2cv9ny2rkd5sdncqkvrg086dkql4jdldawmvmffy5vrbpi";
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
    date = "2018-03-09";
  };

  go-multipart-files = buildFromGitHub {
    version = 3;
    rev = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "1b3zd8338dzda7vrval6wirs7cn5klfw1i2sq5a8qxvrb6rlvb3w";
    date = "2015-09-04";
  };

  go-multiplex = buildFromGitHub {
    version = 5;
    rev = "3ac9031715040479fc59cbf43a09f6a08b3ef9ae";
    date = "2018-03-06";
    owner  = "whyrusleeping";
    repo   = "go-multiplex";
    sha256 = "1daz6l4qjlxj2saim1774zmvm2rw8gr4g3j3y5yisgrgl0dnsan8";
    propagatedBuildInputs = [
      go-log
      go-msgio
    ];
  };

  go-multistream = buildFromGitHub {
    version = 5;
    rev = "612ce31c03aebe1d5adbd3c850ee89e05a82b16d";
    date = "2018-03-08";
    owner  = "multiformats";
    repo   = "go-multistream";
    sha256 = "0mw762cnb0zf7na2h5hz78dkyfi4qks74gjf8kg0cc7j9q7zyw7z";
  };

  go-nat = buildFromGitHub {
    version = 3;
    rev = "dcaf50131e4810440bed2cbb6f7f32c4f4cc95dd";
    owner  = "fd";
    repo   = "go-nat";
    sha256 = "1zv8h4s7rqvkd78q4j2fvg2zr94x5gf964q8hq9vh7cj0zrjb150";
    date = "2015-05-08";
    propagatedBuildInputs = [
      gateway
      goupnp
      jackpal_go-nat-pmp
    ];
  };

  AudriusButkevicius_go-nat-pmp = buildFromGitHub {
    version = 3;
    rev = "452c97607362b2ab5a7839b8d1704f0396b640ca";
    owner  = "AudriusButkevicius";
    repo   = "go-nat-pmp";
    sha256 = "1bz6lhl9h2nv5vvcb5i53zhd4w17aq5pmxi40krps2lhazsgcmba";
    date = "2016-05-22";
  };

  jackpal_go-nat-pmp = buildFromGitHub {
    version = 3;
    rev = "28a68d0c24adce1da43f8df6a57340909ecd7fdd";
    owner  = "jackpal";
    repo   = "go-nat-pmp";
    sha256 = "173kd4l52rmd4d4j6mnf69s6gpmdx7b9npkmkgxlzpiad62vaq20";
    date = "2017-04-05";
  };

  go-nats = buildFromGitHub {
    version = 6;
    rev = "v1.5.0";
    owner = "nats-io";
    repo = "go-nats";
    sha256 = "06h61nw1nd3i2h9g9j8wrwwg84mm2bd625j3qmsfl18xshzsx3mb";
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
    rev = "1662e177fdb0b7964a25e8e7e3570dd49b763c9a";
    owner = "nats-io";
    repo = "go-nats-streaming";
    sha256 = "19vdcvb7pwk90vfqh9hmlaki159rlij1vdlklp6x6gg7jvblyy63";
    propagatedBuildInputs = [
      go-nats
      nuid
      gogo_protobuf
    ];
    date = "2018-03-19";
  };

  go-netrc = buildFromGitHub {
    version = 2;
    owner = "bgentry";
    repo = "go-netrc";
    date = "2014-05-22";
    rev = "9fd32a8b3d3d3f9d43c341bfe098430e07609480";
    sha256 = "68984543a73f4d7ad4b58708207a483bd74fc9388ac582eac532434b11361a9e";
  };

  go-notifier = buildFromGitHub {
    version = 3;
    owner = "whyrusleeping";
    repo = "go-notifier";
    date = "2017-08-27";
    rev = "097c5d47330ff6a823f67e3515faa13566a62c6f";
    sha256 = "1rnnc8nngvpbkzqrsls3q8jzb0nrc8c8qi0z89cw0lzp36l00dy6";
    propagatedBuildInputs = [
      goprocess
    ];
  };

  go-oidc = buildFromGitHub {
    version = 3;
    date = "2017-10-26";
    rev = "a93f71fdfe73d2c0f5413c0565eea0af6523a6df";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "e0370707f20d97f6e8a447de6a6b29564a75cb8a6bd3d8cc992d9996e8b9c78e";
    propagatedBuildInputs = [
      cachecontrol
      clockwork
      go-jose_v2
      oauth2
      pkg
    ];
    meta.autoUpdate = false;
    excludedPackages = "example";
  };

  go-okta = buildFromGitHub {
    version = 3;
    rev = "053fd73f6d35ad82d5eee3481cbf76b10f61dee6";
    owner = "sstarcher";
    repo = "go-okta";
    sha256 = "1g9d4y5c8cqschi4r2jsd8dw2f5drrykgpav13dlad2y1ps3nj8q";
    date = "2017-12-05";
  };

  go-ole = buildFromGitHub {
    version = 5;
    rev = "v1.2.1";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "1v7v4kacvsq1hfznkmab5hfzg6s9zn24ns3nz4dg9p75wn76s7kz";
    excludedPackages = "example";
  };

  go-os-rename = buildFromGitHub {
    version = 3;
    rev = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2";
    owner  = "jbenet";
    repo   = "go-os-rename";
    sha256 = "0dqddk6l49jq35hd1x6nls0wdcy3j9dvlcbakxvibdxiw3k4y50f";
    date = "2015-04-28";
  };

  go-ovh = buildFromGitHub {
    version = 6;
    rev = "498310cd1182ebfb928a6acb71b3ad93f56c2d4f";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "18pnk9c9jdx529a310rba9vmfp7kp4sjqiscxz0x9g3ymvlw1plx";
    date = "2018-03-28";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-peerstream = buildFromGitHub {
    version = 5;
    rev = "de27dedf2287a2bd7030a1ecc94a6913385e6cfe";
    date = "2018-02-15";
    owner  = "libp2p";
    repo   = "go-peerstream";
    sha256 = "0xp4nsr8c759gy2mkm71b66575kzqwpnf8d2979fx19icy258g7g";
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
    rev = "e8d22c780116115ae5624720c9af0c97afe4f551";
    date = "2018-03-31";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "0y9vr3r6wgvjchhjvzvgzwfsjpwl82x8m61j0k3jf1dvfsn7hicz";
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
    version = 6;
    owner = "sbinet";
    repo = "go-python";
    date = "2018-03-27";
    rev = "f976f61134dc6f5b4920941eb1b0e7cec7e4ef4c";
    sha256 = "1x61ra7kmi7gp9z6n6x9flavhnwbqzpav5wk9ai98ray9q2xy49w";
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
    version = 6;
    rev = "v1.1.0";
    owner  = "eapache";
    repo   = "go-resiliency";
    sha256 = "1m8vz7mgmkjfjr925dgmz30bxm7fl7rskan8j6bgy8dbsjwdskc8";
  };

  go-restful = buildFromGitHub {
    version = 5;
    rev = "v2.6.0";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "17kblnhfjix94i3kvqvigixy6zv79yiaj8b748zr30cr41znag90";
  };

  go-restful-swagger12 = buildFromGitHub {
    version = 3;
    rev = "7524189396c68dc4b04d53852f9edc00f816b123";
    owner = "emicklei";
    repo = "go-restful-swagger12";
    sha256 = "0jvcbd2635c2p85gbinsah4jgi9hjgnphn9ji072wrwlx4i3ghxg";
    goPackageAliases = [
      "github.com/emicklei/go-restful/swagger"
    ];
    propagatedBuildInputs = [
      go-restful
    ];
    date = "2017-09-26";
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

  go-reuseport = buildFromGitHub {
    version = 6;
    rev = "b2f2e4cd8932fbd181b9202ffa22bd5206390045";
    owner = "libp2p";
    repo = "go-reuseport";
    sha256 = "0xksakqdaf6w67nzrfs3v6cgz82nh15ywb7c6j0w6ai0iv7zi5dy";
    date = "2018-03-29";
    excludedPackages = "test";
    propagatedBuildInputs = [
      eventfd
      go-log
      libp2p_go-sockaddr
      sys
    ];
  };

  go-rootcerts = buildFromGitHub {
    version = 3;
    rev = "6bb64b370b90e7ef1fa532be9e591a81c3493e00";
    owner = "hashicorp";
    repo = "go-rootcerts";
    sha256 = "1nxfy0j98s2c3sljga8n1r0l1xcz2pp3i9rzk8iy0xid5dh3mv3q";
    date = "2016-05-03";
    buildInputs = [
      go-homedir
    ];
  };

  go-runewidth = buildFromGitHub {
    version = 5;
    rev = "a9d6d1e4dc51df2130326793d49971f238839169";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "02rdxk551m678cdwlr4gcy1kc2lw4q60qwffcgs6i9hzfzham6p7";
    date = "2018-03-04";
  };

  go-semver = buildFromGitHub {
    version = 5;
    rev = "e214231b295a8ea9479f11b70b35d5acf3556d9b";
    owner  = "coreos";
    repo   = "go-semver";
    sha256 = "1fhs8mc9xa5prm7cy05lppag4ll6hdf45bn7469ng9xzyg6jdsw4";
    date = "2018-01-08";
  };

  go-shared = buildFromGitHub {
    version = 3;
    rev = "v0.1.1";
    owner  = "pengsrc";
    repo   = "go-shared";
    sha256 = "038w697lqiz83qxjrvnvfdj0jdr588sy0wggzshmwgry2lpzdsh2";
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
    version = 5;
    rev = "39dbbfa24bbc39559b61cae9b20b0e8db0e55525";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "0hgjrrgh2nszq7j4f8l71l7gs6ifz50ak1130abm6dzf3rn2mmch";
    date = "2018-02-01";
  };

  go-shuffle = buildFromGitHub {
    version = 5;
    owner = "shogo82148";
    repo = "go-shuffle";
    date = "2018-02-18";
    rev = "27e6095f230d6c769aafa7232db643a628bd87ad";
    sha256 = "1s0hfhw7w18kdndl053i0rs72dmmwprjd1qhwfcpbz0lszavi125";
  };

  go-simplejson = buildFromGitHub {
    version = 2;
    rev = "da1a8928f709389522c8023062a3739f3b4af419";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "0qrqmhi7wng3nb42ch4pp7xly2yia8grg3mkifqnra5d9pr7q91j";
    date = "2017-02-06";
  };

  go-smux-multiplex = buildFromGitHub {
    version = 5;
    rev = "feac16f6d6b1dafe1963afcca468baf6e430e01d";
    owner  = "whyrusleeping";
    repo   = "go-smux-multiplex";
    sha256 = "04931x5g8w5p4wy6yxddfhr485ryppjpnw51rwz5881kq2r1w2kv";
    date = "2018-02-01";
    propagatedBuildInputs = [
      go-stream-muxer
      go-multiplex
    ];
  };

  go-smux-multistream = buildFromGitHub {
    version = 3;
    rev = "afa6825376c14a0462fd420a7d4b4d157c937a42";
    owner  = "whyrusleeping";
    repo   = "go-smux-multistream";
    sha256 = "1ckx5y4kqfwfvs9qf4zb1cc699kqsr91i6wnr69zxdsjaxkhqq0n";
    date = "2017-09-12";
    propagatedBuildInputs = [
      go-stream-muxer
      go-multistream
    ];
  };

  go-smux-spdystream = buildFromGitHub {
    version = 3;
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
    rev = "49f324a2b63e778df703cf8e5a502bd56a683ef3";
    owner  = "whyrusleeping";
    repo   = "go-smux-yamux";
    sha256 = "1hp9naxq57dmpvcm6ghvggg7cw5gxm7r0q8jq7fm7lndn9xh4mnh";
    date = "2018-03-22";
    propagatedBuildInputs = [
      go-stream-muxer
      whyrusleeping_yamux
    ];
  };

  go-snappy = buildFromGitHub {
    version = 3;
    rev = "d8f7bb82a96d89c1254e5a6c967134e1433c9ee2";
    owner  = "siddontang";
    repo   = "go-snappy";
    sha256 = "16kr17w2hp91hilncavr4kv06xw6c85vgzzsn330ww5gfvda4x7c";
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
    rev = "f3e9f73a53d14d8257cb9da3d83dda07bbd8b2fe";
    owner  = "libp2p";
    repo   = "go-sockaddr";
    sha256 = "0xsh5jp44vwpvqhpkxni5y7w7x4cnmvqnpn6sf144jj68fx9pw1x";
    date = "2018-03-29";
    propagatedBuildInputs = [
      sys
    ];
  };

  go-spew = buildFromGitHub {
    version = 5;
    rev = "8991bc29aa16c548c550c7ff78260e27b9ab7c73";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1cjs23xhbpk5blv7wbnbn79xzkdnidhs448mzn2qkrddjkhbgs4y";
    date = "2018-02-21";
  };

  go-sqlite3 = buildFromGitHub {
    version = 6;
    rev = "9101028e5ca824d2baf0fbd91b9700e2669a6cd9";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0gmg2g0zgpnxzlxhb6l7m1466mgig53dkmvpbq9585y3mvzwhsyh";
    excludedPackages = "test";
    meta.useUnstable = true;
    date = "2018-03-07";
  };

  CanonicalLtd_go-sqlite3 = buildFromGitHub {
    version = 6;
    rev = "730012cee3364e7717c28f7e9b05ee6dd8684bae";
    owner  = "CanonicalLtd";
    repo   = "go-sqlite3";
    sha256 = "0p6z2ssca5n0mg7avaylkcrc47n7m5aaqqy9sqlzs7sxpmj8abi7";
    excludedPackages = "test";
    meta.useUnstable = true;
    date = "2018-03-29";
  };

  go-statsd-client = buildFromGitHub {
    version = 3;
    rev = "ce77ca9ecdee1c3ffd097e32f9bb832825ccb203";
    owner  = "cactus";
    repo   = "go-statsd-client";
    sha256 = "01k99bprg2x6zd29v4cpva0pzk7v6p0rrvs0n2ggg5k1cilnvxz0";
    date = "2017-08-31";
    excludedPackages = "test";
  };

  go-stdlib = buildFromGitHub {
    version = 5;
    rev = "36723135187404d2f4002f4f189938565e64cc5c";
    owner  = "opentracing-contrib";
    repo   = "go-stdlib";
    sha256 = "1kr8npx9yakil6xyjbsr9dz8qapjwcxsyxy8xl7nbcdpiqa8hjpl";
    date = "2018-03-13";
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
    rev = "d9bbe8f8fa7bf7ed03e6cfc6a2796bb36139e1f4";
    owner  = "ccding";
    repo   = "go-stun";
    sha256 = "0ylnb9z4kb7x58c1h7mzq1m3kg85fipzc51hdafwwgs08r6g0477";
    date = "2017-12-06";
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
    version = 6;
    rev = "bebb2b01b0473b183e4624aaf8e23ae6f4b22417";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "0x583h5ws1x9nwy3lnj0vk432npab0vbg2jn49ysqbyhb2c8gcbm";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2018-03-28";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 version date;
    subPackages = [
      "journal"
    ];
  };

  go-tcp-transport = buildFromGitHub {
    version = 5;
    owner = "libp2p";
    repo = "go-tcp-transport";
    rev = "578cd65fcec1d08d226d1b186e4548065e6bd65c";
    sha256 = "0j2pz7k5vlg7nj98ln52hj29f4bm6zqxqil3prhn46xcxn7m9j8f";
    date = "2018-02-01";
    propagatedBuildInputs = [
      go-log
      go-libp2p-transport
      go-multiaddr
      go-multiaddr-net
      go-reuseport
      mafmt
    ];
  };

  go-temp-err-catcher = buildFromGitHub {
    version = 3;
    owner = "jbenet";
    repo = "go-temp-err-catcher";
    rev = "aac704a3f4f27190b4ccc05f303a4931fd1241ff";
    sha256 = "19ivkcjl34avnzv5jilpiygv2ikzbnnd43axvdisc4cwdkrcwd11";
    date = "2015-01-20";
  };

  go-testing-interface = buildFromGitHub {
    version = 3;
    owner = "mitchellh";
    repo = "go-testing-interface";
    rev = "a61a99592b77c9ba629d254a693acffaeb4b7e28";
    sha256 = "1ml2xzp6lzbf9vzvvsjgfw667md6dnbjh8830s8a29l2flwsa5jd";
    date = "2017-10-04";
  };

  go-toml = buildFromGitHub {
    version = 6;
    owner = "pelletier";
    repo = "go-toml";
    rev = "66540cf1fcd2c3aee6f6787dfa32a6ae9a870f12";
    sha256 = "0hk2350hvzjx0rrjk2s1qq96x3zj01sz0ks2idyablz5dx5b0x7v";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2018-03-23";
  };

  go-units = buildFromGitHub {
    version = 5;
    rev = "47565b4f722fb6ceae66b95f853feed578a4a51c";
    owner = "docker";
    repo = "go-units";
    sha256 = "117whlx46dfk971ispc1ql0sy5nfyzzds54s0ar2sfcma7l47r4p";
    date = "2018-02-12";
  };

  go-unsnap-stream = buildFromGitHub {
    version = 3;
    rev = "62a9a9eb44fd8932157b1a8ace2149eff5971af6";
    owner = "glycerine";
    repo = "go-unsnap-stream";
    sha256 = "0ds4l7c9cnlmp2bl4vfx2filcd9fac47piganbd00q3js5aw3sjv";
    date = "2017-11-27";
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
    version = 5;
    rev = "27454136f0364f2d44b1276c552d69105cf8c498";
    date = "2018-02-28";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "09bz8mvswqmbkwnm71pdndpyscsyyk3yx9hphysdmnrad1mkazbi";
  };

  satori_go-uuid = buildFromGitHub {
    version = 5;
    rev = "36e9d2ebbde5e3f13ab2e25625fd453271d6522e";
    owner  = "satori";
    repo   = "go.uuid";
    sha256 = "0k0lwkqjpypawnw8p874i2qscqzk4xi8vsvnl0llmjpq2knphnf4";
    goPackageAliases = [
      "github.com/satori/uuid"
    ];
    meta.useUnstable = true;
    date = "2018-01-03";
  };

  go-version = buildFromGitHub {
    version = 6;
    rev = "23480c0665776210b5fbbac6eaaee40e3e6a96b7";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "115v0i2mwzjixmp5967gkra8h3ldfly503bi2qmhfwabd75j0glj";
    date = "2018-03-22";
  };

  go-winio = buildFromGitHub {
    version = 5;
    rev = "v0.4.7";
    owner  = "Microsoft";
    repo   = "go-winio";
    sha256 = "1w18syhq8pkxhqfp3x8krxn4j8508x64j7r1y1kw0x36piyw3laf";
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

  go-ws-transport = buildFromGitHub {
    version = 5;
    rev = "0cf90461ccc19765a5afafa9c2f58291471f1f09";
    owner  = "libp2p";
    repo   = "go-ws-transport";
    sha256 = "13jr4nfaaa2l9nznrmz4c4df74pyrxaa2z7b7w1pq5v2648y5p33";
    date = "2018-02-01";
    propagatedBuildInputs = [
      go-libp2p-transport
      go-multiaddr
      go-multiaddr-net
      mafmt
      websocket
    ];
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
    version = 5;
    rev = "c4fab1ac1bec58281ad0667dc3f0907a9476ac47";
    date = "2018-01-30";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "1zqywcxm3d4v0xfqnwcgb34d2v7p2hrc1r7964ssarz1p496cl6l";
  };

  goconfig = buildFromGitHub {
    version = 5;
    owner = "Unknwon";
    repo = "goconfig";
    rev = "ef1e4c783f8f0478bd8bff0edb3dd0bade552599";
    date = "2018-03-08";
    sha256 = "0ja27xc55wvj83z21cksp36vb9jhfw7lakkxsa8i8vvqp47sb1ai";
  };

  gorequest = buildFromGitHub {
    version = 3;
    owner = "parnurzeal";
    repo = "gorequest";
    rev = "8e3aed27fe49f7fdc765dad067845f600fc984e8";
    sha256 = "12jgbq5nz9p0bc3d2xld9201hq62vrg1q7f948wrbcvgx33fq6fl";
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
    rev = "v5.0.4";
    sha256 = "127wc540asw17kxb4igypc7a0xn5yz94jks5wx6yzhqfggjm97br";
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
      go-spew
      go-plugin
      go-sqlite3
      go-version
      grafana_plugin_model
      gzip
      ini_v1
      #jaeger-client-go
      ldap
      log15
      macaron_v1
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
    version = 5;
    owner = "grafana";
    repo = "grafana_plugin_model";
    rev = "dfe5dc0a6ce05825ba7fe2d0323d92e631bffa89";
    sha256 = "0qsklh7809ddnwcc75lrjy6zw0lbj6p4ffnicm3dm8bawx83gvi4";
    date = "2018-01-18";
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
    version = 5;
    date = "2018-02-03";
    rev = "66deaeb636dff1ac7d938ce666d090556056a4b0";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "1csg84lqxxldg17jkh9bfwn0a83abn18yki8wr2srx49hn95dql5";
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
    version = 5;
    rev = "v1.3.1";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "1rn8ar7qdkl8qxv688z23jfzd2w9y7qymghynyh21cs0caqh8q5p";
    propagatedBuildInputs = [
      genproto
      glog
      grpc
      net
      protobuf
    ];
  };

  grpc-websocket-proxy = buildFromGitHub {
    version = 3;
    rev = "830351dc03c6f07d625727d5f993a463babb20e1";
    owner = "tmc";
    repo = "grpc-websocket-proxy";
    sha256 = "03b6066zj7pjrd6j44rzqm47067niaqhjzmvhmmjpcz00fm83qy4";
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
    rev = "2cac68f23d57e3e28a73b70d8d5d904749ec46e8";
    sha256 = "1n7bhisr5y14xicwcb73bjc9r8gchsqcqknhhx93s7hfy9ps7mfw";
    date = "2017-11-14";
  };

  guid = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner = "marstr";
    repo = "guid";
    sha256 = "0i7dlyaxyhlhp6z3m6n29cjsjlb55cwcjvc0qb88r9f5ixgbrpy0";
  };

  gx = buildFromGitHub {
    version = 3;
    rev = "v0.12.1";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "1x4j3vmv6x1b2hvqfxsy95imv2kcc1g53nq90c0n3q3bzd2fgddf";
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
    rev = "v1.6.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "1b9dwacxz9h3i5ba5wig3qg737xssk7lyp1c3sj03nhsyz5fb32y";
    buildInputs = [
      urfave_cli
      fs
      go-homedir
      gx
      stump
    ];
  };

  gzip = buildFromGitHub {
    version = 3;
    date = "2016-02-22";
    rev = "cad1c6580a07c56f5f6bc52d66002a05985c5854";
    owner = "go-macaron";
    repo = "gzip";
    sha256 = "0pcm617hb06yaypffmmn8pwm9mwqszhm8bx2bkbfgbjvbnjzqg7g";
    propagatedBuildInputs = [
      compress
      macaron_v1
    ];
  };

  gziphandler = buildFromGitHub {
    version = 5;
    rev = "v1.0.1";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "0l1gmrffjji0pxm5w3alr1d8df7qcymsvmlb04hil0f3xnbf8inl";
  };

  hashland = buildFromGitHub {
    version = 3;
    rev = "07375b562deaa8d6891f9618a04e94a0b98e2ee7";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "1rs71c9pi9apwh59m42hdyvi0ax9a59rv12s5wmsq8013c3m2wnj";
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

  hashland_for_aeshash = buildFromGitHub {
    version = 3;
    rev = "07375b562deaa8d6891f9618a04e94a0b98e2ee7";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "1rs71c9pi9apwh59m42hdyvi0ax9a59rv12s5wmsq8013c3m2wnj";
    goPackagePath = "leb.io/hashland";
    date = "2017-10-03";
    meta.autoUpdate = false;
    subPackages = [
      "nhash"
    ];
  };

  handlers = buildFromGitHub {
    version = 3;
    owner = "gorilla";
    repo = "handlers";
    rev = "v1.3.0";
    sha256 = "18df12yrv4z6kj1c6kjgcmpj2syr8maqdbjm0q2gxv00vpbgxlkn";
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
    version = 6;
    date = "2018-03-20";
    rev = "f40e974e75af4e271d97ce0fc917af5898ae7bda";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "1p1dyj41nhfl2lq024b297sbplm0q40f0fny1iqhnp209sy77fdq";
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

  highwayhash = buildFromGitHub {
    version = 6;
    date = "2018-03-08";
    rev = "9c7e959d92fc8c6ee2cccdf74ae48685816768e2";
    owner  = "minio";
    repo   = "highwayhash";
    sha256 = "16nss6dyp1fa1m24ax9zdpf2slk9k3vb9s320l28dv7lg5p3kq3w";
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
    version = 5;
    rev = "v1.7.0";
    owner = "mailgun";
    repo = "holster";
    sha256 = "0z551bvx25iwxhmzbj73nxscd9nsyjzarkhfs7yhmjxlj8q8cqbm";
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
    meta.autoUpdate = false;
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
    version = 5;
    rev = "9cad4c3443a7200dd6400aef47183728de563a38";
    owner  = "gregjones";
    repo   = "httpcache";
    sha256 = "04g601pps7nkaq1j1wsjc5krmi1j8zp8kir5yyb9929cpxah8lr8";
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
    version = 3;
    rev = "ac974c61c2f990f4115b119354b5e0b47550e888";
    owner  = "tent";
    repo   = "http-link-go";
    sha256 = "05zir2mh47n1mlrnxgahxplxnaib0248xijd26mfs4ws88507bv3";
    date = "2013-07-02";
  };

  httprequest_v1 = buildFromGitHub {
    version = 5;
    rev = "v1.1.1";
    owner  = "go-httprequest";
    repo   = "httprequest";
    sha256 = "1xlgv41m98xvs0psrv399ml47fi4cx07vch07ygpcgrw8a8vrd5v";
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
    version = 5;
    rev = "d1898390779332322e6b5ca5011da4bf249bb056";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "01ipxh0724d15587yf579pahb2wjqg9qw1ywskd0g7y797lg1m96";
    date = "2018-02-22";
  };

  httpunix = buildFromGitHub {
    version = 3;
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
    rev = "v0.38";
    sha256 = "18w05za55mzfnpxa84zwhz2jplhhhy1skjwfd1yfd99f56rlx3zb";
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
      glob
      go-i18n
      go-immutable-radix
      go-toml
      goorgeous
      image
      imaging
      inflect
      jwalterweatherman
      mage
      mapstructure
      mmark
      net
      nitro
      osext
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
    version = 3;
    rev = "15392b0e99abe5983297959c737b8d000e43b34c";
    owner  = "juju";
    repo   = "idmclient";
    sha256 = "1z91hpkd0panc0qgprr9dlky0ib39x4vphxz0jb1la9y8azi7w7g";
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
    version = 3;
    rev = "v1.0.1";
    owner  = "opencontainers";
    repo   = "image-spec";
    sha256 = "1ar8vvah76z4nv7wygamkz0dyzkgikg5px3rd7g6ymyfc1vjpsl1";
    propagatedBuildInputs = [
      errors
      go4
      go-digest
      gojsonschema
    ];
  };

  imaging = buildFromGitHub {
    version = 5;
    rev = "v1.4.1";
    owner  = "disintegration";
    repo   = "imaging";
    sha256 = "071xq8lc87awfc0lcldb4m5v23b6naav5zi48565sga95bwd4air";
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
    rev = "adc799c2d667cde52c4d87c04a3dda4940f6fe05";
    date = "2018-04-02";
    sha256 = "1jcgm4y9xyri6j8pcl8lvfyjz0hni15pglfkr3qhz5w33vz790ws";
    propagatedBuildInputs = [
      envy
    ];
  };

  influxdb = buildFromGitHub {
    version = 6;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.5.1";
    sha256 = "0rqwm256r8pzyafs1wbbpnygs58n688fnq0hgi41rkx76qjl7xqw";
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
      "client/v2"
      "models"
      "pkg/escape"
    ];
  };

  ini = buildFromGitHub {
    version = 5;
    rev = "v1.33.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "1nkk9v4hb48w8w54sn6m6q7wzmnrlm59k9dqjprl16azq0vg90zq";
  };

  ini_v1 = buildFromGitHub {
    version = 5;
    rev = "v1.33.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "07cpgymz0mc03i4ywyx3bbgb5463lqldc6hwip6aq0mjqyibk0fa";
  };

  inject = buildFromGitHub {
    version = 3;
    date = "2016-06-27";
    rev = "d8a0b8677191f4380287cfebd08e462217bac7ad";
    owner = "go-macaron";
    repo = "inject";
    sha256 = "1q8ma0266zims9cxkar908dln67m2awdfvrnxrv16p5grka5jixi";
  };

  internal = buildFromGitHub {
    version = 3;
    rev = "4747030f7cf2f4c0a01512b00cd68734b167ac3b";
    owner  = "cznic";
    repo   = "internal";
    sha256 = "0kmsbgr8qjqxbzymnb0hyk7xickqddzlmffpl7rjw88jmpafks0a";
    date = "2017-09-05";
    buildInputs = [
      fileutil
      mathutil
      mmap-go
    ];
  };

  ipfs = buildFromGitHub {
    version = 6;
    rev = "v0.4.14";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "046ba17cea675ed8e398acadd89a5d966f6bf8f8c6ef9309fd357f3eb64c4797";
    gxSha256 = "0fpqljxf8y4zhrhd8kif3ajc0h30rg9sd6il0i1b85r1420xnzy1";
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
    rev = "bebc486bb39f2cbae3133716e036a611599f3aa1";
    owner = "ipfs";
    repo = "ipfs-cluster";
    sha256 = "13np03paa1jszyd6bjcqfp9r0h5drcrzglrccmsqnv4012piff4q";
    meta.useUnstable = true;
    date = "2018-03-29";
    excludedPackages = "test";
    propagatedBuildInputs = [
      urfave_cli
      go4
      go-cid
      go-dot
      go-fs-lock
      go-ipfs-api
      go-libp2p
      go-libp2p-crypto
      go-libp2p-consensus
      go-libp2p-host
      go-libp2p-http
      go-libp2p-interface-pnet
      go-libp2p-gorpc
      go-libp2p-gostream
      go-libp2p-peerstore
      go-libp2p-pnet
      go-libp2p-protocol
      go-libp2p-peer
      go-libp2p-raft
      go-libp2p-swarm
      go-log
      go-multiaddr
      go-multiaddr-dns
      go-multiaddr-net
      go-multicodec
      go-ws-transport
      mux
      raft
      raft-boltdb
    ];
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
    version = 3;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0slxjrhnh55jdhhlp4np6fr133pv3wlqgi37bjxgy6jwcm29iidq";
  };

  json-patch = buildFromGitHub {
    version = 6;
    owner = "evanphx";
    repo = "json-patch";
    rev = "v3.0.0";
    sha256 = "0fh1xj7za9xcdbbmyxj6m57gn3kcl0dasqi1zazhcim3bzk11m5v";
    propagatedBuildInputs = [
      go-flags
    ];
  };

  jsonpointer = buildFromGitHub {
    version = 6;
    owner = "go-openapi";
    repo = "jsonpointer";
    rev = "3a0015ad55fa9873f41605d3e8f28cd279c32ab2";
    date = "2018-03-22";
    sha256 = "0xp09p2hqw11k3f2s5ya4hflw4i4h924krlvsl4mv28f37kvscaw";
    propagatedBuildInputs = [
      swag
    ];
  };

  jsonreference = buildFromGitHub {
    version = 6;
    owner = "go-openapi";
    repo = "jsonreference";
    rev = "3fb327e6747da3043567ee86abd02bb6376b6be2";
    date = "2018-03-22";
    sha256 = "1s7xp9pjvyyp4a3a353pwrqqwhjni9wyq9hwgkmhdslfccg6mdxw";
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
    version = 5;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "7c0cea34c8ece3fbeb2b27ab9b59511d360fb394";
    date = "2018-01-09";
    sha256 = "0a0wbsgaah9v383hh66sshnmmw4jck3krlms35dxpjm2hxfsb9l2";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
  };

  jwt-go = buildFromGitHub {
    version = 5;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "v3.2.0";
    sha256 = "0xlri0sdphab7xs9drg06fckb11ysyj9xhlbparclr6wfh648612";
  };

  kcp-go = buildFromGitHub {
    version = 5;
    owner = "xtaci";
    repo = "kcp-go";
    rev = "v3.25";
    sha256 = "0d0gqidk56n3vmm6jj6dq9af2lz9bzwzrzsrby7aqdd8pyj54pvs";
    propagatedBuildInputs = [
      crypto
      errors
      gmsm
      net
      klauspost_reedsolomon
      xor
    ];
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
    rev = "v0.7.0";
    owner = "go-kit";
    repo = "kit";
    sha256 = "1wf764qbq7apl4sri8924qxkipw544hbcx9vkvqbxx41wf88w905";
    subPackages = [
      "log"
      "log/level"
      "metrics"
      "metrics/expvar"
      "metrics/generic"
      "metrics/influx"
      "metrics/internal/lv"
      "metrics/prometheus"
    ];
    propagatedBuildInputs = [
      gohistogram
      influxdb_client
      logfmt
      prometheus_client_golang
      stack
    ];
  };

  kit_for_prometheus = kit.override {
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
    rev = "c4ebf33f93081f8c7602d29a59944e4a9f684ac2";
    owner  = "kubernetes";
    repo   = "api";
    sha256 = "0c0hzqy2xc85cdn3gr2zihw7kspay2vyr3dk11csxj3fql3w2n9k";
    goPackagePath = "k8s.io/api";
    propagatedBuildInputs = [
      gogo_protobuf
      kubernetes-apimachinery
    ];
    meta.useUnstable = true;
    date = "2018-03-29";
  };

  kubernetes-apimachinery = buildFromGitHub {
    version = 6;
    rev = "0ed326127d3068118ef128c76673dad6005736ba";
    owner  = "kubernetes";
    repo   = "apimachinery";
    sha256 = "12l7jnzismpm03m7lp9w2zipplargr9r487ra9ri0cl97jbh2wdw";
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
      pflag
      gogo_protobuf
      spdystream
      yaml
    ];
    postPatch = ''
      rm -r pkg/util/uuid
    '';
    meta.useUnstable = true;
    date = "2018-03-28";
  };

  kubernetes-kube-openapi = buildFromGitHub {
    version = 5;
    rev = "50ae88d24ede7b8bad68e23c805b5d3da5c8abaf";
    date = "2018-02-16";
    owner  = "kubernetes";
    repo   = "kube-openapi";
    sha256 = "0nvvk853zk03ps0d3mdgj5i5qy8nz17fdvdzrk576d4f5wsjsi22";
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
    rev = "88e8ea169afa2918712ce2bc64fc1e2d11d72b12";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "6778814163b61f870e9032025fc24a9bfb7f899a3d1f353aa94fc666dc038159";
    goPackagePath = "k8s.io/client-go";
    excludedPackages = "\\(test\\|fake\\)";
    propagatedBuildInputs = [
      crypto
      glog
      gnostic
      gopass
      gophercloud
      go-autorest
      groupcache
      kubernetes-api
      kubernetes-apimachinery
      mergo
      net
      oauth2
      pflag
      protobuf
      time
    ];
    postPatch = ''
      grep -q 'spt.Token,' plugin/pkg/client/auth/azure/azure.go
      sed -i 's#spt.Token,#spt.Token(),#' plugin/pkg/client/auth/azure/azure.go
    '';
    meta.useUnstable = true;
    date = "2018-03-28";
  };

  ldap = buildFromGitHub {
    version = 3;
    rev = "v2.5.1";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "0csrsr88k66yfd95lwznikh1iij6zsr45mcbxaswz5l12fsm7l9w";
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
    rev = "v0.6";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "1bzqlmna1l59dlhx53gnb75ncg76sp299g2vzwayz4159n875gk8";
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
    rev = "d7fdc8f54aecdaba627aedc1d740ee1cc2d3a26c";
    owner = "xenolf";
    repo = "lego";
    sha256 = "1l0qn76ny92gdvim3l4k22k8y79hl7a1kk09k0qwdgp7wrinsnxs";
    buildInputs = [
      auroradnsclient
      aws-sdk-go
      #azure-sdk-for-go
      urfave_cli
      crypto
      dns
      dnspod-go
      dnsimple-go
      go-autorest
      go-jose_v1
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
    '';
    date = "2018-04-02";
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
    version = 5;
    rev = "791d3fcb5d1b1af9a0ad6700cd8956b2f7a0a518";
    owner = "docker";
    repo = "libkv";
    sha256 = "1pdzi2axvgqi4fva0mv25281chprybw5hwmzxmk8xk4n51pd5y7i";
    date = "2017-12-19";
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
    version = 6;
    rev = "5c1218c956c99f3365711974e300087810c31379";
    owner = "docker";
    repo = "libnetwork";
    sha256 = "1lag49sd7mad0pwc30bf3q5djhf0iwv39vpa0ngn6a0a9d2w0vby";
    date = "2018-04-02";
    subPackages = [
      "datastore"
      "discoverapi"
      "types"
    ];
    propagatedBuildInputs = [
      libkv
      sctp
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
    rev = "3681c2a912330352991ecdd642f257efe5b85518";
    owner = "peterh";
    repo = "liner";
    sha256 = "110j0y6iqljydwh1w2y396bzn9w68lkly177slawkmzl7vp4yfkp";
    date = "2017-11-22";
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
      internal
      zappy
    ];
    meta.useUnstable = true;
    date = "2016-11-02";
  };

  lockfile = buildFromGitHub {
    version = 5;
    rev = "6a197d5ea61168f2ac821de2b7f011b250904900";
    owner = "nightlyone";
    repo = "lockfile";
    sha256 = "1pl63q7bgjl651z9f2750iapnwlgnswk4cncn7f32hsq3y3gd825";
    date = "2017-08-04";
  };

  log15 = buildFromGitHub {
    version = 3;
    rev = "0decfc6c20d9ca0ad143b0e89dcaa20f810b4fb3";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "1d5i3yv6571lbdpwag711v34m4psp49is63zqrk3lpfkrwyasf71";
    goPackageAliases = [
      "gopkg.in/inconshreveable/log15.v2"
    ];
    propagatedBuildInputs = [
      go-colorable
      go-isatty
      stack
      sys
    ];
    date = "2017-10-19";
  };

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

  loggo = buildFromGitHub {
    version = 6;
    rev = "7f1609ff1f3fcf3519ed62ccaaa9e609ea287838";
    owner = "juju";
    repo = "loggo";
    sha256 = "0jc3bml282w54gwgp0gyjfw1g282slg3irlfv645sba90lvdc4gn";
    date = "2018-03-27";
    propagatedBuildInputs = [
      ansiterm
    ];
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
    version = 6;
    rev = "778f2e774c725116edbc3d039dc0dfc1cc62aae8";
    owner = "sirupsen";
    repo = "logrus";
    sha256 = "1cak6rpvrcqsjm8fnsnj0cyi5zbbk39bmy5w7gqpgb9vr3619981";
    goPackageAliases = [
      "github.com/Sirupsen/logrus"
    ];
    propagatedBuildInputs = [
      crypto
      sys
    ];
    meta.useUnstable = true;
    date = "2018-03-29";
  };

  logutils = buildFromGitHub {
    version = 3;
    date = "2015-06-09";
    rev = "0dc08b1671f34c4250ce212759ebd880f743d883";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "1g005p42a22ag4qvkb2jx50z638r21vrvvgpwpd3c1d3qazjg7ha";
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
    version = 6;
    rev = "f332c3883f63c75ea6c95eae3aec71a2b2d88b49";
    owner = "minio";
    repo = "lsync";
    sha256 = "0ifljlsl3f67hlkgzzrl6ffzwbxximw445v574ljd6nqs4j3c4rn";
    date = "2018-03-28";
  };

  luhn = buildFromGitHub {
    version = 3;
    rev = "v2.0.0";
    owner  = "calmh";
    repo   = "luhn";
    sha256 = "179qp1rkn185d2xj7djg193y3ia0cdlxw5spp8k7ads4k9yg0xh0";
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
    rev = "lxd-3.0.0";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "084sivbypahhgz299m9ia0chkzvhiw9dqqacnckj6zmhwkcgn53j";
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
    version = 5;
    rev = "v1.1";
    owner  = "pierrec";
    repo   = "lz4";
    sha256 = "0v9bqxkq6l8d04jh951m3aqjjmx0xjfgsg09wgis51k60wpjh89y";
    propagatedBuildInputs = [
      pierrec_xxhash
    ];
  };

  macaroon-bakery_v2 = buildFromGitHub {
    version = 5;
    rev = "v2.0.1";
    owner  = "go-macaroon-bakery";
    repo   = "macaroon-bakery";
    sha256 = "0rdb7as8y25wqb02r553xra1paqmq93n512nrs92yvnjd4511z0l";
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
    version = 5;
    date = "2018-01-20";
    rev = "ab6a47300c1df531e468771e7d08fcd6d33f032e";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "1271ff3nx64gin1z6hhxml1vzyjq934cys8bs02i809zimrwyh2x";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  mage = buildFromGitHub {
    version = 3;
    rev = "v2.0.1";
    owner = "magefile";
    repo = "mage";
    sha256 = "07b1kyaa08fadacypyhvjxywaxw4fd2impdrncvva7vrji5xlzrv";
    excludedPackages = "testdata";
  };

  mapstructure = buildFromGitHub {
    version = 5;
    date = "2018-02-20";
    rev = "00c29f56e2386353d58c599509e8dc3801b0d716";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "034n8nmfbx5873s84ymyxlxv2458ivj21g2wi96dfj425pfa2rsk";
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
    version = 5;
    date = "2018-02-21";
    rev = "7764e6a2216aaa02c36f75aad62538d39c2962c2";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "1cybkgk58ync6r5k2lwz2fw5vl6hmlh0n5yfq0a3wx8jlavl8vlr";
    excludedPackages = "example";
    buildInputs = [
      bigfft
    ];
  };

  maxminddb-golang = buildFromGitHub {
    version = 5;
    rev = "v1.3.0";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "1srrf03bm32dfb8hzpmh698f4vf8aqbxxlqwwdln3z20iagh4fvv";
    propagatedBuildInputs = [
      sys
    ];
  };

  mc = buildFromGitHub {
    version = 6;
    owner = "minio";
    repo = "mc";
    rev = "8aaf909a089e46a8786f1ea06c069582973f51b5";
    sha256 = "0hs6zfwdnhlgka13x3c9vw6fqg73xpw0095i47lj4k3hv4s9fwlh";
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
    date = "2018-03-28";
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

  whyrusleeping_mdns = buildFromGitHub {
    version = 3;
    date = "2017-02-03";
    rev = "348bb87e5cd39b33dba9a33cb20802111e5ee029";
    owner = "whyrusleeping";
    repo = "mdns";
    sha256 = "1vr6p0qjbwq5mk7zsxf40zzhxmik6sb2mnqdggz7r6lp3i7z736l";
    propagatedBuildInputs = [
      dns
      net
    ];
  };

  memberlist = buildFromGitHub {
    version = 5;
    rev = "2288bf30e9c8d7b5f6549bf62e07120d72fd4b6c";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "1kgak886pkig6a52q7jb8h8dfz350j2zl2aq55798l1l0cywhdx4";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
      hashicorp_go-sockaddr
      seed
    ];
    meta.useUnstable = true;
    date = "2018-02-09";
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
    version = 6;
    rev = "v0.3.3";
    owner = "imdario";
    repo = "mergo";
    sha256 = "1nndpa2dx0z13hrhn76yvizi3ngjmfmvkv1w9277k5cvpfvipvf0";
  };

  mesh = buildFromGitHub {
    version = 6;
    rev = "0c91e692ee9e89b956b9c4dfc5feb59a0ff87699";
    owner = "weaveworks";
    repo = "mesh";
    sha256 = "1gpi5svsh6d0j878awyl043fh7kpi5aqzn16nmbp9ksw21xl6xjw";
    date = "2018-03-23";
    propagatedBuildInputs = [
      crypto
    ];
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
    version = 3;
    rev = "r2016.08.01";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "04yl8rdzpwbnxad6dxsxjh0m9ksmzi8pqr24nc9rxn8xg61jfg99";
    goPackagePath = "gopkg.in/mgo.v2";
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
    version = 6;
    owner = "minio";
    repo = "minio";
    rev = "98315b8e60af1acd41aaeb1eba9216f929d2cd69";
    sha256 = "05dg6r2gb1m9h5qk31kywfhhd0nnnv8ya3mx889llqy38gwq52ry";
    propagatedBuildInputs = [
      aliyun-oss-go-sdk
      amqp
      atime
      azure-sdk-for-go
      atomic
      blazer
      cli_minio
      color
      cors
      crypto
      dsync
      elastic_v5
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
      paho-mqtt-golang
      pb
      pq
      profile
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
    date = "2018-04-02";
  };

  # The pkg package from minio, for bootstrapping minio
  minio_pkg = minio.override {
    propagatedBuildInputs = [
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
    rev = "5.0.0";
    sha256 = "194p853mxl97zp4hn20qwizrpirvbbd1mj8q3vcwiz6bc5azv6z1";
    propagatedBuildInputs = [
      crypto
      go-homedir
      ini
      net
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
    version = 6;
    owner = "moby";
    repo = "moby";
    rev = "785b3e32876e10d638d9b1bae00e3f340a2f47ec";
    date = "2018-04-02";
    sha256 = "0k9p9ds0njvw0260scqq59v46jqk27p7xyhmmdmh78d1gz88842r";
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
    version = 5;
    rev = "r3.7.3";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "04k77al89km0zx6llwrb80iczdsgs106phd84l821cxxspfnia7k";
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
    version = 3;
    rev = "v1.0";
    owner = "inconshreveable";
    repo = "mousetrap";
    sha256 = "0a5rc2jmgcdbp28qp5di2znps95gwz2fmv1j0b4xi5k6jrbsyib8";
  };

  mow-cli = buildFromGitHub {
    version = 3;
    rev = "v1.0.3";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "0wff94c1436hrlrb7mwi8s6if49pkfs67cpmy1m5p15f6wycqlhf";
  };

  ns1-go_v2 = buildFromGitHub {
    version = 5;
    rev = "a5bcac82d3f637d3928d30476610891935b2d691";
    owner  = "ns1";
    repo   = "ns1-go";
    sha256 = "03wrg73xg2gl115f1pbz86qzxyjhcac56yc2chkq7ip0xig3pc3w";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2018-03-15";
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

  multiaddr-filter = buildFromGitHub {
    version = 3;
    rev = "e903e4adabd70b78bc9293b6ee4f359afb3f9f59";
    owner  = "whyrusleeping";
    repo   = "multiaddr-filter";
    sha256 = "0p8d06rm2zazq14ri9890q9n62nli0jsfyy15cpfy7wxryql84n7";
    date = "2016-05-16";
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
    version = 5;
    rev = "ddea229ff1dff9e6fe8a6c0344ac73b09e81fce5";
    owner  = "uber-go";
    repo   = "multierr";
    sha256 = "14gj29ikqr1jx7sgyh8zd55r8vn5wiyi0r0dss45fgpn5nnibgxz";
    goPackagePath = "go.uber.org/multierr";
    propagatedBuildInputs = [
      atomic
    ];
    date = "2018-01-22";
  };

  murmur3 = buildFromGitHub {
    version = 5;
    rev = "v1.1";
    owner  = "spaolacci";
    repo   = "murmur3";
    sha256 = "0g576p7ma7r4r1dcbiqi704i3mqnab0nygpya5lrc3g7ia39prmb";
  };

  mux = buildFromGitHub {
    version = 5;
    rev = "v1.6.1";
    owner = "gorilla";
    repo = "mux";
    sha256 = "0mjnfrimyq8ggld7swissyyr9kk8nxy3knv1ndqv8n0h6mfbxkw1";
    propagatedBuildInputs = [
      context
    ];
  };

  mysql = buildFromGitHub {
    version = 5;
    rev = "1a676ac6e4dce68e9303a1800773861350374a9e";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "0j75rdhhz8wphj7r34ysi2g2hfk74yibf0yzj1csax1ij34g941z";
    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';
    date = "2018-03-08";
  };

  names_v2 = buildFromGitHub {
    version = 3;
    date = "2017-11-13";
    rev = "54f00845ae470a362430a966fe17f35f8784ac92";
    owner = "juju";
    repo = "names";
    sha256 = "08qd8wbaasz9pj0kjhbalaj1hxq0qmgg80ch8ljypry0324cqxn4";
    goPackagePath = "gopkg.in/juju/names.v2";
    propagatedBuildInputs = [
      juju_errors
      utils_for_names
    ];
  };

  net-rpc-msgpackrpc = buildFromGitHub {
    version = 3;
    date = "2015-11-16";
    rev = "a14192a58a694c123d8fe5481d4a4727d6ae82f3";
    owner = "hashicorp";
    repo = "net-rpc-msgpackrpc";
    sha256 = "0dlpb20x8c6a6s6crzf2z7dmgb66p9d9zbnb0ipsgd613gaz7ha5";
    propagatedBuildInputs = [
      ugorji_go
      go-multierror
    ];
  };

  netlink = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "1fp489fj5kd4bqf2c7qkhcb12gyndn9s87cv0bmwkxazs5zzrqmh";
    propagatedBuildInputs = [
      netns
      sys
    ];
  };

  netns = buildFromGitHub {
    version = 3;
    rev = "be1fbeda19366dea804f00efff2dd73a1642fdcc";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "1v0azn8ndn1cdx254rs5v9agwqkiwn7bgfrshvx6gxhpghxk1x26";
    date = "2017-11-11";
  };

  nitro = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "nitro";
    rev = "24d7ef30a12da0bdc5e2eb370a79c659ddccf0e8";
    date = "2013-10-03";
    sha256 = "1sbiyzxwca05n06xvfshz19n30qybq8gcyy00hv7hwpflqrjl0ii";
  };

  nodb = buildFromGitHub {
    version = 3;
    owner = "lunny";
    repo = "nodb";
    rev = "fc1ef06ad4af0da31cdb87e3fa5ec084c67e6597";
    date = "2016-06-21";
    sha256 = "116cqkn4yh0n5qrx04kf2rvnb0kplsaps0adarwzci0wnnwgc4gd";
    propagatedBuildInputs = [
      goleveldb
      lunny_log
      go-snappy
      toml
    ];
  };

  nomad = buildFromGitHub {
    version = 5;
    rev = "v0.7.1";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "1d96z1isxyk0bh6rwasai4x3mv9w0aqm304hr4ph1qx0hbglyddw";

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
      osext
      prometheus_client_golang
      raft-boltdb
      raft
      rkt
      runc
      scada-client
      seed
      serf
      snappy
      spec_appc
      srslog
      sync
      sys
      tail
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

    preBuild = ''
      pushd go/src/$goPackagePath
      go list ./... | xargs go generate
      popd
    '';

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
      "api"
      "api/contexts"
      "helper"
      "helper/uuid"
    ];
    propagatedBuildInputs = [
      cronexpr
      go-cleanhttp
      go-multierror
      go-rootcerts
      hcl
    ];
  };

  notify = buildFromGitHub {
    version = 5;
    owner = "zillode";
    repo = "notify";
    date = "2018-03-13";
    rev = "a4d89c12bcfbda5640050eb549079dad19f7741c";
    sha256 = "1vy9l1xalnd6s15ai9f18d4bnk2baipn766sx2w3xnnbcxbfkfzs";
    goPackageAliases = [
      "github.com/rjeczalik/notify"
    ];
    propagatedBuildInputs = [
      sys
    ];
  };

  nuid = buildFromGitHub {
    version = 6;
    rev = "3e58d42c9cfe5cd9429f1a21ad8f35cd859ba829";
    owner = "nats-io";
    repo = "nuid";
    sha256 = "1n4jr4x7s3dcm4z6ac6badsz538acr4ghw0lmv8rmzixv0mxnvd4";
    date = "2018-03-17";
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
    version = 5;
    rev = "v0.1";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "16krz6gc190c870wjvffz8z3n1wrm37qnmp0fy1wr5ds1kvh80qj";
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
    version = 5;
    owner = "chrismalek";
    repo = "oktasdk-go";
    rev = "d0c464c6e7d0c3407d2ec2da7a5818536e600515";
    date = "2018-02-13";
    sha256 = "0cd2h42z9m69g6gmyqf8w9ga24yc53v27bwxx47pf8ynjc63ipaq";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  opencensus = buildFromGitHub {
    version = 6;
    owner = "census-instrumentation";
    repo = "opencensus-go";
    rev = "3caf8526cbb5a05613ed56e43120d22bb903c503";
    sha256 = "1bcldys11x5j5srszj1fz70viqrbjqgp7hcf3pch30izpzfs12h8";
    goPackagePath = "go.opencensus.io";
    subPackages = [
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
      "trace/propagation"
    ];
    propagatedBuildInputs = [
      grpc
      net
    ];
    meta.useUnstable = true;
    date = "2018-04-02";
  };

  open-golang = buildFromGitHub {
    version = 2;
    owner = "skratchdot";
    repo = "open-golang";
    rev = "75fb7ed4208cf72d323d7d02fd1a5964a7a9073c";
    date = "2016-03-02";
    sha256 = "da900f012522dd61cc0504a16bbb137e3ed2173d0715fbf709046a1e0d923ca3";
  };

  openid-go = buildFromGitHub {
    version = 3;
    owner = "yohcop";
    repo = "openid-go";
    rev = "cfc72ed89575fe6b1b7b880d537ba0c5e37f7391";
    date = "2017-09-01";
    sha256 = "0ai04iinihpzxcj1mz8zkx048b5djqc7cyfr34mfibkvzx238jjd";
    propagatedBuildInputs = [
      net
    ];
  };

  openssl = buildFromGitHub {
    version = 6;
    date = "2018-03-29";
    rev = "bed982ee200d16c1cfc6c0845d0be025864c1c1b";
    owner = "10gen";
    repo = "openssl";
    sha256 = "1sq94ml80fhy7jw0lal388m141lhyzna0c6kx46hzhwm52y60ai2";
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
    version = 5;
    owner = "opentracing";
    repo = "opentracing-go";
    rev = "328fceb7548c744337cd010914152b74eaf4c4ab";
    sha256 = "1ydiyq8saja7ch7cjyymzrvmxr4qmwdbv3xd1q6dv43zqs4a1mdq";
    goPackageAliases = [
      "github.com/frrist/opentracing-go"
    ];
    excludedPackages = "harness";
    propagatedBuildInputs = [
      net
    ];
    date = "2018-03-15";
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
    version = 5;
    rev = "40d624026db6bba02e9ad012a27ed01ca9f4984b";
    owner = "pquerna";
    repo = "otp";
    sha256 = "1a861abj0hb0xaa0fvxymfl99hrz862y0bm55fygsnprqmb50vsm";
    propagatedBuildInputs = [
      barcode
    ];
    date = "2018-02-20";
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
    version = 6;
    owner = "eclipse";
    repo = "paho.mqtt.golang";
    rev = "v1.1.1";
    sha256 = "0nqziiql7fvkwr69hx3jd4q79lk2qxxspiijkdq1k7f5dsr6j3ls";
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
    version = 5;
    owner = "cheggaaa";
    repo = "pb";
    date = "2018-03-05";
    rev = "75a8cbd866a7bad0d4a3b2b8cb6cab48a1475155";
    sha256 = "12pl91n0pd161vzwdlgbklvhmn267ir9zy5hgr0jnz845dvyhi98";
    propagatedBuildInputs = [
      go-runewidth
      sys
    ];
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 5;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.22";
    sha256 = "0ccj5h9x88dq6pf4j1b5v706vybx793d291bafkkn6wd7f6k3x8c";
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
    version = 5;
    date = "2018-03-01";
    owner  = "xiaq";
    repo   = "persistent";
    rev = "cd415c64068256386eb46bbbb1e56b461872feed";
    sha256 = "1nha332n4n4px21cilixy4y2zjjja79vab03f4hlx08syfyq5yqk";
  };

  persistent-cookiejar = buildFromGitHub {
    version = 3;
    date = "2017-10-26";
    owner  = "juju";
    repo   = "persistent-cookiejar";
    rev = "d5e5a8405ef9633c84af42fbcc734ec8dd73c198";
    sha256 = "1knkwj44wq85wkxb69v3yh5v9ddix63a2saq49077yd7l13j6rmd";
    excludedPackages = "test";
    propagatedBuildInputs = [
      errgo_v1
      go4
      net
      retry_v1
    ];
  };

  pester = buildFromGitHub {
    version = 5;
    owner = "sethgrid";
    repo = "pester";
    rev = "ed9870dad3170c0b25ab9b11830cc57c3a7798fb";
    date = "2018-02-27";
    sha256 = "018wg5477mjvf2j51ph2bk48mahgf13h1pbbpdybgdfqlganndsb";
  };

  pfilter = buildFromGitHub {
    version = 3;
    owner = "AudriusButkevicius";
    repo = "pfilter";
    rev = "0.0.3";
    sha256 = "0r3isyy0vnsam0ycr6kf3748gaz1d5r3rd45zi2xg4pa4q17lwaf";
  };

  pflag = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "pflag";
    rev = "1cd4a0c365d95803411bec89fb7b76bade17053b";
    sha256 = "1blwknf4gm8g2x0cpz7ipiwci8bm8hv0bs8p236sndsrwmmj87hh";
    date = "2018-03-30";
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
    version = 5;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "1d5002593acb237433a98512c6343587b03ebe5d";
    date = "2018-02-23";
    sha256 = "0z9jbpw7jpa7ja66bmbc0ci67bhzyxn9lgypns2111krni7m318y";
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
    version = 5;
    date = "2018-01-08";
    owner  = "coreos";
    repo   = "pkg";
    rev = "97fdf19511ea361ae1c100dd393cc47f8dcfa1e1";
    sha256 = "0y3day5j98a52dpf8y4rcp9ayizgml02vljg4rfvfl26wg11rlsr";
    buildInputs = [
      crypto
      yaml_v1
    ];
    propagatedBuildInputs = [
      go-systemd_journal
    ];
  };

  plz = buildFromGitHub {
    version = 5;
    owner  = "v2pro";
    repo   = "plz";
    rev = "0.9.1";
    sha256 = "0blavw4cyw7n46n81q7rjmn3jb8dgs24mcvkk80baj5xflbrn2x8";
    excludedPackages = "\\(witch\\|test\\|dump\\)";
  };

  poly1305 = buildFromGitHub {
    version = 5;
    rev = "6cf43fdfd7a228cf3003ae23d10ddbf65e85997b";
    owner  = "aead";
    repo   = "poly1305";
    sha256 = "07wx10yqr1mmb35i6z8s6wsragn2x9ly7g119rw0dymcbcsp64dz";
    date = "2017-07-15";
  };

  pongo2 = buildFromGitHub {
    version = 6;
    rev = "97eac295f74b5fbb7fd3113e35f4ccf3c816e389";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "06nnhmqxvsc6sgs80i6yldjpk0ng6j89iwqrgp5h97jzxzmszvs5";
    date = "2018-02-16";
    propagatedBuildInputs = [
      juju_errors
    ];
  };

  pprof = buildFromGitHub {
    version = 6;
    rev = "36d5638be8576a5a3d915cddcdd75329165907b1";
    owner  = "google";
    repo   = "pprof";
    sha256 = "15pp3f7hicig8syxpprwkpd03sqn2bbcc4nl7vcbyxq9npmvdimc";
    date = "2018-04-02";
    propagatedBuildInputs = [
      demangle
    ];
  };

  pq = buildFromGitHub {
    version = 6;
    rev = "d34b9ff171c21ad295489235aec8b6626023cd04";
    owner  = "lib";
    repo   = "pq";
    sha256 = "134lqw3f9j8bdxghzddr3dx713lbzpi5f4s7c9x85mgvk0v252pj";
    date = "2018-03-27";
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
    version = 6;
    rev = "780932d4fbbe0e69b84c34c20f5c8d0981e109ea";
    date = "2018-03-21";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "17fbm5v73071zh8sw75ir0rbkpwm8zdzksbsy944d1m2g2vddfq4";
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
    rev = "30d42a105341e640d284d9920da2078029764980";
    sha256 = "162rlxy065dq1acdwcr9y9lc6zx2pjqdqvngrq6bnrargw15avid";
    date = "2017-11-15";
  };

  prometheus = buildFromGitHub {
    version = 5;
    rev = "v2.2.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "1nym99y77v7ccnnjvsnb1j806w1nm6gzhvzkvl8srvh7r96a03fq";
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
      kit_for_prometheus
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
    rev = "f504d69affe11ec1ccb2e5948127f86878c9fd57";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "0bc97fwvjgikbwf0jalj47qvlgq4wyikdqfygdqq56glqghzfz72";
    propagatedBuildInputs = [
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      perks
    ];
    date = "2018-03-28";
  };

  prometheus_client_model = buildFromGitHub {
    version = 3;
    rev = "99fa1f4be8e564e8a6b613da7fa6f46c9edafc6c";
    date = "2017-11-17";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "0axllq8fkndw91p52cg9bq1r812r2sfy7a3vy5sbmw1iyifbic1c";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 6;
    date = "2018-03-26";
    rev = "38c53a9f4bfcd932d1b00bfc65e256a7fba6b37a";
    owner = "prometheus";
    repo = "common";
    sha256 = "1v4xw2bmwgfrbg7063r14pmzxjq247hna94gx7ha4mb7mf6cw9cp";
    buildInputs = [
      errors
      kit_for_prometheus
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

  prometheus_tsdb = buildFromGitHub {
    version = 5;
    date = "2018-03-15";
    rev = "195bc0d286b077f5633eb4bda76743620588b2fa";
    owner = "prometheus";
    repo = "tsdb";
    sha256 = "0giad787bl8gqfdqp5qsycwixxg6m62hyvnrf01d9wbglwihmbyq";
    propagatedBuildInputs = [
      cespare_xxhash
      errors
      kingpin_v2
      kit_for_prometheus
      lockfile
      prometheus_client_golang
      sync
      sys
      ulid
    ];
  };

  properties = buildFromGitHub {
    version = 5;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.6";
    sha256 = "1bnvwplxrp88vnmmaygfk08a93jai7pgbgryjc6wyxqd91716rpl";
  };

  prose = buildFromGitHub {
    version = 3;
    owner = "jdkato";
    repo = "prose";
    rev = "v1.1.0";
    sha256 = "08daklyimc51cxmv72hfnhsdaq9k5ps5d73am53kz7dsl838zrki";
    propagatedBuildInputs = [
      urfave_cli
      go-shuffle
      sentences_v1
      stats
    ];
  };

  gogo_protobuf = buildFromGitHub {
    version = 5;
    owner = "gogo";
    repo = "protobuf";
    rev = "v1.0.0";
    sha256 = "1cfng3fx9mgi96bbi0z5phlz2bylfmgy80rzmwb2jqryafdgms2b";
    excludedPackages = "test";
  };

  protobuild = buildFromGitHub {
    version = 3;
    rev = "dd989eff46b904de37a40c429288f7f2e5256ac5";
    date = "2017-09-06";
    owner = "stevvooe";
    repo = "protobuild";
    sha256 = "09jw4n6jlp11h7pjirvmwv38kjxxgl5wmlg7lhvgiahh57wz42yb";
    propagatedBuildInputs = [
      protobuf
      gogo_protobuf
      toml
    ];
    postPatch = ''
      sed -i "s,/usr/local,${pkgs.protobuf-cpp},g" descriptors.go
    '';
  };

  pty = buildFromGitHub {
    version = 5;
    owner = "kr";
    repo = "pty";
    rev = "v1.1.1";
    sha256 = "0k507mp3j6vbx7vdlhp6dpbr5syh4zn14c1rqgf1p5jbh3raqbxb";
  };

  purell = buildFromGitHub {
    version = 5;
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "975f53781597ed779763b7b65566e74c4004d8de";
    sha256 = "01bdjh5g5gx8b0jszxp4bz8l5y62q7mca5q9h607wn2lynz0akfx";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
    date = "2018-03-10";
  };

  qart = buildFromGitHub {
    version = 3;
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "0iba8lcrc79p5pzc35bnkphn6lnccnz0d2da6ypzv9xn6phyja3z";
  };

  qingstor-sdk-go = buildFromGitHub {
    version = 5;
    rev = "v2.2.10";
    owner  = "yunify";
    repo   = "qingstor-sdk-go";
    sha256 = "09c2dk3lm7malbpwwrvhng9jqb2qn0akcvpg8wjvnz58la86y09i";
    excludedPackages = "test";
    propagatedBuildInputs = [
      go-shared
      logrus
      yaml_v2
    ];
  };

  ql = buildFromGitHub {
    version = 5;
    rev = "eccf3e9caa43fab70d7ddfdee5c3fb73fc76c2a1";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "10hmyhflysfmvdkp246jvhp17gfl51ix2vg8dnfa13lz4ymn41gz";
    propagatedBuildInputs = [
      b
      exp
      go4
      golex
      lldb
      mathutil
      strutil
    ];
    postPatch = ''
      rm -r vendored
      sed -i 's,github.com/cznic/ql/vendored/,,' file.go
    '';
    date = "2018-02-28";
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
    version = 3;
    rev = "2caba252f4dc53eaf6b553000885530023f54623";
    owner  = "alexcesaro";
    repo   = "quotedprintable";
    sha256 = "1vxbp1n7439gb3vwynqaxdqcv0xlkzzxv88mpcvhsshzbiqhb1cs";
    goPackagePath = "gopkg.in/alexcesaro/quotedprintable.v3";
    date = "2015-07-16";
  };

  rabbit-hole = buildFromGitHub {
    version = 5;
    rev = "8ea6071d12bbf59ed5a948573bc0e3c350bbbc32";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "0zbmri6wimpw12kna6vbr9jpszwb2452r9bf7kqii9gmygwjdvyf";
    date = "2018-03-09";
  };

  radius = buildFromGitHub {
    version = 6;
    rev = "ffa36398b7877e988e31f3b8da7782eb083ce692";
    date = "2018-03-30";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "008mq0y5dl5fhhn7hn6zk11f7as5bpvf58i9l8jmpcf4qh3a8mx7";
    goPackagePath = "layeh.com/radius";
  };

  raft = buildFromGitHub {
    version = 5;
    date = "2018-02-12";
    rev = "a3fb4581fb07b16ecf1c3361580d4bdb17de9d98";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "17gx1nn3wgma4j3iqcpviyxjyy4zava69zx0gskvpxvp94cf9p53";
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
    version = 3;
    date = "2017-10-10";
    rev = "6e5ba93211eaf8d9a2ad7e41ffad8c6f160f9fe3";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "08k5ax1iwpwxhb7rmjmgbdb4ywlqpgdj4yj95f0ppyw0jcskv3dc";
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft
    ];
  };

  raft-http = buildFromGitHub {
    version = 6;
    date = "2018-02-14";
    rev = "e4290d0af830073ec140538e8974aa4393495ea1";
    owner  = "CanonicalLtd";
    repo   = "raft-http";
    sha256 = "1344f97ayn8lyvps47vjilfi68wfxha906fwdprjibv6l8yv18i6";
    propagatedBuildInputs = [
      errors
      raft
      raft-membership
    ];
    postPatch = ''
      rm testing.go
    '';
  };

  raft-membership = buildFromGitHub {
    version = 6;
    date = "2018-02-12";
    rev = "26ef52960f54c472f52fb3701f19f25319e1032e";
    owner  = "CanonicalLtd";
    repo   = "raft-membership";
    sha256 = "1n8q8aq2qr0cxn1zk05f391dqz758svqypdqcrdb7nhyakl88691";
    propagatedBuildInputs = [
      raft
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
    version = 5;
    rev = "1.0.1";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0lg302miyrkff04a1jqfrz1kdb96miw7qrm3x3g21n7w3vp40y4g";
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
    version = 6;
    owner = "ncw";
    repo = "rclone";
    date = "2018-04-02";
    rev = "06a8d3011d0673b339a0bbba0f99e47fca41c303";
    sha256 = "0hilpngclsqj8yawbm5s1bynb7xjh9zzikcan59gqw0cxccw1y9f";
    propagatedBuildInputs = [
      appengine
      aws-sdk-go
      bbolt
      cgofuse
      cobra
      crypto
      eme
      errors
      ewma
      fs
      ftp
      fuse
      go-acd
      go-cache
      go-daemon
      go-http-auth
      goconfig
      google-api-go-client
      net
      oauth2
      open-golang
      pflag
      qingstor-sdk-go
      sdnotify
      sftp
      ssh-agent
      swift
      sys
      tb
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
    version = 3;
    date = "2015-03-07";
    rev = "fc89ed2e418d27e3ea76e708e54276d2b44ae9cf";
    owner = "siddontang";
    repo = "rdb";
    sha256 = "0q2jpnjyr1gqjl50m3xwa3mqwryn14i9jcl7nwxw0yvxh6vlvnhh";
    propagatedBuildInputs = [
      cupcake_rdb
    ];
  };

  redigo = buildFromGitHub {
    version = 6;
    owner = "garyburd";
    repo = "redigo";
    date = "2018-03-20";
    rev = "e8e59ed1cd89662b75af5d1109e39e5dc148cc00";
    sha256 = "16xywgbpyp2g4qns3pjwsj1ixdn9c1l3041l2jwlgq9wzy992ffx";
    meta.useUnstable = true;
  };

  redis_v2 = buildFromGitHub {
    version = 3;
    rev = "v2.3.2";
    owner  = "go-redis";
    repo   = "redis";
    sha256 = "1svhq879d7r2paj2q9h8qy3h2lf90dmkncb7a87na86z2dikhll2";
    goPackagePath = "gopkg.in/redis.v2";
    propagatedBuildInputs = [
      bufio_v1
    ];
  };

  klauspost_reedsolomon = buildFromGitHub {
    version = 5;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2017-12-19";
    rev = "0b30fa71cc8e4e9010c9aba6d0320e2e5b163b29";
    sha256 = "1dki3v9qjx47lwr4d0bb05r7bncl4yy6issnf05dc706aara4mr6";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  reflect2 = buildFromGitHub {
    version = 5;
    rev = "1.0.0";
    owner  = "modern-go";
    repo   = "reflect2";
    sha256 = "0algyl8i67y5i6c28c2hf31i9jxqb3q2pi1acz1y2b5hrj68w6wz";
    propagatedBuildInputs = [
      concurrent
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

  resize = buildFromGitHub {
    version = 5;
    owner = "nfnt";
    repo = "resize";
    date = "2018-02-21";
    rev = "83c6a9932646f83e3267f353373d47347b6036b2";
    sha256 = "051hb20f94gy5s8ng9x9zldikwrva10nq0mg9qlv6g7h99yl5xia";
  };

  retry_v1 = buildFromGitHub {
    version = 5;
    owner = "go-retry";
    repo = "retry";
    rev = "v1.0.0";
    sha256 = "181q1f5w65j1y068rz8rm1yv8rpm86fbzfmb81h03jh0s5w14w6d";
    goPackagePath = "gopkg.in/retry.v1";
  };

  rkt = buildFromGitHub {
    version = 6;
    owner = "rkt";
    repo = "rkt";
    rev = "66c30d3a2339ced87eae722e8bd3920ee527d938";
    sha256 = "12w8wp13i6vdim00f3b1nyg4b0i64fys0ycl9n4m2rvkjgjn7887";
    subPackages = [
      "api/v1"
      "networking/netinfo"
    ];
    propagatedBuildInputs = [
      cni
    ];
    meta.useUnstable = true;
    date = "2018-03-27";
  };

  roaring = buildFromGitHub {
    version = 3;
    rev = "v0.3.16";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "125vrshk7a09w0q6171hlng0z6xvlk74qcxl7bw0dygl62w48gs5";
    propagatedBuildInputs = [
      go-unsnap-stream
      msgp
    ];
  };

  rollinghash = buildFromGitHub {
    version = 5;
    rev = "v3.0.1";
    owner  = "chmduquesne";
    repo   = "rollinghash";
    sha256 = "0vypx2hv37fqhrfcvqy208bvyvq25zr9w830xfmh6nscxb9dfrdd";
    propagatedBuildInputs = [
      bytefmt
    ];
  };

  roundtrip = buildFromGitHub {
    version = 3;
    owner = "gravitational";
    repo = "roundtrip";
    rev = "0.0.2";
    sha256 = "12qqkm9pn398g5bfnaknynii4yqc2sa1i8qhzpp8jkdqf3bczcvz";
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

  run = buildFromGitHub {
    version = 5;
    rev = "v1.0.0";
    owner = "oklog";
    repo = "run";
    sha256 = "0m6zlr3dric91r1fina1ng26zj7zpq97rqmnxgxj5ylmw3ah3jw9";
  };

  runc = buildFromGitHub {
    version = 6;
    rev = "cc4307ab6643668ce5abc6b524e1764a54c32550";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "06ms3kb4hjg7hbbz5hzdyns7c5sb2w9690wh837ldn48fv3nfj32";
    propagatedBuildInputs = [
      urfave_cli
      console
      dbus
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
    date = "2018-04-03";
    postPatch = ''
      grep -q 'unix.SIGUNUSED' signalmap.go
      sed -i '/unix.SIGUNUSED/d' signalmap.go
    '';
  };

  runtime-spec = buildFromGitHub {
    version = 6;
    rev = "a1998ecf27964b493231626886dea534e2cfadc2";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "1fqypfsi116h9q867jmap27aprmkh6kwnl8pd3j1c6qi321yqpz6";
    buildInputs = [
      gojsonschema
    ];
    #meta.autoUpdate = false;
    date = "2018-04-06";
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
    version = 3;
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "86672fcb3f950f35f2e675df2240550f2a50762f";
    date = "2017-09-18";
    sha256 = "1wz3vr7cm291bmrc7xd6v6vb5fk66iqjkky34snfkv5k1bvqlkqv";
  };

  sarama_v1 = buildFromGitHub {
    version = 5;
    owner = "Shopify";
    repo = "sarama";
    rev = "v1.16.0";
    sha256 = "0ns2cr1qzsslcdgfwbfwjffx2h3a1ywwlrlx3iky8m095qwd9d5g";
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
    version = 3;
    date = "2016-06-01";
    rev = "6e896784f66f82cdc6f17e00052db91699dc277d";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "0qafn7fq202skkdrvsgacifbpznclx6cqkscahldaan2rc2rglys";
    buildInputs = [
      armon_go-metrics
    ];
    propagatedBuildInputs = [
      net-rpc-msgpackrpc
      hashicorp_yamux
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
    version = 5;
    owner = "ishidawataru";
    repo = "sctp";
    rev = "07191f837fedd2f13d1ec7b5f885f0f3ec54b1cb";
    sha256 = "4ff89c03e31decd45b106e5c70d5250e131bd05162b1d42f55ba176231d85299";
    date = "2018-02-18";
    meta.autoUpdate = false;
  };

  sdnotify = buildFromGitHub {
    version = 3;
    rev = "ed8ca104421a21947710335006107540e3ecb335";
    owner = "okzk";
    repo = "sdnotify";
    sha256 = "089plny2r6hf1h8zwf97zfahdkizvnnla4ybd04likinvh45hb38";
    date = "2016-08-04";
  };

  seed = buildFromGitHub {
    version = 2;
    rev = "e2103e2c35297fb7e17febb81e49b312087a2372";
    owner = "sean-";
    repo = "seed";
    sha256 = "0hnkw8zjiqkyffxfbgh1020dgy0vxzad1kby0kkm8ld3i5g0aq7a";
    date = "2017-03-13";
  };

  selinux = buildFromGitHub {
    version = 6;
    rev = "76b408a8e68e301b8245ba414ab600a0d1d797d9";
    owner = "opencontainers";
    repo = "selinux";
    sha256 = "0n8w5vzzfmnvs2l25dbq3nhr9rk64pcdi1wv412i5h0yyxl6z5qs";
    date = "2018-01-04";
  };

  semver = buildFromGitHub {
    version = 5;
    rev = "c5e971dbed7850a93c23aa6ff69db5771d8e23b3";
    owner = "blang";
    repo = "semver";
    sha256 = "16mdgsmh63alzrdisqygnqbi1ls4f56fwd6lhkvsbbbh944a6krl";
    date = "2018-03-05";
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
    version = 5;
    rev = "3b250ce4404edb266330f53fcfc8ad0d0dacfae7";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "0gpky6sq85m8sa1022x745qifrisrypbx9z19glwrbgvyla38wxn";

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
    date = "2018-02-27";
  };

  service = buildFromGitHub {
    version = 6;
    rev = "615a14ed75099c9eaac6949e22ac2341bf9d3197";
    owner  = "kardianos";
    repo   = "service";
    sha256 = "0ncwicq2rf2gna88hiwg1dy56d363b7w7v3dnc34h8lfh4p66wba";
    date = "2018-03-20";
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
    version = 2;
    rev = "b8e286a0dba8f4999042d6b258daf51b31d08938";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "12a9irqcs1jsvxpfb6i1357r5xn14qchn4k9a211f4w1ddgiiw7d";
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
    version = 5;
    owner = "pkg";
    repo = "sftp";
    rev = "1.5.0";
    sha256 = "1syfqays36s6r30qxflz6idbjlxn0g8x8nwlzcwhnfjxh74iw4g9";
    propagatedBuildInputs = [
      crypto
      errors
      fs
    ];
  };

  sha256-simd = buildFromGitHub {
    version = 5;
    owner = "minio";
    repo = "sha256-simd";
    date = "2017-12-13";
    rev = "ad98a36ba0da87206e3378c556abbfeaeaa98668";
    sha256 = "1qprs68yr4md5mvqsj7nlzkc708l1kas44n242fzlfy51bix1xwn";
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
      unidecode
    ];
  };

  smartcrop = buildFromGitHub {
    version = 5;
    rev = "f6ebaa786a12a0fdb2d7c6dee72808e68c296464";
    owner  = "muesli";
    repo   = "smartcrop";
    sha256 = "1fcbivf87z5kx9y87xmgmnfqp3llnrpm1jv5ci5g1czz9dggzh4b";
    date = "2018-02-28";
    propagatedBuildInputs = [
      image
      resize
    ];
  };

  smux = buildFromGitHub {
    version = 5;
    rev = "v1.0.7";
    owner  = "xtaci";
    repo   = "smux";
    sha256 = "0ql428xn5r714nq8imw25gmgfddz00jkllrldg9clz94wnpmm9ly";
    propagatedBuildInputs = [
      errors
    ];
  };

  softlayer-go = buildFromGitHub {
    version = 6;
    date = "2018-03-31";
    rev = "b248bb399df4971d7911ba775b187ecee6260e75";
    owner = "softlayer";
    repo = "softlayer-go";
    sha256 = "1bh3mwf04pz4cx2b6scp21079m0q21q3w0g79rz84md01nsklzpf";
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
    date = "2017-11-03";
    rev = "081216856ee01315ad130cb9ccd5d2a40624c619";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "0ikfdrly4qnsvvri96jcz9d7lgpbf9xl9x82y23lpcrd1fwkis39";
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

  spec_appc = buildFromGitHub {
    version = 3;
    rev = "v0.8.11";
    owner  = "appc";
    repo   = "spec";
    sha256 = "1zglgv1nazzh1sm1p10vpz371njxd2xhh6lhqlsc5zqlk3h2qdzb";
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
    date = "2018-03-26";
    rev = "9acd88844bc186c3ec7f318cd3d56f1114b4ab99";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "0swdw08lxcz5iqi1vk46aga25pqb8s5f6xigrfcx1zzb8dlnzi2w";
    propagatedBuildInputs = [
      jsonpointer
      jsonreference
      swag
    ];
  };

  srslog = buildFromGitHub {
    version = 5;
    rev = "f6152a1bd05565e87729ad672a792b951046d235";
    date = "2018-01-18";
    owner  = "RackSec";
    repo   = "srslog";
    sha256 = "0v9f0v51q1rnsbs671zvmdbn7whrlmmc65drpjsac7bszhirihfv";
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
    rev = "v1.7.0";
    owner = "go-stack";
    repo = "stack";
    sha256 = "12mzkgxayiblwzdharhi7wqf6wmwn69k4bdvpyzn3xyw5czws9z3";
  };

  stathat = buildFromGitHub {
    version = 3;
    date = "2016-07-15";
    rev = "74669b9f388d9d788c97399a0824adbfee78400e";
    owner = "stathat";
    repo = "go";
    sha256 = "1sj08j6pqq43x3d73ql0y947lvwn5xybvf7waqc7nixvjxla0mcp";
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
    rev = "1bf9dbcd8cbe1fdb75add3785b1d4a9a646269ab";
    owner = "montanaflynn";
    repo = "stats";
    sha256 = "1bc074vn5dsfylg3kjjvz7z7p9pqhz6v81i5klq141587nz7vksw";
    date = "2017-12-01";
  };

  structs = buildFromGitHub {
    version = 5;
    rev = "ebf56d35bba727c68ac77f56f2fcf90b181851aa";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "0n7y3m141mzl5r9a19ffvdrb9ifqvk52ba2br6f9l2vy6q8d07sc";
    date = "2018-01-23";
  };

  stump = buildFromGitHub {
    version = 3;
    date = "2016-06-11";
    rev = "206f8f13aae1697a6fc1f4a55799faf955971fc5";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "0vxx2mf7pz5b33icjy3sc6ndm6ahrhqzmgb1kmnlnjxs1ilmca53";
  };

  strutil = buildFromGitHub {
    version = 3;
    date = "2017-10-16";
    rev = "529a34b1c186b483642a7a230c67521d9aa4b0fb";
    owner = "cznic";
    repo = "strutil";
    sha256 = "09wimc44daxzmn560s7wffbijqacw1apvsmvrinc1ypllqxmymsl";
  };

  suture = buildFromGitHub {
    version = 5;
    rev = "bb8f53725a7667da6eda75187ecd07811a29d274";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "1mz1hn32018i05hm854kjm5vcdsv2f9qg7hvg0nsgw1vcv306z02";
    date = "2018-01-03";
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
    version = 5;
    rev = "ceb469cb0fdf2d792f28d771bc05da6c606f55e5";
    owner = "go-openapi";
    repo = "swag";
    sha256 = "0c9k8d58if8xirhpxmp0fzp9vlml027icrgclff9gk2f78cbkb7z";
    date = "2018-03-02";
    propagatedBuildInputs = [
      easyjson
      yaml_v2
    ];
  };

  swarmkit = buildFromGitHub {
    version = 6;
    rev = "a57b79c2e4e9ae7df2096b69f50eef0b8b5e4ff8";
    owner = "docker";
    repo = "swarmkit";
    sha256 = "0sxz7ax5id21rclxm1al1da59pifkvc8c0ymf6z04jgs6awl70zk";
    date = "2018-04-02";
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
      "fips"
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
    rev = "b2a7479cf26fa841ff90dd932d0221cb5c50782d";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "1rj3zc0yhryw0zhbnrq0w5d6a4qylj4hxk582vszad95kmfi4j56";
    date = "2018-03-27";
  };

  syncthing = buildFromGitHub rec {
    version = 5;
    rev = "v0.14.45";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "0q4ib9jakppkpjm5qz0fkr7llxjrhyqw9fsqhg97p40n74a209dp";
    buildFlags = [ "-tags noupgrade" ];
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
      go-stun
      gogo_protobuf
      goleveldb
      groupcache
      kcp-go
      luhn
      net
      notify
      osext
      pfilter
      pq
      prometheus_client_golang
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

  tablewriter = buildFromGitHub {
    version = 5;
    rev = "b8a9be070da40449e501c3c4730a889e42d87a9e";
    date = "2018-01-30";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "0w53s805id9xj4kfasgsq53ymiigimqf57n5kqwkk3q6fxbpgdrq";
    propagatedBuildInputs = [
      go-runewidth
    ];
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
    version = 6;
    rev = "da98221b13fe8e6f9981d712ddac0f0329d7a45a";
    date = "2018-03-23";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "1jdcjn0mymz6bsmlsifj9x7w0yn3vd0q9q81j07pi9fanyp8xr31";
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
    version = 6;
    rev = "v2.5.6";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "d2821f3231ea1b5a76db2b1f1fbd53d5697703b014900a1cf5a92e5b8700c1a6";
    nativeBuildInputs = [
      pkgs.protobuf-cpp
      gogo_protobuf.bin
      pkgs.zip
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
      logrus
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
    patches = [
      (fetchTritonPatch {
        rev = "ef43c5626941774c41bdbdda0a59d18c220fe742";
        file = "t/teleport/2.5.2.patch";
        sha256 = "c6a045be6770316942ba533f6c3450ea4871a27b5124c5562d86d094bc15dcc4";
      })
    ];
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
    version = 3;
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "1wp7bswkmzm8rzzz0pg10w7092mbjv1l5gdwv7nncxapr9wbdigr";
    date = "2016-04-05";
  };

  termbox-go = buildFromGitHub {
    version = 5;
    rev = "e2050e41c8847748ec5288741c0b19a8cb26d084";
    date = "2018-03-03";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "1jk38dy0zpsapqmv4sckwszskba4ngza69v3zzy9j8hw6k7av04n";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 5;
    rev = "v1.2.1";
    owner = "stretchr";
    repo = "testify";
    sha256 = "0f0alv3mrz38f71wb8zlavy75p27am96rgq24qbbd4mkr3pin9as";
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

  thrift = buildFromGitHub {
    version = 3;
    rev = "0.11.0";
    owner  = "apache";
    repo   = "thrift";
    sha256 = "0a3yk479zkyak9g7rakif60dpci29rhmqn3iq8w5afdfyfmj9cfm";
    subPackages = [
      "lib/go/thrift"
    ];
    propagatedBuildInputs = [
      net
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

  times = buildFromGitHub {
    version = 3;
    rev = "d25002f62be22438b4cd804b9d3c8db1231164d0";
    date = "2017-02-15";
    owner  = "djherbis";
    repo   = "times";
    sha256 = "0cy5z8zba7mgxm4fwad3fd698jyr5gmr2i4j2zisffg5j4xsn631";
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
    version = 3;
    rev = "c5a927568de7aad8a58127d80bcd36ca4e71e454";
    date = "2013-12-01";
    owner = "ChimeraCoder";
    repo = "tokenbucket";
    sha256 = "1rc2kdapbr8aw8sf1y5gpqjq4absx57aabr8qg74v9hqirqy9nmp";
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
    version = 3;
    date = "2014-10-24";
    rev = "dd632973f1e7218eb1089048e0798ec9ae7dceb8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "17ij7zjw58949hrjmq4kjysnd7cqrawlzmwafrf4msxi1mylkk7q";
    goPackagePath = "gopkg.in/tomb.v1";
  };

  toml = buildFromGitHub {
    version = 2;
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.3.0";
    sha256 = "1cnryizxrj7si27knhh83dd03abw5r0yhac2vmv861inpl3lflx2";
    goPackageAliases = [
      "github.com/burntsushi/toml"
    ];
  };

  trace = buildFromGitHub {
    version = 6;
    owner = "gravitational";
    repo = "trace";
    rev = "1.1.4";
    sha256 = "1svspbnjy7yr1jwp7rha34wgj42s1y6vzjy3wymk9azry6g2g6vk";
    propagatedBuildInputs = [
      clockwork
      grpc
      logrus
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
    rev = "505f0eee75dcba5ccb00cf81eea7f5b836b28e7c";
    owner  = "xlab";
    repo   = "treeprint";
    sha256 = "0zadq4cnqpmjy9cp6l497fa30l8wmkw9lil0g437f128x15fcf6b";
    date = "2018-03-24";
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

  triton-go = buildFromGitHub {
    version = 6;
    rev = "1.2.0";
    owner  = "joyent";
    repo   = "triton-go";
    sha256 = "06mygzv2wr4aq36zyg00s3wsxvnx4wb70f24m6g5b6gdgna04cxd";
    excludedPackages = "test";
    propagatedBuildInputs = [
      crypto
      errors
    ];
  };

  gravitational_ttlmap = buildFromGitHub {
    version = 3;
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

  ulid = buildFromGitHub {
    version = 5;
    rev = "7e1bd8a9a281b5abdf651a430b918bb0ecdbceda";
    owner = "oklog";
    repo = "ulid";
    sha256 = "1dfpjnw44n1ffx7gxbh0gibkjain70dsljx8dp187waasljbfwg0";
    date = "2018-03-14";
    propagatedBuildInputs = [
      getopt
    ];
  };

  unidecode = buildFromGitHub {
    version = 3;
    rev = "cb7f23ec59bec0d61b19c56cd88cee3d0cc1870c";
    owner = "rainycape";
    repo = "unidecode";
    sha256 = "0ldjpakbmw0kkmcgcfnp4agjilr6lx9z53dcmcnvimshlgbafms2";
    date = "2015-09-07";
  };

  units = buildFromGitHub {
    version = 3;
    rev = "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a";
    owner = "alecthomas";
    repo = "units";
    sha256 = "180b1kxzm03hr4jsy2nnh23g3a3rr0xdlg004a6vla4qvbysj7jh";
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

  usso = buildFromGitHub {
    version = 3;
    rev = "5b79b358f4bb6735c1b00f6ad051c07c1a1a03e9";
    owner = "juju";
    repo = "usso";
    sha256 = "0q450q292i3ih20n50rf2rc1d3idf1kl8ky2jwrf6r2aq49zw82x";
    date = "2016-04-18";
    propagatedBuildInputs = [
      errgo_v1
      openid-go
    ];
  };

  utils = buildFromGitHub {
    version = 5;
    rev = "d18e608d01400189bcda3e2669505cbd30e9dda9";
    owner = "juju";
    repo = "utils";
    sha256 = "1llv1zcp56gyx8h9z8khcwyjh2fp914nn2qnrw7g1yjjcr258iax";
    date = "2018-02-07";
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
    version = 3;
    rev = "6c6132ff69f0f6c088739067407b5d32c52e1d0f";
    owner = "dimchansky";
    repo = "utfbom";
    sha256 = "0hibb137n78v50hznzh7080346jgllv6da8wlpr000ajypzw228a";
    date = "2017-03-28";
  };

  google_uuid = buildFromGitHub {
    version = 6;
    rev = "dec09d789f3dba190787f8b4454c7d3c936fed9e";
    owner = "google";
    repo = "uuid";
    sha256 = "06y940a5bsy0zhbpbp7v9n4a2n7d9x1wg1j3cij817ij547llrn0";
    date = "2017-11-29";
    goPackageAliases = [
      "github.com/pborman/uuid"
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 6;
    rev = "c65b2f87fee37d1c7854c9164a450713c28d50cd";
    owner = "pborman";
    repo = "uuid";
    sha256 = "1d73sl1nzmn38rgp2yl5iz3m6bpi80m6h4n4b9a4fdi9ra7f3kzm";
    date = "2018-01-22";
  };

  validator_v2 = buildFromGitHub {
    version = 3;
    rev = "460c83432a98c35224a6fe352acf8b23e067ad06";
    owner = "go-validator";
    repo = "validator";
    sha256 = "0fsicvc6vciyyv0i19v8a572c3z8kxvayf626md8cz44fz3jrdxn";
    goPackagePath = "gopkg.in/validator.v2";
    date = "2017-08-14";
  };

  vault = buildFromGitHub {
    version = 6;
    rev = "v0.9.6";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "1x4nldjnwxgf655nr7wvnplxkp3zm3qf16ma6bm95z3wlbal2mcf";

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
      keybase_go-crypto
      kr_text
      go-errors
      go-github
      go-glob
      go-hclog
      go-hdb
      go-homedir
      go-memdb
      go-mssqldb
      go-multierror
      go-okta
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
      logxi
      mapstructure
      mgo_v2
      mitchellh_cli
      mysql
      net
      nomad_api
      oauth2
      oktasdk-go
      otp
      pester
      pkcs7
      pq
      protobuf
      gogo_protobuf
      rabbit-hole
      radius
      reflectwalk
      scada-client
      snappy
      structs
      swift
      sys
      triton-go
      vault-plugin-auth-centrify
      vault-plugin-auth-gcp
      vault-plugin-auth-kubernetes
      yaml
    ];

    postPatch = ''
      rm -r physical/azure
      sed -i '/physAzure/d' command/commands.go

      grep -q 'hashicorp/golang-math-big' helper/keysutil/encrypted_key_storage.go
      sed -i 's,github.com/hashicorp/golang-math-big,math,' helper/keysutil/encrypted_key_storage.go
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
      hcl
      go-cleanhttp
      go-glob
      go-multierror
      go-rootcerts
      mapstructure
      net
      pester
      snappy
      structs
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
      "helper/logbridge"
      "helper/logformat"
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
      hcl
      jose
      logxi
      mapstructure
      net
      pester
      protobuf
      snappy
      structs
      sys
    ];
  };

  vault-plugin-auth-centrify = buildFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault-plugin-auth-centrify";
    rev = "fe071f6755f0c48a5a6569211698f6b3d09f23f1";
    sha256 = "1w0pg6g24hd4glgkys09fdqpw3dnvkg4lrcmymbnjmglvi17z0s8";
    date = "2018-03-30";
    propagatedBuildInputs = [
      cloud-golang-sdk
      go-cleanhttp
      logxi
      vault_for_plugins
    ];
  };

  vault-plugin-auth-gcp = buildFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault-plugin-auth-gcp";
    rev = "0876f586cb18a1521e834546f9d0c980b1843099";
    sha256 = "1jxqvgbnmifw2x1jb12xvcpdp1y7bl1y79mnh4x5y0pka4w1cmp9";
    date = "2018-03-30";
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
    rev = "2457cd430d39c5601b614e10e88ba011e5b6023e";
    sha256 = "1kya2lc16w2xwnzh0vqiin89hyq7x8r2d06j3s442k1lxgmvf3m0";
    date = "2018-03-30";
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

  viper = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "viper";
    rev = "v1.0.2";
    sha256 = "0nz8av4qjj07ikdz1v8v0za0nasa02hy6phr6j1g3fpy48rs25pg";
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
    version = 3;
    rev = "d14193dfc626125c831501c1c42340b4248e1f5a";
    owner  = "lunixbochs";
    repo   = "vtclean";
    sha256 = "09cnxishcajlxkfvavphzvzkyjya24ckjsxjq9lawfkzvwv1kf5p";
    date = "2017-05-04";
  };

  vultr = buildFromGitHub {
    version = 5;
    rev = "1.15.0";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "12aawg9hzqc989aqsmnl0n1m9awbw8g8xwrry2vxb2ac17i2c445";
    propagatedBuildInputs = [
      crypto
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  w32 = buildFromGitHub {
    version = 2;
    rev = "bb4de0191aa41b5507caa14b0650cdbddcd9280b";
    owner = "shirou";
    repo = "w32";
    sha256 = "021764v4m4xp2xdsnlzx6871h5l8vraww39qig7sjsvbpw0v1igx";
    date = "2016-09-30";
  };

  webbrowser = buildFromGitHub {
    version = 3;
    rev = "54b8c57083b4afb7dc75da7f13e2967b2606a507";
    owner  = "juju";
    repo   = "webbrowser";
    sha256 = "0i98zmgrl6zdrg8brjyyr04krpcn01ssvv5g85fmwpiq9qlis12a";
    date = "2016-03-09";
  };

  websocket = buildFromGitHub {
    version = 5;
    rev = "eb925808374e5ca90c83401a40d711dc08c0c0f6";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "0s7bxvpc7yylk9n939r9jq3qzg7lx6ackkq7km7b4mln1h4ff1lf";
    date = "2018-03-06";
  };

  whirlpool = buildFromGitHub {
    version = 3;
    rev = "c19460b8caa623b49cd9060e866f812c4b10c4ce";
    owner = "jzelinskie";
    repo = "whirlpool";
    sha256 = "1dhhxpm9hwnddxajkqc6k6kf6rbj926nkvw88rngycvqxir6bs5k";
    date = "2017-06-03";
  };

  winsvc = buildFromGitHub {
    version = 6;
    rev = "f8fb11f83f7e860e3769a08e6811d1b399a43722";
    owner = "btcsuite";
    repo = "winsvc";
    sha256 = "0g9c7dqhsc20xkcdn30nrjapdpvyx56vlspkgs65abljya3lkmpm";
    date = "2015-01-17";
  };

  wmi = buildFromGitHub {
    version = 5;
    rev = "1.0.0";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "1il8zwa8r4n7g1xiw58jslxj8r6dgmxrdgapplzlfzz078rvvdw6";
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
    version = 6;
    rev = "v2.2.1";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "0w1gan4v27nh2g90qsy9c1blrk3hbnprchr679xvjsa8d02m3mh4";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yaml_v1 = buildFromGitHub {
    version = 3;
    rev = "9f9df34309c04878acc86042b16630b0f696e1de";
    date = "2014-09-24";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "0r3zpg7d7i2wl6qdi75sh33d20sm5lh5cvbw60j13xxkbpy04ggs";
    goPackagePath = "gopkg.in/yaml.v1";
  };

  hashicorp_yamux = buildFromGitHub {
    version = 5;
    date = "2018-03-14";
    rev = "2658be15c5f05e76244154714161f17e3e77de2e";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "08v7ghpmcrmh1a0awm4jd0rby6ds6mbmrxchb5fvighc39r92xx1";
  };

  whyrusleeping_yamux = buildFromGitHub {
    version = 6;
    date = "2018-03-22";
    rev = "63d22127b261bf7014885d25fabe034bed14f04b";
    owner  = "whyrusleeping";
    repo   = "yamux";
    sha256 = "0snvj9ckkb71q495yp2krn67bsa6ykvqvq32n13dxckml1g0s5vb";
  };

  xattr = buildFromGitHub {
    version = 6;
    rev = "v0.2.3";
    owner  = "pkg";
    repo   = "xattr";
    sha256 = "1fkvplmyr8yhr9nprnpx0jnfrdb9v1vanvkijb3ama1dgdy92ybh";
  };

  xdr = buildFromGitHub {
    version = 5;
    rev = "v1.1.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "001zdv75v0ksw55p2qqddjraqwhssjxfiachwic8jl60p365mwpp";
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
    rev = "v0.6.4";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "1r3z9i0zna80rdirm8fc0rvmhgqm0n044xscnwlll64v4drbaiwz";
    propagatedBuildInputs = [
      builder
      core
    ];
  };

  xsecretbox = buildFromGitHub {
    version = 5;
    rev = "88b1956e8d9a013c98dda528d3a5b77f168b057f";
    owner  = "jedisct1";
    repo   = "xsecretbox";
    sha256 = "0fb8sb29z6h3j9lapcqszv5bzv2wq5j7swhi0mb4iflxcig9shjn";
    date = "2018-02-14";
    propagatedBuildInputs = [
      chacha20
      crypto
      poly1305
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
    version = 5;
    rev = "48099fad606eafc26e3a569fad19ff510fff4df6";
    owner  = "cespare";
    repo   = "xxhash";
    sha256 = "1gcq2ydv6s23lsb1da8hydc3sbydxjxdac9s22g8nb7jxs0rqgym";
    date = "2018-01-29";
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
    rev = "v1.7.1";
    owner  = "uber-go";
    repo   = "zap";
    sha256 = "0i05s29x2v7kx8s8gr04nzqp4frkmcy49wzpzng44r4n3glpyvyi";
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
    version = 3;
    date = "2016-07-23";
    rev = "2533cb5b45cc6c07421468ce262899ddc9d53fb7";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1lvc4gi9h8xbgjq6x2bvxnq9pxh707zlgccpwmycpzx86gfvigmh";
    buildInputs = [
      mathutil
    ];
    extraSrcs = [
      internal
    ];
  };
}; in self
