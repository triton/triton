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
    rev = "7f59a8c76b8594d06044bfe0bcbe475cb2020482";
    date = "2016-05-16";
    owner = "golang";
    repo = "appengine";
    sha256 = "0w2y6g9ncaipmpgmpcbpjxyrfa925wzbknf9pd6srzdia1fk8l2q";
    goPackagePath = "google.golang.org/appengine";
    propagatedBuildInputs = [ protobuf net ];
  };

  crypto = buildFromGitHub {
    rev = "5bcd134fee4dd1475da17714aac19c0aa0142e2f";
    date = "2016-05-17";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "0dgqrrs1ns2m5rh10nih5pg8mir7qnx1dkda8lj01q5rgqp525js";
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
    rev = "c4c3ea71919de159c9e246d7be66deb7f0a39a58";
    date = "2016-05-27";
    owner  = "golang";
    repo   = "net";
    sha256 = "18yxx4bbbjnj2afkx0irfmgg9dwl3w89kk1h71jq1fs9gq6rxpma";
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
    rev = "c406a4cc4ba462e5dc2f16225c5bd9488f9cbe10";
    date = "2016-05-20";
    owner = "golang";
    repo = "oauth2";
    sha256 = "08ns6pnwrmz784l5qbsc06ffwmfzypqr2y1bvr84f63r09rxb33a";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [ net gcloud-golang-compute-metadata ];
  };


  protobuf = buildFromGitHub {
    rev = "3b06fc7a4cad73efce5fe6217ab6c33e7231ab4a";
    date = "2016-06-01";
    owner = "golang";
    repo = "protobuf";
    sha256 = "0kp7ix62n4gyx6p8c4br42ih4mnxa17gmwj9frdph21x24cgsmc1";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [ "code.google.com/p/goprotobuf" ];
  };

  snappy = buildFromGitHub {
    rev = "d9eb7a3d35ec988b8585d4a0068e462c27d28380";
    date = "2016-05-29";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "1z7xwm1w0nh2p6gdp0cg6hvzizs4zjn43c7vrm1fmf3sdvp6pxnw";
    goPackageAliases = [ "code.google.com/p/snappy-go/snappy" ];
  };

  sys = buildFromGitHub {
    rev = "d4feaf1a7e61e1d9e79e6c4e76c6349e9cab0a03";
    date = "2016-05-16";
    owner  = "golang";
    repo   = "sys";
    sha256 = "10v013f1gsn63ydhpmyy778b5iljz29j3msl68nab5fbiy7hzmwr";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    rev = "f773ec03ce334298742df7f3108fc0d402646d22";
    date = "2016-05-05";
    owner = "golang";
    repo = "text";
    sha256 = "1ag0cy3cqdlg53zibha3b94a9xd7qr4xiv2kmxra6nln3qg09az7";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
  };

  tools = buildFromGitHub {
    rev = "b41cbfc0fac050e3a416b4f51df202a101cd2aa5";
    date = "2016-04-03";
    owner = "golang";
    repo = "tools";
    sha256 = "1gq67rc1b2b7amr1fqhwgl08khpb3h2820dnagdvl962wzfylf6f";
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
    rev = "v1.1.31";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "0i814pcq0zffkh19w5gbcpnqphgg8ilmwy2qinmsl398bfy51lh7";
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
    rev = "v1.2.1";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "1fm23v09n43f61pzkd0znl9nwlss8kj076pqycsj7vq1bjf1lw0v";
  };

  btree = buildFromGitHub {
    rev = "7d79101e329e5a3adf994758c578dab82b90c017";
    owner  = "google";
    repo   = "btree";
    sha256 = "0ky9a9r1i3awnjisk8bkw4d9v5jkcm9w6sphd889vxdhvizvkskl";
    date = "2016-05-24";
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
    rev = "v1.17.0";
    owner = "codegangsta";
    repo = "cli";
    sha256 = "0171xw72kvsk4zcygvrmslcir9qp7q4v1lh6rpllayf9ws1253dl";
    buildInputs = [ yaml-v2 ];
  };

  cli-go = buildFromGitHub {
    rev = "v1.17.0";
    owner  = "codegangsta";
    repo   = "cli";
    sha256 = "0171xw72kvsk4zcygvrmslcir9qp7q4v1lh6rpllayf9ws1253dl";
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
    sha256 = "157g5j6a8jf762p308w6sy4byhcqqvm3il5iyjwf5ykavvjizz31";

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
    inherit (consul) owner repo;
    rev = "b43f900766ad92eebbd5a8f931fe0fe244f9969d";
    date = "2016-05-29";
    sha256 = "b23e92cc7a51574cc4a727915c58247d4e81cb2f47c7256f49ccbcf5311cef9e";
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
    rev = "48ab6605c66ac797e07f615101c3e9e10e932b66";
    date = "2016-05-12";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "03pjrzhgxcz4zr3sh73mzma9s3ai91cwj52sgn9qw4lrdj7gairp";
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
    rev = "0383bfe017e02efb418ffd595fc54777a35e48b0";
    owner = "anacrolix";
    repo = "envpprof";
    sha256 = "0i9d021hmcfkv9wv55r701p6j6r8mj55fpl1kmhdhvar8s92rjgl";
    date = "2016-05-28";
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
    rev = "v2.3.6";
    owner  = "coreos";
    repo   = "etcd";
    sha256 = "0x1fhn5hgdamj8xbry6b3dqaddy0ls00x4bcrpm4fp2n940k3l18";
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

  gateway = buildFromGitHub {
    date = "2016-05-22";
    rev = "edad739645120eeb82866bc1901d3317b57909b1";
    owner  = "calmh";
    repo   = "gateway";
    sha256 = "0gzwns51jl2jm62ii99c7caa9p7x2c8p586q1cjz8bpv2mcd8njg";
    goPackageAliases = [
      "github.com/jackpal/gateway"
    ];
  };

  gcloud-golang = buildFromGoogle {
    rev = "1fbaa7ea974691031228bc481570e528b9404a80";
    repo = "cloud";
    sha256 = "d160830fc4aca0add3741d1d4b30cb07861d4b09704623d833cbbceae8340cf3";
    propagatedBuildInputs = [ net oauth2 protobuf google-api-go-client grpc ];
    excludedPackages = "oauth2";
    meta.hydraPlatforms = [ ];
    date = "2016-05-31";
  };

  gcloud-golang-compute-metadata = buildFromGoogle {
    inherit (gcloud-golang) rev repo sha256 date;
    subPackages = [ "compute/metadata" "internal" ];
    buildInputs = [ net ];
  };

  gettext = buildFromGitHub {
    rev = "305f360aee30243660f32600b87c3c1eaa947187";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "0s1f99llg462mbcdmg2yp8l6ifq56v6qp8bw33ng5yrws91xflj7";
    date = "2016-06-02";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  ginkgo = buildFromGitHub {
    rev = "5437a97bf824dec14e58d68c56ee36e772670c2e";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "18hbr3m7yk7zdj94cs5izgkfd491j7if2760wlip6mhlsxmfhwrh";
    date = "2016-05-09";
  };

  glob = buildFromGitHub {
    rev = "0.2.0";
    owner = "gobwas";
    repo = "glob";
    sha256 = "1lbijdwchj6v7qpy9mr0xzs3v2y868vrmsxk1y24dm6wpacz50jd";
  };

  ugorji_go = buildFromGitHub {
    date = "2016-05-31";
    rev = "b94837a2404ab90efe9289e77a70694c355739cb";
    owner = "ugorji";
    repo = "go";
    sha256 = "0419rraxl5hwpwmwf6ac5201as1456r128llwa49qnl3jg4s98rz";
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
    rev = "b7b8a0e04b0cb0ca0b379421c58ec6fab9939b85";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "0ypkjl63xjw4r618dr94p8c1sccnw09bb1x7h124s916q9j9p3vp";
    propagatedBuildInputs = [ inf snappy hailocab_go-hostpool net ];
    date = "2016-05-25";
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
    rev = "d5336c75940ef31c9ceeb0ae64cf92944bccb4ee";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "0qym7qakr4ibwqfw43gjz43ks9g3q8k7dyr0m9lhpc7pqr1py2sj";
    date = "2016-05-07";
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
    rev = "c73e51675ad2455a4515b6213eb7145eaade4824";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "1fiv3vslwmvrj0hmq6ywa6zc3285qvyadr69dcxscbnf9gfzkcfx";
    propagatedBuildInputs = [
      protobuf
      yaml-v2
    ];
    date = "2016-05-16";
  };

  google-api-go-client = buildFromGitHub {
    rev = "63ade871fd3aec1225809d496e81ec91ab76ea29";
    date = "2016-05-31";
    owner = "google";
    repo = "google-api-go-client";
    sha256 = "11m3gpacaqznzrfiss0vgpcm75kw08bb29flzra7lzw7i92k0jvw";
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
    rev = "1.0.0";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "76f0b4db2d01c2f4c13cb6cecb56c6176b64702c4d1ae40be117f0753d984a85";
  };

  goskiplist = buildFromGitHub {
    rev = "2dfbae5fcf46374f166f8969cb07e167f1be6273";
    owner  = "ryszard";
    repo   = "goskiplist";
    sha256 = "1dr6n2w5ikdddq9c1fwqnc0m383p73h2hd04302cfgxqbnymabzq";
    date = "2015-03-12";
  };

  govalidator = buildFromGitHub {
    rev = "df81827fdd59d8b4fb93d8910b286ab7a3919520";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "0bhnv6fd6msyi7y258jkrqr28gmnc34aj5fxii85494di8g2ww5z";
    date = "2016-05-19";
  };

  go-base58 = buildFromGitHub {
    rev = "1.0.0";
    owner  = "jbenet";
    repo   = "go-base58";
    sha256 = "0sbss2611iri3mclcz3k9b7kw2sqgwswg4yxzs02vjk3673dcbh2";
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
    rev = "v0.0.5";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "1cj5wp5b0c5xg6hd5v9207b47aysji2zyg7zcs3z4rimzhnlbbnc";
  };

  go-difflib = buildFromGitHub {
    date = "2016-01-10";
    rev = "792786c7400a136282c1664665ae0a8db921c6c2";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0xhjjfvx97zkms5004v1k3prc5g1kljiayhf05v0n0yf89s5r28r";
  };

  go-dockerclient = buildFromGitHub {
    date = "2016-05-19";
    rev = "d9a325f6111a14ebceefba8ff6afeb3bdaa72729";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "0mndgwj71qaxvz2gndx0qjxgczvdnv2nn56am69ky54kps453klh";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      mux
    ];
  };

  go-flags = buildFromGitHub {
    date = "2016-05-28";
    rev = "b9b882a3990882b05e02765f5df2cd3ad02874ee";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "02wzy17cl9v91ssmidqgvsk82dgg0iskd12h8dkp1ya1f9cvn7rj";
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
    date = "2016-05-17";
    rev = "7ec4e45f77474b3a7b7d9b7ef233a0cc8339ddf3";
    owner = "google";
    repo = "go-github";
    sha256 = "1q9fda69xsk273p3i4wwdv4fww609a2zyw6j73a3n90a28bbga2j";
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
    rev = "88e58c26e9fe8ac578a0d76a68e32838acf17a8d";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "06xxhpm88ak5sgwvd0rjcxjx3dpw199dqgn2f7azhp7cjajzissb";
    date = "2016-05-31";
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
    rev = "v1.0.0";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "0c54r9g10rcnrm9rzj815gjkcgmr5z3pjgh3b4b19vbsgm2rx7hf";
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
    rev = "8f9e220b36393c03854c2d224c5a55644b13e205";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "16ka135074r3i89fiwjhhrmidzfv8kv5hqk2rnhbq9mcrsv138ms";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [ pkgs.lxc ];
    date = "2016-05-31";
  };

  go-lz4 = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1bdh2wqp2hh81x00wmsb4px9fzj13jcrdl6w52pabqkr2wyyqwkf";
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
    date = "2016-05-20";
    rev = "fbf75676ee9c0a3a23eb0a4d9220a3612cfbd1ed";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0wrkka9y0w8arfy08aghawwxxj36cgm6i0dw9ri6vhbb821nfar0";
    propagatedBuildInputs = [ prometheus_client_golang datadog-go ];
  };

  go-mssqldb = buildFromGitHub {
    rev = "2a223b1644106bc7ca456c12cde55a80185813ef";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "045nj6bqxxg84d3v7y2pkf5qgwp15lvkbk20c05chzcr1gmbdfh1";
    date = "2016-05-15";
    buildInputs = [ crypto ];
  };

  go-multiaddr = buildFromGitHub {
    rev = "f3dff105e44513821be8fbe91c89ef15eff1b4d4";
    date = "2016-05-09";
    owner  = "jbenet";
    repo   = "go-multiaddr";
    sha256 = "0qdma38d4bmib063hh899h2491kgzgg16kgqdvypncchawq8nqlj";
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    rev = "d4cfd691db9f50e430528f682ca603237b0eaae0";
    owner  = "jbenet";
    repo   = "go-multiaddr-net";
    sha256 = "0nwqaqfn30qxhwa0v2sbxankkj41krbwd30bp92y0xrkz5ivvi16";
    date = "2016-05-16";
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

  go-nat-pmp = buildFromGitHub {
    rev = "452c97607362b2ab5a7839b8d1704f0396b640ca";
    owner  = "AudriusButkevicius";
    repo   = "go-nat-pmp";
    sha256 = "0jjwqvanxxs15nhnkdx0mybxnyqm37bbg6yy0jr80czv623rp2bk";
    date = "2016-05-22";
    buildInputs = [
      gateway
    ];
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
    rev = "38ee283dabf11c9cbdb968eebd79b1fa7acbabe6";
    date = "2016-05-14";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0nwdi1m386p8wxdvnwzqr17dwsj6px5qnn9qy22n7nd2pv49m8hs";
  };

  go-syslog = buildFromGitHub {
    date = "2015-02-18";
    rev = "42a2b573b664dbf281bd48c3cc12c086b17a39ba";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "0zbnlz1l1f50k8wjn8pgrkzdhr6hq4rcbap0asynvzw89crh7h4g";
  };

  go-systemd = buildFromGitHub {
    rev = "4484981625c1a6a2ecb40a390fcb6a9bcfee76e3";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "087x8yx5hgdpll7j048gjbkc45p4i1hivy68bd56lqj8gb06ypaf";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2016-05-27";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 date;
    subPackages = [
      "journal"
    ];
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
    rev = "0181db47023708a38c2d20d2fe25a5fa034d5743";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "04kryh7dmz8zwd2kdma119fg6ydw2gm9zr041i8hr6dnjvrrp177";
    date = "2016-05-19";
  };

  go-zookeeper = buildFromGitHub {
    rev = "4b20de542e40ed2b89d65ae195fc20a330919b92";
    date = "2016-05-31";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "0qhm2bn9idjg02vdjdcnlij69ag4wc3d5vcm6pcra989hiqllqb1";
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
    date = "2016-05-15";
    rev = "02826c3e79038b59d737d3b1c0a1d937f71a4433";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "093p9jiid2c03d02g8fada7bl05244caddd7qjmjs0ggsrardc46";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    rev = "b0b7afa173ab8030774fdf383cac027c3c5077d2";
    date = "2016-05-17";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "01vmparkz8sjplwc7prbgiwdrvavdn618g4gw5gw61k6094pdx20";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [ "github.com/grpc/grpc-go" ];
    propagatedBuildInputs = [ http2 net protobuf oauth2 glog ];
    excludedPackages = "\\(test\\|benchmark\\)";
  };

  gucumber = buildFromGitHub {
    date = "2016-05-11";
    rev = "5692705bb5ff96c5d7b33819b4739715008cc635";
    owner = "lsegal";
    repo = "gucumber";
    sha256 = "19hvwz21rmfkhxjdhj6jwjk0fmjwwa1yyfgvz9xyp7gi3fcnvnhy";
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
    date = "2016-04-08";
    rev = "6215360e5247e7c4bdc317a5f95e3fa5f084a33b";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "6b3ab530f6980279edb5a1994226adefc377b70aa3e993b5d29c7d498d5cdbd4";
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
    rev = "v0.9.0";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "0wqf867vifpfa81a1vhazjgfjjhiykqpnkblaxxj6ppyxlzrs3cp";
    goPackagePath = "gopkg.in/inf.v0";
    goPackageAliases = [ "github.com/go-inf/inf" ];
  };

  ini = buildFromGitHub {
    rev = "v1.12.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "0kh539ajs00ciiizf9dbf0244hfgwcflz1plk8prj4iw9070air7";
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
    rev = "v0.4.2";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "0vpc8pisrv55n7g9yxz8lm7kn328ha3fqfsjsybjd9yxpv5wi7y9";
    gxSha256 = "049f1fq0lld0bq91cs4m6fw784jnarzsnghkvvgdral335xj7wrn";

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
    rev = "lxd-2.0.2";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "1d935hv0h48l9i5a023mkmy9jy0fg5i0nwq9gp3xfkqb8r3rjvq8";
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
    date = "2016-05-31";
    rev = "1e4a8091631113ae8bfc4717f53bd857ccf6f540";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "067brg0mpdcn8qmk0159m074spjn9b88nsf9k5gckqzp266fv2gl";
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
    rev = "e40875155efce3d98562ca9e265e152c364ada3e";
    owner  = "anacrolix";
    repo   = "missinggo";
    sha256 = "0ph15im9qv4inny5vdiqcccfa5i5imckqn6h761bwlinazj5xz4i";
    date = "2016-05-31";
    propagatedBuildInputs = [
      b
      btree
      docopt-go
      envpprof
      goskiplist
      iter
      roaring
      tagflag
    ];
  };

  missinggo_lib = buildFromGitHub {
    inherit (missinggo) rev owner repo sha256 date;
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      iter
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
    date = "2014-03-12";
    rev = "f693c7e88ba316d1a0ae3e205e22a01aa3ec2848";
    owner  = "inconshreveable";
    repo   = "muxado";
    sha256 = "db9a65b811003bcb48d1acefe049bb12c8de232537cf07e1a4a949a901d807a2";
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
    rev = "e299ab1a585b04a7e7d4d2f609f241b69ca7d326";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "1nkkkrlp1i03wvzdj2h9v7pzk01yp1zzjplk1p3imjba9dhaihmg";
    date = "2016-05-25";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    rev = "8ba1072b58e0c2a240eb5f6120165c7776c3e7b8";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "05r4qri45ngm40kp9qdbyqrs15gx7swjj27bmc7i04wg9yd65j95";
    date = "2016-04-30";
  };

  nomad = buildFromGitHub {
    rev = "v0.3.2";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "11n87z4f2y3s3fkf6xp41671m39fmn4b6lry4am9cqf0g2im46rh";

    buildInputs = [
      datadog-go wmi armon_go-metrics go-radix aws-sdk-go perks speakeasy
      bolt go-systemd go-units go-humanize go-dockerclient ini go-ole
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

  pkg = buildFromGitHub rec {
    date = "2016-05-30";
    owner  = "coreos";
    repo   = "pkg";
    rev = "7f080b6c11ac2d2347c3cd7521e810207ea1a041";
    sha256 = "0j11lvs1mwykw91x27lkr6sqssgbcraz047f23vnmdwdqsfzlgfi";
    buildInputs = [
      crypto
      go-systemd_journal
      yaml-v1
    ];
  };

  pongo2-v3 = buildFromGitHub {
    rev = "v3.0";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "1qjcj7hcjskjqp03fw4lvn1cwy78dck4jcd0rcrgdchis1b84isk";
    goPackagePath = "gopkg.in/flosch/pongo2.v3";
  };

  pq = buildFromGitHub {
    rev = "ee1442bda7bd1b6a84e913bdb421cb1874ec629d";
    owner  = "lib";
    repo   = "pq";
    sha256 = "0ds49x3glbxx3b1wycgn2vcalhqqv2vzhfv8r75bzb16snzpmy6x";
    date = "2016-05-10";
  };

  prometheus_client_golang = buildFromGitHub {
    rev = "488edd04dc224ba64c401747cd0a4b5f05dfb234";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "0fvsa9qg10cswzdal96w90gk96h96wdm8cji1rrdf83zccbr7src";
    propagatedBuildInputs = [
      goautoneg
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      prometheus_procfs
      beorn7_perks
    ];
    date = "2016-05-31";
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
    date = "2016-05-30";
    rev = "a3a8fe85f2579bcfec713dbfacbdd0797a792f3a";
    owner = "prometheus";
    repo = "common";
    sha256 = "0x8ib432793plr3zhfk1a28ilaclkcnxwk6vnlqcvhl34gw8fwfb";
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
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "02n7f1j42jp8f4nvg83nswfy6yy0mz2axaygr6kdqwj11n44rdim";
  };

  ql = buildFromGitHub {
    rev = "v1.0.3";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1r1370h0zpkhi9fs57vx621vsj8g9j0ijki0y4mpw18nz2mq620n";
    propagatedBuildInputs = [ go4 b exp strutil ];
  };

  raft = buildFromGitHub {
    date = "2016-05-05";
    rev = "5fdd8ee3c3b2cc508e29991c4caf117977034eb1";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "021wa1k8iyys32dn20y4diiqa674dgnld068dxl0m23lr6yn3fv7";
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
    rev = "v0.2.5";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1kc85xpk5p0fviywck9ci3i8nzsng34gx29i2j3322ax1nyj93ap";
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
    rev = "bf58a8f54497acc1f414a5e752057a6694feccf3";
    date = "2016-05-04";
    owner  = "opencontainers";
    repo   = "runtime-spec";
    sha256 = "458cbe83d33e754f18da879f6313a05c68a58856bb2a36056a81d119d967f2c0";
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
    date = "2016-05-20";
    rev = "e1439544d8ecd0f3e9373a636d447668096a8f81";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "1aks9mz0xrgxb9fvpf9pac104zwamzv2j53bdirgxsjn12904cqm";
  };

  stathat = buildFromGitHub {
    date = "2016-03-03";
    rev = "91dfa3a59c5b233fef9a346a1460f6e2bc889d93";
    owner = "stathat";
    repo = "go";
    sha256 = "1d9ahyn0w7n4kyn05b7hrm7gx9nj2rws4m6zg762v1wilq96d2nh";
  };

  structs = buildFromGitHub {
    date = "2016-05-19";
    rev = "3fe2facc32a7fbde4b29c0f85604dc1dd22836d2";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "1850w18j7wnjy9rm9dsbxqi5vwrklhrd3xgv5ih14kq0jms4gyhi";
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
    rev = "v0.13.4";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "06wdyy6cy2rvxjz03pvxc4as8cb17r7qlj3zf3w58hi9m8v0g6fn";
    buildFlags = [ "-tags noupgrade" ];
    buildInputs = [
      go-lz4 du luhn xdr snappy ratelimit osext
      goleveldb suture qart crypto net text rcrowley_go-metrics
      go-nat-pmp glob gateway
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
    rev = "8d0265a48283795806b872b4728c67bf5c777f20";
    date = "2016-05-27";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "10asls1x37b0qibj850y6940rx7bhr20qvbcihcwn162qa50qlh0";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  tagflag = buildFromGitHub {
    rev = "b4e0d6bdcd327e72ac967a672213c45c36fa9735";
    date = "2016-05-11";
    owner  = "anacrolix";
    repo   = "tagflag";
    sha256 = "1m1qjwlb4w9fvvxd2bbbm2ypvqbdlmrw2smqmc36vv8bw8gi6wcp";
    propagatedBuildInputs = [
      go-humanize
      missinggo_lib
      xstrings
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
    rev = "787573b5b9864b9e1d12561b9b1bd1c8c951a51e";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "04z7myghdgvjk9zl3kl8cvw81xyjzs3ij71mdjqdbr9158afffc2";
    date = "2016-05-31";
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
    rev = "v0.5.3";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "00czqns7w4km48j9hhmq825dia8j0r03zv5ajk5ii6i3dwq8bw2h";

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
    rev = "v1.0.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "11sggyd6plhcd4bdi8as0bx70bipda8li1rdf0y2n5iwnar3qflq";
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

  yaml-v1 = buildFromGitHub {
    rev = "9f9df34309c04878acc86042b16630b0f696e1de";
    date = "2014-09-24";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "128xs9pdz042hxl28fi2gdrz5ny0h34xzkxk5rxi9mb5mq46w8ys";
    goPackagePath = "gopkg.in/yaml.v1";
  };

  yamux = buildFromGitHub {
    date = "2016-05-19";
    rev = "172cde3b6ca5c154ff4e6e2ef96b7451332a9946";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "1z9dcg5zcwpvgx48djsh7inf44i9b6dxcrsx68ch569slqm63s7a";
  };

  xdr = buildFromGitHub {
    rev = "v2.0.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "017k3y66fy2azbv9iymxsixpyda9czz8v3mhpn17750vlg842dsp";
  };

  xstrings = buildFromGitHub {
    rev = "3959339b333561bf62a38b424fd41517c2c90f40";
    date = "2015-11-30";
    owner  = "huandu";
    repo   = "xstrings";
    sha256 = "16l1cqpqsgipa4c6q55n8vlnpg9kbylkx1ix8hsszdikj25mcig1";
  };

  zappy = buildFromGitHub {
    date = "2016-03-05";
    rev = "4f5e6ef19fd692f1ef9b01206de4f1161a314e9a";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1kinbjs95hv16kn4cgm3vb1yzv09ina7br5m3ygh803qzxp7i5jz";
  };
}; in self
