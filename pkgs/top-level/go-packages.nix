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
    rev = "v1.1.0";
    owner = "golang";
    repo = "appengine";
    sha256 = "1xx61vwraas3azs6chhf0pq4776rn5xn94w3d9v1xfskmyx7z53k";
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
    rev = "767337190e5911af68ee322b08b978b344bf03bf";
    date = "2018-06-21";
    owner = "golang";
    repo = "build";
    sha256 = "05bf10apqqccd4s0z4847mzsmwskw6z0n1vixwqxj3pzc19gzqsw";
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
    rev = "a49355c7e3f8fe157a85be2f77e6e269a0f89602";
    date = "2018-06-21";
    owner = "golang";
    repo = "crypto";
    sha256 = "1gxhfd8vhw036d50fnvl2naq6dai02jjdvxiasffwrqa66fsh67f";
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
    rev = "37b0a153249d1779281c77010c6a61cc4ae67b04";
    date = "2018-06-05";
    owner = "golang";
    repo = "debug";
    sha256 = "005m4ak7gp42p9967k7lcpwki40v682y8nxysc4c5fr8cr06rnnd";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
    propagatedBuildInputs = [
      cobra
    ];
  };

  geo = buildFromGitHub {
    version = 6;
    rev = "e41ca803f92c4c1770133cfa5b4fc8249a7dbe82";
    owner = "golang";
    repo = "geo";
    sha256 = "1ai46qpx9s79w9ccipiszjyzx1zl9vnzivcwycdgnc53hgvyy9b1";
    date = "2018-05-01";
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
    rev = "af66defab954cb421ca110193eed9477c8541e2a";
    date = "2018-06-01";
    owner = "golang";
    repo = "image";
    sha256 = "1rfr8y1bjimspmhza9l9z0wc0g3n6p25ilfrigslis5jkxwiaya0";
    goPackagePath = "golang.org/x/image";
    propagatedBuildInputs = [
      text
    ];
  };

  net = buildFromGitHub {
    version = 6;
    rev = "afe8f62b1d6bbd81f31868121a50b06d8188e1f9";
    date = "2018-06-21";
    owner = "golang";
    repo = "net";
    sha256 = "1gr6y9issxc3v4k72h2xwrz8kh4ip1mnb72450w9805xdvdpsi7i";
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
    rev = "ef147856a6ddbb60760db74283d2424e98c87bff";
    date = "2018-06-20";
    owner = "golang";
    repo = "oauth2";
    sha256 = "05khb37njl3mb2pc9d3fb864rq12173jjyh4i77da2b0a42xgr4h";
    goPackagePath = "golang.org/x/oauth2";
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };

  protobuf = buildFromGitHub {
    version = 6;
    rev = "v1.1.0";
    owner = "golang";
    repo = "protobuf";
    sha256 = "0xl1k76bhsmy2l67na052amd8mf8i8yb4ygs6d5mgacsj5ijdly0";
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
    rev = "63fc586f45fe72d95d5240a5d5eb95e6503907d3";
    date = "2018-06-22";
    owner  = "golang";
    repo   = "sys";
    sha256 = "0jy5rhkzaaq240s1hwnv4lynnw2fmsnc2pxi18awvsj3kfaf5l7c";
    goPackagePath = "golang.org/x/sys";
  };

  text = buildFromGitHub {
    version = 6;
    rev = "5cec4b58c438bd98288aeb248bab2c1840713d21";
    owner = "golang";
    repo = "text";
    sha256 = "1x5pwzam04c89mmh22fiz1r9nb4had5qg4rw477r05r8mlc64syq";
    goPackagePath = "golang.org/x/text";
    excludedPackages = "\\(cmd\\|test\\)";
    buildInputs = [
      tools_for_text
    ];
    date = "2018-06-17";
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
    rev = "25b95b48224cce18163c7d49dcfb89a2d5ecd209";
    date = "2018-06-20";
    owner = "golang";
    repo = "tools";
    sha256 = "03f34qgviw91w3lgsfabiq46n2vrr5r40lkhv5b8zlggqgiamss9";
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
      "go/callgraph"
      "go/callgraph/cha"
      "go/loader"
      "go/ssa"
      "go/ssa/ssautil"
      "go/types/typeutil"
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
    rev = "v1.1.1";
    sha256 = "0rf9957j4cz2jc2k98612pv9m2hb0mksay9i31xsjgq4r23clfr9";
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
    rev = "v0.15.0";
    sha256 = "0cc7q514rzxa1wzqqwhl8yp8z1pjn221ix6xdix3qsgw7jwk4a98";
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
    rev = "a854445ff36db2497a5863dc34e4c866ace022e4";
    date = "2018-06-21";
    sha256 = "0py27lpbi4m7hi6py9wapgpy8h763w7cz0qw74i7xgd9i38mi768";
    propagatedBuildInputs = [
      protobuf
    ];
  };

  aliyun-oss-go-sdk = buildFromGitHub {
    version = 6;
    rev = "1.9.0";
    owner  = "aliyun";
    repo   = "aliyun-oss-go-sdk";
    sha256 = "0i75ab6hi8xwkrvcicmm0r99k23il6d7fi7rpb3jcdm1y04mia4d";
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
    rev = "e5adc2ada8b8efff032bf61173a233d143e9318e";
    date = "2018-05-28";
    sha256 = "1cxig3djn13w8avnlr9g1r2ig9xy03xcszxf3yg32sk5pi2lrm7p";
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
    version = 6;
    rev = "00e08cc179d12a869b3328f2feba1d0684bf7d72";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "024h6xrwxs96hvzp4kkrip29vlhfswdh57nkcwcsm1avjz9vxi93";
    goPackageAliases = [
      "gopkg.in/asn1-ber.v1"
    ];
    date = "2018-06-02";
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
    rev = "v1.14.13";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "1qpppal8qrbvk0gg5kp36sgk1l0q0dfhwbw906v67c6m0mrrmz59";
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
    rev = "v17.4.0";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "11662vz1ifgphac0hrh6vlhlvc63riyyy4p6pjf9qn4p16rpiq8b";
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
    version = 6;
    owner = "whyrusleeping";
    repo = "base32";
    rev = "c30ac30633ccdabefe87eb12465113f06f1bab75";
    sha256 = "1g2ah84rf7nv08j89crbpmxn74gc4x0x0n2zr0v9l7iwx5iqblv6";
    date = "2017-08-28";
  };

  base58 = buildFromGitHub {
    version = 6;
    rev = "4df4dc6e86a912614d09719d10cad427b087cbfb";
    owner  = "mr-tron";
    repo   = "base58";
    sha256 = "0173rmw4sjnf8g7g7hqmxwg6d4arn9ynxrszw7qqpnv04dfjv7fd";
    date = "2018-06-21";
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
    rev = "v1.5.1";
    sha256 = "959a36690c3687eed66672cd7befecd88dd3a3fa7e84ce2b6387288894ebcdfa";
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
    version = 6;
    owner = "btcsuite";
    repo = "btcd";
    date = "2018-05-31";
    rev = "86fed781132ac890ee03e906e4ecd5d6fa180c64";
    sha256 = "0c3hnmmq7v80bn885bvhsy84ghvxm4r9b7q72wj10sjgj4zim21i";
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
    rev = "v0.2.0";
    owner  = "go-xorm";
    repo   = "builder";
    sha256 = "1fh901zx9z4a8g3zzxfvzln6zv0dr3c3k8biz3qkhf8gfimky19d";
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
    version = 6;
    owner = "pquerna";
    repo = "cachecontrol";
    rev = "1555304b9b35fdd2b425bccf1a5613677705e7d0";
    date = "2018-05-17";
    sha256 = "1rxvdxb4j7mvbyqsazfxy2vgg5wyvcmw9yx695bdnqicxlkwjpix";
  };

  candidclient = buildFromGitHub {
    version = 6;
    rev = "6504df157e74a5f4b54dd720e5352e164e0f1882";
    owner  = "CanonicalLtd";
    repo   = "candidclient";
    sha256 = "1vjsnsqmnqqxhvqvyb78rbmg1vpmhbrvbcy2v3yz11wr6ykddxba";
    date = "2018-04-06";
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
    rev = "v1.0.19";
    sha256 = "0cgr8va4brk7bpm1s7xqnbxfipq0vpkss4cs55sz7v7g7fzcf7c8";
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
    rev = "e2538746bfea853aaa589feb8ec46bd46ee78f86";
    owner  = "aead";
    repo   = "chacha20";
    sha256 = "1rlb7l1hpakkjyzdxwhnf504bzmnn979ddzdrzns0xjy8bvgvkmq";
    date = "2018-05-03";
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
    rev = "1e3d94a8321308ca2c154a87aed2b9c2155a178d";
    owner  = "alecthomas";
    repo   = "chroma";
    sha256 = "1a9w3jrlzvx4zkxh6if68s65y2p8xcp9c3j8y86mn5jq0j2sklha";
    excludedPackages = "cmd";
    propagatedBuildInputs = [
      fnmatch
      regexp2
    ];
    meta.useUnstable = true;
    date = "2018-06-23";
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
    date = "2018-06-24";
    rev = "1c20e3f6019c748d663eef42cbab995e07fabe64";
    owner = "docker";
    repo = "cli";
    sha256 = "0v4r36adiwbqh5ly5zha0c08ll8cn8dns9800bp7zkfy8v7iv338";
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
    date = "2018-04-14";
    rev = "c48282d14eba4b0817ddef3f832ff8d13851aefd";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "1zb58bvlqnvnnfag443zm0y7jyvc0zg93dvh3m0z3f1nxsl6w3z4";
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
    rev = "1e58aa3361fd650121dceeedc399e7189c05674a";
    sha256 = "07v2kpz1ynmwlbvf1dwn5dhcasgd8xa8vym5dfy8jvnaf1pgbf7v";
    propagatedBuildInputs = [
      go-homedir
      go-md2man
      mousetrap
      pflag
      viper
      yaml_v2
    ];
    meta.useUnstable = true;
    date = "2018-05-31";
  };

  cockroach = buildFromGitHub {
    version = 6;
    rev = "v2.0.3";
    owner  = "cockroachdb";
    repo   = "cockroach";
    sha256 = "1bb33cziim1y9rykb2n29x028h8nlzfdx0axjrq7k44vgbjm23ib";
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

  collections = buildFromGitHub {
    version = 6;
    rev = "90152009b5f349bb218a9bf4a6034dd8437c031b";
    owner  = "juju";
    repo   = "collections";
    sha256 = "0nqp89qkxdldmyd4brrm5271pw5w78ymw5m7zilfbscvc3s08fxg";
    date = "2018-05-16";
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
    rev = "da59b551951d50441ca26b7a8cd81317f34df87f";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "0dmhr52ha8ymgajwb995aqsj88y0mzi2r75drip10x9spiwc8yhs";
    date = "2018-06-17";
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
    rev = "v1.3.0";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "0mh2xrx9jz56ibb5i2mcxi32d3j497438h9alpfv0n9a67jqjidg";
    propagatedBuildInputs = [
      cpuid
    ];
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
    version = 6;
    rev = "4e0f2df8846ee9557b5c88307a769ff2f85e89cd";
    owner = "gravitational";
    repo = "configure";
    sha256 = "1gnkzr1jhcqad6ba9q7krk9is14xnfga74pvvmxsa89i65p9sy3h";
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
    rev = "9290d21dc56074581f619579c43d970b4514bc08";
    owner = "containerd";
    repo = "console";
    sha256 = "0zyz9m9qc4szhx0xjmaw4xm21lr840mf2v40g1p9hvwvlywf0bly";
    date = "2018-06-04";
    propagatedBuildInputs = [
      errors
      sys
    ];
  };

  consul = buildFromGitHub rec {
    version = 6;
    rev = "v1.1.0";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "0minr3ghk3wa19p9fhbyzy4xbrhizx42gi2lkav5qqbsf5vfkzja";
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
      gziphandler
      hcl
      hil
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      net
      net-rpc-msgpackrpc
      oauth2
      prometheus_client_golang
      raft-boltdb
      raft
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
    ];
  };

  consulfs = buildFromGitHub {
    version = 6;
    rev = "v0.2";
    owner = "bwester";
    repo = "consulfs";
    sha256 = "0y8msx0yxphfl7rrllisni2s6fa565xrhr4kr69y7ms4anxbzi97";
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
    rev = "v1.1.1";
    owner = "gorilla";
    repo = "context";
    sha256 = "1sy7s5ypgv4j7zgfrdbfzrlr6888sm78am6i9bf2l81lvh4yw5kg";
  };

  continuity = buildFromGitHub {
    version = 6;
    rev = "246e49050efdf45e8f17fbbcf1547ee376f9939e";
    owner = "containerd";
    repo = "continuity";
    sha256 = "0d1r1pkjijwdbk0w0jwsb6m9b3shqjm0pjhh36a8qq4ibh6c0hm7";
    date = "2018-06-12";
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
    date = "2017-05-25";
    rev = "d23ffcb85de31694d6ccaa23ccb4a03e55c1303f";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "168y1w04qhygly1axy2s1p6kzjkcfn01h91ix9xnf1f4sc2n3k9a";
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
    rev = "v1.1.4";
    owner = "coredns";
    repo = "coredns";
    sha256 = "15f7pfj5v9bwfjdrk6jarx5abgymyj2lqwpnrv8dp4i4i63isvz3";
    subPackages = [
      "plugin/etcd/msg"
      "plugin/pkg/dnsutil"
    ];
    propagatedBuildInputs = [
      dns
    ];
  };

  cors = buildFromGitHub {
    version = 6;
    owner = "rs";
    repo = "cors";
    rev = "v1.4.0";
    sha256 = "0bcj5i59bs3d94yswzhbys90kx7v279lns3ql33bs3rq0bncaxpv";
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
    rev = "8cbcc64e38bf24e9066af813a0f3236772ceb80a";
    owner = "godbus";
    repo = "dbus";
    sha256 = "17agc8h00wjha02vahxwmclk242hrgsiif7kga10kvv0v6l5m904";
    date = "2018-05-31";
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
    date = "2018-05-24";
    rev = "fc6590592b44fedfff586c5d94647c090fbd6bac";
    owner = "ianlancetaylor";
    repo = "demangle";
    sha256 = "05qs8mj78sn7l4miirbcqqm6yv2ns02f1rq2aysb72wsrnxb8992";
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
    rev = "749f6afb4572201e3c37325d0ffedb6f32be8950";
    owner = "docker";
    repo = "distribution";
    sha256 = "129nkj92s9k4y9hfwzfq0y6l01hrwzzndhvr7lacdlzfkhqji3l2";
    meta.useUnstable = true;
    date = "2018-06-11";
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
    rev = "v1.0.8";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0z6wcg7z99ps2wfjdvcypahr8wpfajxyzx4190vhaxsdglkad3nk";
    propagatedBuildInputs = [
      crypto
      net
    ];
  };

  dnscrypt-proxy = buildFromGitHub {
    version = 6;
    rev = "2.0.15";
    owner  = "jedisct1";
    repo   = "dnscrypt-proxy";
    sha256 = "0bg7x83xcqyaxb9fk390qq1igkks11bcjd4x1rrmbk4ciky2zsbj";
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
    rev = "v0.6.0";
    owner = "docker";
    repo = "docker-credential-helpers";
    sha256 = "01gzy7drx9l2015n6igypm0y7g8aacxmc9mq2l1kbzh61pn6qrag";
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
    rev = "e5bc052920ea9aabf43aeee5ce3c517289c5a7c6";
    owner  = "CanonicalLtd";
    repo   = "dqlite";
    sha256 = "1685xrszzhrlhs16xzr6fadazypl8hxc2bgy00n1r1clp2r3k6nm";
    date = "2018-05-07";
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
    rev = "3fdea8d05856a0c8df22ed4bc71b3219245e4485";
    date = "2018-06-06";
    sha256 = "1fasd9q1d4516jas7fv8awf0bsnayvsdfw8y35wrjnqrkndylac0";
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
    rev = "v5.0.69";
    sha256 = "18jvs63kywj67y9f5f7ij26s0wzra4cwk3khgdgxsjf5zcnhd0xf";
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
    rev = "f82458dfe0e95ea220f11283d6c8f19e9b1d7bb4";
    sha256 = "0m8wzf5vc1axqyracy6mjypqkywgjfl0n1297grckwccakwzrjsj";
    excludedPackages = "website";
    propagatedBuildInputs = [
      bolt
      go-isatty
      persistent
      sys
    ];
    meta.useUnstable = true;
    date = "2018-06-17";
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
    rev = "v1.6.3";
    sha256 = "1rp2v2zwjigpc57zd7sq4fnbbqgyl8gyp7in62can8nfbxb364fl";
    propagatedBuildInputs = [
      godotenv
      go-homedir
    ];
  };

  errgo_v1 = buildFromGitHub {
    version = 6;
    owner = "go-errgo";
    repo = "errgo";
    rev = "c17903c6b19d5dedb9cfba9fa314c7fae63e554f";
    sha256 = "18sbwmnxkx36kcw6yl29z0s4fvrn1gkcacwpzislbbf9x81rxqlv";
    date = "2018-05-02";
    goPackagePath = "gopkg.in/errgo.v1";
  };

  juju_errors = buildFromGitHub {
    version = 6;
    owner = "juju";
    repo = "errors";
    rev = "c7d06af17c68cd34c835053720b21f6549d9b0ee";
    sha256 = "072ayhg9j3ff1xl2a6kjk87wsyijkhh26mxrcjvj0cf8n4av2z5a";
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
    version = 6;
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
    rev = "8f6348a97d483316c5039d6bbc2f66ba2c00e1d0";
    sha256 = "1207kplhsqxsgkg5479gp3cvz3ag9w171wrfv65vgw125ms0nm5f";
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
    date = "2018-06-22";
  };

  etcd_client = etcd.override {
    subPackages = [
      "auth/authpb"
      "client"
      "clientv3"
      "clientv3/balancer"
      "clientv3/balancer/picker"
      "clientv3/balancer/resolver/endpoint"
      "clientv3/concurrency"
      "etcdserver/api/v3rpc/rpctypes"
      "etcdserver/etcdserverpb"
      "mvcc/mvccpb"
      "pkg/logutil"
      "pkg/pathutil"
      "pkg/srv"
      "pkg/systemd"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
      "raft"
      "raft/raftpb"
      "version"
    ];
    buildInputs = [
      go-systemd
    ];
    propagatedBuildInputs = [
      go-grpc-middleware
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
    rev = "v0.2.1";
    owner  = "cyphar";
    repo   = "filepath-securejoin";
    sha256 = "0sz7cppgh5zyqdmkdih3i69yaixi3kks37yzw15g4algk0dyx0yk";
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
    rev = "2403248fa8cc9f7909862627aa7337f13f8e0bf1";
    sha256 = "12zxp0a86hpnrfn28gw04rcs0h3pv08xihzbmlyc5lzmffqp31rp";
    date = "2018-04-04";
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
    rev = "1.1";
    sha256 = "1ysz6m279s3hrpj2phlyl73wk568fqj7glzcjmag6q9idmjxpi5z";
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
    rev = "254b60fe060127b9fd3c420fadd0906bf0382227";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "1676id4w0jfpb00rxg9iq3pwq0x2rwlr0l7jcb7szc8432ibj362";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
    date = "2018-05-23";
  };

  genproto = buildFromGitHub {
    version = 6;
    date = "2018-06-21";
    rev = "80063a038e333bbe006c878e4c5ce4c74d055498";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "08bp954h7dpd3hpwsjrr032d6nrjmnx6j22wg26293fpz81zcl5x";
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
    rev = "1f59bad84b577735b27a1ee855f01ed2f50cd88b";
    owner = "gin-gonic";
    repo = "gin";
    sha256 = "0fik4sgmbp13jmli3cckpnns6qphrqsxrwjnpfssnakh3r9f0fgg";
    date = "2018-06-23";
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
    rev = "v1.5.0";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "0x57zd5dxljm4l7crxdwb0zr94z6ys9mwww2hkyi30aqwx6fqpjx";
    buildInputs = [
      sys
    ];
  };

  gitmap = buildFromGitHub {
    version = 6;
    rev = "ecb6fe06dbfd6bb4225e7fda7dc15612ecc8d960";
    date = "2018-06-17";
    owner = "bep";
    repo = "gitmap";
    sha256 = "0rhzkvydch9n43vic7g5zpdrkcpxaa4n4fb7qh5kgva9dqavbq81";
  };

  gjson = buildFromGitHub {
    version = 6;
    owner = "tidwall";
    repo = "gjson";
    rev = "v1.1.2";
    sha256 = "0yizk488rmjj6yf3176ahi0d039wahbviawl361pnaw380dgv11j";
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
    rev = "v1.1.1";
    owner = "ugorji";
    repo = "go";
    sha256 = "0ypzblak2idf9wf94pzrxj42py49hq8vd3rl3kslzxp8i2bz89kf";
    goPackageAliases = [
      "github.com/hashicorp/go-msgpack"
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
    rev = "v2.0.2";
    sha256 = "1qxnzlyfshkaf23xlqljq8kzzbxn797hcqqwxbd2kzhmfg97b7c4";
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
    date = "2018-04-17";
    rev = "9599cf28b011184741f249bd9f9330756b506cbc";
    owner = "camlistore";
    repo = "go4";
    sha256 = "0fvk9mvwmxy3sz7gdhb95fafmwmzf9c2lxl7hijycbz0l1gvsrqy";
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
    version = 5;
    rev = "33e07d32887e1e06b7c025f27ce52f62c7990bc0";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "1igpbfw1k6ixy3x525xgw69q7cxibzbb9baxdxqc1gf5h2j2bbnp";
    date = "2018-02-23";
  };

  gocql = buildFromGitHub {
    version = 6;
    rev = "e06f8c1bcd787e6bf0608288b314522f08cc7848";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "0knikvdlsbc1px3gkxry2808wm3w14j5d5ljy91cg6rzc2m4agdg";
    propagatedBuildInputs = [
      inf_v0
      snappy
      go-hostpool
      net
    ];
    date = "2018-06-17";
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
    rev = "v1.3.0";
    owner  = "digitalocean";
    repo   = "godo";
    sha256 = "0cqmj8zfi34xbxw533rg3gfq2cvspywri77kwrd9lyn561ganbm2";
    propagatedBuildInputs = [
      go-querystring
      http-link-go
      net
    ];
  };

  godotenv = buildFromGitHub {
    version = 6;
    rev = "1709ab122c988931ad53508747b3c061400c2984";
    owner  = "joho";
    repo   = "godotenv";
    sha256 = "0gh580jlvnwrkyginbkxkrm5y8kpfrb8xryfz72xpbg3gfyiz2i9";
    date = "2018-04-05";
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
    version = 5;
    rev = "b0b1615b78e5ee59739545bb38426383b2cda4c9";
    owner  = "petermattis";
    repo   = "goid";
    sha256 = "17wnw44ff0fsfr2c87g35m3bfm4makr0xyixfcv7r56hadll841y";
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
    version = 6;
    rev = "1d523034197ff1f222f6429836dd36a2457a1874";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "0vl40jznkwb6v240zf53njcmz2mgaljzdg3sxf8mkbzkkdfxnb6d";
    date = "2018-06-18";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gomaasapi = buildFromGitHub {
    version = 6;
    rev = "abe11904dd8cd40f0777b7704ae60348a876542e";
    date = "2018-05-21";
    owner = "juju";
    repo = "gomaasapi";
    sha256 = "0rfbvrq7lsp5zgdi3bncw239j67gsajk3d19jz42jqj4gmsywplj";
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
    rev = "1952afaa557dc08e8e0d89eafab110fb501c1a2b";
    date = "2017-02-08";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "1h1sjgjv4ay6y26g25vg2q0iawmw8fnlam7r66qiq0hclzb72fcn";
  };

  gomemcached = buildFromGitHub {
    version = 6;
    rev = "0da75df145308b9a4e6704d762ca9d9b77752efc";
    date = "2018-05-02";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "0q7pqr79hr32k9j4wmr5ql2camcf84gyqwy6fnhm50g1v7c6idiw";
    excludedPackages = "mocks";
    propagatedBuildInputs = [
      crypto
      errors
      goutils_gomemcached
    ];
  };

  gopacket = buildFromGitHub {
    version = 6;
    rev = "165a0afa8d2975ef02eff12550e6aa75d6a1c828";
    owner = "google";
    repo = "gopacket";
    sha256 = "1k37z1hqqwfr5s60sa57j2bj0vdxghmwc29bpf122rmszc0rr2ss";
    buildInputs = [
      pkgs.libpcap
      pkgs.pf-ring
    ];
    propagatedBuildInputs = [
      net
      sys
    ];
    date = "2018-06-20";
  };

  gophercloud = buildFromGitHub {
    version = 6;
    rev = "1ad7a96d69a2e8105920431ee428843b6d1ee4c3";
    owner = "gophercloud";
    repo = "gophercloud";
    sha256 = "05hjgppfv0hqsvkas7xanblplkj5j5vbdj7z6dcri7ang8426l7h";
    date = "2018-06-23";
    excludedPackages = "test";
    propagatedBuildInputs = [
      crypto
      yaml_v2
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 6;
    date = "2018-06-22";
    rev = "d84cd321885bb5799adca4df58b23d64d5586a4e";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "0zsl9jncpajxb8ldmym7jr7fm8dln33sns8hcmlh0pj57wmp260k";
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
    rev = "62b4d222669dc214b631ef9750d7eeaf197ef7a5";
    owner = "google";
    repo = "gops";
    sha256 = "00m4apfq37iw6m7bg3p4kfy3w7d04kzhi5w7r9m622pf98b252h6";
    propagatedBuildInputs = [
      keybase_go-ps
      gopsutil
      goversion
      osext
      treeprint
    ];
    meta.useUnstable = true;
    date = "2018-04-30";
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
    version = 5;
    date = "2018-02-01";
    rev = "0fb14efe8c47ae851c0034ed7a448854d3d34cf3";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "0v3md1h33bisx1dymp1zmy48kikkrjpz5qg7i37zckdlabq5220m";
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
    rev = "0d5a0ceb10cf9ab89fdd744cc8c50a83134f6697";
    date = "2018-06-21";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "0xfmkaw4n6fzvykp46bmhdy6x2d2jghnvjwcdb4sv5ha5hwcsrar";
    propagatedBuildInputs = [
      ginkgo
      gomega
      snappy
    ];
  };

  gomega = buildFromGitHub {
    version = 6;
    rev = "v1.4.0";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "1vym4yinh7ak5sdqhx4wyxxwjj4m9df23kax44g1hdgcd1zkadbj";
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
      date = "2018-06-21";
    };
    rev = "3639d6d93f377f39a1de765fa4ef37b3c7ca8bd9";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 6;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "0nn1n0xa3lpwxh6n1vhkwvbis85h3z3iljjpgvjfylh3bl8m9png";
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
    rev = "v2.18.05";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "0kvpmicf792z35i978p3dqv6m9kpqbbd02nrk2skfkcgkqb4ik70";
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
    rev = "1395d1447324cbea88d249fbfcfd70ea878fdfca";
    owner  = "huin";
    repo   = "goupnp";
    sha256 = "0rd9bplqh7z6m6mgy5qlwhdqgji5ds77zj9vf787z81ynh5hdsk1";
    date = "2018-04-15";
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
    rev = "7d2e70ef918f16bd6455529af38304d6d025c952";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "16isnqzdjmn0nflh8jbfylskq1aajinga4gcrr36gsmj51jm22sy";
    date = "2018-03-19";
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
    rev = "v0.18.0";
    owner = "vmware";
    repo = "govmomi";
    sha256 = "04j39cgny28p56dvi7sgfd1rn2qbk5naqmnv7zgs8s6ra7bqc6ic";
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
    rev = "v10.11.4";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "1vs7qn2z77b4mkyrk0g4sczxmm89prnjdkps5njjyasm65dxnhza";
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

  go-buffruneio = buildFromGitHub {
    version = 5;
    owner = "pelletier";
    repo = "go-buffruneio";
    rev = "e2f66f8164ca709d4c21e815860afd2024e9b894";
    sha256 = "05jmk93x2g6803qz6sbwdm922s04hb6k6bqpbmbls8yxm229wid1";
    date = "2018-01-19";
  };

  go-cache = buildFromGitHub {
    version = 6;
    rev = "9f6ff22cfff829561052f5886ec80a2ac148b4eb";
    owner = "patrickmn";
    repo = "go-cache";
    sha256 = "03n0cbqsmn1yvzjqc26gzgr9w37hmqrpdw6bcvylg9niswrhzj71";
    date = "2018-05-27";
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
    rev = "v0.7.21";
    owner = "ipfs";
    repo = "go-cid";
    sha256 = "1iq19hs9igzmsxbm0c6cqmdz0zwwhsfpxj8r3015a8h0pcz94aaa";
    propagatedBuildInputs = [
      go-multibase
      go-multihash
    ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 6;
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

  go-conn-security = buildFromGitHub {
    version = 6;
    rev = "v0.1.3";
    owner = "libp2p";
    repo = "go-conn-security";
    sha256 = "0ia1zrvgj24gyapvhyspxslkvfzfpxklqgzq8hmgwxixscwmz82w";
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
    rev = "16db1f1fe037412f12738fa4d8448c549c4edd77";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "10pdlbss4z4v9ahj9x32b68lb65qgbvcmc19nbcq02r23wzafsyl";
    date = "2018-05-01";
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
    rev = "5114a9a81e1b256bfe283702d45dad50f8bf5ddf";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "1f5rrifby4hmj5y5vc84hc7w1wwa60q9j6abj639yn7ycy991cpn";
    date = "2018-06-14";
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
    version = 6;
    rev = "6970cb987309cbf378c4797818df3dc55da31726";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "1jm2n9gg8ll27iy24xxwswawgaxq61d18wv966sgzngmsww7vc3v";
    propagatedBuildInputs = [
      goid
    ];
    date = "2018-06-07";
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
    rev = "283c00e7695d2b48f5cab77849d8f6409648e21d";
    owner  = "hashicorp";
    repo   = "go-discover";
    sha256 = "1997c1g84kp3gfanj50yb6bqbl2cckbdcrylk3cm0rkx94x6y895";
    date = "2018-06-07";
    propagatedBuildInputs = [
      aliyungo
      aws-sdk-go
      #azure-sdk-for-go
      #go-autorest
      godo
      google-api-go-client
      gophercloud
      govmomi
      oauth2
      #scaleway-sdk
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
    date = "2018-06-21";
    rev = "be08a2e7eafecb4d8c6bc61be94233a06904a121";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "1fnsg0yrdn6f4847hwv08fmnh952jczbzmrx5ahwws02lmilvhpy";
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
    version = 6;
    rev = "v0.9.17";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "0c79zrzbmyy32i9an8aa31fj4i44p79cbapkk2h8a2fxg80n8kfj";
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
    rev = "v0.2.0";
    owner  = "libp2p";
    repo   = "go-flow-metrics";
    sha256 = "1pajckma0j71h8an169hz8whx2mrgv1gwwnbpnssi22r678cnqhy";
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
    rev = "v0.1.5";
    owner  = "ipfs";
    repo   = "go-fs-lock";
    sha256 = "0r45c08ha0cgcjcixwaf4xa3glcq30ka37bygc0sq89hkrvypcz5";
    propagatedBuildInputs = [
      go-ipfs-util
      go-log
      go4
    ];
  };

  go-getter = buildFromGitHub {
    version = 6;
    rev = "3f60ec5cfbb2a39731571b9ddae54b303bb0a969";
    date = "2018-04-25";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "19ppd1h31bak15vh17nr8qmqqmzsflic6nbasysil4q4hnwvs35s";
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

  go-git-ignore = buildFromGitHub {
    version = 6;
    rev = "1.0.2";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "0aj67ykpw2h86h9qgw47kvabms9lx8fp9nl1wldh24j37iwmwxfw";
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
    rev = "72fa8515823be4fdc723721a5423ca6b98ec62c0";
    owner = "CanonicalLtd";
    repo = "go-grpc-sql";
    sha256 = "16wg2fa8p1yz1zs8l67c9g7nv0wiqnvwvsfy8yyhqhbxh220ma37";
    date = "2018-05-24";
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
    date = "2018-04-02";
    rev = "69ff559dc25f3b435631604f573a5fa1efdb6433";
    owner  = "hashicorp";
    repo   = "go-hclog";
    sha256 = "04nm5h3yaym6syj84x2d7rkx723npxdjq67y4ihqn0mali8zibwx";
  };

  go-hdb = buildFromGitHub {
    version = 6;
    rev = "v0.12.1";
    owner  = "SAP";
    repo   = "go-hdb";
    sha256 = "0n5q4nz6bbjpbs8g2jb5lgl72r1y8n73ak2zx24mnbgncrxpji64";
    propagatedBuildInputs = [
      text
    ];
  };

  go-homedir = buildFromGitHub {
    version = 6;
    date = "2018-05-23";
    rev = "3864e76763d94a6df2f9960b16a20a33da9f9a66";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "1bm6z1h26ff7rcq9xcwdbk30zh8faa6bqgnwjxfvrac5x2zqdx5s";
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
    version = 6;
    rev = "02af3965c54e8cacf948b97fef38925c4120652c";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "0wbln9jp2clw3xaw8ynbz7q5civp154gh64iaq55zliy1mqxjf8x";
    date = "2018-04-21";
  };

  go-i18n = buildFromGitHub {
    version = 6;
    rev = "f6ac3d9cf0c4b6a32527779e992ebde26bd3d948";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "1f2x5bs38w5d94lq3zvmlcrd5576j70xa2ri4qc8czrymq43gd1g";
    excludedPackages = "example";
    propagatedBuildInputs = [
      go-toml
      text
      toml
      yaml_v2
    ];
    date = "2018-05-28";
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
    rev = "de157cafdf393f0c43f49351aeb42c5f528778b8";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "129iqcf50i1nvpr2kaaqsbjcszchlvd87vws166i63c0ajg27s16";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-homedir
      go-ipfs-cmdkit
      go-libp2p-peer
      go-libp2p-pubsub
      go-multiaddr
      go-multiaddr-net
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2018-06-13";
  };

  go-ipfs-cmdkit = buildFromGitHub {
    version = 6;
    rev = "v1.1.1";
    owner  = "ipfs";
    repo   = "go-ipfs-cmdkit";
    sha256 = "1jr9vj5mdp9xmindn7and0vdsapwxksbyvx3dz60xxz39jppy75d";
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
    rev = "v0.0.3";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "1rhbq5yc4zkc4yan9caq8azlns3krn4ixk91xlvyxxxf4gipf427";
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
    rev = "v6.0.2";
    sha256 = "0fp06660jba79hi11pnddfyxwf8g4y4vks2dffa87pkni4jzqg3z";
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
    rev = "v2.1.2";
    sha256 = "0vbgf7hd9z4il8pjd13i2dn4r41d43bgj1yyyiqwhnyg82kyak59";
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
    rev = "v1.6.2";
    sha256 = "03ij86hq40cpnnxgjka365xy0sb3dbp38sdwpvb6912hrsypp8qp";
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
    date = "2018-06-11";
    rev = "ae156c461f3e7f3877843beb05a3ff3dfc737365";
    sha256 = "1mfhi5xd134fzvg2bi73czjbfh2p76gi8kf0sw7g24jksahdr5lk";
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
    date = "2018-06-04";
    rev = "fb4df4b77cebd7c5fd04f847e6985b647a937560";
    sha256 = "0k7q4cin5l3ma3866dqw8lyqfc6428h72amscq8xb863ascnjrad";
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
    rev = "v3.0.2";
    sha256 = "1azg9maz9dj26r0m1f3fq8sk0kcqrvicslb0szb0ca25464l75i0";
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
    date = "2018-06-04";
    rev = "25a66b71e7fe040d934f16416191e625b8069c53";
    sha256 = "1mjgijlbxls1z0aigy213xcd48jmh3ab2db8ig8yv6mz2a1qskzn";
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
    rev = "v0.0.9";
    sha256 = "1zpjd0i48slwl749qmsgx2cs03qmf5rqrnc9l450bysjgqk2yj9d";
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
      go-libp2p-transport
    ];
  };

  go-libp2p-loggables = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-loggables";
    rev = "v1.1.16";
    sha256 = "1k9zhhy41gdsl08kid8q21fby14znqgc2ykbb0j9p2b7zijg10pb";
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
    rev = "v2.1.2";
    sha256 = "179m6ji9jpfpj7pxm3flvacgz0d9bfc8si4xn06dmifwsx05335c";
    propagatedBuildInputs = [
      go-flow-metrics
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-protocol
      go-libp2p-transport
    ];
  };

  go-libp2p-nat = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-nat";
    rev = "v0.8.2";
    sha256 = "06l50v9z7sxkqpncgmbvg40m7ahfbhywv323ilalmjdm23vhdkhg";
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
    rev = "v3.0.2";
    sha256 = "1d8lpxn0czm25bxxcvw0aq58xbp869j5bz4zdckkwaqh5yjgkg97";
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
    rev = "v2.3.4";
    sha256 = "0fyhjfic8dxjlkc8r2s467k21sfhh5m3n5z886ag2gppb9h5an7b";
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
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-peerstore";
    rev = "v1.4.20";
    sha256 = "0631nzbrk9sq3a7f70ji5h2fhn1kac8gqjgj65k8swwb0yrp45bs";
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
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-pnet";
    rev = "v3.0.1";
    sha256 = "0l7c5rwday5sp9h96lhx2yz6ry41lxhc13b2aq5wh018lmyfz4bf";
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
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-pubsub";
    rev = "v0.1.0";
    sha256 = "1w3b9r7qqif4dbkpxa7v0p81pscndrn8s4krb8b0bmkvjv4472y3";
    propagatedBuildInputs = [
      gogo_protobuf
    ];
  };

  go-libp2p-raft = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-raft";
    date = "2018-06-04";
    rev = "c8f01205146983ba1f6fd1b59094950f6ba9e28b";
    sha256 = "0x41f4phycny5qp8iqnrnfgl9pmnhzhi0kkzj5bv5jakx61pk552";
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
    rev = "v2.0.2";
    sha256 = "1z2habc68xbgdqyb95zaadw3mzqmd3h6mandfm30fawa1w86d9kq";
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
    rev = "v3.0.2";
    sha256 = "052pfp5w90nkbh839708db4jdw7k601bg9igl14pr33f82c9rr9f";
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
    rev = "v3.0.2";
    sha256 = "07pk4xb0pv9qqk3nmr365c57z625q8kvwn2pqn1xsikh02cm8j0l";
    propagatedBuildInputs = [
      go-libp2p-net
      go-libp2p-peer
      go-log
      go-multiaddr
      go-multiaddr-net
      go-stream-muxer
      mafmt
    ];
  };

  go-libp2p-transport-upgrader = buildFromGitHub {
    version = 6;
    owner = "libp2p";
    repo = "go-libp2p-transport-upgrader";
    rev = "v0.1.2";
    sha256 = "0x31h32n6k7lsgj2jr9d1pradli4vf0bl0w53m6jsnwqbksrbmwn";
    propagatedBuildInputs = [
      go-conn-security
      go-log
      go-libp2p-interface-pnet
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-transport
      go-maddr-filter
      go-multiaddr-net
      go-stream-muxer
      go-temp-err-catcher
    ];
  };

  go-log = buildFromGitHub {
    version = 6;
    owner = "ipfs";
    repo = "go-log";
    rev = "v1.5.3";
    sha256 = "1m821zgrcg88zkwyaxl0fprk7w8yygy5yg7rhbikgwncicraf6j2";
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
    rev = "1c13b43ccb43defbf04a8b4b931e4bb18fd481e6";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "08zfn7yvf60i5lki5gfrc80ygvgljbn0b96bnjm0hm3hjcbj6pva";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2018-06-07";
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
    rev = "v1.1.8";
    sha256 = "1m3im0fagkig79j63865vbv1sz1p0vvsd0pzjs539zczqiha3d9i";
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

  go-mega = buildFromGitHub {
    version = 6;
    date = "2018-04-26";
    rev = "3ba49835f4db01d6329782cbdc7a0a8bb3a26c5f";
    owner = "t3rm1n4l";
    repo = "go-mega";
    sha256 = "17kv0b0cksw9vqg1y3arq5rxr5ilfy1gfwz8gbryarh57i79n0y8";
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
    version = 6;
    date = "2018-06-20";
    rev = "58588f401c2cc130a7308a52ca3bc6c0a76db04b";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0s51g3ghn784yngx49cr32jb8iccdrir2fzjq8k6wn0fkfhwvghd";
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
    version = 6;
    rev = "e2704e165165ec55d062f5919b4b29494e9fa790";
    date = "2018-05-03";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "1g6q2a5rqwg29n7wzf6id458rxafbjajxkf90sxg36qn79s25j6y";
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
    rev = "v0.2.23";
    owner  = "libp2p";
    repo   = "go-mplex";
    sha256 = "0ycq4phn17810303493q19zc3l2khivhh2zl1gxcb69mk7z3mwdf";
    propagatedBuildInputs = [
      go-log
      go-msgio
    ];
  };

  go-msgio = buildFromGitHub {
    version = 6;
    rev = "v0.0.3";
    owner = "libp2p";
    repo = "go-msgio";
    sha256 = "1rzf3n00lb9lnysmd521r4x0b3r8khi353h0d9ma8rb3ipppgv2r";
  };

  go-mssqldb = buildFromGitHub {
    version = 6;
    rev = "50fdbcac66a55c4ea139706823b3fd0631453b59";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "1mpr020x9hrkld2pfh72l2mhsr6f4adm44y28rnnscqd1h8fwlwl";
    date = "2018-06-25";
    propagatedBuildInputs = [
      crypto
      google-cloud-go
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 6;
    rev = "v1.2.7";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "0cwn4pdyjsx56qdlk50biwgxs5g2m44j8rrcpv7nb18gbssplb1z";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-dns = buildFromGitHub {
    version = 6;
    rev = "v0.2.3";
    owner  = "multiformats";
    repo   = "go-multiaddr-dns";
    sha256 = "1jsyi0bhp1d4j2vdahwzgx1a1n3r3p1v6zmgimc8avq286vpzbrm";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 6;
    rev = "v1.6.1";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "1zralwd5fqj9gzd3rim7ra5pglajvrq08hljjviskp4a8likmh7i";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  go-multibase = buildFromGitHub {
    version = 6;
    rev = "v0.2.6";
    owner  = "multiformats";
    repo   = "go-multibase";
    sha256 = "0iswkffms5gdi36y75fqmg2pxmq6r6hhrnknywxkhx9i5inx30ji";
    propagatedBuildInputs = [
      base58
      base32
    ];
  };

  go-multicodec = buildFromGitHub {
    version = 6;
    rev = "v0.1.5";
    owner  = "multiformats";
    repo   = "go-multicodec";
    sha256 = "1n32nvp6n895hmd4bf5ya7z6alfg90xrc0vfa56rcjqx1hic57kc";
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
    version = 6;
    date = "2017-12-04";
    rev = "b7773ae218740a7be65057fc60b366a49b538a44";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "0c8hps8bq1nlb0xp95mawisn80kdgph18zyn24fpffk1w3d3phrn";
    propagatedBuildInputs = [
      errwrap
    ];
  };

  go-multihash = buildFromGitHub {
    version = 6;
    rev = "8be2a682ab9f254311de1375145a2f78a809b07d";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "1vjp0mkbvf5zaccfagnbs4ggckyaj5al6v11qqq46fsv5xbq4yax";
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
    date = "2018-06-09";
  };

  go-multiplex = buildFromGitHub {
    version = 6;
    rev = "v0.2.23";
    owner  = "whyrusleeping";
    repo   = "go-multiplex";
    sha256 = "127cnfhdmwqblxgc8iinyg4ja7swpzhwykq44hh7cx2v41ywabfb";
    propagatedBuildInputs = [
      go-log
      go-mplex
      go-msgio
    ];
  };

  go-multistream = buildFromGitHub {
    version = 6;
    rev = "v0.3.7";
    owner  = "multiformats";
    repo   = "go-multistream";
    sha256 = "140k5h9f15l6pib4z44lqqx1k0m9047dp5qaq1aybbnxxk154san";
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
    rev = "28a68d0c24adce1da43f8df6a57340909ecd7fdd";
    owner  = "jackpal";
    repo   = "go-nat-pmp";
    sha256 = "0yznawhlp4bz11j2y4b56dqrfm26371jxck9rksy596pjr94f5m6";
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
    date = "2017-10-26";
    rev = "a93f71fdfe73d2c0f5413c0565eea0af6523a6df";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "5053ff90109c64fbf49eae61164e36caafb3dd0e34ae68639c95e906cb55d317";
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

  go-ole = buildFromGitHub {
    version = 6;
    rev = "43b0ecce3dadf91c771cf0d1b1849fb52b9f4de0";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "0j0bzlqifh20v69n3v6r93kis852zh9ivk96jqc2yypabbh7maz1";
    excludedPackages = "example";
    date = "2018-06-24";
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
    rev = "858d9a5df2fb99a2f91d6e700726e83502b80589";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "1ap0vz865xs3269i25x3hqma25m0n0zi89yckslpxkk3mk6a46zy";
    date = "2018-06-06";
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
    date = "2018-03-27";
    rev = "f976f61134dc6f5b4920941eb1b0e7cec7e4ef4c";
    sha256 = "1x61ra7kmi7gp9z6n6x9flavhnwbqzpav5wk9ai98ray9q2xy49w";
    propagatedBuildInputs = [
      pkgs.python2Packages.python
    ];
  };

  go-querystring = buildFromGitHub {
    version = 6;
    date = "2017-01-11";
    rev = "53e6ce116135b80d037921a7fdd5138cf32d7a8a";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "1ibpx1hpqjkvcmn4gsz54k9p62sl1iac2kgb97spcl630nn4p0yj";
  };

  go-radix = buildFromGitHub {
    version = 6;
    rev = "1fca145dffbcaa8fe914309b1ec0cfc67500fe61";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "1lwh7qfsn0nk20jprdfa79ibnz9vw8yljhcvw7c2sqhss4lwyvkz";
    date = "2017-07-27";
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
    rev = "v2.7.1";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "1zrzamgsr4kzdmv4cbz4dv9l9wf8mlk7x7xdiwf4crwhr18h75p9";
  };

  go-retryablehttp = buildFromGitHub {
    version = 6;
    rev = "3b087ef2d313afe6c55b2f511d20db04ca767075";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "1zdrjy1bya7av65iq4zyy9dk26sdvjv4asa6yn5as05msz7fdl84";
    date = "2018-05-31";
    propagatedBuildInputs = [
      go-cleanhttp
    ];
  };

  go-reuseport = buildFromGitHub {
    version = 6;
    rev = "v0.1.15";
    owner = "libp2p";
    repo = "go-reuseport";
    sha256 = "1dzxpfx6k94h9r67y2z1dbp02g89z14jxnhqk55rldsvvaff83qy";
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
    rev = "v0.1.6";
    owner = "libp2p";
    repo = "go-reuseport-transport";
    sha256 = "0iiqsfrn322016ra09q5fl69qjn46z53n3w7vwpllsabhaypnq9w";
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
    rev = "ce7b0b5c7b45a81508558cd1dba6bb1e4ddb51bb";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "10bchclblrbva05cyr29l16im4j3v9n33wipq1vjf1z4b6p7v1qr";
    date = "2018-04-08";
  };

  go-safetemp = buildFromGitHub {
    version = 6;
    rev = "b1a1dbde6fdc11e3ae79efd9039009e22d4ae240";
    owner  = "hashicorp";
    repo   = "go-safetemp";
    sha256 = "16aqn987gflps6w00rin36fdny1p6vwc15qx516kjskmp2j6vah5";
    date = "2018-03-26";
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
    version = 6;
    rev = "0e6ea8a329671a8faad289d167ff50fc5432d594";
    owner  = "pengsrc";
    repo   = "go-shared";
    sha256 = "1qhbfyk545z6512dr3amz2yczmi3ak4h5b6gb50sh80yf79dixw3";
    propagatedBuildInputs = [
      gabs
    ];
    meta.useUnstable = true;
    date = "2018-06-04";
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
    version = 5;
    owner = "shogo82148";
    repo = "go-shuffle";
    date = "2018-02-18";
    rev = "27e6095f230d6c769aafa7232db643a628bd87ad";
    sha256 = "1s0hfhw7w18kdndl053i0rs72dmmwprjd1qhwfcpbz0lszavi125";
  };

  go-smux-multiplex = buildFromGitHub {
    version = 6;
    rev = "6c9914bb78b80e4e5947a43d27781b8863e19062";
    owner  = "whyrusleeping";
    repo   = "go-smux-multiplex";
    sha256 = "1kd68sk1m7ciyi52wniqqr888xvl019plvkhcmmdz6q52l76qafv";
    date = "2018-06-09";
    propagatedBuildInputs = [
      go-stream-muxer
      go-multiplex
    ];
  };

  go-smux-multistream = buildFromGitHub {
    version = 6;
    rev = "c707bf3c25fa380b20b54907790efde288775938";
    owner  = "whyrusleeping";
    repo   = "go-smux-multistream";
    sha256 = "1h80ajrsg1jdxsxi1m6qfydd7v181544yxhs4nhr18p4676qdnk3";
    date = "2018-05-29";
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
    rev = "eac25f3e2d47aae211e457e7664b52634c95eea8";
    owner  = "whyrusleeping";
    repo   = "go-smux-yamux";
    sha256 = "1yqvixh36ffgd28b99py2qdm4zbrql659mphci4if08saz1vpjw9";
    date = "2018-06-04";
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
    version = 5;
    rev = "8991bc29aa16c548c550c7ff78260e27b9ab7c73";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1cjs23xhbpk5blv7wbnbn79xzkdnidhs448mzn2qkrddjkhbgs4y";
    date = "2018-02-21";
  };

  go-sqlite3 = buildFromGitHub {
    version = 6;
    rev = "25ecb14adfc7543176f7d85291ec7dba82c6f7e4";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "18pygq04kjz8xh2562r5g9lznaan09ck5dddb5wsrgclhfg08xgg";
    excludedPackages = "test";
    meta.useUnstable = true;
    date = "2018-06-13";
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
    rev = "a4887aeaa186e68961d2d6af7d5fbac6bd6fa79b";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "1kzjy72rjq1v8rw6cdidbizld4z6zz1kcb37mjsb0rc91i5zh743";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2018-05-25";
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
    rev = "v2.0.2";
    sha256 = "0p4grazpdhbn3dkv4y4mq0yqldqw10yhmmh1y5jn4zra68f2fl7w";
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
    rev = "a61a99592b77c9ba629d254a693acffaeb4b7e28";
    sha256 = "1mc2ig4m9igl60r14y26mdn2nlm36saxg7wk2qwif4i0mpzdd91p";
    date = "2017-10-04";
  };

  go-toml = buildFromGitHub {
    version = 6;
    owner = "pelletier";
    repo = "go-toml";
    rev = "c01d1270ff3e442a8a57cddc1c92dc1138598194";
    sha256 = "15ml3fx3q6ywsaypwhhbava0qgcwr1yj80wxisdikzygrxcwnak5";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2018-06-05";
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
    rev = "27454136f0364f2d44b1276c552d69105cf8c498";
    date = "2018-02-28";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "09bz8mvswqmbkwnm71pdndpyscsyyk3yx9hphysdmnrad1mkazbi";
  };

  satori_go-uuid = buildFromGitHub {
    version = 6;
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
    version = 6;
    rev = "ad45545899c7b13c020ea92b2072220eefad42b8";
    owner  = "mitchellh";
    repo   = "go-wordwrap";
    sha256 = "0yj17x3c1mr9l3q4dwvy8y2xgndn833rbzsjf10y48yvr12zqjd0";
    date = "2015-03-14";
  };

  go-ws-transport = buildFromGitHub {
    version = 6;
    rev = "v2.0.2";
    owner  = "libp2p";
    repo   = "go-ws-transport";
    sha256 = "1zcqnv94vagl4qhrws6mfvpm1hqlg5yd0fsq3djrcqyjwjyv15ma";
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

  gocertifi = buildFromGitHub {
    version = 6;
    owner = "certifi";
    repo = "gocertifi";
    rev = "2018.01.18";
    sha256 = "0vjky8wyxb2mn6lx7qycbrmyv2cz0zywx78ndfysk6jvw6a6axkv";
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
    rev = "v5.1.4";
    sha256 = "1wvjzak3w7hgmd2h9a9jmqyd2kmm9z8rl166mfgkpkl0nqbmdk02";
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
    date = "2018-05-13";
    rev = "24b0969c4cb722950103eed87108c8d291a8df00";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "0hgx93wkvldxqbcybyxda2xinwi95lxnckifs8vi8zspysi5z2xc";
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
    rev = "v1.4.1";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "09909lx70af9d87hns6j0p4rbnma5zilfbzbn9p984cpv8pxrlc3";
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
    rev = "08ed213262b5bb2cf6ccb0baa71c6b201d353e63";
    sha256 = "1lsv9314qma8fbdwyklbwz83a0lafwxi75f0lklcfhlh79z93gmz";
    date = "2018-05-01";
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
    rev = "v0.13.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "00f6xyfjpb1ika1zvq6hyy9a9jnbkgyjmgv4gg900wkq8nhd5y32";
    propagatedBuildInputs = [
      urfave_cli
      go-git-ignore
      go-homedir
      go-ipfs-api
      go-multiaddr
      go-multiaddr-net
      go-multihash
      go-os-rename
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
    rev = "v1.7.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "13a5q18srbqzc24f6000scds5qsar73m3gyj8lw32ml9vwillpnp";
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
    version = 5;
    rev = "v1.0.1";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "0l1gmrffjji0pxm5w3alr1d8df7qcymsvmlb04hil0f3xnbf8inl";
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
    rev = "13a38d26174b16d5b4bf6f1094c1389ec9879572";
    sha256 = "08pmp9cx0pfyay1km17zj2w25q93aq0bnhsnz98pcrb9gkixzp6j";
    date = "2018-05-08";
  };

  hashstructure = buildFromGitHub {
    version = 6;
    date = "2017-06-09";
    rev = "2bca23e0e452137f789efbc8610126fd8b94f73b";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "12z3vcxbdgkn1hfisj3m23kgq9lkl1rby5cik7878sbdy9zkl0bw";
  };

  hcl = buildFromGitHub {
    version = 6;
    date = "2018-04-04";
    rev = "ef8a98b0bbce4a65b5aa4c368430a80ddc533168";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "021d9wa412zyr4ak7sh1zb1mr9rg8iqw2ha5pn2ixb41sb8f4a31";
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
    rev = "f0b70129076928479e599e20e5179e9b17f6ae3d";
    owner = "mailgun";
    repo = "holster";
    sha256 = "1d20w9n97vrwsdak595nmvadam44qwz0nmhhd5fwaxg3l9isjhap";
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      errors
      logrus
      structs
    ];
    date = "2018-06-21";
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
    version = 6;
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
    version = 6;
    rev = "adbc77eec0d91467376ca515bc3a14b8434d0f18";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "1x1py2mqm7wjdirpj5kh39p130vag4xqylryjxjn267awksqcqs5";
    date = "2018-04-11";
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
    rev = "v0.42.1";
    sha256 = "1ks4dp00bb6ym4a8nnsbkjvjgjdhyxbw3ir7hbg5fd7s46nk3c9k";
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
    rev = "v1.0.1";
    owner  = "opencontainers";
    repo   = "image-spec";
    sha256 = "0nbdx1qz40d35b2gibj8gddsc83bnpk1ilah641smkf7i8zk5py0";
    propagatedBuildInputs = [
      errors
      go4
      go-digest
      gojsonschema
    ];
  };

  imaging = buildFromGitHub {
    version = 6;
    rev = "v1.4.2";
    owner  = "disintegration";
    repo   = "imaging";
    sha256 = "12w3371299nahjgrpbmsivs9a9642xif043bnvd61k9d26zb9z6f";
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
    rev = "v1.0.0";
    sha256 = "1ymzjhgyy46bai2l57a76y9bsgzhg0a5vrv8bl7fpjawl3flkbbi";
    propagatedBuildInputs = [
      envy
    ];
  };

  influxdb = buildFromGitHub {
    version = 6;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.5.4";
    sha256 = "0bi56zvqqsc663f8fl5y2v4y2w0b5hgbns3492anw5f838n1cvag";
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
    rev = "5e999e6a81820d4450f2a1f35c5597b569258f01";
    owner  = "influxdata";
    repo   = "influxql";
    sha256 = "03apwik0hk0wrkjbljq9ady1v6bbik6n6y9ffpyrj2ckqkngh2dn";
    date = "2018-06-21";
    propagatedBuildInputs = [
      gogo_protobuf
    ];
  };

  ini = buildFromGitHub {
    version = 6;
    rev = "v1.37.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "0m3rs026prhisqil30k98q6viq0kfrl2y4rb6spdqlw93c1924cv";
  };

  ini_v1 = buildFromGitHub {
    version = 6;
    rev = "v1.37.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "09m1bly53ki2326axa9nj9kip2fq11s7iqwsppf7ryjixzgz7d7i";
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
    rev = "v0.4.17-rc1";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "6b90fd9117a044254e7223c653673c56c988021943338c545163a85560cbce3d";
    gxSha256 = "0gx0rwj1ymzbia03fngp4v7ipkvkvyvzw2q2anypspzh1r96n4zq";
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
    rev = "8682780cdedd5ff4cdb17c6d0434cb9c784c36c4";
    owner = "ipfs";
    repo = "ipfs-cluster";
    sha256 = "1fzga7dgnmh81hhak2snzn4rymj06pmrnsxhbcv0rzbmqp017k53";
    meta.useUnstable = true;
    date = "2018-06-22";
    excludedPackages = "test";
    propagatedBuildInputs = [
      urfave_cli
      go-cid
      go-dot
      go-floodsub
      go-fs-lock
      go-ipfs-api
      go-libp2p
      go-libp2p-consensus
      go-libp2p-crypto
      go-libp2p-host
      go-libp2p-http
      go-libp2p-interface-pnet
      go-libp2p-gorpc
      go-libp2p-gostream
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-pnet
      go-libp2p-protocol
      go-libp2p-raft
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
    rev = "v0.7.0";
    owner = "go-kit";
    repo = "kit";
    sha256 = "1wf764qbq7apl4sri8924qxkipw544hbcx9vkvqbxx41wf88w905";
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
    rev = "00c78f6603af046dfcada47ba511ddc94e7a64ce";
    owner  = "kubernetes";
    repo   = "api";
    sha256 = "1h9x28cn1r93gnwyqgvrgx09007li10waiz53zrc5n5bxkdanvl7";
    goPackagePath = "k8s.io/api";
    propagatedBuildInputs = [
      gogo_protobuf
      kubernetes-apimachinery
    ];
    meta.useUnstable = true;
    date = "2018-06-24";
  };

  kubernetes-apimachinery = buildFromGitHub {
    version = 6;
    rev = "1c56055d3f2ff0ae5ff61d86dc8c88d2928b7ab3";
    owner  = "kubernetes";
    repo   = "apimachinery";
    sha256 = "1061d177i4jd72zwyn7z2nz673khdmw6gzphh11f5mg4rx0cwsjq";
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
      reflect2
      spdystream
      yaml
    ];
    postPatch = ''
      rm -r pkg/util/uuid
    '';
    meta.useUnstable = true;
    date = "2018-06-24";
  };

  kubernetes-kube-openapi = buildFromGitHub {
    version = 6;
    rev = "4cac20de16b951c103aa40c4bafbc8cefdd18a12";
    date = "2018-06-22";
    owner  = "kubernetes";
    repo   = "kube-openapi";
    sha256 = "044bkggb2c8xa5kgjx9gbjqp8x41b7xnla7waizcy9kwnd2229l9";
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
    rev = "57012a8ca3a79ba74a7857acc94c46e87e9aa47c";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "11c747r76kwlgyn8p79la18iwgpkm2rqj8g2vazd1l9pp3iyv1li";
    goPackagePath = "k8s.io/client-go";
    excludedPackages = "\\(test\\|fake\\)";
    propagatedBuildInputs = [
      crypto
      diskv
      glog
      gnostic
      go-autorest
      gophercloud
      groupcache
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
    date = "2018-06-24";
  };

  ldap = buildFromGitHub {
    version = 6;
    rev = "ef52f0f48a85a3a669e1f6bdcf90a62b97762952";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "0hg06d0yjj9cpvc3pxabfx3q6bdlczgcjnmpbhihl5564wqz5hj6";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [
      asn1-ber
    ];
    date = "2018-06-07";
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
    rev = "v1.0.1";
    owner = "xenolf";
    repo = "lego";
    sha256 = "0kbsk3v53x3wjiapmjjzj7rq9syfm93qyjzcfjxi8a28d39a4bpb";
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
    rev = "9a5f6cf3c788525dcf8bbd2f0839f80c3e74614d";
    owner = "docker";
    repo = "libnetwork";
    sha256 = "14n4qd3gmmyhssy40bpnib5g3rij3mxsfnv0hgn4r5ny24x6nb71";
    date = "2018-06-22";
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
    rev = "v0.15.2";
    owner  = "lightstep";
    repo   = "lightstep-tracer-go";
    sha256 = "1i0dpvwrbxn2k45v54ahjn0l2h9xdyvrbk51yiwlqili2l971s2l";
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
    rev = "8c1271fcf47f341a9e6771872262870e1ad7650c";
    owner = "peterh";
    repo = "liner";
    sha256 = "1xmqfn5c61qy0126nqn9i48p7h828z8nr1wpa22j9hhv4asxjdm7";
    date = "2018-06-19";
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
    rev = "0decfc6c20d9ca0ad143b0e89dcaa20f810b4fb3";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "14nbvlq60aj16vjpajrccvl31kb5a214lyzy6z8hqrm4sb16adix";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
      stack
      sys
    ];
    date = "2017-10-19";
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
    rev = "7887c61bf0de75586961948b286be6f7d05d9f58";
    owner = "lunny";
    repo = "log";
    sha256 = "00impglzjzlc1aqhgg21avpms02q7vm3063ngwn6f4ihk99r2xq1";
    date = "2016-09-21";
  };

  mailgun_log = buildFromGitHub {
    version = 6;
    rev = "2f35a4607f1abf71f97f77f99b0de8493ef6f4ef";
    owner = "mailgun";
    repo = "log";
    sha256 = "0ykzq36pbzjyhsvpj2whcl26fyi0ibjlgl7x8zf5mbp71i47dxjq";
    date = "2015-09-26";
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
    rev = "75068beb13ada9c0ddde611f678523fda7352650";
    owner = "sirupsen";
    repo = "logrus";
    sha256 = "10gmc51srhjx9rchd5ibsqvqr9bkjrkwxi1h97bgy4j4p3bdl1nd";
    goPackageAliases = [
      "github.com/Sirupsen/logrus"
    ];
    propagatedBuildInputs = [
      crypto
      sys
    ];
    meta.useUnstable = true;
    date = "2018-06-18";
  };

  logutils = buildFromGitHub {
    version = 6;
    date = "2015-06-09";
    rev = "0dc08b1671f34c4250ce212759ebd880f743d883";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "1g005p42a22ag4qvkb2jx50z638r21vrvvgpwpd3c1d3qazjg7ha";
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
    rev = "lxd-3.2";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "1g8690jyxg3sbv8dl6jzw44kg5301r18bjir1i856ignm94i8pf4";
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
    rev = "v2.0.2";
    owner  = "pierrec";
    repo   = "lz4";
    sha256 = "1i8p6xic9w0mg1jwpig2ffqfwvl7r41p6ylgi6yb7zj3560y8nk0";
    propagatedBuildInputs = [
      profile
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
    version = 6;
    date = "2018-06-11";
    rev = "794419fbc8492a4d5b7ba38b58c2bb47d9e37eaa";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "0146s538nllwllrijn5nf4xfhs64gnq648kqvsm321k91rkw3ydv";
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
    rev = "2.1";
    owner = "magefile";
    repo = "mage";
    sha256 = "1psd827jpwr2xl13jxj9b820hdmydglwfgjnb5im2rcagbszs0ay";
    excludedPackages = "testdata";
  };

  mapstructure = buildFromGitHub {
    version = 6;
    date = "2018-05-11";
    rev = "bb74f1db0675b241733089d5a1faa5dd8b0ef57b";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "1yfz94ik3iinzny5q593y8g1pbxc5mh68ad906wfw1aac128hq34";
  };

  martian = buildFromGitHub {
    version = 6;
    rev = "412d6c62968910b965c4d374abc8f3de72986a06";
    owner = "google";
    repo = "martian";
    sha256 = "146r3kr7s8y1i1n7kkz6faaqnsghhx05j39pjm8ily841x240v3k";
    date = "2018-06-04";
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
    rev = "4070902cdaa5e9553433e9e96a185327dc5bf7bc";
    sha256 = "01k6mr1m29aqm5n0cb5kzydc1bvgbg7plm7pnykigcvcrdcl1jl2";
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
    date = "2018-06-21";
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
    version = 6;
    date = "2015-06-22";
    rev = "1031fa0ce2f20c1c0e1e1b51951d8ea02c84fa05";
    owner = "rainycape";
    repo = "memcache";
    sha256 = "0fqi1yy90dgf82l7zr8hgn4jp5r5gg7wr3bb62mpjy9431bdkw1a";
  };

  mergo = buildFromGitHub {
    version = 6;
    rev = "v0.3.5";
    owner = "imdario";
    repo = "mergo";
    sha256 = "0d7ywf6l2jakh8y15m64cpvswcprzvs5hagffrj1f8d9rrjqxacq";
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
    rev = "r2016.08.01";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "04mpjagap39x10pjxrxf4v90g7461qsx92llzqjnz1a1m1isba6v";
    goPackagePath = "gopkg.in/mgo.v2";
    excludedPackages = "dbtest";
    buildInputs = [
      pkgs.cyrus-sasl
    ];
  };

  minheap = buildFromGitHub {
    version = 6;
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
    rev = "f46ee54194db32205f32b925fe459c158666ac98";
    sha256 = "0s750aqcc9paz0vby02avankhx68ryv3z3n6zfq3kr78ggfp3rc2";
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
    date = "2018-06-22";
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
    rev = "f43432a35c6ffcd3f71be416f5166046f4dc6b2d";
    sha256 = "13sil3b36h6qnx9frxhlhf6nmj19bq2n82h6xzk47mlz1fh8d9nr";
    propagatedBuildInputs = [
      crypto
      go-homedir
      ini
      net
    ];
    meta.useUnstable = true;
    date = "2018-06-22";
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
    rev = "v1.3.6";
    sha256 = "1prcgb8xqvzqvwky9mz5yq386hjhl2194ly6rg4aakqc3651rspi";
    propagatedBuildInputs = [
      toml
    ];
  };

  moby = buildFromGitHub {
    version = 6;
    owner = "moby";
    repo = "moby";
    rev = "320e4fed2258ba9eea97f2e0b8a4e08d835bb080";
    date = "2018-06-23";
    sha256 = "13mn35s4sz2bn9nm8hy88d7jc5w89h5pw4hv7nq5k0mzq46ak093";
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
    rev = "r4.0.0";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "1ng1dqagf6nszlnrg9kcrif8x9k5q95zfxl2x78srr1yjsq0kzyq";
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
    rev = "4a57e760766adfc52f0ea97633a06da8f6ee9b2a";
    owner  = "ns1";
    repo   = "ns1-go";
    sha256 = "1ipng0k8nvfjgjaq0fxi71xpb7c89nkybfaql6r6wgdhqs1iq0nq";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2018-06-12";
  };

  msgp = buildFromGitHub {
    version = 6;
    rev = "ef41b42e603a8b9d25e0027b432f41d141093fbd";
    owner  = "tinylib";
    repo   = "msgp";
    sha256 = "0bh6zsjk6njgxird40lnvpdlq0f9mnxkzlim6qkma5is0dkvjkyf";
    propagatedBuildInputs = [
      fwd
      chalk
      tools
    ];
    date = "2018-06-19";
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
    version = 6;
    rev = "be1fbeda19366dea804f00efff2dd73a1642fdcc";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "1v0azn8ndn1cdx254rs5v9agwqkiwn7bgfrshvx6gxhpghxk1x26";
    date = "2017-11-11";
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
    rev = "v0.8.4";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "13j3w2njrc8yhmskhpl6xgd44cn9k2qzk50sf9570rixgf2vm6by";

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
    date = "2018-04-20";
    rev = "b9ceffc925039c77cd9e0d38f248279ccc4399e2";
    sha256 = "1cqs9p3nkx221949jrndky2qcyh4x24skw54r82mq00c62v206rc";
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

  objx = buildFromGitHub {
    version = 6;
    rev = "v0.1.1";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "01dbh7nb5hyac0gf8hvslh2dgzwd490m5y9wxzvwlanmzrna3yym";
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
    rev = "d136bc2a9a1d1df22012bee58bebcaa585039012";
    date = "2018-05-24";
    sha256 = "107lbi6yvbmsi642a0pmca9kqx5a0868xnkj02lbsz81d860xs2k";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  opencensus = buildFromGitHub {
    version = 6;
    owner = "census-instrumentation";
    repo = "opencensus-go";
    rev = "48905db4a42827c009d77f5745a6a9125266823f";
    sha256 = "13xvvf4q97kxy4gjcvr0bz3s6gd3gynyb0rz1404ycb9ysazchfa";
    goPackagePath = "go.opencensus.io";
    subPackages = [
      "."
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
    ];
    propagatedBuildInputs = [
      grpc
      net
    ];
    meta.useUnstable = true;
    date = "2018-06-21";
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
    rev = "bd9c3193394760d98b2fa6ebb2291f0cd1d06a7d";
    sha256 = "0h44byaxxzxlzcpwk3xcdqjy7is58blhkavfpc45ynv5p5qkqgg9";
    goPackageAliases = [
      "github.com/frrist/opentracing-go"
    ];
    excludedPackages = "harness";
    propagatedBuildInputs = [
      net
    ];
    date = "2018-06-06";
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
    rev = "7b7d3c712f975469621fc8fb0a1fa08f0bcafe52";
    owner = "pquerna";
    repo = "otp";
    sha256 = "0nxsp7rmxfrbdnnbi04jk0q6f4viskq5q03lk4rqxamr9nyd1kj2";
    propagatedBuildInputs = [
      barcode
    ];
    date = "2018-06-21";
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
    date = "2018-05-21";
    rev = "2af8bbdea9e99e83b3ac400d8f6b6d1b8cbbf338";
    sha256 = "1vq232hfd127fqszfczqh2y1z5jif0fcvh3v0imvpmdc336mri4p";
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
    rev = "v1.0.25";
    sha256 = "1wp97kwpia8pzs7vfrynsmnmd45g7952bkrv0xhdr1kwwn2ry5gh";
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

  pester = buildFromGitHub {
    version = 6;
    owner = "sethgrid";
    repo = "pester";
    rev = "1.0.0";
    sha256 = "14qdmyf02afip0vcpnplvs1iin4i05haaixpw46r355b1whd5q5p";
  };

  pflag = buildFromGitHub {
    version = 6;
    owner = "spf13";
    repo = "pflag";
    rev = "v1.0.1";
    sha256 = "0b8l4pwv0i55m4wm482kd1vdzjslzispva5qplasdvz6vvirgq0m";
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
    version = 5;
    date = "2018-01-08";
    owner  = "coreos";
    repo   = "pkg";
    rev = "97fdf19511ea361ae1c100dd393cc47f8dcfa1e1";
    sha256 = "0y3day5j98a52dpf8y4rcp9ayizgml02vljg4rfvfl26wg11rlsr";
    propagatedBuildInputs = [
      crypto
      go-systemd_journal
      yaml_v1
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
    version = 6;
    rev = "969857f48f7ae439b6d2449ed1dcd9aaabc49c67";
    owner  = "aead";
    repo   = "poly1305";
    sha256 = "19ysvx7sy9wf79yy3af0ba45sj659rpkkmbrfkh8yc6jq6k61vxy";
    date = "2018-04-11";
  };

  pongo2 = buildFromGitHub {
    version = 6;
    rev = "67f4ff8560dfa2b00920118f228c0a2f68760631";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "0qf3cmzgfdlxv3a7yg0gvy4rdr5y0pmwhn54x4vq59qyx314n6xa";
    date = "2018-06-11";
    propagatedBuildInputs = [
      juju_errors
    ];
  };

  pprof = buildFromGitHub {
    version = 6;
    rev = "8b03ce837f3401233d4e32de3a5f0ea3ff1c13c2";
    owner  = "google";
    repo   = "pprof";
    sha256 = "11x3apfla5nddf361k91zydpc6i8jgkkb1d1q3gnh42sm9hws3xs";
    date = "2018-06-05";
    propagatedBuildInputs = [
      demangle
      readline
    ];
  };

  pq = buildFromGitHub {
    version = 6;
    rev = "90697d60dd844d5ef6ff15135d0203f65d2f53b8";
    owner  = "lib";
    repo   = "pq";
    sha256 = "0h6846rwbdkxwl22v4h1i1dq91bxk3v87xla2a34cjigdh9grx10";
    date = "2018-05-23";
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
    rev = "7d6f385de8bea29190f15ba9931442a0eaef9af7";
    date = "2018-06-12";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "1f4rchss45nf9fv4x8aw9nahblblzbyxgl0x7wiff2ddlln5ma9l";
  };

  profile = buildFromGitHub {
    version = 6;
    owner = "pkg";
    repo = "profile";
    rev = "v1.2.1";
    sha256 = "1r0kcrfn4vn6q5zcdmdkxiad4mlwxy8h0bmgffqvhn7y626cpjb5";
  };

  progmeter = buildFromGitHub {
    version = 6;
    owner = "whyrusleeping";
    repo = "progmeter";
    rev = "30d42a105341e640d284d9920da2078029764980";
    sha256 = "162rlxy065dq1acdwcr9y9lc6zx2pjqdqvngrq6bnrargw15avid";
    date = "2017-11-15";
  };

  prometheus = buildFromGitHub {
    version = 6;
    rev = "v2.3.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "1kncl161yixxmqy84grxkdiy7fw94y4x569fddjvb6b977j1j2ff";
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
    rev = "77e8f2ddcfed59ece3a8151879efb2304b5cbbcf";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "0ngqzn0d0b12b6fr6j2ya7528cqq7id1v9zg4qsv9l453dbhfgfl";
    propagatedBuildInputs = [
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      perks
    ];
    date = "2018-06-23";
  };

  prometheus_client_model = buildFromGitHub {
    version = 6;
    rev = "99fa1f4be8e564e8a6b613da7fa6f46c9edafc6c";
    date = "2017-11-17";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "0cv75ws6yba5a57616gfpb2n4pixcmcfq71fhins0qzqx1bgwvyx";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 6;
    date = "2018-05-18";
    rev = "7600349dcfe1abd18d72d3a1770870d9800a7801";
    owner = "prometheus";
    repo = "common";
    sha256 = "1j9zcd2hnfpq98j7f6qjg74pb7xkzlnvf4gp6s42rczjawgyqacr";
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
    date = "2018-06-05";
    rev = "c848349f07c83bd38d5d19faa5ea71c7fd8923ea";
    owner = "prometheus";
    repo = "tsdb";
    sha256 = "07dkf7slv0yvpq63d7i28zng55hkl5iqc8mskp955vxyp54s1150";
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
    rev = "7a779a0ce551727b41b0b5b498d9d454d280859b";
    sha256 = "1scaj3s9hsg0ag3694s44yjqvd27rs0hydh2jnxmgs404bym55zp";
    propagatedBuildInputs = [
      urfave_cli
      go-shuffle
      sentences_v1
      stats
    ];
    date = "2018-06-22";
  };

  gogo_protobuf = buildFromGitHub {
    version = 5;
    owner = "gogo";
    repo = "protobuf";
    rev = "v1.0.0";
    sha256 = "1cfng3fx9mgi96bbi0z5phlz2bylfmgy80rzmwb2jqryafdgms2b";
    excludedPackages = "test";
  };

  pty = buildFromGitHub {
    version = 6;
    owner = "kr";
    repo = "pty";
    rev = "v1.1.2";
    sha256 = "1gprvjxlk2ii7syhikph3hxhkf9dyj9z2naf3faq65ifi15y8vbb";
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
    version = 6;
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "1wka69q9yyryiyylrcwjnhv0mhlkk04b1nxzvhflbhqv1rz8y0g7";
  };

  qingstor-sdk-go = buildFromGitHub {
    version = 6;
    rev = "v2.2.14";
    owner  = "yunify";
    repo   = "qingstor-sdk-go";
    sha256 = "14rh3513k7ddd5vnixm3b7fqgfxi010r9m0q54jp0j0dplca9rpz";
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
    rev = "f161a4e024cf7d37ec41a617f9caae7f13671a7e";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "09j6c4kh3jjcydsw9zd4p6m6l3d70ncbg2cpwcqflvv5p53njl2l";
    date = "2018-06-18";
  };

  radius = buildFromGitHub {
    version = 6;
    rev = "505941eec7a1478cee7528d056963577ca4e9cc3";
    date = "2018-05-30";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "0wvw6l5zcc8x0a5bcdx0y12qbp1dj506r8s8l12rwp7cpbygk5mb";
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
    version = 5;
    rev = "1.0.1";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0lg302miyrkff04a1jqfrz1kdb96miw7qrm3x3g21n7w3vp40y4g";
  };

  raven-go = buildFromGitHub {
    version = 6;
    date = "2018-05-17";
    rev = "ed7bcb39ff10f39ab08e317ce16df282845852fa";
    owner  = "getsentry";
    repo   = "raven-go";
    sha256 = "0w10xlfkva0sprq9g5a7zwvwgi0za00l8yd0pdv6iwqqxkqskclr";
    propagatedBuildInputs = [
      errors
      gocertifi
    ];
  };

  rclone = buildFromGitHub {
    version = 6;
    owner = "ncw";
    repo = "rclone";
    date = "2018-06-18";
    rev = "1550f70865245f917c63330039b18876bb214c8f";
    sha256 = "08k96by07z4bdqfbxmvspkab982ihkw1az996ym6arydq237kwhn";
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
      go-mega
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
    owner = "garyburd";
    repo = "redigo";
    date = "2018-04-04";
    rev = "569eae59ada904ea8db7a225c2b47165af08735a";
    sha256 = "0fzyzwszy9pa6izra69slj8izj7s15gndcj7zffyqnlh3y6ds2d6";
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
    date = "2018-05-04";
    rev = "7d9453e171e998ffa322b015f10db4e4519adadf";
    sha256 = "1bz18fg9jlmmgp6fslqziz1vyz46msif2kpc7663mjn2l0hhxhmw";
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
    version = 6;
    date = "2017-07-26";
    rev = "63d60e9d0dbc60cf9164e6510889b0db6683d98c";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "1xpgzn3rgc222yz09nmn1h8xi2769x3b5cmb23wch0w43cj8inkz";
  };

  regexp2 = buildFromGitHub {
    version = 6;
    rev = "v1.1.6";
    owner  = "dlclark";
    repo   = "regexp2";
    sha256 = "1jb5ln420ic5w719msd6sdyd5ck88fxj50wxy7g2lyirm1mklgsd";
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
    rev = "4080b1743e0c46fa1645f4de64f1b75a980d82a3";
    sha256 = "19j0ip7bpl9fzz14nbbgw8ci2dcylh4ya6hyjrvp3ykkqz407jzb";
    subPackages = [
      "api/v1"
      "networking/netinfo"
    ];
    propagatedBuildInputs = [
      cni
    ];
    meta.useUnstable = true;
    date = "2018-05-28";
  };

  roaring = buildFromGitHub {
    version = 6;
    rev = "v0.4.9";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1pvrwcn4y9574r10l727i781q62ibdh0yyzkpfzdmnnfyx1v5azn";
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
    version = 6;
    owner = "gravitational";
    repo = "roundtrip";
    rev = "37ee6ee8eac0767a2f81cddf6f3fa0d37046fecc";
    sha256 = "16yl4sksvibpjdml23gb0w02r0hkhjvgrkpc93bbhh8gf1ld18s2";
    propagatedBuildInputs = [
      trace
    ];
    date = "2018-06-02";
  };

  rpc = buildFromGitHub {
    version = 6;
    owner = "gorilla";
    repo = "rpc";
    rev = "5c1378103183095acc1b9289ac1475e3bc1e818e";
    sha256 = "014xk9jz4khhcnw44ck4fi10wjy311cwd37ngnib58498y40fwm2";
    date = "2018-06-18";
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
    rev = "3ccfa2ffb2daf575b417cef6cdd731233d3c7dad";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "1p7a7ngnpnz1d582cz9zg2a3idh7d4wdhfl0mpch1ifhp1y3ypx7";
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
    date = "2018-06-25";
  };

  runtime-spec = buildFromGitHub {
    version = 6;
    rev = "7c4c8f63a63693f75cfa0f3f397151fb8d9732ad";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "0fvg0pv1bimnjs5y2s55hyy9fy4xdbyy5rd9lazfx34d4ay4kdi9";
    buildInputs = [
      gojsonschema
    ];
    #meta.autoUpdate = false;
    date = "2018-06-15";
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
    rev = "v1.17.0";
    sha256 = "1p2kbf3lxkdirj6dbphimfrwkb3n8hwiyjwr1cix9inlhqpnzxh0";
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
    rev = "v1.17.0";
    sha256 = "1w12rnpz60v8g1iz8glknn6hj88p6bwhzag9kynhxk5qk23r5n37";
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
    version = 5;
    owner = "ishidawataru";
    repo = "sctp";
    rev = "07191f837fedd2f13d1ec7b5f885f0f3ec54b1cb";
    sha256 = "4ff89c03e31decd45b106e5c70d5250e131bd05162b1d42f55ba176231d85299";
    date = "2018-02-18";
    meta.autoUpdate = false;
  };

  sdnotify = buildFromGitHub {
    version = 6;
    rev = "ed8ca104421a21947710335006107540e3ecb335";
    owner = "okzk";
    repo = "sdnotify";
    sha256 = "089plny2r6hf1h8zwf97zfahdkizvnnla4ybd04likinvh45hb38";
    date = "2016-08-04";
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
    rev = "6ccd0b50d53ae771fe5259ff7a4039110777aa2d";
    owner = "opencontainers";
    repo = "selinux";
    sha256 = "0zd39n56gbgd315lw66rxdq1g7vibg61qgp5592x2p7wryrs4l8q";
    date = "2018-06-19";
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
    version = 6;
    rev = "v1.0.6";
    owner = "neurosnap";
    repo = "sentences";
    sha256 = "1y42a5ynxrfs6bsipr7ysdw8vyfgwl4y7f739bziqfvpxrzg09ix";
    goPackagePath = "gopkg.in/neurosnap/sentences.v1";
  };

  serf = buildFromGitHub {
    version = 6;
    rev = "984a73625de3138f44deb38d00878fab39eb6447";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "19v7wldmly8rjrhbbjd9mm3zk1kympfsnp3j774dk1jjfdvnhzrg";

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
    date = "2018-05-30";
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
    rev = "1.8.0";
    sha256 = "0545ma41c5aql0jvkz4hwhpaayay3s38v423cnwch01js895c38l";
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
    rev = "v1.1.1";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "0xnyg82hpvm91pbwp5nf0ayqb0lwyjqrskbni0grhxi9fhakrvpj";
    propagatedBuildInputs = [
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

  softlayer-go = buildFromGitHub {
    version = 6;
    date = "2018-06-21";
    rev = "116c442862a4890be37f0808dda4ffac86c47bbf";
    owner = "softlayer";
    repo = "softlayer-go";
    sha256 = "04m5m536qjw7f8lfjhld7pbqxnchdvfr7qpbpzm5xng8y090593a";
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
    date = "2018-04-15";
    rev = "bcff419492eeeb01f76e77d2ebc714dc97b607f5";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "1dy1cy0b0zr7kgraijyjwn1m6lkjg7nskg4i9ilfaxpyydcjmrbx";
    propagatedBuildInputs = [
      jsonpointer
      jsonreference
      swag
    ];
  };

  srslog = buildFromGitHub {
    version = 6;
    rev = "1f7cff998e92763c026b26ab7c80a39e19acc368";
    date = "2018-05-14";
    owner  = "RackSec";
    repo   = "srslog";
    sha256 = "16xxdmhn5cvq9s2g72n6vgrn90shk2kxxcvi9n7cw2sp3xaq208z";
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
    rev = "ba9c9e33906f58169366275e3450db66139a31a9";
    date = "2015-12-15";
    owner  = "xanzy";
    repo   = "ssh-agent";
    sha256 = "1334004122rcqvs45sn0ikdak95zbjcrqkdbsmnhr3fmv9zch5fj";
    propagatedBuildInputs = [
      crypto
    ];
  };

  stack = buildFromGitHub {
    version = 6;
    rev = "v1.7.0";
    owner = "go-stack";
    repo = "stack";
    sha256 = "12mzkgxayiblwzdharhi7wqf6wmwn69k4bdvpyzn3xyw5czws9z3";
  };

  stathat = buildFromGitHub {
    version = 6;
    date = "2016-07-15";
    rev = "74669b9f388d9d788c97399a0824adbfee78400e";
    owner = "stathat";
    repo = "go";
    sha256 = "04jfh6i5wshjlm3j252llw6dj9szp3s5ad730vd036d263fk15j7";
  };

  stats = buildFromGitHub {
    version = 6;
    rev = "0.3.0";
    owner = "montanaflynn";
    repo = "stats";
    sha256 = "0mir9h6f2kkpd15gyzsbv6x85kmffjh8x6wva8s17nkw9rsn1knh";
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
    version = 6;
    date = "2016-06-11";
    rev = "206f8f13aae1697a6fc1f4a55799faf955971fc5";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "024gilapc226id7a6zh5c1cfgfqxayhqn0h8m5l9p5lb2va5bzmd";
  };

  suture = buildFromGitHub {
    version = 6;
    rev = "v2.0.3";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "05ivm92dcrvj1x761yz1ykkp0kbm4pz2q31j95wmd6xwg8sacfs9";
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
    rev = "811b1089cde9dad18d4d0c2d09fbdbf28dbd27a5";
    owner = "go-openapi";
    repo = "swag";
    sha256 = "1n18dry66qp18g7gc0qfjxmdn31x4hsb7m1m1kyackxihxsls4jg";
    date = "2018-04-05";
    propagatedBuildInputs = [
      easyjson
      yaml_v2
    ];
  };

  swarmkit = buildFromGitHub {
    version = 6;
    rev = "58764805d83cc0f5290bfa6ba748898ee5ff87d5";
    owner = "docker";
    repo = "swarmkit";
    sha256 = "1gip1997csj101qc9nhh7l0pcg33ilha76nvyc1yqakg09hj9h82";
    date = "2018-06-19";
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
    rev = "v1.0.39";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "0ca11fb0lrixfd1dhpp8frrnfmjmywcgm8fbmc64pw2fq361mg17";
  };

  syncthing = buildFromGitHub rec {
    version = 6;
    rev = "v0.14.48";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "13mvd2cvnddq0jxaryslcxqcqnm6vzqkhy0iq65gn441sjmp1xsb";
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
      gogo_protobuf
      goleveldb
      groupcache
      net
      notify
      osext
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
      pushd go/src/$goPackagePath
      go run script/genassets.go gui > lib/auto/gui.files.go
      popd
    '';
  };

  tablewriter = buildFromGitHub {
    version = 6;
    rev = "d4647c9c7a84d847478d890b816b7d8b62b0b279";
    date = "2018-05-06";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "0v8cpqba72ccqk02sis1x2kdsnwxqz40falqzq4mnhgc87fqr3qm";
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
    version = 6;
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "17d1mby8cmxz50pv20r4dhdw01dkkamljng556kf35ls0jg9p9wp";
    date = "2016-04-05";
  };

  termbox-go = buildFromGitHub {
    version = 6;
    rev = "5c94acc5e6eb520f1bcd183974e01171cc4c23b3";
    date = "2018-06-13";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "1hx6lamffj9v6qxxbm30m91yrj4mdhximi9ilani9scfl765pysm";
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
    rev = "af7ecd6a2b15efe5c6b742cf4a9ccb31bcc1f362";
    owner  = "apache";
    repo   = "thrift";
    sha256 = "1j15zlagi5dv52gb5i6r074yxr3mn0502hj97zqb9j4r7xdqvr8k";
    subPackages = [
      "lib/go/thrift"
    ];
    propagatedBuildInputs = [
      net
    ];
    date = "2018-06-22";
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
    rev = "v0.3.0";
    sha256 = "0cby7gc7iimbjawg8z5zm3nn70f6mj2lw7qvamh9hrnf81yp5wq3";
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
    rev = "eb799ce68da4150b16ff5d0c89a24e2a2ad993d8";
    owner = "tstranex";
    repo = "u2f";
    sha256 = "077ead659217b4dfaa8f5399d3e45a15713464bd5603704810715e0090aa4064";
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
    rev = "c746c6e86f4fb2a04bc08d66b7a0f7e900d9cbab";
    owner = "juju";
    repo = "utils";
    sha256 = "13p48pbm4hqq31j51v0b3sphggaiand7vwrc12kg8x8pggc3jx22";
    date = "2018-06-19";
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
    rev = "6c6132ff69f0f6c088739067407b5d32c52e1d0f";
    owner = "dimchansky";
    repo = "utfbom";
    sha256 = "06gr9hxflz72lg5h3wxyk7nyjz2qyrl09p88bnc2y3ds85i3l8rl";
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
    rev = "v0.10.3";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "1iny3inp1d316zbaj4z8ksqpnhbpcczwkv9sri02xwyjvvnbxzjm";

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
      pester
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
      mapstructure
      net
      pester
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
      pester
      protobuf
      snappy
      sys
    ];
  };

  vault-plugin-auth-azure = buildFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault-plugin-auth-azure";
    rev = "b6ea73720e04697cd70258d4d15afb893823d8e7";
    sha256 = "01747gn0mjaps4kfwr2r6p07acnfb59dpnyymay0lqncw4ga8alg";
    date = "2018-06-06";
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
    rev = "938178a6cf7984923db84aba4881913f84de9eea";
    sha256 = "16zr9cxycs2clyxd7qmh57yvz88agc5g8jdwkwbmyhbr1kbq4cg9";
    date = "2018-06-06";
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
    rev = "00e5bbe1b7d82707a43ae69de55a240fc888275e";
    sha256 = "1qxpggzilkphxq0kdlzmj9pdsqwms89wd2mjy5glbsnhkaq8i93z";
    date = "2018-06-06";
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
    rev = "7ca24869a5b9c9e308c475a21c9ce1331734120e";
    sha256 = "0i9wxwah10jj71ax1ijggaxh6y0hwbjym0pl8l1jbpr33wqrfy60";
    date = "2018-06-19";
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
    rev = "v1.4.0";
    sha256 = "13bswwsp8n46q0q79pylvx1w8dlipjkbzjb4x87y1rnmbcqcqf0p";
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
    version = 6;
    rev = "2d01aacdc34a083dca635ba869909f5fc0cd4f41";
    owner  = "lunixbochs";
    repo   = "vtclean";
    sha256 = "13scvqsi1ay4yx84s4r00bdsy70rv4c6p57x4d6bbivjm8bj2pd6";
    date = "2018-06-21";
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
      ratelimit
    ];
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
    rev = "54b8c57083b4afb7dc75da7f13e2967b2606a507";
    owner  = "juju";
    repo   = "webbrowser";
    sha256 = "0i98zmgrl6zdrg8brjyyr04krpcn01ssvv5g85fmwpiq9qlis12a";
    date = "2016-03-09";
  };

  websocket = buildFromGitHub {
    version = 6;
    rev = "5ed622c449da6d44c3c8329331ff47a9e5844f71";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "1qgpcwg2m4xxssnqa67rrk6scnjgwmz53bcnf2xnjrkl34r25611";
    date = "2018-06-05";
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
    version = 6;
    rev = "e9ed3c6dfb39bb1a32197cb10d527906fe4da4b6";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "087swqan77hvy0nmj3d6h76n97p0942zqraf298irc7p5jlc2352";
    propagatedBuildInputs = [
      yaml_v2
    ];
    date = "2018-05-03";
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
    date = "2018-06-04";
    rev = "3520598351bb3500a49ae9563f5539666ae0a27c";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "1w7b5fsvx00jv9rcmdw08sikhz9wxskhm4q37vb2kmdzcxx6ka5a";
    goPackageAliases = [
      "github.com/influxdata/yamux"
    ];
  };

  whyrusleeping_yamux = buildFromGitHub {
    version = 6;
    date = "2018-06-04";
    rev = "35d045d4429ecf19430a2b94efc590bc40f2f7af";
    owner  = "whyrusleeping";
    repo   = "yamux";
    sha256 = "01332rqxkq8kbh6vdsaxndmmmpzss9286kh3waq4npy7r0afi6hc";
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
    rev = "v0.3.0";
    owner  = "pkg";
    repo   = "xattr";
    sha256 = "1hc62yfb71giibzxawywcq1b5dbnj8bwdmd3c8gig1r6qgvzgig2";
    propagatedBuildInputs = [
      sys
    ];
  };

  xdr = buildFromGitHub {
    version = 5;
    rev = "v1.1.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "001zdv75v0ksw55p2qqddjraqwhssjxfiachwic8jl60p365mwpp";
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
    version = 5;
    rev = "48099fad606eafc26e3a569fad19ff510fff4df6";
    owner  = "cespare";
    repo   = "xxhash";
    sha256 = "1gcq2ydv6s23lsb1da8hydc3sbydxjxdac9s22g8nb7jxs0rqgym";
    date = "2018-01-29";
  };

  pierrec_xxhash = buildFromGitHub {
    version = 6;
    rev = "a0006b13c722f7f12368c00a3d3c2ae8a999a0c6";
    owner  = "pierrec";
    repo   = "xxHash";
    sha256 = "0zzllb2d027l3862rz3r77a07pvfjv4a12jhv4ncj0y69gw4lf7l";
    date = "2017-07-14";
  };

  xz = buildFromGitHub {
    version = 6;
    rev = "v0.5.4";
    owner  = "ulikunitz";
    repo   = "xz";
    sha256 = "1xr4vvp27d9vc6crfp98rhb8dc7giq2jsf3hm829nq2fidjwpydd";
  };

  zap = buildFromGitHub {
    version = 6;
    rev = "v1.8.0";
    owner  = "uber-go";
    repo   = "zap";
    sha256 = "0ai9282ncmp43mg9y2a75li52l5lq5r8cj9c9vv5f9qzcwhd12db";
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
    rev = "v1.0.0";
    owner  = "jsternberg";
    repo   = "zap-logfmt";
    sha256 = "1619ma694s85np6a3ckr9gq6cf3y3kmrqd1m3cwfwf2r4a3ylbc5";
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
