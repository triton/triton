/* This file defines the composition for Go packages. */

{ overrides, stdenv, go, buildGoPackage, git
, fetchgit, fetchhg, fetchurl, fetchzip, fetchFromGitHub, fetchFromBitbucket, fetchbzr, pkgs }:

let
  self = _self // overrides; _self = with self; {

  inherit go buildGoPackage;

  fetchGxPackage = { src, sha256 }: stdenv.mkDerivation {
    name = "gx-src-${src.name}";

    impureEnvVars = [ "NIX_API" ];
    buildCommand = ''
      if ! [ -f /etc/ssl/certs/ca-certificates.crt ]; then
        echo "Missing /etc/ssl/certs/ca-certificates.crt" >&2
        echo "Please update to a version of nix which supports ssl." >&2
        exit 1
      fi

      unpackDir="$TMPDIR/src"
      mkdir "$unpackDir"
      cd "$unpackDir"
      unpackFile "${src}"
      cd *

      mtime=$(find . -type f -print0 | xargs -0 -r stat -c '%Y' | sort -n | tail -n 1)
      if [ "$(( $(date -u '+%s') - 600 ))" -lt "$mtime" ]; then
        str="The newest file is too close to the current date (10 minutes):\n"
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
      tar --sort=name --owner=0 --group=0 --numeric-owner \
        --no-acls --no-selinux --no-xattrs \
        --mode=go=rX,u+rw,a-s \
        --clamp-mtime --mtime=@$mtime \
        -c . | brotli --quality 6 --output "$out"
    '';

    buildInputs = [ gx.bin ];
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = sha256;
    preferLocalBuild = true;
  };

  buildFromGitHub =
    { rev
    , date ? null
    , owner
    , repo
    , sha256
    , gxSha256 ? null
    , goPackagePath ? "github.com/${owner}/${repo}"
    , name ? baseNameOf goPackagePath
    , ...
    } @ args:
    buildGoPackage (args // (let
        name' = "${name}-${if date != null then date else if builtins.stringLength rev != 40 then rev else stdenv.lib.strings.substring 0 7 rev}";
      in {
        inherit rev goPackagePath;
        name = name';
        src = let
          src' = fetchFromGitHub {
            name = name';
            inherit rev owner repo sha256;
          };
        in if gxSha256 == null then
          src'
        else
          fetchGxPackage { src = src'; sha256 = gxSha256; };
      })
  );

  buildFromGoogle = { rev, date ? null, repo, sha256, name ? repo, goPackagePath ? "google.golang.org/${repo}", ... }@args: buildGoPackage (args // (let
      name' = "${name}-${if date != null then date else if builtins.stringLength rev != 40 then rev else stdenv.lib.strings.substring 0 7 rev}";
    in {
      inherit rev goPackagePath;
      name = name';
      src  = fetchzip {
        name = name';
        url = "https://code.googlesource.com/go${repo}/+archive/${rev}.tar.gz";
        inherit sha256;
        stripRoot = false;
        purgeTimestamps = true;
      };
    })
  );

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    rev = "e234e71924d4aa52444bc76f2f831f13fa1eca60";
    date = "2016-04-18";
    owner = "golang";
    repo = "appengine";
    sha256 = "06l62j64mjgmfc295m5dmyfizbwmvs5cnfs0cj2hrl5xm5hpprr8";
    goPackagePath = "google.golang.org/appengine";
    propagatedBuildInputs = [ protobuf net ];
  };

  crypto = buildFromGitHub {
    rev = "019870fc9d457ee8abd13a2e93e3f2a3b55b7119";
    date = "2016-05-04";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "04ycvrrqm2z9j00aazkrxkav5gqhaw04rz7khzk7l1navn3cjjf8";
    goPackagePath = "golang.org/x/crypto";
    goPackageAliases = [
      "code.google.com/p/go.crypto"
      "github.com/golang/crypto"
    ];
    buildInputs = [
      net_crypto_lib
    ];
  };

  glog = buildFromGitHub {
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-25";
    owner  = "golang";
    repo   = "glog";
    sha256 = "0wj30z2r6w1zdbsi8d14cx103x13jszlqkvdhhanpglqr22mxpy0";
  };

  codesearch = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-06-17";
    owner  = "google";
    repo   = "codesearch";
    sha256 = "12bv3yz0l3bmsxbasfgv7scm9j719ch6pmlspv4bd4ix7wjpyhny";
  };

  image = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-01-02";
    owner = "golang";
    repo = "image";
    sha256 = "05c5qrph5r5ikzxw1mlgihx8396hawv38q2syjvwbxdiib9gfg9k";
    goPackagePath = "golang.org/x/image";
    goPackageAliases = [ "github.com/golang/image" ];
  };

  net = buildFromGitHub {
    rev = "35ec611a141ee705590b9eb64d673f9e6dfeb1ac";
    date = "2016-04-28";
    owner  = "golang";
    repo   = "net";
    sha256 = "1v9adcws9g9q8k65bdwnl0cvh6ay8sqfdwy8n1zxg8n0bzdhabax";
    goPackagePath = "golang.org/x/net";
    goPackageAliases = [
      "code.google.com/p/go.net"
      "github.com/hashicorp/go.net"
      "github.com/golang/net"
    ];
    propagatedBuildInputs = [ text crypto ];
  };

  net_crypto_lib = buildFromGitHub {
    inherit (net) rev date owner repo sha256 goPackagePath;
    subPackages = [
      "context"
    ];
  };

  oauth2 = buildFromGitHub {
    rev = "e86e2718db89775a4604abc10a5d3a5672e7336e";
    date = "2016-05-04";
    owner = "golang";
    repo = "oauth2";
    sha256 = "1rvhaj5h31wrinfyd5s7jfil4j5pifrr9fb4m2h7mdfr93hmj7k0";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [ net gcloud-golang-compute-metadata ];
  };


  protobuf = buildFromGitHub {
    rev = "7cc19b78d562895b13596ddce7aafb59dd789318";
    date = "2016-04-26";
    owner = "golang";
    repo = "protobuf";
    sha256 = "0gn7ciqf2wfci2iqvmlxdwkkq5bv0mgp9vkzhbg3yhzi4jxg7lf6";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [ "code.google.com/p/goprotobuf" ];
  };

  snappy = buildFromGitHub {
    rev = "d7b1e156f50d3c4664f683603af70e3e47fa0aa2";
    date = "2016-05-05";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "02safgb0izv4pnmndg4awkb9avnf88fa9lmag6jv4lbcmq7hazyw";
    goPackageAliases = [ "code.google.com/p/snappy-go/snappy" ];
  };

  sys = buildFromGitHub {
    rev = "b776ec39b3e54652e09028aaaaac9757f4f8211a";
    date = "2016-04-20";
    owner  = "golang";
    repo   = "sys";
    sha256 = "08c5k25h5frld4pdjpg0r224dn25bccnhlbxacj9f867c3vsp35h";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    rev = "bd1c9905f55d983c0cd0b15cf0c3e2fe860c8902";
    date = "2016-04-28";
    owner = "golang";
    repo = "text";
    sha256 = "15p33l1sf4rm40lkz5jsx368xxyqz17r740pvjc68idhn3xgx6h2";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
  };

  tools = buildFromGitHub {
    rev = "0b2f4dcf4db5371000beb66b65cde17aa91a28a2";
    date = "2016-05-01";
    owner = "golang";
    repo = "tools";
    sha256 = "0dqpksaq6rrbf4bm0bd6d0s7rgawr14vc11qb7giqnlb23fmcdih";
    goPackagePath = "golang.org/x/tools";
    goPackageAliases = [ "code.google.com/p/go.tools" ];

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

    buildInputs = [ appengine net ];

    # Do not copy this without a good reason for enabling
    # In this case tools is heavily coupled with go itself and embeds paths.
    allowGoReference = true;

    # Set GOTOOLDIR for derivations adding this to buildInputs
    postInstall = ''
      mkdir -p $bin/nix-support
      echo "export GOTOOLDIR=$bin/bin" >> $bin/nix-support/setup-hook
    '';
  };


  ## THIRD PARTY

  ansicolor = buildFromGitHub {
    date = "2015-11-20";
    rev = "a422bbe96644373c5753384a59d678f7d261ff10";
    owner  = "shiena";
    repo   = "ansicolor";
    sha256 = "1qfq4ax68d7a3ixl60fb8kgyk0qx0mf7rrk562cnkpgzrhkdcm0w";
  };

  asn1-ber = buildFromGitHub {
    rev = "v1.1";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "1mi96bl0jn3nrp4v5aqxgqf5zdndif1qdhdjgjayigjkl67770s3";
    goPackageAliases = [
      "github.com/nmcclain/asn1-ber"
      "github.com/vanackere/asn1-ber"
      "gopkg.in/asn1-ber.v1"
    ];
  };

  assertions = buildGoPackage rec {
    version = "1.5.0";
    name = "assertions-${version}";
    goPackagePath = "github.com/smartystreets/assertions";
    src = fetchurl {
      name = "${name}.tar.gz";
      url = "https://github.com/smartystreets/assertions/archive/${version}.tar.gz";
      sha256 = "1s4b0v49yv7jmy4izn7grfqykjrg7zg79dg5hsqr3x40d5n7mk02";
    };
    buildInputs = [ oglematchers ];
    propagatedBuildInputs = [ goconvey ];
    doCheck = false;
  };

  aws-sdk-go = buildFromGitHub {
    rev = "v1.1.23";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "1p86aavhqsy6lqvz833gkfq02k2c459hqszlxkaqqvcn81ymm9sf";
    buildInputs = [ testify gucumber tools ];
    propagatedBuildInputs = [ ini go-jmespath ];

    preBuild = ''
      pushd go/src/$goPackagePath
      make generate
      popd
    '';
  };

  b = buildFromGitHub {
    date = "2016-02-10";
    rev = "47184dd8c1d2c7e7f87dae8448ee2007cdf0c6c4";
    owner  = "cznic";
    repo   = "b";
    sha256 = "1sw8yyb906v3kv8km8wnyrgkvyjbv74iinrdvjh1qb87p2vr4b17";
  };

  bigfft = buildFromGitHub {
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
  };

  bolt = buildFromGitHub {
    rev = "v1.2.0";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "14w1zf6d9mn6p2m9ypalrf55zfqm81v63r8g8gq3ll8nzc8flw48";
  };

  btree = buildFromGitHub {
    rev = "00edb8c3163323f673bbe3c04afd9429eb12117d";
    owner  = "google";
    repo   = "btree";
    sha256 = "0c54la6hazdymx54x1q93ghi5gwd5iyfxyk6kha9vxzaj7ys3fyr";
    date = "2016-04-18";
  };

  bufs = buildFromGitHub {
    date = "2014-08-18";
    rev = "3dcccbd7064a1689f9c093a988ea11ac00e21f51";
    owner  = "cznic";
    repo   = "bufs";
    sha256 = "0551h2slsb7lg3r6yif65xvf6k8f0izqwyiigpipm3jhlln37c6p";
  };

  candiedyaml = buildFromGitHub {
    date = "2016-04-29";
    rev = "99c3df83b51532e3615f851d8c2dbb638f5313bf";
    owner  = "cloudfoundry-incubator";
    repo   = "candiedyaml";
    sha256 = "104giv2wjiispfsm82q3lk5qjvfjgrqhhnxm2yma9i21klmvir0y";
  };

  cascadia = buildGoPackage rec {
    rev = "0.0.1"; #master
    name = "cascadia-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/andybalholm/cascadia";
    goPackageAliases = [ "code.google.com/p/cascadia" ];
    propagatedBuildInputs = [ net ];
    buildInputs = propagatedBuildInputs;
    doCheck = true;

    src = fetchFromGitHub {
      inherit rev;
      owner = "andybalholm";
      repo = "cascadia";
      sha256 = "1z21w6p5bp7mi2pvicvcqc871k9s8a6262pkwyjm2qfc859c203m";
    };
  };

  check-v1 = buildFromGitHub {
    rev = "4f90aeace3a26ad7021961c297b22c42160c7b25";
    owner = "go-check";
    repo = "check";
    goPackagePath = "gopkg.in/check.v1";
    sha256 = "1vmf8shg0kqakmh60k5m985vxj9h2lb18lw69qx9scl5i66n746h";
    date = "2016-01-05";
  };

  circbuf = buildFromGitHub {
    date = "2015-08-26";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "0wgpmzh0ga2kh51r214jjhaqhpqr9l2k6p0xhy5a006qypk5fh2m";
  };

  mitchellh-cli = buildFromGitHub {
    date = "2016-03-23";
    rev = "168daae10d6ff81b8b1201b0a4c9607d7e9b82e3";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "1ihlx94djy3npy88kv1ahsgk4vh4jchsgmyj2pkrawf8chf1i4v3";
    propagatedBuildInputs = [ crypto go-radix speakeasy go-isatty ];
  };

  codegangsta-cli = buildFromGitHub {
    rev = "v1.16.0";
    owner = "codegangsta";
    repo = "cli";
    sha256 = "1m3m0znsc63cgsxhrq1krbh8f4z06632xyvv5zhq53d7r8wdlk8w";
    buildInputs = [ yaml-v2 ];
  };

  cli-go = buildFromGitHub {
    rev = "v1.16.0";
    owner  = "codegangsta";
    repo   = "cli";
    sha256 = "1m3m0znsc63cgsxhrq1krbh8f4z06632xyvv5zhq53d7r8wdlk8w";
  };

  columnize = buildFromGitHub {
    rev = "v2.1.0";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "0r9r4p4x1vnrq31dj5bvw3phhmqpsb5vwh72cs2wwxmhalzq92hx";
  };

  copystructure = buildFromGitHub {
    date = "2016-01-28";
    rev = "80adcec1955ee4e97af357c30dee61aadcc02c10";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "0ripl8zx55a9phrzw00fnk8ni3jj2bkahn3ffa767a1pz1fysz5j";
    propagatedBuildInputs = [ reflectwalk ];
  };

  consul = buildFromGitHub {
    rev = "v0.6.4";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "61fc1fe5de6afae2b8f4b1d038eac69841bf88d7862330ae30c749a48c2cef94";

    buildInputs = [
      datadog-go circbuf armon_go-metrics go-radix speakeasy bolt
      go-bindata-assetfs go-dockerclient errwrap go-checkpoint go-cleanhttp
      go-immutable-radix go-memdb ugorji_go go-multierror go-reap go-syslog
      golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft raft-boltdb
      scada-client serf yamux muxado dns mitchellh-cli mapstructure columnize
      copystructure hil hashicorp-go-uuid crypto sys
    ];

    # Keep consul.ui for backward compatability
    passthru.ui = pkgs.consul-ui;
  };

  consul-api = buildFromGitHub {
    inherit (consul) rev owner repo sha256;
    buildInputs = [ go-cleanhttp serf ];
    subPackages = [ "api" "tlsutil" ];
  };

  consul-template = buildFromGitHub {
    rev = "v0.14.0";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "021l329gyj0z4pgm25yfl0ff1zgfm27653bxq4mv5cp5chi5amnq";

    buildInputs = [
      consul-api
      go-cleanhttp
      go-multierror
      go-reap
      go-syslog
      logutils
      mapstructure
      serf
      yaml-v2
      vault-api
    ];
  };

  context = buildGoPackage rec {
    rev = "v1.1";
    name = "config-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/gorilla/context";

    src = fetchFromGitHub {
      inherit rev;
      owner = "gorilla";
      repo = "context";
    sha256 = "0fsm31ayvgpcddx3bd8fwwz7npyd7z8d5ja0w38lv02yb634daj6";
    };
  };

  cronexpr = buildFromGitHub {
    rev = "f0984319b44273e83de132089ae42b1810f4933b";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "0d2c67spcyhr4bxzmnqsxnzbn6a8sw893wvc4cx7a3js4ydy7raz";
    date = "2016-03-18";
  };

  datadog-go = buildFromGitHub {
    date = "2016-03-29";
    rev = "cc2f4770f4d61871e19bfee967bc767fe730b0d9";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "10c1jkghl7a7a4z80lsjg11gx3vf6nn7y5x078b98mxisf0x0cdv";
  };

  dbus = buildFromGitHub {
    rev = "v4.0.0";
    owner = "godbus";
    repo = "dbus";
    sha256 = "0q2qabf656sq0pd3candndd8nnkwwp4by4hlkxjn4fs85ld44i8s";
  };

  discosrv = buildFromGitHub {
    rev = "1a2ac62dd59a350a2efd5dd742454a3dcf98dbc7";
    owner = "syncthing";
    repo = "discosrv";
    sha256 = "1b0abfd379010e85cc748e3dea9bd736e3386afbf1cb5c41c27eaeb2cc17fc57";
    buildInputs = [ ql groupcache pq ratelimit syncthing-lib ];
    date = "2016-04-30";
  };

  dns = buildFromGitHub {
    rev = "435593900842b8eff4c624ce6a903f71c9552ae2";
    date = "2016-05-03";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "06a72hqgx40a9nmxj3ynlmw6yyhwyp2x1p2ankqz1i0yix1dlljq";
  };

  weppos-dnsimple-go = buildFromGitHub {
    rev = "65c1ca73cb19baf0f8b2b33219b7f57595a3ccb0";
    date = "2016-02-04";
    owner  = "weppos";
    repo   = "dnsimple-go";
    sha256 = "0v3vnp128ybzmh4fpdwhl6xmvd815f66dgdjzxarjjw8ywzdghk9";
  };

  docker = buildFromGitHub {
    rev = "v1.11.1";
    owner = "docker";
    repo = "docker";
    sha256 = "07dd4f76dc07334ee269406b110c5e274a6f36f032268b9083ae0c7dc8ab0382";
  };

  docker_for_runc = buildFromGitHub {
    inherit (docker) rev owner repo sha256;
    subPackages = [
      "pkg/mount"
      "pkg/symlink"
      "pkg/system"
      "pkg/term"
    ];
    propagatedBuildInputs = [
      go-units
    ];
  };

  docker_for_go-dockerclient = buildFromGitHub {
    inherit (docker) rev owner repo sha256;
    subPackages = [
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/idtools"
      "pkg/ioutils"
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
    ];
    propagatedBuildInputs = [
      go-units
      logrus
      net
      runc
    ];
  };

  docopt-go = buildFromGitHub {
    rev = "0.6.2";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "11cxmpapg7l8f4ar233f3ybvsir3ivmmbg1d4dbnqsr1hzv48xrf";
  };

  duo_api_golang = buildFromGitHub {
    date = "2016-03-22";
    rev = "6f814b626e6aad2bb14b95969b42fdb09c4a0f16";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "01lxky92b71ayzc2fw1y7phdzn9m62sr7p1y1pm6adbzjaqlpg8n";
  };

  envpprof = buildFromGitHub {
    rev = "8fa1da4090ff3fd48ec8b5a34bf2d063dbcd5526";
    owner = "anacrolix";
    repo = "envpprof";
    sha256 = "0r6d13b1nk1pf5h1nk3wp08s0gb9any6syk9h9y19hj0dvhsnah1";
    date = "2016-04-16";
  };

  du = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "du";
    sha256 = "02gri7xy9wp8szxpabcnjr18qic6078k213dr5k5712s1pg87qmj";
  };

  errwrap = buildFromGitHub {
    date = "2014-10-27";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "02hsk2zbwg68w62i6shxc0lhjxz20p3svlmiyi5zjz988qm3s530";
  };

  etcd = buildFromGitHub {
    rev = "v2.3.3";
    owner  = "coreos";
    repo   = "etcd";
    sha256 = "0khnfvwjh7x187c770cig93wyxkb50iarn1hkz23scd0m3vd6fy1";
  };

  etcd-client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256;
    subPackages = [
      "client"
      "pkg/pathutil"
      "pkg/transport"
      "pkg/types"
      "Godeps/_workspace/src/golang.org/x/net"
      "Godeps/_workspace/src/github.com/ugorji/go/codec"
    ];
  };

  exp = buildFromGitHub {
    date = "2015-12-07";
    rev = "c21cce1fce3e6e5bc84854aa3d02a808de44229b";
    owner  = "cznic";
    repo   = "exp";
    sha256 = "00dx5nnjxwpd8dmig210hsgag0brk8391kar97kp3dlikn6dbqb5";
    propagatedBuildInputs = [ bufs fileutil mathutil sortutil zappy ];
  };

  fileutil = buildFromGitHub {
    date = "2015-07-08";
    rev = "1c9c88fbf552b3737c7b97e1f243860359687976";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "0naps0miq8lk4k7k6c0l9583nv6wcdbs9zllvsjjv60h4fsz856a";
    buildInputs = [ mathutil ];
  };

  fs = buildFromGitHub {
    date = "2013-11-07";
    rev = "2788f0dbd16903de03cb8186e5c7d97b69ad387b";
    owner  = "kr";
    repo   = "fs";
    sha256 = "16ygj65wk30cspvmrd38s6m8qjmlsviiq8zsnnvkhfy5l0gk4c86";
  };

  gcloud-golang = buildFromGoogle {
    rev = "200292f09e3aaa34878d801ab71fe823b1f7d36a";
    repo = "cloud";
    sha256 = "ab7b5eec625a74410cd23b3fd1d214b7aaf241a0c33f13113a2dd21283b869db";
    propagatedBuildInputs = [ net oauth2 protobuf google-api-go-client grpc ];
    excludedPackages = "oauth2";
    meta.hydraPlatforms = [ ];
    date = "2016-04-28";
  };

  gcloud-golang-compute-metadata = buildFromGoogle {
    inherit (gcloud-golang) rev repo sha256 date;
    subPackages = [ "compute/metadata" "internal" ];
    buildInputs = [ net ];
  };

  gettext = buildFromGitHub {
    rev = "4a979356fe964fec12e18326a32a89661f93dea7";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "0x9yk379r6wj6z0is78ikrvihxy9blh5k1n5gir2lrdhgmarf0rl";
    date = "2016-02-20";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  ginkgo = buildFromGitHub {
    rev = "2c2e9bb47b4e44067024f29339588cac8b34dd12";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "36f14f864756e7d0af8580a64e73018e688f875fbee009a83405eb5f2316c423";
    date = "2016-04-09";
  };

  ugorji_go = buildFromGitHub {
    date = "2016-03-28";
    rev = "a396ed22fc049df733440d90efe17475e3929ccb";
    owner = "ugorji";
    repo = "go";
    sha256 = "0i6v9ql86j0fgscwkbpfgi9m97y7vxaqyivlckw9ngdqnm4wcgpq";
    goPackageAliases = [ "github.com/hashicorp/go-msgpack" ];
  };

  go4 = buildFromGitHub {
    date = "2016-03-13";
    rev = "03efcb870d84809319ea509714dd6d19a1498483";
    owner = "camlistore";
    repo = "go4";
    sha256 = "4ae6361927b65dcd2747c11d808dbd441b465be50468623db36bc1cb4277264f";
    goPackagePath = "go4.org";
    goPackageAliases = [ "github.com/camlistore/go4" ];
    buildInputs = [ gcloud-golang net ];
    autoUpdatePath = "github.com/camlistore/go4";
  };

  goamz = buildFromGitHub {
    rev = "02d5144a587b982e33b95f484a34164ce6923c99";
    owner  = "goamz";
    repo   = "goamz";
    sha256 = "0nrw83ys5c9aiqxrangig7c0dk9xl41cqs9gskka9sk849fpl9f2";
    date = "2016-04-07";
    goPackageAliases = [
      "github.com/mitchellh/goamz"
    ];
    buildInputs = [
      check-v1
      go-ini
      go-simplejson
      sets
    ];
  };

  goautoneg = buildGoPackage rec {
    name = "goautoneg-2012-07-07";
    goPackagePath = "bitbucket.org/ww/goautoneg";
    rev = "75cd24fc2f2c2a2088577d12123ddee5f54e0675";

    src = fetchFromBitbucket {
      inherit rev;
      owner  = "ww";
      repo   = "goautoneg";
      sha256 = "9acef1c250637060a0b0ac3db033c1f679b894ef82395c15f779ec751ec7700a";
    };

    meta.autoUpdate = false;
  };

  gocapability = buildFromGitHub {
    rev = "2c00daeb6c3b45114c80ac44119e7b8801fdd852";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "0kwcqvj2fq6wl453hcc3q4fmyrv3yk9m3igxwksx9rmpnzaclz8r";
    date = "2015-07-16";
  };

  gocql = buildFromGitHub {
    rev = "2e0390b6fbe023664fcdaa9767f0f83fbe78956d";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "048y18ing8iynn08qqqjz1psljp1ci40prbh447ic6pqm4vhdpvj";
    propagatedBuildInputs = [ inf snappy hailocab_go-hostpool net ];
    date = "2016-05-02";
  };

  goconvey = buildGoPackage rec {
    version = "1.5.0";
    name = "goconvey-${version}";
    goPackagePath = "github.com/smartystreets/goconvey";
    src = fetchurl {
      name = "${name}.tar.gz";
      url = "https://github.com/smartystreets/goconvey/archive/${version}.tar.gz";
      sha256 = "0g3965cb8kg4kf9b0klx4pj9ycd7qwbw1jqjspy6i5d4ccd6mby4";
    };
    buildInputs = [ oglematchers ];
    doCheck = false; # please check again
  };

  gojsonpointer = buildFromGitHub {
    rev = "e0fe6f68307607d540ed8eac07a342c33fa1b54a";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "1gm1m5vf1nkg87qhskpqfyg9r8n0fy74nxvp6ajcqb04v3k8sd7v";
    date = "2015-10-27";
  };

  gojsonreference = buildFromGitHub {
    rev = "e02fc20de94c78484cd5ffb007f8af96be030a45";
    owner  = "xeipuuv";
    repo   = "gojsonreference";
    sha256 = "1c2yhjjxjvwcniqag9i5p159xsw4452vmnc2nqxnfsh1whd8wpi5";
    date = "2015-08-08";
    propagatedBuildInputs = [ gojsonpointer ];
  };

  gojsonschema = buildFromGitHub {
    rev = "d3178baac32433047aa76f07317f84fbe2be6cda";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "0iacjvsfizg2islh6dlhxdd1d2y3ppffgb7avvy3wd6dpaccfpv2";
    date = "2016-05-01";
    propagatedBuildInputs = [ gojsonreference ];
  };

  govers = buildFromGitHub {
    rev = "3b5f175f65d601d06f48d78fcbdb0add633565b9";
    date = "2015-01-09";
    owner = "rogpeppe";
    repo = "govers";
    sha256 = "1ir47942q9z6h5cajn84hvibhxicq93yrrgd36bagkibi4b2s5qf";
    dontRenameImports = true;
  };

  golang-lru = buildFromGitHub {
    date = "2016-02-07";
    rev = "a0d98a5f288019575c6d1f4bb1573fef2d1fcdc4";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "1q4cvlrk1pzki8lkf8b5mc3ciini8b6dlljrijycdh7izfc17vsz";
  };

  golang-petname = buildFromGitHub {
    rev = "2182cecef7f257230fc998bc351a08a5505f5e6c";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "0404sq4sn06f44nkw5g31qz8rywcdlhsbah3jgx64qby5826y1i5";
    date = "2016-02-01";
  };

  golang_protobuf_extensions = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "0r1sv4jw60rsxy5wlnr524daixzmj4n1m1nysv4vxmwiw9mbr6fm";
    buildInputs = [ protobuf ];
  };

  goleveldb = buildFromGitHub {
    rev = "cfa635847112c5dc4782e128fa7e0d05fdbfb394";
    date = "2016-04-25";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "1g3z08af36r0vw79784r3a07psgl12qsa4vpl4ljcf7nsnxkb7ry";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    rev = "7ce781ea776b2fd506491011353bded2e40c8467";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "00728gg7inc980xvxdy158s2xklrgfldgzkl960jjsv1w10l2vbn";
    buildInputs = [ protobuf ];
    date = "2016-03-05";
  };

  google-api-go-client = buildFromGitHub {
    rev = "f9a4669e07732c84854dce1f5c451c22427228fb";
    date = "2016-05-03";
    owner = "google";
    repo = "google-api-go-client";
    sha256 = "1ajj4fdmwbv2s507ydffhmssj3kgkzh81n8bf8spgw2qm6ii095b";
    goPackagePath = "google.golang.org/api";
    goPackageAliases = [ "github.com/google/google-api-client" ];
    buildInputs = [ net ];
  };

  gopass = buildFromGitHub {
    date = "2016-03-03";
    rev = "66487b23f2880ba32e185121d2cd51a338ea069a";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0r4kx80hq48fkipz4x7hkiqb74hygpja1h5xbzydaw4cdgc5vwjs";
    propagatedBuildInputs = [ crypto ];
  };

  gopsutil = buildFromGitHub {
    rev = "v2.0.0";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "05ww47x7847hzna1zpxzx290imj393vn3jqyl4s63bmw77zw6q8r";
  };

  goskiplist = buildFromGitHub {
    rev = "2dfbae5fcf46374f166f8969cb07e167f1be6273";
    owner  = "ryszard";
    repo   = "goskiplist";
    sha256 = "1dr6n2w5ikdddq9c1fwqnc0m383p73h2hd04302cfgxqbnymabzq";
    date = "2015-03-12";
  };

  govalidator = buildFromGitHub {
    rev = "5b6e9375cbf581a9008064f7216e816b568d6daa";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "13h4ln4ziwaf3056mxblr8d7bxn7dypn6yfgqz5m615ibj5xqlax";
    date = "2016-04-23";
  };

  go-base58 = buildFromGitHub {
    rev = "6237cf65f3a6f7111cd8a42be3590df99a66bc7d";
    owner  = "jbenet";
    repo   = "go-base58";
    sha256 = "1d6zrd3f59sa5lvaprlf6pf07p9inm0kv1a1xzqwx4w0400sv6wm";
    date = "2015-03-17";
  };

  go-bencode = buildGoPackage rec {
    version = "1.1.1";
    name = "go-bencode-${version}";
    goPackagePath = "github.com/ehmry/go-bencode";

    src = fetchurl {
      url = "https://${goPackagePath}/archive/v${version}.tar.gz";
      sha256 = "0y2kz2sg1f7mh6vn70kga5d0qhp04n01pf1w7k6s8j2nm62h24j6";
    };
  };

  go-bindata-assetfs = buildFromGitHub {
    rev = "57eb5e1fc594ad4b0b1dbea7b286d299e0cb43c2";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "0kr3jz9lfivm0q9lsl6zpa4i02qa79304kn059skr0dnsnizj2q7";
    date = "2015-12-24";
  };

  go-checkpoint = buildFromGitHub {
    date = "2015-10-22";
    rev = "e4b2dc34c0f698ee04750bf2035d8b9384233e1b";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "1lnwx8c6ny3d2smj6ap4ar0d3i7fzjbi0mhmrnpmyln0anrp4yd4";
    buildInputs = [ go-cleanhttp ];
  };

  go-cleanhttp = buildFromGitHub {
    date = "2016-04-07";
    rev = "ad28ea4487f05916463e2423a55166280e8254b5";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "1knpnv6wg2fnnsk2h2bj4m003f7xsvwm58vnn9gc753mbr78vx00";
  };

  go-colorable = buildFromGitHub {
    rev = "v0.0.4";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "1dlrjfky9kd9v7kgabdgqya6zhq9ny7rj6z7giayywm1zw1l9kii";
  };

  go-difflib = buildFromGitHub {
    date = "2016-01-10";
    rev = "792786c7400a136282c1664665ae0a8db921c6c2";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0xhjjfvx97zkms5004v1k3prc5g1kljiayhf05v0n0yf89s5r28r";
  };

  go-dockerclient = buildFromGitHub {
    date = "2016-05-03";
    rev = "7cbfc4525fb2aeeeff56dc5c6fe18a5536a51f6b";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "0p03ycfbrmz2ghjc2vpr0mjngrsgm7a55xnm1jpv6cpjyyw1q097";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      mux
    ];
  };

  go-flags = buildFromGitHub {
    date = "2016-02-27";
    rev = "6b9493b3cb60367edd942144879646604089e3f7";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0h73kgavvxlv3lfp2fxq51blsk8bwafchazsan88xdz7jl17cpfj";
  };

  go-getter = buildFromGitHub {
    rev = "3142ddc1d627a166970ddd301bc09cb510c74edc";
    date = "2016-04-21";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "0ml435wwvd49bw0mzy5qgkmsv8yvx9ic5hdgcprp7r5ya8r3wx86";
    buildInputs = [ aws-sdk-go ];
  };

  go-git-ignore = buildFromGitHub {
    rev = "228fcfa2a06e870a3ef238d54c45ea847f492a37";
    date = "2016-01-15";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "1a78b1as3xd2v3lawrb0y43bm3rmb452mysvzqk1309gw51lk4gx";
  };

  go-github = buildFromGitHub {
    date = "2016-04-25";
    rev = "842c551fdeae14c97c04ef490f601ae4d849a00c";
    owner = "google";
    repo = "go-github";
    sha256 = "1rgdxvidh15jjz1pikva0vdzkrcc7yl4ln2ba0b7llr60fl7yvi5";
    buildInputs = [ oauth2 ];
    propagatedBuildInputs = [ go-querystring ];
  };

  go-homedir = buildFromGitHub {
    date = "2016-03-01";
    rev = "981ab348d865cf048eb7d17e78ac7192632d8415";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "0qi72bsvgcspf5f4qjjirxj53lwygs08v2brglwg0i65wgxyk5rs";
  };

  hailocab_go-hostpool = buildFromGitHub {
    rev = "e80d13ce29ede4452c43dea11e79b9bc8a15b478";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "06ic8irabl0iwhmkyqq4wzq1d4pgp9vk1kmflgv1wd5d9q8qmkgf";
  };

  go-humanize = buildFromGitHub {
    rev = "8929fe90cee4b2cb9deb468b51fb34eba64d1bf0";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "1876x9742jh3ri3d23abdnpz5c7ww0cs118fii19c33q34w1gsc6";
    date = "2015-11-25";
  };

  go-immutable-radix = buildFromGitHub {
    date = "2016-02-21";
    rev = "8e8ed81f8f0bf1bdd829593fdd5c29922c1ea990";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "0zpzf4sz5y99ff8d8d4hga0860af5chhbncvhs80k66rrr6hin6h";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ini = buildFromGitHub {
    rev = "a98ad7ee00ec53921f08832bc06ecf7fd600e6a1";
    owner = "vaughan0";
    repo = "go-ini";
    sha256 = "07i40hj47z5m6wa5bzy7sc2na3hbwh84ridl40yfybgdlyrzdkf4";
    date = "2013-09-23";
  };

  go-ipfs-api = buildFromGitHub {
    date = "2016-04-27";
    rev = "60ded1996d84cc0c5607e7e32b8138cc91cb4b18";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "0nhjwf56vsdxay4bjv4f09k9k847i9gbm1bxklr37hf5srpmqbgr";
    excludedPackages = "tests";
    propagatedBuildInputs = [ go-multiaddr-net go-multipart-files tar-utils ];
  };

  go-isatty = buildFromGitHub {
    rev = "v0.0.1";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "0ynlb7bh0c6jfcx1d5hsv3zga56x049akdv8cf7hpfsrzkzcqwx8";
  };

  go-jmespath = buildFromGitHub {
    rev = "0.2.2";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "141a1i19fbmcf8qsz88kfb34vvmqpz5ya6hqz9r4v92by840xczi";
  };

  go-jose = buildFromGitHub {
    rev = "v1.0.2";
    owner = "square";
    repo = "go-jose";
    sha256 = "0pp117a464kj8br9pqk9xha87plndfg8mhfc9k1bq0v4qs7awyiq";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    goPackageAliases = [
      "github.com/square/go-jose"
    ];
    buildInputs = [
      codegangsta-cli
      kingpin-v2
    ];
  };

  go-lxc-v2 = buildFromGitHub {
    rev = "5e8be8b35eee531ff7772b0fc3114e7c452b49e4";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "0k54y42i0yipl5kr6sx6a0s7fqagp55d0w8w2cbk362zbbw9vdk5";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [ pkgs.lxc ];
    date = "2016-04-19";
  };

  go-lz4 = buildFromGitHub {
    date = "2015-08-21";
    rev = "74ddf82598bc4745b965729e9c6a463bedd33049";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1f96sh6f8mr7vdwnflaca2ldah1d4j79j9p3crqgp468an9jdi3k";
  };

  go-memdb = buildFromGitHub {
    date = "2016-03-01";
    rev = "98f52f52d7a476958fa9da671354d270c50661a7";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "07938b1ln4x7caflhgsvaw8kikh5xcddwrc6zj0hcmzmbpfpyxai";
    buildInputs = [ go-immutable-radix ];
  };

  rcrowley_go-metrics = buildFromGitHub {
    rev = "eeba7bd0dd01ace6e690fa833b3f22aaec29af43";
    date = "2016-02-25";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "0xph1i8ml681xnh9qy3prvbrgzwb0sssaxlqz2yk1p6fczvq9210";
    propagatedBuildInputs = [ stathat ];
  };

  armon_go-metrics = buildFromGitHub {
    date = "2016-03-06";
    rev = "f303b03b91d770a11a39677f1d3b55da4002bbcb";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0xvqidv4xwl7hs0cvwzshmw4w1dsydrgmfbbdwr6njgx321ry2fg";
    propagatedBuildInputs = [ prometheus_client_golang datadog-go ];
  };

  go-mssqldb = buildFromGitHub {
    rev = "8d4984e8baccbf5bfadd7f7e366fd61b7ccac38b";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "0is28sa9mf6r3d831qpg6997xs00h21li61vsll2d9af5fydvm6m";
    date = "2015-03-11";
    buildInputs = [ crypto ];
  };

  go-multiaddr = buildFromGitHub {
    rev = "41d11170520e5b0ea0af2489d7ac5fbdd452e603";
    date = "2016-01-19";
    owner  = "jbenet";
    repo   = "go-multiaddr";
    sha256 = "07409gd1aw3i0lzmhh07yzgw791hmgrl6cg1ch642j0a46jff7zw";
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    rev = "f1f304d1e018c4935b44aff20587579a94168954";
    owner  = "jbenet";
    repo   = "go-multiaddr-net";
    sha256 = "1wsxvqkpm6ycc5r7av4vqr7mvih3si3fryyaa3l9zd0dmzz0jfg4";
    date = "2016-04-26";
    propagatedBuildInputs = [
      go-multiaddr
      utp
    ];
  };

  go-multierror = buildFromGitHub {
    date = "2015-09-16";
    rev = "d30f09973e19c1dfcd120b2d9c4f168e68d6b5d5";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "0l1410m98pklnqkr6fqi2bpcqfag5z1l3snykn46ps38lb1sc3f3";
    propagatedBuildInputs = [ errwrap ];
  };

  go-multihash = buildFromGitHub {
    rev = "e8d2374934f16a971d1e94a864514a21ac74bf7f";
    owner  = "jbenet";
    repo   = "go-multihash";
    sha256 = "0ks70g7fg8vr17wmgcivp3x307yyr646s00iwl2p625ardcfh3wv";
    propagatedBuildInputs = [ go-base58 crypto ];
    date = "2015-04-12";
  };

  go-multipart-files = buildFromGitHub {
    rev = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "0fdzi6v6rshh172hzxf8v9qq3d36nw3gc7g7d79wj88pinnqf5by";
    date = "2015-09-03";
  };

  go-ole = buildFromGitHub {
    rev = "v1.2.0";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "1bkvi5l2sshjrg1g9x1a4i337adrv1vhk8p1xrkx5z05nfwazvx0";
  };

  go-plugin = buildFromGitHub {
    rev = "cccb4a1328abbb89898f3ecf4311a05bddc4de6d";
    date = "2016-02-11";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "00ry0hchkaf4yc9csvzh875kl5ym7ax2y59xzaw50626xvzl305k";
    buildInputs = [ yamux ];
  };

  go-querystring = buildFromGitHub {
    date = "2016-03-10";
    rev = "9235644dd9e52eeae6fa48efd539fdc351a0af53";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "0c0rmm98vz7sk7z6a1r07dp6jyb513cyr2y753sjpnyrc28xhdwg";
  };

  go-radix = buildFromGitHub {
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  go-reap = buildFromGitHub {
    rev = "2d85522212dcf5a84c6b357094f5c44710441912";
    owner  = "hashicorp";
    repo   = "go-reap";
    sha256 = "0q90nf4mgvxb26vd7avs1mw1m9cb6x9mx6jnz4xsia71ghi3lj50";
    date = "2016-01-13";
    propagatedBuildInputs = [ sys ];
  };

  go-runewidth = buildFromGitHub {
    rev = "v0.0.1";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "1sf0a2fbp2fp0lgizh2bjd3cgni35czvshx5clb2m6b604k7by9a";
  };

  go-simplejson = buildFromGitHub {
    rev = "v0.5.0";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "09svnkziaffkbax5jjnjfd0qqk9cpai2gphx4ja78vhxdn4jpiw0";
  };

  go-spew = buildFromGitHub {
    rev = "5215b55f46b2b919f50a1df0eaa5886afe4e3b3d";
    date = "2015-11-05";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1l4dg2xs0vj49gk0f5d4ij3hrwi72ay4w9a7xjkz1syg4qi9jy40";
  };

  go-sqlite3 = buildFromGitHub {
    rev = "7204887cf3a42df1cfaa5505dc3a3427f6dded8b";
    date = "2016-05-03";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "02giz6yarf12zv5viz69bxmbqzm6rfmkyniy88jxa6vzizpakvpg";
  };

  go-syslog = buildFromGitHub {
    date = "2015-02-18";
    rev = "42a2b573b664dbf281bd48c3cc12c086b17a39ba";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "0zbnlz1l1f50k8wjn8pgrkzdhr6hq4rcbap0asynvzw89crh7h4g";
  };

  go-systemd = buildFromGitHub {
    rev = "7b2428fec40033549c68f54e26e89e7ca9a9ce31";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "0z8i7a6a68dkcgmvdxkdxk6qgn56zdizjvkfg0hin2yn4xnm9wgd";
    propagatedBuildInputs = [ pkgs.systemd_lib dbus ];
    date = "2016-02-02";
  };

  go-units = buildFromGitHub {
    rev = "v0.3.0";
    owner = "docker";
    repo = "go-units";
    sha256 = "15gnwpncr6ibxrvnj76r6j4fyskdixhjf6nc8vaib8lhx360avqc";
  };

  hashicorp-go-uuid = buildFromGitHub {
    rev = "73d19cdc2bf00788cc25f7d5fd74347d48ada9ac";
    date = "2016-03-29";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "1c8z6g9fyhbn35ps6agyf25mhqpsdpgr6kp3rq4kw2rsal6n8lqa";
  };

  go-version = buildFromGitHub {
    rev = "2e7f5ea8e27bb3fdf9baa0881d16757ac4637332";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "1pdfp2vgmrrgcs3yc07jn7fd32f88pahjy8hysxmnghywvw1a7p1";
    date = "2016-02-13";
  };

  go-zookeeper = buildFromGitHub {
    rev = "5250732bd2ed71d1e374212ebfc32760eca10c0a";
    date = "2016-04-19";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "0vakzxf2la8fjkqsrpjlicxz98yiw56ap4gbscai57izajbiasy3";
  };

  goquery = buildGoPackage rec {
    rev = "0.0.1"; #tag v.0.3.2
    name = "goquery-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/PuerkitoBio/goquery";
    propagatedBuildInputs = [ cascadia net ];
    buildInputs = [ cascadia net ];
    doCheck = true;
    src = fetchFromGitHub {
      inherit rev;
      owner = "PuerkitoBio";
      repo = "goquery";
      sha256 = "0bskm3nja1v3pmg7g8nqjkmpwz5p72h1h81y076x1z17zrjaw585";
    };
  };

  groupcache = buildFromGitHub {
    date = "2016-02-11";
    rev = "4eab30f13db9d8b25c752e99d1583628ac2fa422";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "0i72yji981w22sk62hxd228rs13ym3zziqm3bq89xw21mdda5gj2";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    rev = "b062a3c003c22bfef58fa99d689e6a892b408f9d";
    date = "2016-04-25";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "0ksc8rrzss5q5lk4a778i824l530d4pj1l8jwb74x4pwcisng4y4";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [ "github.com/grpc/grpc-go" ];
    propagatedBuildInputs = [ http2 net protobuf oauth2 glog ];
    excludedPackages = "\\(test\\|benchmark\\)";
  };

  gucumber = buildFromGitHub {
    date = "2016-01-10";
    rev = "44a4d7eb3b14a88cf82b073dfb7e06277afdc549";
    owner = "lsegal";
    repo = "gucumber";
    sha256 = "1lbck0hc7hdy720w4ilnyak0qk145l9g9xjl5gb2z5y7ngclrk23";
    buildInputs = [ testify ];
    propagatedBuildInputs = [ ansicolor ];
  };

  gx = buildFromGitHub {
    rev = "v0.7.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "0c5nwmza4c07rh3j02bxgy7cqa8hc3gr5a1zhn150v15fix75l9l";
    propagatedBuildInputs = [
      go-homedir
      go-multiaddr
      go-multihash
      go-multiaddr-net
      semver
      go-git-ignore
      stump
      codegangsta-cli
      go-ipfs-api
    ];
    excludedPackages = [
      "tests"
    ];
  };

  gx-go = buildFromGitHub {
    rev = "v1.2.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "008yfrax1kd9r63rqdi9fcqhy721bjq63d4ypm5d4nn0fbychg4s";
    buildInputs = [
      codegangsta-cli
      fs
      gx
      stump
    ];
  };

  hashstructure = buildFromGitHub {
    date = "2016-03-30";
    rev = "95415bb46460fb895bab077547e323b42b0df8da";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "0ssrwgfjd84pixgbldj0vkwhc9n6yzfqvmqmb1qdawl3m562w5gf";
  };

  hcl = buildFromGitHub {
    date = "2016-04-26";
    rev = "9a905a34e6280ce905da1a32344b25e81011197a";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "0pjyhr68pisdw6ziglskz26ql0r3ixmlsnv296bvxzfh6a46v80c";
  };

  hil = buildFromGitHub {
    date = "2016-04-18";
    rev = "01dc167cd239b7ccab78a683b866536cd5904719";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "1zbs2yv0fx18k3qmk3262mj68xaz3hz7g24vw16iygdnfz02r5y8";
    propagatedBuildInputs = [
      mapstructure
      reflectwalk
    ];
  };

  http2 = buildFromGitHub rec {
    rev = "aa7658c0e9902e929a9ed0996ef949e59fc0f3ab";
    owner = "bradfitz";
    repo = "http2";
    sha256 = "0hzmrc9vfh83s57cvfhi26zgvwmr38yg2xxw1yhygfxn3x8ri05c";
    buildInputs = [ crypto ];
    date = "2016-01-16";
  };

  httprouter = buildFromGitHub {
    rev = "77366a47451a56bb3ba682481eed85b64fea14e8";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "12hj2pc07nzha56rcpq6js0j7gs207blasxrixbwcwcgy9pamc80";
    date = "2016-02-19";
  };

  inf = buildFromGitHub {
    date = "2015-09-11";
    rev = "3887ee99ecf07df5b447e9b00d9c0b2adaa9f3e4";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "04645xzvz6ir52hc25r6sbaaq5j9i8ch6p9fv3hwpmkfgq2xq46q";
    goPackagePath = "gopkg.in/inf.v0";
    goPackageAliases = [ "github.com/go-inf/inf" ];
  };

  ini = buildFromGitHub {
    rev = "v1.11.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "10q0nksm4z91vyzhawdrmvabr847h15zl9jwh7p6kp2cb728hmbq";
  };

  iter = buildFromGitHub {
    rev = "454541ec3da2a73fc34fd049b19ee5777bf19345";
    owner  = "bradfitz";
    repo   = "iter";
    sha256 = "0sv6rwr05v219j5vbwamfvpp1dcavci0nwr3a2fgxx98pjw7hgry";
    date = "2014-01-23";
  };

  flagfile = buildFromGitHub {
    date = "2015-02-13";
    rev = "871ce569c29360f95d7596f90aa54d5ecef75738";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "0s7g6xsv5y75gzky43065r7mfvdbgmmr6jv0w2b3nyir3z00frxn";
  };

  ipfs = buildFromGitHub {
    rev = "v0.4.1";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "02zqb0mlb87qb7gcl18xkichi8zwsjfbr8dzakz52qkam97s4dbs";
    gxSha256 = "1mc21qzxxgqnsig1cwhvaay9ncingz5rl3fdc4yfkp805wsfl5sr";

    subPackages = [
      "cmd/ipfs"
    ];
  };

  kingpin-v2 = buildFromGitHub {
    rev = "v2.1.11";
    owner = "alecthomas";
    repo = "kingpin";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    sha256 = "0s3xz1pwqdfk466nk2qj1r5p1n9qh6y7ndik44yq56i5k3lxb9qg";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  ldap = buildFromGitHub {
    rev = "v2.3.0";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "1iwapk3z1cz6q1a4hfyp857ny2skdjjx7hjhbcn6q5fd64ldpv8y";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [ asn1-ber ];
  };

  lego = buildFromGitHub {
    rev = "v0.3.1";
    owner = "xenolf";
    repo = "lego";
    sha256 = "12bry70rgdi0i9dybhaq1vfa83ac5cdka86652xry1j7a8gq0z76";

    buildInputs = [
      aws-sdk-go
      codegangsta-cli
      crypto
      dns
      weppos-dnsimple-go
      go-ini
      go-jose
      goamz
      google-api-go-client
      oauth2
      net
      vultr
    ];

    subPackages = [
      "."
    ];
  };

  log15-v2 = buildFromGitHub {
    rev = "v2.11";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "1krlgq3m0q40y8bgaf9rk7zv0xxx5z92rq8babz1f3apbdrn00nq";
    goPackagePath = "gopkg.in/inconshreveable/log15.v2";
    propagatedBuildInputs = [
      go-colorable
    ];
  };

  logrus = buildFromGitHub rec {
    rev = "v0.10.0";
    owner = "Sirupsen";
    repo = "logrus";
    sha256 = "1rf70m0r0x3rws8334rmhj8wik05qzxqch97c31qpfgcl96ibnfb";
  };

  logutils = buildFromGitHub {
    date = "2015-06-09";
    rev = "0dc08b1671f34c4250ce212759ebd880f743d883";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "11p4p01x37xcqzfncd0w151nb5izmf3sy77vdwy0dpwa9j8ccgmw";
  };

  luhn = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "luhn";
    sha256 = "13brkbbmj9bh0b9j3avcyrj542d78l9hg3bxj7jjvkp5n5cxwp41";
  };

  lxd = buildFromGitHub {
    rev = "lxd-2.0.0";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "0z1q1srmgjbhfyvqx84f661rhq7n2ni54v0x40yhwnzh0c14m3bf";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-lxc-v2
      go-sqlite3
      go-systemd
      log15-v2
      pkgs.lxc
      mux
      pborman_uuid
      pongo2-v3
      protobuf
      tablewriter
      tomb-v2
      yaml-v2
      websocket
    ];
  };

  mathutil = buildFromGitHub {
    date = "2016-01-19";
    rev = "38a5fe05cd94d69433fd1c928417834c604f281d";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "08z3ss9lw9r9mczba2dki1q0sa24gvvwg9ky9akgk045zpsx650b";
    buildInputs = [ bigfft ];
  };

  mapstructure = buildFromGitHub {
    date = "2016-02-11";
    rev = "d2dd0262208475919e1a362f675cfc0e7c10e905";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "1pmjkrlz0mvs90ysag12pp4sldhfm1m91472w50wjaqhda028ijh";
  };

  mdns = buildFromGitHub {
    date = "2015-12-05";
    rev = "9d85cf22f9f8d53cb5c81c1b2749f438b2ee333f";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "0hsbhh0v0jpm4cg3hg2ffi2phis4vq95vyja81rk7kzvml17pvag";
    propagatedBuildInputs = [ net dns ];
  };

  memberlist = buildFromGitHub {
    date = "2016-03-28";
    rev = "88ac4de0d1a0ca6def284b571342db3b777a4c37";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "0pwd52ypmq8fp7qbafsc4ll0008wwwx62xx086fzs6dirq3vchhq";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
    ];
  };

  mgo = buildFromGitHub {
    rev = "r2016.02.04";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "0q968aml9p5x49x70ay7myfg6ibggckir3gam5n6qydj6rviqpy7";
    goPackagePath = "gopkg.in/mgo.v2";
    goPackageAliases = [ "github.com/go-mgo/mgo" ];
    buildInputs = [ pkgs.cyrus-sasl tomb-v2 ];
  };

  missinggo = buildFromGitHub {
    rev = "c49275eaef9c8b81592331bbd4c32ad6329e701c";
    owner  = "anacrolix";
    repo   = "missinggo";
    sha256 = "0vc1xcgvbwfnwplp36qfa099c0bcpi5d441q28xiy8d5ig1sdpdq";
    date = "2016-04-30";
    propagatedBuildInputs = [
      b
      btree
      docopt-go
      goskiplist
      iter
      roaring
    ];
  };

  mongo-tools = buildFromGitHub {
    rev = "r3.3.4";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "88a5ab20f2af8abcf80fdf726abcb775fd0d365b74fe4c8b96801639c093a1e0";
    buildInputs = [ crypto mgo go-flags gopass openssl tomb-v2 ];

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

  mow-cli = buildFromGitHub {
    rev = "772320464101e904cd51198160eb4d489be9cc49";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "1dwy7pwh3mig3xj1x8bcd8cm6ilv2581vah9rwi992agx3b8318s";
    date = "2016-02-21";
  };

  mux = buildFromGitHub {
    rev = "v1.1";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1iicj9v3ippji2i1jf2g0jmrvql1k2yydybim3hsb0jashnq7794";
    propagatedBuildInputs = [ context ];
  };

  muxado = buildFromGitHub {
    date = "2016-04-12";
    rev = "abadcf80c5cad697d16042f459ec1dca9acef317";
    owner  = "inconshreveable";
    repo   = "muxado";
    sha256 = "1ziszvgs3b6kzpbf1wkbnr16skfldrs6m5kpfcfx85hdhsdi3dbs";
  };

  mysql = buildFromGitHub {
    rev = "7ebe0a500653eeb1859664bed5e48dec1e164e73";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "072al51lhz9rkmd3wdzix3i2bvpzff3l79pc96g7cazi2xr6fbcp";
    date = "2016-04-11";
  };

  net-rpc-msgpackrpc = buildFromGitHub {
    date = "2015-11-15";
    rev = "a14192a58a694c123d8fe5481d4a4727d6ae82f3";
    owner = "hashicorp";
    repo = "net-rpc-msgpackrpc";
    sha256 = "007pwdpap465b32cx1i2hmf2q67vik3wk04xisq2pxvqvx81irks";
    propagatedBuildInputs = [ ugorji_go go-multierror ];
  };

  netlink = buildFromGitHub {
    rev = "7ec36826870685e65907935a6a8848f10a30eeaf";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "01n9vhn9dzhal2i3r47giq5hwfzznv611xk3ssavgapg9l5y2llq";
    date = "2016-05-03";
  };

  nomad = buildFromGitHub {
    rev = "v0.3.2";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "11n87z4f2y3s3fkf6xp41671m39fmn4b6lry4am9cqf0g2im46rh";

    buildInputs = [
      datadog-go wmi armon_go-metrics go-radix aws-sdk-go perks speakeasy
      bolt go-systemd docker go-units go-humanize go-dockerclient ini go-ole
      dbus protobuf cronexpr consul-api errwrap go-checkpoint go-cleanhttp
      go-getter go-immutable-radix go-memdb go-multierror go-syslog
      go-version golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft
      raft-boltdb scada-client serf yamux syslogparser go-jmespath osext
      go-isatty golang_protobuf_extensions mitchellh-cli copystructure
      hashstructure mapstructure reflectwalk runc prometheus_client_golang
      prometheus_common prometheus_procfs columnize gopsutil ugorji_go sys
      go-plugin circbuf go-spew
    ];

    subPackages = [
      "."
    ];
  };

  objx = buildFromGitHub {
    date = "2015-09-28";
    rev = "1a9d0bb9f541897e62256577b352fdbc1fb4fd94";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "0ycjvfbvsq6pmlbq2v7670w1k25nydnz4scx0qgiv0f4llxnr0y9";
  };

  openssl = buildFromGitHub {
    date = "2015-03-30";
    rev = "4c6dbafa5ec35b3ffc6a1b1e1fe29c3eba2053ec";
    owner = "10gen";
    repo = "openssl";
    sha256 = "1yyq8acz9pb19mnr9j5hd0axpw6xlm8fbqnkp4m16mmfjd6l5kii";
    goPackageAliases = [ "github.com/spacemonkeygo/openssl" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.openssl ];
    propagatedBuildInputs = [ spacelog ];

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,spacemonkeygo/openssl,10gen/openssl,g'
    '';
  };

  osext = buildFromGitHub {
    date = "2015-12-22";
    rev = "29ae4ffbc9a6fe9fb2bc5029050ce6996ea1d3bc";
    owner = "kardianos";
    repo = "osext";
    sha256 = "05803q7snh1pcwjs5f8g35wfhv21j0mp6yk9agmcx50rjcn3x6qr";
    goPackageAliases = [
      "github.com/bugsnag/osext"
      "bitbucket.org/kardianos/osext"
    ];
  };

  perks = buildFromGitHub rec {
    date = "2014-07-16";
    owner  = "bmizerany";
    repo   = "perks";
    rev = "d9a9656a3a4b1c2864fdb44db2ef8619772d92aa";
    sha256 = "1p5aay4x3q255vrdqv2jcl45acg61j3bz6xgljvqdhw798cyf6a3";
  };

  beorn7_perks = buildFromGitHub rec {
    date = "2016-02-29";
    owner  = "beorn7";
    repo   = "perks";
    rev = "3ac7bf7a47d159a033b107610db8a1b6575507a4";
    sha256 = "1swhv3v8vxgigldpgzzbqxmzdwpvjdii11a3xql677mfbvgv7mpq";
  };

  pongo2-v3 = buildFromGitHub {
    rev = "v3.0";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "1qjcj7hcjskjqp03fw4lvn1cwy78dck4jcd0rcrgdchis1b84isk";
    goPackagePath = "gopkg.in/flosch/pongo2.v3";
  };

  pq = buildFromGitHub {
    rev = "dd3290b2f71a8b30bee8e4e75a337a825263d26f";
    owner  = "lib";
    repo   = "pq";
    sha256 = "1v19lr4l9qzdx0m18kdvczpqcimair1lh68k0s010vc752b0arvm";
    date = "2016-04-26";
  };

  prometheus_client_golang = buildFromGitHub {
    rev = "90c15b5efa0dc32a7d259234e02ac9a99e6d3b82";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "03n3pp6kmbjh8dfskibkj4gd2mwg38nqsgg81661myjncff07x18";
    propagatedBuildInputs = [
      goautoneg
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      prometheus_procfs
      beorn7_perks
    ];
    date = "2016-03-17";
  };

  prometheus_client_model = buildFromGitHub {
    rev = "fa8ad6fec33561be4280a8f0514318c79d7f6cb6";
    date = "2015-02-12";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "150fqwv7lnnx2wr8v9zmgaf4hyx1lzd4i1677ypf6x5g2fy5hh6r";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    date = "2016-05-04";
    rev = "dd586c1c5abb0be59e60f942c22af711a2008cb4";
    owner = "prometheus";
    repo = "common";
    sha256 = "0qsrsx5gcwynylaqjccq721v185vr8s1glg0df35aiyjnprk8j9r";
    buildInputs = [ net prometheus_client_model httprouter logrus protobuf ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      prometheus_client_golang
    ];
  };

  prometheus_common_for_client = buildFromGitHub {
    inherit (prometheus_common) date rev owner repo sha256;
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

  prometheus_procfs = buildFromGitHub {
    rev = "abf152e5f3e97f2fafac028d2cc06c1feb87ffa5";
    date = "2016-04-11";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "08536i8yaip8lv4zas4xa59igs4ybvnb2wrmil8rzk3a2hl9zck8";
  };

  qart = buildFromGitHub {
    date = "2014-04-20";
    rev = "ccb109cf25f0cd24474da73b9fee4e7a3e8a8ce0";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "0i0dw748avvskwdx7bq9yfxc44nr7v3gkn21qclzcq2rr3gz11x0";
  };

  ql = buildFromGitHub {
    rev = "v1.0.3";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1r1370h0zpkhi9fs57vx621vsj8g9j0ijki0y4mpw18nz2mq620n";
    propagatedBuildInputs = [ go4 b exp strutil ];
  };

  raft = buildFromGitHub {
    date = "2016-04-09";
    rev = "1c84b7ca86424d341b95457cf6da85fdb367c4f0";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "0iv0kc4f1z4zrxymdranb5zic1b30cyy5b36nwjcf27kvk91zddy";
    propagatedBuildInputs = [ armon_go-metrics ugorji_go ];
  };

  raft-boltdb = buildFromGitHub {
    date = "2015-02-01";
    rev = "d1e82c1ec3f15ee991f7cc7ffd5b67ff6f5bbaee";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "07g818sprpnl0z15wl16wj9dvyl9igqaqa0w4y7mbfblnpydvgis";
    propagatedBuildInputs = [ bolt ugorji_go raft ];
  };

  ratelimit = buildFromGitHub {
    rev = "77ed1c8a01217656d2080ad51981f6e99adaa177";
    date = "2015-11-25";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0m7bvg8kg9ffl624lbcq47207n6r54z9by1wy0axslishgp1lh98";
  };

  raw = buildFromGitHub {
    rev = "724aedf6e1a5d8971aafec384b6bde3d5608fba4";
    owner  = "feyeleanor";
    repo   = "raw";
    sha256 = "0pkvvvln5cyyy0y2i82jv39gjnfgzpb5ih94iav404lfsachh8m1";
    date = "2013-03-27";
  };

  relaysrv = buildFromGitHub rec {
    rev = "v0.12.18";
    owner  = "syncthing";
    repo   = "relaysrv";
    sha256 = "8853b92808f01ce1a81a64c13a7294b6769b29ffdf3f5796afcf09263e007a32";
    buildInputs = [ syncthing-lib du ratelimit net ];
    excludedPackages = "testutil";
  };

  reflectwalk = buildFromGitHub {
    date = "2015-05-27";
    rev = "eecf4c70c626c7cfbb95c90195bc34d386c74ac6";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "0zpapfp4vx9zr3zlw2405clgix7jzhhdphmsyhar4yhhs04fb3qz";
  };

  roaring = buildFromGitHub {
    rev = "f292b80692877243664179967e342850a81f8941";
    date = "2016-04-28";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1c8fd039c79841c4ff572f5c168c19320f77a2d30cf4aaf280d68ef6fd144805";
  };

  runc = buildFromGitHub {
    rev = "v0.1.1";
    owner  = "opencontainers";
    repo   = "runc";
    sha256 = "4cf4042352f6a1cb21889dc5b7511b42f3808c7602c469e458a320e39d46a0b4";
    propagatedBuildInputs = [
      go-units
      logrus
      docker_for_runc
      go-systemd
      protobuf
      gocapability
      netlink
      codegangsta-cli
      runtime-spec
    ];
  };

  runtime-spec = buildFromGitHub {
    rev = "v0.5.0";
    owner  = "opencontainers";
    repo   = "runtime-spec";
    sha256 = "1jv82zyvhdg5pqbdm0265i6rsc4mzwxll8cjzggfhwagypn467w5";
    buildInputs = [
      gojsonschema
    ];
  };

  scada-client = buildFromGitHub {
    date = "2015-08-28";
    rev = "84989fd23ad4cc0e7ad44d6a871fd793eb9beb0a";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "0cbc50nyax4fazckm1chxychlbqgjcs93zl4hj5mnhy73089j0pk";
    buildInputs = [ armon_go-metrics net-rpc-msgpackrpc yamux ];
  };

  semver = buildFromGitHub {
    rev = "v3.1.0";
    owner = "blang";
    repo = "semver";
    sha256 = "0s7pzm46x92fw63cfp8v7gjdwb5mpgsrxgp01mx2j5wvjw5ygppb";
  };

  serf = buildFromGitHub {
    rev = "v0.7.0";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1qzphmv2kci14v5xis08by1bhl09a3yhjy0glyh1wk0s96mx2d1b";

    buildInputs = [
      net circbuf armon_go-metrics ugorji_go go-syslog logutils mdns memberlist
      dns mitchellh-cli mapstructure columnize
    ];
  };

  sets = buildFromGitHub {
    rev = "6c54cb57ea406ff6354256a4847e37298194478f";
    owner  = "feyeleanor";
    repo   = "sets";
    sha256 = "11gg27znzsay5pn9wp7rl427v8bl1rsncyk8nilpsbpwfbz7q7vm";
    date = "2013-02-27";
    propagatedBuildInputs = [
      slices
    ];
  };

  slices = buildFromGitHub {
    rev = "bb44bb2e4817fe71ba7082d351fd582e7d40e3ea";
    owner  = "feyeleanor";
    repo   = "slices";
    sha256 = "05i934pmfwjiany6r9jgp27nc7bvm6nmhflpsspf10d4q0y9x8zc";
    date = "2013-02-25";
    propagatedBuildInputs = [
      raw
    ];
  };

  sortutil = buildFromGitHub {
    date = "2015-06-17";
    rev = "4c7342852e65c2088c981288f2c5610d10b9f7f4";
    owner = "cznic";
    repo = "sortutil";
    sha256 = "11iykyi1d7vjmi7778chwbl86j6s1742vnd4k7n1rvrg7kq558xq";
  };

  spacelog = buildFromGitHub {
    date = "2015-03-20";
    rev = "ae95ccc1eb0c8ce2496c43177430efd61930f7e4";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "0j0s42z2mi4xx0aszaq2vrnjllz562swxcq77vdk9fcn9vy10cz3";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    date = "2015-09-02";
    rev = "36e9cfdd690967f4f690c6edcc9ffacd006014a0";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "13ixl56gap48s78yaifrqb137rkm2fazk20wq0zs76c694m44baq";
  };

  stathat = buildFromGitHub {
    date = "2016-03-03";
    rev = "91dfa3a59c5b233fef9a346a1460f6e2bc889d93";
    owner = "stathat";
    repo = "go";
    sha256 = "1d9ahyn0w7n4kyn05b7hrm7gx9nj2rws4m6zg762v1wilq96d2nh";
  };

  structs = buildFromGitHub {
    date = "2016-03-17";
    rev = "73c4e3dc02a78deaba8640d5f3a8c236ec1352bf";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "0ky7f5wsfm0gqhlwmhdjw5k1sgl4201g5889a6m2ls6c5kbfv4aw";
  };

  stump = buildFromGitHub {
    date = "2015-11-05";
    rev = "bdc01b1f13fc5bed17ffbf4e0ed7ea17fd220ee6";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "010lm1yr8pdnba5z2lbbwwqqf6i5bdwmm1vhbbq5375nmxxb4h6j";
  };

  strutil = buildFromGitHub {
    date = "2015-04-30";
    rev = "1eb03e3cc9d345307a45ec82bd3016cde4bd4464";
    owner = "cznic";
    repo = "strutil";
    sha256 = "0ipn9zaihxpzs965v3s8c9gm4rc4ckkihhjppchr3hqn2vxwgfj1";
  };

  suture = buildFromGitHub {
    rev = "v1.1.1";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0hpi9swsln9nrj4c18hac8905g8nbgfd8arpi8v118pasx5pw2l0";
  };

  sync = buildFromGitHub {
    rev = "812602587b72df6a2a4f6e30536adc75394a374b";
    owner  = "anacrolix";
    repo   = "sync";
    sha256 = "10rk5fkchbmfzihyyxxcl7bsg6z0kybbjnn1f2jk40w18vgqk50r";
    date = "2015-10-30";
    buildInputs = [
      missinggo
    ];
  };

  syncthing = buildFromGitHub rec {
    rev = "v0.12.22";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "198ac8b828fb70b9202efcd6e1a5aa952981a2bbbe6358a8fc9fce0146631b63";
    buildFlags = [ "-tags noupgrade,release" ];
    buildInputs = [
      go-lz4 du luhn xdr snappy ratelimit osext
      goleveldb suture qart crypto net text rcrowley_go-metrics
    ];
    postPatch = ''
      # Mostly a cosmetic change
      sed -i 's,unknown-dev,${rev},g' cmd/syncthing/main.go
    '';
  };

  syncthing-lib = buildFromGitHub {
    inherit (syncthing) rev owner repo sha256;
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
    rev = "ff71fe7a7d5279df4b964b31f7ee4adf117277f6";
    date = "2015-07-17";
    owner  = "jeromer";
    repo   = "syslogparser";
    sha256 = "1x1nq7kyvmfl019d3rlwx9nqlqwvc87376mq3xcfb7f5vxlmz9y5";
  };

  tablewriter = buildFromGitHub {
    rev = "c9c819c8d9cafaeff4dc99f1686394dcd274b66b";
    date = "2016-04-29";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "1838156zpgiqqrawlkhxkl8fihrflw0h3rxzprv8pxfxa2iril83";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  tar-utils = buildFromGitHub {
    rev = "beab27159606f5a7c978268dd1c3b12a0f1de8a7";
    date = "2016-03-22";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "0p0cmk30b22bgfv4m29nnk2359frzzgin2djhysrqznw3wjpn3nz";
  };

  template = buildFromGitHub {
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "10albmv2bdrrgzzqh1rlr88zr2vvrabvzv59m15wazwx39mqzd7p";
    date = "2016-04-05";
  };

  testify = buildFromGitHub {
    rev = "v1.1.3";
    owner = "stretchr";
    repo = "testify";
    sha256 = "12r2v07zq22bk322hn8dn6nv1fg04wb5pz7j7bhgpq8ji2sassdp";
    propagatedBuildInputs = [ objx go-difflib go-spew ];
  };

  tokenbucket = buildFromGitHub {
    rev = "c5a927568de7aad8a58127d80bcd36ca4e71e454";
    date = "2013-12-01";
    owner = "ChimeraCoder";
    repo = "tokenbucket";
    sha256 = "11zasaakzh4fzzmmiyfq5mjqm5md5bmznbhynvpggmhkqfbc28gz";
  };

  tomb-v2 = buildFromGitHub {
    date = "2014-06-26";
    rev = "14b3d72120e8d10ea6e6b7f87f7175734b1faab8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1ixpcahm1j5s9rv52al1k8047hsv7axxqvxcpdpa0lr70b33n45f";
    goPackagePath = "gopkg.in/tomb.v2";
    goPackageAliases = [ "github.com/go-tomb/tomb" ];
  };

  units = buildFromGitHub {
    rev = "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a";
    owner = "alecthomas";
    repo = "units";
    sha256 = "1jj055kgx6mfx5zw263ci70axk3z5006db74dqhcilxwk1a2ga23";
    date = "2015-10-22";
  };

  utp = buildFromGitHub {
    rev = "e509da33168949a91f52f58a7fb1de4ce2e181d1";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "05apxm2mh8r41y891bylx1lpz7g2bfrqpr8nr142z8kk58ylvxpa";
    date = "2016-04-30";
    propagatedBuildInputs = [
      envpprof
      missinggo
      sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    rev = "v1.0";
    owner = "pborman";
    repo = "uuid";
    sha256 = "1yk7vxrhsyk5izazdqywzfwb7iq6b5lwwdp0yc4rl4spqx30s0f9";
  };

  hashicorp_uuid = buildFromGitHub {
    rev = "ebb0a03e909c9c642a36d2527729104324c44fdb";
    date = "2016-03-11";
    owner = "hashicorp";
    repo = "uuid";
    sha256 = "0ifcaib2q3j90z0yxgprp6w7hawihhbx1qcdkyzr6c7qy3c808w0";
  };

  vault = buildFromGitHub rec {
    rev = "v0.5.2";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "0qi011gvmn40pvq4q5930ms2jc7pxlf6gr6m89bjcj6d6254v11v";

    buildInputs = [
      armon_go-metrics go-radix govalidator aws-sdk-go speakeasy etcd-client
      duo_api_golang structs ini ldap mysql gocql snappy go-github
      go-querystring hailocab_go-hostpool consul-api errwrap go-cleanhttp
      go-multierror go-syslog golang-lru logutils serf hashicorp_uuid
      go-jmespath osext pq mitchellh-cli copystructure go-homedir mapstructure
      reflectwalk columnize go-zookeeper ugorji_go crypto net oauth2 sys
      asn1-ber inf yaml yaml-v2 hashicorp-go-uuid hcl go-mssqldb
    ];
  };

  vault-api = buildFromGitHub {
    inherit (vault) rev owner repo sha256;
    subPackages = [ "api" ];
    propagatedBuildInputs = [
      hcl
      structs
      go-cleanhttp
      go-multierror
      mapstructure
    ];
  };

  vultr = buildFromGitHub {
    rev = "v1.8";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "1p4vb6rbcfr02fml2sj8nwsy34q4n9ylidhr90vjzk99x57pcjf7";
    propagatedBuildInputs = [
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  websocket = buildFromGitHub {
    rev = "1f512fc3f05332ba7117626cdfb4e07474e58e60";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "10aaf2xqpjdmz12hs90nbbhhm50jmblvmiq3h4c0xzb1aq91bnxx";
    date = "2016-04-28";
  };

  wmi = buildFromGitHub {
    rev = "f3e2bae1e0cb5aef83e319133eabfee30013a4a5";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "1paiis0l4adsq68v5p4mw7g7vv39j06fawbaph1d3cglzhkvsk7q";
    date = "2015-05-20";
  };

  yaml = buildFromGitHub {
    rev = "e8e0db9016175449df0e9c4b6e6995a9433a395c";
    date = "2016-05-03";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "197j3jkw2vzdq37gkdx6va5riky8c8vjk1i2503zp75ssnmb82cl";
    propagatedBuildInputs = [ candiedyaml ];
  };

  yaml-v2 = buildFromGitHub {
    rev = "a83829b6f1293c91addabc89d0571c246397bbf4";
    date = "2016-03-01";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "0jf2man0a6jz02zcgqaadqa3844jz5kihrb343jq52xp2180zwzz";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yamux = buildFromGitHub {
    date = "2016-04-20";
    rev = "c8a8a076e0858546ae6e2ee189d94e78b9b881ce";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "0r9gg73z84hhd06k6x2yr4gdibals7m676ghpisq72baz8jkzyhi";
  };

  xdr = buildFromGitHub {
    rev = "8cb24337527a8f0f70bd43be68676a4390ca1c14";
    date = "2016-01-28";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "e72f1e0869388c5949d99d03dcb077b1e7edf0137c42eae8cc2b5c8e77dd92f2";
  };

  zappy = buildFromGitHub {
    date = "2016-03-05";
    rev = "4f5e6ef19fd692f1ef9b01206de4f1161a314e9a";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1kinbjs95hv16kn4cgm3vb1yzv09ina7br5m3ygh803qzxp7i5jz";
  };
}; in self
