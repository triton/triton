/* This file defines the composition for Go packages. */

{ stdenv
, buildGoPackage
, fetchbzr
, fetchFromBitbucket
, fetchFromGitHub
, fetchgit
, fetchhg
, fetchpatch
, fetchurl
, fetchzip
, git
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

  buildFromGitHub =
    { rev
    , date ? null
    , owner
    , repo
    , sha256
    , version
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
            inherit rev owner repo sha256 version;
          };
        in if gxSha256 == null then
          src'
        else
          fetchGxPackage { src = src'; sha256 = gxSha256; };
      })
  );

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner = "golang";
    repo = "appengine";
    sha256 = "0z0vrrwh4f4ji2v3sv40db7m5l31mw08mjwlgzibf0nfjaganwgl";
    goPackagePath = "google.golang.org/appengine";
    propagatedBuildInputs = [
      protobuf
      net
    ];
  };

  crypto = buildFromGitHub {
    version = 2;
    rev = "f6b343c37ca80bfa8ea539da67a0b621f84fab1d";
    date = "2016-12-21";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "1q8ry46xkq354szl5xf8568dvfznv21hkbbl7cigrdmmbrm82984";
    goPackagePath = "golang.org/x/crypto";
    goPackageAliases = [
      "code.google.com/p/go.crypto"
      "github.com/golang/crypto"
    ];
    buildInputs = [
      net_crypto_lib
    ];
  };

  debug = buildFromGitHub {
    version = 2;
    rev = "fb508927b491eca48a708e9d000fdb7afa53c32b";
    date = "2016-06-20";
    owner  = "golang";
    repo   = "debug";
    sha256 = "19g7hcsp24z5plbb2d2y5z16h0z0nc4fmf3lx7m3avf60zvwhns9";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
  };

  geo = buildFromGitHub {
    version = 2;
    rev = "8052dea609ab3333f59022c79c55b12c25f12268";
    owner = "golang";
    repo = "geo";
    sha256 = "04y3dr4f1523x469yakpx4n38hnlm514diwzd3iiryjzqm3vjxfr";
    date = "2016-11-18";
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
    version = 2;
    rev = "8fd7f25955530b92e73e9e1932a41b522b22ccd9";
    date = "2016-12-29";
    owner  = "golang";
    repo   = "net";
    sha256 = "128gjzr46b406nalgwkphby943c8ysigjxh0m88k2s7m7xabvxnv";
    goPackagePath = "golang.org/x/net";
    goPackageAliases = [
      "github.com/hashicorp/go.net"
      "github.com/golang/net"
    ];
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
    version = 2;
    rev = "314dd2c0bf3ebd592ec0d20847d27e79d0dbe8dd";
    date = "2016-12-14";
    owner = "golang";
    repo = "oauth2";
    sha256 = "1r61rmfkqv17rh848pmy49xkzdjq8pmvvn9mxxxjq520vw3kk1rg";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [
      net
      google-cloud-go-compute-metadata
    ];
  };


  protobuf = buildFromGitHub {
    version = 2;
    rev = "8ee79997227bf9b34611aee7946ae64735e6fd93";
    date = "2016-11-16";
    owner = "golang";
    repo = "protobuf";
    sha256 = "12x7d1m6ryjqj4a1hvg60pgx12acvvc8997zlwfzzzmnb6dbc83q";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [
      "code.google.com/p/goprotobuf"
    ];
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
    version = 1;
    rev = "d9eb7a3d35ec988b8585d4a0068e462c27d28380";
    date = "2016-05-29";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "1z7xwm1w0nh2p6gdp0cg6hvzizs4zjn43c7vrm1fmf3sdvp6pxnw";
    goPackageAliases = [
      "code.google.com/p/snappy-go/snappy"
    ];
  };

  sync = buildFromGitHub {
    version = 2;
    rev = "450f422ab23cf9881c94e2db30cac0eb1b7cf80c";
    date = "2016-12-05";
    owner  = "golang";
    repo   = "sync";
    sha256 = "04qq47zm1sg0vw8434h298fs5hvk3j1f08162qr430jxhx063img";
    goPackagePath = "golang.org/x/sync";
    propagatedBuildInputs = [
      net
    ];
  };

  sys = buildFromGitHub {
    version = 2;
    rev = "d75a52659825e75fff6158388dddc6a5b04f9ba5";
    date = "2016-12-14";
    owner  = "golang";
    repo   = "sys";
    sha256 = "1bw12m4mn5rndxj69b1hcallbcyidxw8nvhpw8iasnfs6qxv89ly";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    version = 2;
    rev = "a49bea13b776691cb1b49873e5d8df96ec74831a";
    date = "2016-12-16";
    owner = "golang";
    repo = "text";
    sha256 = "0qk1dhzpszyza2qivflnn8ajw13dfyr8azb4883aiacx9hm47mgc";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
    excludedPackages = "cmd";
  };

  time = buildFromGitHub {
    version = 2;
    rev = "f51c12702a4d776e4c1fa9b0fabab841babae631";
    date = "2016-10-27";
    owner  = "golang";
    repo   = "time";
    sha256 = "0p46261y3p546n3gbv6w1r32m0743s7zkr899sgd5jfpws6l114n";
    goPackagePath = "golang.org/x/time";
    propagatedBuildInputs = [
      net
    ];
  };

  tools = buildFromGitHub {
    version = 2;
    rev = "908849c3379245f71612058fbf92cf6bf58c3c75";
    date = "2016-12-20";
    owner = "golang";
    repo = "tools";
    sha256 = "16r0v2f4fq64i0xh1g80bf4qnvv398ypsw7v48zqz7ibxlj5ayab";
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

  ace = buildFromGitHub {
    version = 2;
    owner = "yosssi";
    repo = "ace";
    rev = "ea038f4770b6746c3f8f84f14fa60d9fe1205b56";
    date = "2016-07-28";
    sha256 = "15bw81d4d25q54w0a26rqfljs1iqmqv9pk4yark8n95dbrrk57rd";
    buildInputs = [
      gohtml
    ];
  };

  afero = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "afero";
    rev = "90dd71edc4d0a8b3511dc12ea15d617d03be09e0";
    date = "2016-12-26";
    sha256 = "0nn2jsyaq3rmg2qqajkmw441ia72rdg1nvxlw6nha39hd4rq0vfx";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  amber = buildFromGitHub {
    version = 2;
    owner = "eknkc";
    repo = "amber";
    rev = "70e65b69c34997098bf7cc8820b4af04a2191784";
    date = "2016-12-05";
    sha256 = "04ghglw9rcwjkzd620gi6f3fh948ga9pn7j6v7lf2y63ar67j2vx";
  };

  amqp = buildFromGitHub {
    version = 2;
    owner = "streadway";
    repo = "amqp";
    rev = "63795daa9a446c920826655f26ba31c81c860fd6";
    date = "2016-12-24";
    sha256 = "1hhrxlp7clrc7v5s4rwia5q0h0c4zhc6fd3pswks1a2lf73l53qx";
  };

  ansi = buildFromGitHub {
    version = 1;
    owner = "mgutz";
    repo = "ansi";
    rev = "c286dcecd19ff979eeb73ea444e479b903f2cfcb";
    date = "2015-09-14";
    sha256 = "1yifpfc2bil9ljrbp6ia10xl10jd95bp4c3k5jfpjnym77a942vq";
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
    version = 2;
    rev = "b144e4fe15d4968eb8d6e33d70761727d124814e";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "1n5x5y71f8g1p63x5dnpj2pj79625j2j3d8swgyrbi845frrskdd";
    goPackageAliases = [
      "github.com/nmcclain/asn1-ber"
      "github.com/vanackere/asn1-ber"
      "gopkg.in/asn1-ber.v1"
    ];
    date = "2016-09-13";
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
    version = 2;
    rev = "v1.6.9";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "00zfbvd09v4l20ddq77zs5blz823h2jl1qwgs12y2x4qfdfkb36c";
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
    version = 2;
    date = "2016-12-15";
    rev = "1620af6b32398bfc91827ceae54a8cc1f55df04d";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "0p7ckygm0hsrd9wg1a09hx6s2nhy8047szbz79gc3b7gldma8k97";
    excludedPackages = "Gododir";
    buildInputs = [
      decimal
      go-autorest
      satori_uuid
    ];
  };

  b = buildFromGitHub {
    version = 1;
    date = "2016-07-16";
    rev = "bcff30a622dbdcb425aba904792de1df606dab7c";
    owner  = "cznic";
    repo   = "b";
    sha256 = "0zjr4spbgavwq4lvxzl3h8hrkbyjk49vq14jncpydrjw4a9qql95";
  };

  bigfft = buildFromGitHub {
    version = 1;
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
  };

  binding = buildFromGitHub {
    version = 2;
    date = "2016-12-22";
    rev = "48920167fa152d02f228cfbece7e0f1e452d200a";
    owner = "go-macaron";
    repo = "binding";
    sha256 = "0dnkwgdx9y2dq7x3q9703371c7ph8w3aqr9q64vcrb086lisbj7z";
    buildInputs = [
      com
      compress
      macaron_v1
    ];
  };

  blackfriday = buildFromGitHub {
    version = 2;
    owner = "russross";
    repo = "blackfriday";
    rev = "5f33e7b7878355cd2b7e6b8eefc48a5472c69f70";
    sha256 = "15j4y3a3s0p0phdi5wyzz8c4v7zlvpy78f2nkczm8k15syyrjih8";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    date = "2016-10-03";
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
    rev = "c97913dcbd76de40b051a9b4cd827f7eaeb7a868";
    date = "2016-04-21";
    sha256 = "0w55l15zswdq1l9ngrp8yw96cd9sml49xiprcc4yw3avjh0k7i83";
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
    rev = "56a7ecbeb18dde53c6db4bd96b541fd9741b8d44";
    date = "2016-12-24";
    sha256 = "13ng4c23244nc5haqd33v93l78yczmnr3s1npib8nfjbvyq6h633";
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
    date = "2016-12-27";
    rev = "cba24044c4e73d1378241cdd053a1e67cff61753";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "10rbs0xfc6j73k3ngybw0kblhjfw8px4j20dmgwiiap2blj1nncg";
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
    date = "2016-11-25";
    rev = "9636d96501d1d89ea3827c9df770320544399422";
    sha256 = "1z6lvr4nkxyr8mhl0g3i32qlbf8fg8wcxrjyn9jmpvq82liwg056";
    buildInputs = [
      elastic_v5
      toml
      urfave_cli
      yaml_v2
    ];
  };

  mitchellh_cli = buildFromGitHub {
    version = 2;
    date = "2016-10-29";
    rev = "fa17b36f6c61f1ddbbb08c9f6fde94b3c065a09d";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "1xjh016f6qfjdw4m89i97l8hqkrfcblyx5miw6x12as4f7mkddzz";
    propagatedBuildInputs = [ crypto go-radix speakeasy go-isatty ];
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
    date = "2016-07-15";
    rev = "b64f5908f4945f4b11ed4a0a9d3cc1e23350866d";
    owner = "cockroachdb";
    repo = "cmux";
    sha256 = "0jzd6sq80xp558ljsiyi3i0ln7i54bzhi317yig8fiwljyz0blrz";
    propagatedBuildInputs = [
      net
    ];
  };

  cobra = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "cobra";
    rev = "1dd5ff2e11b6dca62fdcb275eb804b94607d8b06";
    date = "2016-09-04";
    sha256 = "092gzrf6s95lkn8v13qy4dchn08h3rnsqmh5kwvyaka1gn8942jz";
    buildInputs = [
      pflag
      viper
    ];
    propagatedBuildInputs = [
      go-md2man
    ];
  };

  color = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "fatih";
    repo   = "color";
    sha256 = "1k3vcxmy0hb7zxfakwpw90zy7fmkix9rlfvxlxag35c7xhm2xjkd";
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
    rev = "0fbbb3f0e3fbdc5bae7c6cd5f6c1887ebfb76360";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "14wgv4g9daq27ivpyiilvbl73dc87biymm60m2qc24pb41slnhi0";
    date = "2016-12-20";
  };

  com = buildFromGitHub {
    version = 1;
    rev = "28b053d5a2923b87ce8c5a08f3af779894a72758";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "0rl00hsj57xbpbj7bz1c9lqwq4lwh8i1yamm3gadzdxir9lysj91";
    date = "2015-10-08";
  };

  compress = buildFromGitHub {
    version = 2;
    rev = "v1.2";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "1amxiff7mvi0ahcrh2vg2k8g5g5k83mbzj0afn0jgc5l1k0wgafh";
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
    version = 2;
    rev = "v0.7.2";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "0sxbxplg0g9adfgxl893s8x32rdzg6xy855fgmgj00n8rjzr3vdq";

    buildInputs = [
      datadog-go circbuf armon_go-metrics go-radix speakeasy bolt
      go-bindata-assetfs go-dockerclient errwrap go-checkpoint
      go-immutable-radix go-memdb ugorji_go go-multierror go-reap go-syslog
      golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft_v2 raft-boltdb_v2
      scada-client yamux muxado dns mitchellh_cli mapstructure columnize
      copystructure hil hashicorp-go-uuid crypto sys aws-sdk-go go-sockaddr
    ];

    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];

    postPatch = let
      version = stdenv.lib.substring 1 (stdenv.lib.stringLength rev - 1) rev;
    in ''
      sed \
        -e 's,\(Version[ \t]*= "\)unknown,\1${version},g' \
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
      serf
    ];
    subPackages = [
      "api"
      "lib"
      "tlsutil"
    ];
    meta.autoUpdate = false;
  };

  consulfs = buildFromGitHub {
    version = 2;
    rev = "745c59d46a74b8aceccbd3f1dd4ad064f6e8bb64";
    owner = "bwester";
    repo = "consulfs";
    sha256 = "0a2hrppqyaymlg8bcmzbadcxrsz9kcnin4w10sinv7x142d21g7q";
    date = "2016-10-28";
    buildInputs = [
      consul_api
      fuse
      logrus
      net
    ];
  };

  consul-template = buildFromGitHub {
    version = 2;
    rev = "v0.18.0-rc1";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "f3dc56abb5f2fe584329ae881ef944bf31a0fb5baea7f78a781828e6922dd8d3";

    propagatedBuildInputs = [
      consul_api
      errors
      go-cleanhttp
      go-multierror
      go-reap
      go-shellwords
      go-syslog
      logutils
      mapstructure
      serf
      toml
      yaml_v2
      vault_api
    ];
  };

  consul-template_for_nomad = buildFromGitHub {
    version = 2;
    rev = "47bb974122b976c33aa8035152833265dcd9c630";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "a5328e13295798b958d148918833f8dcbc3820efeebe632e05ef98192e53ec1e";
    propagatedBuildInputs = [
      consul_api
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
    meta.autoUpdate = false;
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
    date = "2016-10-13";
    rev = "5af94aef99f597e6a9e1f6ac6be6ce0f3c96b49d";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "1yp71islikmgmzlg3hfwih9cfca0k9lmb3bz7yv1v54vk34lq118";
    propagatedBuildInputs = [ reflectwalk ];
  };

  core = buildFromGitHub {
    version = 2;
    rev = "v0.5.6";
    owner = "go-xorm";
    repo = "core";
    sha256 = "0mrywfw7npvfz052rkkzvxgcjdp9azmh5dk36rzaj1i0yyhs06i9";
  };

  cors = buildFromGitHub {
    version = 2;
    owner = "rs";
    repo = "cors";
    rev = "v1.0";
    sha256 = "018bf66d3425cffafa913e6ebf4d5ba26a5c22313e041140ed177921b53e4852";
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
    buildInputs = [
      net
    ];
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
    version = 1;
    rev = "1.0.0";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "13kjgqx5bs187fapqiirsaig950n2is0a35y2b7ap07dazxxxh3m";
  };

  dbus = buildFromGitHub {
    version = 2;
    rev = "4b24ebee04561bf8a3bcc09aead82062edc56778";
    owner = "godbus";
    repo = "dbus";
    sha256 = "19jm3lmg0pv2bylhha64i7ygq26w3kmmh2nmpbbk7gxlgzvlm201";
    date = "2016-12-02";
  };

  decimal = buildFromGitHub {
    version = 2;
    rev = "d6f52241f332c63811249bd79a522406bea1a7c9";
    owner  = "shopspring";
    repo   = "decimal";
    sha256 = "1m94f3410nnp439gjfgysalmgz87p1kdwr9xrkzmc9ka8gwmszy2";
    date = "2016-09-18";
  };

  distribution = buildFromGitHub {
    version = 2;
    rev = "v2.5.1";
    owner = "docker";
    repo = "distribution";
    sha256 = "0qygqdf8myy0cmd28bfp5vil9aslrhdsc0wn8h90pfjjg5msabxh";
  };

  distribution_engine-api = buildFromGitHub {
    inherit (distribution) rev owner repo sha256 version;
    subPackages = [
      "digest"
      "reference"
    ];
  };

  dns = buildFromGitHub {
    version = 2;
    rev = "00b8eaaab9411e1ff61e5030ef7e58bed412ad2a";
    date = "2016-12-27";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0ifsbxykjy5vzsnfc3gag16xg17lhc0nxabhf5v9zjc905gr632x";
  };

  weppos-dnsimple-go = buildFromGitHub {
    version = 1;
    rev = "65c1ca73cb19baf0f8b2b33219b7f57595a3ccb0";
    date = "2016-02-04";
    owner  = "weppos";
    repo   = "dnsimple-go";
    sha256 = "0v3vnp128ybzmh4fpdwhl6xmvd815f66dgdjzxarjjw8ywzdghk9";
  };

  dnspod-go = buildFromGitHub {
    version = 2;
    rev = "f6b1d56f1c048bd94d7e42ac36efb4d57b069b6f";
    owner = "decker502";
    repo = "dnspod-go";
    sha256 = "0ylbl4dy0xjkkp82qld7fdqbyxjgw4l8ny2v1jjvl3fgp16fagv4";
    date = "2016-08-21";
  };

  docker = buildFromGitHub {
    version = 2;
    rev = "5374d53322abd6a5b2ebb34b7422abc26d1b5eb3";
    owner = "docker";
    repo = "docker";
    sha256 = "1m4vpkj4gjin7xh5msg2byp12ypxp7qawa96m666ca9r9a60vlyr";
    meta.useUnstable = true;
    date = "2016-12-30";
  };

  docker_for_runc = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
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
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "api/types"
      "api/types/blkiodev"
      "api/types/container"
      "api/types/filters"
      "api/types/mount"
      "api/types/strslice"
      "api/types/swarm"
      "api/types/versions"
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/idtools"
      "pkg/integration/cmd"
      "pkg/ioutils"
      "pkg/jsonlog"
      "pkg/jsonmessage"
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
    ];
    propagatedBuildInputs = [
      check
      engine-api
      go-units
      logrus
      net
      runc
    ];
  };

  docker_for_teleport = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "pkg/term"
    ];
  };

  docopt-go = buildFromGitHub {
    version = 1;
    rev = "0.6.2";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "11cxmpapg7l8f4ar233f3ybvsir3ivmmbg1d4dbnqsr1hzv48xrf";
  };

  du = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "du";
    sha256 = "02gri7xy9wp8szxpabcnjr18qic6078k213dr5k5712s1pg87qmj";
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
    date = "2016-12-23";
    rev = "9cafd4d729eb71b31ef7851a8c8f6ceb855d0915";
    sha256 = "0rvd5mgfayd23q1xz77rv06pxjw7sdscif2wdpj2vzggzzk64k0q";
  };

  ed25519 = buildFromGitHub {
    version = 1;
    owner = "agl";
    repo = "ed25519";
    rev = "278e1ec8e8a6e017cd07577924d6766039146ced";
    sha256 = "0jsscj4n6wcp3zyphinr461kwkxgrx5365jymbqnhqzki759xm5h";
    date = "2015-08-30";
  };

  egoscale = buildFromGitHub {
    version = 2;
    rev = "ab4b0d7ff424c462da486aef27f354cdeb29a319";
    date = "2016-09-22";
    owner  = "pyr";
    repo   = "egoscale";
    sha256 = "d4eb223131b97f9048d32ee26741e4c4be409e80a23e39d1f0d01c2c7a19c8db";
    meta.autoUpdate = false;
    subPackages = [
      "src/egoscale"
    ];
  };

  elastic_v2 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v2.0.54";
    sha256 = "9360c71601d67abd5b611ff6221ad92d02985d555046c874af61ef1d9bdb7fb7";
    goPackagePath = "gopkg.in/olivere/elastic.v2";
  };

  elastic_v3 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v3.0.59";
    sha256 = "dc2549cfdb71d8cbd901d339f3bb8a8844eede858f96842661986e990735aade";
    goPackagePath = "gopkg.in/olivere/elastic.v3";
    propagatedBuildInputs = [
      net
    ];
    meta.autoUpdate = false;
  };

  elastic_v5 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v5.0.13";
    sha256 = "dbff20655c7e4d5533dd8048006fa8fda2896b9dcce35a7549d1dc3f3228b3a9";
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
    rev = "601d0e278ceda9aa2085a61c9265f6e690ef5255";
    date = "2016-07-27";
    sha256 = "f3497a95d1638bfe22afc275e308a51626ca206a69675b6d5d48ca81297d0ebf";
    meta.useUnstable = true;
  };

  emoji = buildFromGitHub {
    version = 2;
    owner = "kyokomi";
    repo = "emoji";
    rev = "v1.5";
    sha256 = "0m41n13m8r0i6b75zv297fg6bdd82vrz3klxlkc855is079i0v4f";
  };

  encoding = buildFromGitHub {
    version = 2;
    owner = "jwilder";
    repo = "encoding";
    date = "2016-09-27";
    rev = "4dada27c33277820fe35c7ee71ed34fbc9477d00";
    sha256 = "14xlhzr94x0qyrik05ijfjxpcbnnda8rhndgm02kfh2fi5kqk37z";
  };

  engine-api = buildFromGitHub {
    version = 1;
    rev = "v0.4.0";
    owner = "docker";
    repo = "engine-api";
    sha256 = "1cgqhlngxlvplp6p560jvh4p003nm93pl4wannnlhwhcjrd34vyy";
    propagatedBuildInputs = [
      distribution_engine-api
      go-connections
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
    version = 2;
    owner = "pkg";
    repo = "errors";
    rev = "v0.8.0";
    sha256 = "00fi35kiry67anhr4lxryyw5l9c26xj2zc5wzspr4z39paxgb4km";
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
    version = 2;
    owner = "coreos";
    repo = "etcd";
    rev = "v3.0.15";
    sha256 = "005ljymp3awc6amfw432g80w5xvxlamf07135mmf562dwlvkzmpa";
    buildInputs = [
      bolt
      btree
      urfave_cli
      clockwork
      cobra
      cmux
      gopcap
      go-humanize
      go-semver
      go-systemd
      groupcache
      grpc
      grpc-gateway
      loghisto
      net
      pb_v1
      pflag
      pkg
      probing
      procfs
      prometheus_client_golang
      pty
      gogo_protobuf
      speakeasy
      tablewriter
      ugorji_go
      yaml

      pkgs.libpcap
    ];
  };

  etcd_client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256 version;
    subPackages = [
      "client"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
    ];
    buildInputs = [
      go-systemd
      net
    ];
    propagatedBuildInputs = [
      pkg
      ugorji_go
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

  fileutil = buildFromGitHub {
    version = 2;
    date = "2016-12-22";
    rev = "e618435e3202890725c12ccff676e9e3b2592c71";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "1da5lhaq1fjd9rxhdr82namrpfmydj5sry5jm1r0v0ism68mbbj2";
    buildInputs = [
      mathutil
    ];
  };

  flagfile = buildFromGitHub {
    version = 2;
    date = "2016-10-12";
    rev = "25bbc4d62e1d1375f0dbd5a506cee7b79d7b1fc5";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "1sigrak391jz5f4zv1scnhwkmg9dzxszf0wymhi8dpz018kmj8s7";
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
    rev = "cb2da332d00cbc04e4f3f677520dc3e7cc11874b";
    date = "2016-11-29";
    sha256 = "06fbr2yjnzgqcbscg09csjvbk9zxszwvmmfib8k4vqwwvpj1iq58";
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
    date = "2016-11-07";
    rev = "da06d194a00e19ce00d9011a13931c3f6f6887c7";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "0qsrkf0pcf2rx086flz6p9ifcmxdkhgx7jki88w17hh3rsj39ay7";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
  };

  genproto = buildFromGitHub {
    version = 2;
    date = "2016-12-16";
    rev = "b3e7c2fb04031add52c4817f53f43757ccbf9c18";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "0b5lazz720bx1yfk3zkq1rh2bznfcwksd4dxng5x4dbkfj9lbsyr";
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

  geoip2-golang = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "1kpc4cmfr95rml0xbb57md860qf0n544vh2s1gcwq8y7r6ihac23";
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
    rev = "e185767ab450dd717718019ebe6115112af5c575";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "1zx8blg917c9nlklahcgiryivpyn4jab3xym1hq8x2inaffn6cfs";
    date = "2016-12-20";
  };

  gjson = buildFromGitHub {
    version = 2;
    owner = "tidwall";
    repo = "gjson";
    date = "2016-12-16";
    rev = "e3f249f4fdf33c278edeb770426a6f83c954ae64";
    sha256 = "1jhykszg4cwlvx0f1bhvsjwafyrwkhfx6wjhfkfwvqlyrjliqd03";
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
    version = 2;
    date = "2016-10-05";
    rev = "1e9ce2a5ac4092fdf61e293634e40bfb49595105";
    owner = "siddontang";
    repo = "go";
    sha256 = "0gvvbvpk9yn24lhg4fzncwrs32awmll8s27qvsz2an0lvscqbhcz";
  };

  ugorji_go = buildFromGitHub {
    version = 2;
    date = "2016-11-30";
    rev = "9c7f9b7a2bc3a520f7c7b30b34b7f85f47fe27b6";
    owner = "ugorji";
    repo = "go";
    sha256 = "0cn3sc177kvxdmlnd4l2iyrvvdcc1hf9hra05k5hflc0cbwxszvr";
    goPackageAliases = [ "github.com/hashicorp/go-msgpack" ];
  };

  go-acd = buildFromGitHub {
    version = 2;
    owner = "ncw";
    repo = "go-acd";
    rev = "7954f1fad2bda6a7836999003e4481d6e32edc1e";
    date = "2016-11-17";
    sha256 = "fa27c7949aec70f33862ff626c1b8c32de2289000e6fd003396d1e17d2c0457e";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  go4 = buildFromGitHub {
    version = 2;
    date = "2016-11-18";
    rev = "09d86de304dc27e636298361bbfee4ac6ab04f21";
    owner = "camlistore";
    repo = "go4";
    sha256 = "1kmgqki7qp8mrhn8n7lrwy25w53farczvbk6yjvx2bqa6v50wbia";
    goPackagePath = "go4.org";
    goPackageAliases = [ "github.com/camlistore/go4" ];
    buildInputs = [
      google-cloud-go
      oauth2
      net
      sys
    ];
  };

  goamz = buildFromGitHub {
    version = 2;
    rev = "fb002ae75f50beb93874fa6ce2c861e488ce08a0";
    owner  = "goamz";
    repo   = "goamz";
    sha256 = "16z3wf5sii3cgrkccm6mijg6i028rlyf3212s0zs20az9wak4pvv";
    date = "2016-09-17";
    goPackageAliases = [
      "github.com/mitchellh/goamz"
    ];
    excludedPackages = "testutil";
    buildInputs = [
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
      version = 1;
      inherit rev;
      owner  = "ww";
      repo   = "goautoneg";
      sha256 = "9acef1c250637060a0b0ac3db033c1f679b894ef82395c15f779ec751ec7700a";
    };

    meta.autoUpdate = false;
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
    version = 2;
    rev = "5d087d1f0cd04ad126a3b2642b041d8f4a750677";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "1wbwsq2ig4hjr4fjs3kmbkq7pndrxp3qspxzj6qsi9gfi49v564n";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2016-12-29";
  };

  gojsonpointer = buildFromGitHub {
    version = 1;
    rev = "e0fe6f68307607d540ed8eac07a342c33fa1b54a";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "1gm1m5vf1nkg87qhskpqfyg9r8n0fy74nxvp6ajcqb04v3k8sd7v";
    date = "2015-10-27";
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
    version = 2;
    rev = "59f99ebfe5f712a0055e321231fc3be94e4e00b2";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "128qvk0rahairbvnn137f0a1b0909dyv0348lhgfri5xz54fjwaj";
    date = "2016-12-15";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gollectd = buildFromGitHub {
    version = 2;
    owner = "kimor79";
    repo = "gollectd";
    rev = "v1.0.0";
    sha256 = "16ax20j3ji6zqxii16kinvgrxb0xjn9qhfhhiin7k40w0aas5dhi";
  };

  gomemcache = buildFromGitHub {
    version = 2;
    rev = "2fafb84a66c4911e11a8f50955b01e74fe3ab9c5";
    date = "2016-11-27";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "0hnj6006w196i2vqa3agw9rwxx91in7s1m0bq9x5kdlwjyx6sx1d";
  };

  gomemcached = buildFromGitHub {
    version = 2;
    rev = "832858c5df7b06c4d1df2b0d98e0a4213416a500";
    date = "2016-12-01";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "010qdrrrzyj74jj21riamq1p1s8cra58syy8vjy66jl8mi18b4w7";
    propagatedBuildInputs = [
      goutils_logging
    ];
  };

  gopacket = buildFromGitHub {
    version = 2;
    rev = "v1.1.12";
    owner = "google";
    repo = "gopacket";
    sha256 = "0bgmj6njrqcb6rzcm915mgy0j9cf0r51ha0gnxvqvkak6fs2xa0m";
    buildInputs = [
      pkgs.libpcap
      pkgs.pf-ring
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 2;
    date = "2016-12-26";
    rev = "e0ba5081473dca0a69826693dca7f03fc0e3d086";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "0qa1q6141f7rg1i8nm2bljcb83sbc31ld58x1h902q4833glzymp";
    goPackagePath = "cloud.google.com/go";
    goPackageAliases = [
      "google.golang.org/cloud"
    ];
    propagatedBuildInputs = [
      debug
      gax-go
      genproto
      geo
      google-api-go-client
      grpc
      net
      oauth2
      protobuf
      time
    ];
    postPatch = ''
      sed -i 's,bundler.Close,bundler.Stop,g' logging/logging.go
    '';
    excludedPackages = "oauth2";
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

  goreq = buildFromGitHub {
    version = 1;
    rev = "fc08df6ca2d4a0d1a5ae24739aa268863943e723";
    date = "2016-05-07";
    owner = "franela";
    repo = "goreq";
    sha256 = "152fmchwwwgyg16i79vl09cyid8ry3ddhj09nzx2xrfg5632sn7s";
  };

  goterm = buildFromGitHub {
    version = 2;
    rev = "cc3942e537b1ab00de92d348c40acbfa6565d20f";
    date = "2016-11-03";
    owner = "buger";
    repo = "goterm";
    sha256 = "0m7q1bccdjgijhrq056rs8brizrvsiyr8k0iphprs8wmlr0hz5vi";
  };

  goutils = buildFromGitHub {
    version = 1;
    rev = "5823a0cbaaa9008406021dc5daf80125ea30bba6";
    date = "2016-03-10";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "0053nk5jhn3lcwb8sg2bv39gy841ldgcl3cnvwn5mmx3658il0kn";
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
    version = 2;
    rev = "7ff34179c702c0520311e1a68e01ce3aa1d21cb1";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "1f83b2canzy3kp0msjysl70vkkcy8b3wq6gpf4dmzb9jqdvcgj2y";
    date = "2016-11-14";
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
    rev = "23851d93a2292dcc56e71a18ec9e0624d84a0f65";
    date = "2016-12-27";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "04s0jnc4pz33b3bqbqypbdfxa7424wnwcxxy0hsmwm9fa6r32jas";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    version = 2;
    rev = "f1f0f388b31eca4e2cbe7a6dd8a3a1dfddda5b1c";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "1h704v86dbspva6haf0cj99l5izr679dl3792gwy9wb6wahdix3r";
    propagatedBuildInputs = [
      protobuf
      yaml_v2
    ];
    date = "2016-11-18";
  };

  google-api-go-client = buildFromGitHub {
    version = 2;
    rev = "55146ba61254fdb1c26d65ff3c04bc1611ad73fb";
    date = "2016-12-12";
    owner = "google";
    repo = "google-api-go-client";
    sha256 = "0q2bkjypjbjrkl5zjwbhr829ni74fzm16qxs8id1y5l1a1qgbl95";
    goPackagePath = "google.golang.org/api";
    buildInputs = [
      genproto
      grpc
      net
      oauth2
    ];
  };

  gopass = buildFromGitHub {
    version = 2;
    date = "2016-10-03";
    rev = "f5387c492211eb133053880d23dfae62aa14123d";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0cjbnrbv0fa09jgvmwszs9cphk6vn31kcpysvxfsyfzg9bfiannf";
    propagatedBuildInputs = [
      crypto
    ];
  };

  gopsutil = buildFromGitHub {
    version = 2;
    rev = "v2.16.11";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "0wyyq28ya6mk9ff4q1yl7vzbk286k35w1y5xr9x0jk5x0icd7qy9";
  };

  goquery = buildFromGitHub {
    version = 2;
    rev = "v1.0.2";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "1n57fwiyv1ndf5d21ns6q7i08qvwirpgrpsy9fvap3r0wnkdja59";
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
    version = 2;
    rev = "3b2665001c4c24e3b076d1ca8c428049ecbb925b";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "0q1clznbxa4izis823fl7hxjcjggnzamc44xnhkj7b5li7n8dj90";
    date = "2016-12-27";
  };

  go-autorest = buildFromGitHub {
    version = 2;
    rev = "v7.2.2";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "1632kfmg873i58cx1fvjfx4lil2cywqq8v6lnqjln3ipwrhwkl6q";
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
    version = 1;
    rev = "9a6736ed45b44bf3835afeebb3034b57ed329f3e";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "1hm0sbnbqaw7f847i6ynwz6b92xv6v46lpwpbql9nv8w1kp1q9y5";
    date = "2016-08-22";
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
    date = "2016-01-24";
    rev = "df1e16fde7fc330a0ca68167c23bf7ed6ac31d6d";
    sha256 = "f70b9d9ee10b67102fb76c75935289cca6eda7c741b6517c25fa1a8b1dfd5198";
  };

  go-cache = buildFromGitHub {
    version = 2;
    rev = "e7a9def80f35fe1b170b7b8b68871d59dea117e1";
    owner = "patrickmn";
    repo = "go-cache";
    sha256 = "17zkd2lyjfp8rzn3z0d59rbjbkv5w5c7wsb7h33d81rrlj9af7ai";
    date = "2016-11-25";
  };
  go-checkpoint = buildFromGitHub {
    version = 1;
    date = "2016-08-16";
    rev = "f8cfd20c53506d1eb3a55c2c43b84d009fab39bd";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "066rs0gbflz5jbfpvklc3vg5zs7l1fdfjrfy21y4c4j5vkm49gz5";
    buildInputs = [ go-cleanhttp ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 1;
    date = "2016-04-07";
    rev = "ad28ea4487f05916463e2423a55166280e8254b5";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "1knpnv6wg2fnnsk2h2bj4m003f7xsvwm58vnn9gc753mbr78vx00";
  };

  go-collectd = buildFromGitHub {
    version = 2;
    owner = "collectd";
    repo = "go-collectd";
    rev = "v0.3.0";
    sha256 = "0dzs6ia5y3dc6vcdqv7llgxj381jdpl17kbjgn0ncggshxly4zhf";
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
  };

  go-colorable = buildFromGitHub {
    version = 1;
    rev = "v0.0.6";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "08iwf0p0jyqcwk82vb9shqlhphhz94pdb395gpacz9r76fk5iqhq";
  };

  go-connections = buildFromGitHub {
    version = 1;
    rev = "v0.2.1";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "07rcj6rhps7jg9yywy5328zcqnxakqhbiv5vscsfjz3c021rzcgf";
    propagatedBuildInputs = [
      logrus
      net
      runc
    ];
  };

  go-couchbase = buildFromGitHub {
    version = 2;
    rev = "bfe555a140d53dc1adf390f1a1d4b0fd4ceadb28";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "06knznii3y7vyadc3rzirbgmvxq325dg7p68w5krx5nwncw99xnv";
    date = "2016-12-28";
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
    version = 2;
    rev = "df314da3158786e5ea7ae99889366febe828fbd7";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "0vs1zfvxs9iqpdh9dx3xs5448plrl9wdja6c4jym0rlh6dwni97k";
    date = "2016-12-07";
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

  go-dockerclient = buildFromGitHub {
    version = 2;
    date = "2016-12-15";
    rev = "4a934a8fd3ec3d4f84d9dcd8b47e7b277918c366";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "06b9n53rbcj6v11sy6ijsdba0qx1airf218wiv17da71d0j8fnn2";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      mux
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

  go-flags = buildFromGitHub {
    version = 2;
    rev = "v1.1";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0bha0a59akal9apycvrv0wq4gdsfh5hz5439rb4arbny0kvb9529";
  };

  go-floodsub = buildFromGitHub {
    version = 2;
    rev = "805e5f0bd5e4c61046678287f00d66879b4ae4a4";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "1ih8ds45ag6chv0wd2manbi7is574hd7p7p6qmcrw7bdph3jdcvd";
    date = "2016-12-28";
    propagatedBuildInputs = [
      gogo_protobuf
      go-libp2p-host
      go-libp2p-net
      go-libp2p-peer
      go-log
      timecache
    ];
  };

  go-getter = buildFromGitHub {
    version = 2;
    rev = "2fbd997432e72fe36060c8f07ec1eaf98d098177";
    date = "2016-09-12";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "0sp59zf5jqbhvk81n0blbz5ddz30173m3zx57m12sqizr9zvvis9";
    propagatedBuildInputs = [
      aws-sdk-go
      go-homedir
      go-netrc
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
    version = 2;
    date = "2016-12-29";
    rev = "90861904aa86352a956f91ba0664df93a3547584";
    owner = "google";
    repo = "go-github";
    sha256 = "1mv7gr42f6kd77i1w13ilhxjmhszm3vsrvyddjpj5ja0xx0q8j6c";
    buildInputs = [ oauth2 ];
    propagatedBuildInputs = [ go-querystring ];
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
    version = 2;
    owner = "minio";
    repo = "go-homedir";
    date = "2016-02-15";
    rev = "0b1069c753c94b3633cc06a1995252dbcc27c7a6";
    sha256 = "0e595179466b94fcf18515a1791319cbfdd60b3e12b06dfc2cc7778a79a201c7";
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
    version = 1;
    owner = "yosssi";
    repo = "gohtml";
    rev = "ccf383eafddde21dfe37c6191343813822b30e6b";
    date = "2015-09-23";
    sha256 = "1ccniz4r354r2y4m2dz7ic9nywzi6jffnh44dy6icyqi64v9ydw7";
    propagatedBuildInputs = [
      net
    ];
  };

  go-humanize = buildFromGitHub {
    version = 2;
    rev = "ef638b6c2e62b857442c6443dace9366a48c0ee2";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "0x0ig32p0xv6kb504x0dq0nn0afgk9nhy92js10gd20zr2qm83zr";
    date = "2016-12-02";
  };

  go-i18n = buildFromGitHub {
    version = 2;
    rev = "v1.7.0";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "1pgmg111sqjhih87jpqmks7pf99byi1r40q5rzpwqwvsww428gh6";
    buildInputs = [
      yaml_v2
    ];
  };

  go-immutable-radix = buildFromGitHub {
    version = 1;
    date = "2016-06-08";
    rev = "afc5a0dbb18abdf82c277a7bc01533e81fa1d6b8";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1yyhag8vnr7vi4ak2rkd651k9h8221dpdsqpva95zvf9nycgzlsd";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ini = buildFromGitHub {
    version = 1;
    rev = "a98ad7ee00ec53921f08832bc06ecf7fd600e6a1";
    owner = "vaughan0";
    repo = "go-ini";
    sha256 = "07i40hj47z5m6wa5bzy7sc2na3hbwh84ridl40yfybgdlyrzdkf4";
    date = "2013-09-23";
  };

  go-ipfs-api = buildFromGitHub {
    version = 2;
    rev = "4cadfedb1a3f22fe8dc8f38f2d317ac9d92e98b5";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "1jipziy8ddvxbx894aw5xnawpkqwiyhn9vywzkxa1s9bizdbd80x";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-floodsub
      go-multiaddr
      go-multiaddr-net
      go-multipart-files
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2016-12-11";
  };

  go-ipfs-util = buildFromGitHub {
    version = 2;
    rev = "70eede8dce2a98e86bb760247702e4e9b23139bb";
    owner  = "ipfs";
    repo   = "go-ipfs-util";
    sha256 = "0lbp58z0w4fxagicq66lq8jdc38f4cqp6bmsgqfrsg971k0dy7cd";
    date = "2016-10-04";
    buildInputs = [
      go-base58
      go-multihash
    ];
  };

  go-isatty = buildFromGitHub {
    version = 2;
    rev = "30a891c33c7cde7b02a981314b4228ec99380cca";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "06m7qccpnd9vhhqz6cajn5xb6wddfwk9n537qma8gxbdlx4x07m0";
    date = "2016-11-23";
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
    meta.autoUpdate = false;
  };

  go-jose_v2 = buildFromGitHub {
    version = 2;
    rev = "v2.0.1";
    owner = "square";
    repo = "go-jose";
    sha256 = "08f0p394pxn36qhb856lbnkdf950p9sr9avddanhgmd5yh6caxvp";
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
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-crypto";
    date = "2016-10-17";
    rev = "d9387cd9d7519fe0a5b0974b79db3b15417ac246";
    sha256 = "1xrfa4v08dns58jj8hpg7pwhsjkqi0qk9d5fzwb1d2zacsn7i737";
    propagatedBuildInputs = [
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
    date = "2016-11-17";
    rev = "160b4e479a07f6257595f6c152936a5a80f4a56a";
    sha256 = "0h9jwarab2l9p86bgp4061hjya5hphy8griz8fqkzdsifvawmcz9";
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
    date = "2016-11-03";
    rev = "e229506a1c0f193cf8ba5f9f35f40f6ef50e0d12";
    sha256 = "0aa15b5aqwy4h3n22pi3bw51i2m4pm7r293hp9g81apd98wcyfbi";
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
    date = "2016-11-17";
    rev = "3e063c4154c3ba66314e2734673cbf33eebfe817";
    sha256 = "0z74gw9di93xzw5pahybbhj3rzfk8svswdydi62pgnn4vx1d0nxx";
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
    date = "2016-11-02";
    rev = "668f732449f75e719b369a04998e048597f786cf";
    sha256 = "0xq6pxxv5c8qklf2mrkqyy7m257h8pni7kldd2pylpwk9lg95y3b";
    propagatedBuildInputs = [
      go-base58
      go-ipfs-util
      go-libp2p-crypto
      go-log
      go-multihash
    ];
  };

  go-libp2p-peerstore = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-peerstore";
    date = "2016-11-17";
    rev = "63b884f50774b52336796d85f0b418ff5a99b128";
    sha256 = "1s83sdq64sh6kr5ybb5dql4svg1npwgn9n88pyiyjb7flz3lli6m";
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
    date = "2016-12-07";
    rev = "781e60ebcf259c8c6a12638b89f92c5d4df06086";
    sha256 = "18g3f32cn4jmif1rnyizhy8iw5h91cv088i5daqnd8pb0hbprdv5";
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
    date = "2016-09-03";
    rev = "7c24d3c8b0889a7091d7f3618b9ad32b575db2c6";
    sha256 = "0xvgrj61mi3g1i4kp10836wmvg1k8rgngh7c82w266x7lyg7w00s";
    propagatedBuildInputs = [
      whyrusleeping_go-logging
    ];
  };

  whyrusleeping_go-logging = buildFromGitHub {
    version = 2;
    owner = "whyrusleeping";
    repo = "go-logging";
    date = "2016-12-07";
    rev = "0a5b4a6decf577ce8293eca85ec733d7ab92d742";
    sha256 = "057iwrmlhjnr4w9f9nhndicldv8h4007rxblr7l16rpkbski00wb";
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
    version = 2;
    rev = "82a07a67a43089687c0cc71ad515cde8d8ae3b8f";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "0ymzsbfp7bw7zghj70yywyl99ccpjw6y1chzymc1jp5x4xakbb31";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2016-11-26";
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
    date = "2016-10-04";
    rev = "d9f56211111ad200d4a1fb404c784870a89a0706";
    sha256 = "14akw6zwx6i8x8azl64h05hlzidnhh7a6jdz4jq14mz1fhc78cm6";
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-net
    ];
  };

  go-md2man = buildFromGitHub {
    version = 2;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "v1.0.6";
    sha256 = "1i67z76plrd7ygk66691bgarcx5kfkf1ryvcwdaa099hbliwbai8";
    propagatedBuildInputs = [
      blackfriday
    ];
  };

  go-memdb = buildFromGitHub {
    version = 2;
    date = "2016-12-16";
    rev = "cb9a474f84cc5e41b273b20c6927680b2a8776ad";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "10wqzlzlmv04gk44fanqlw4fg3q9xj2hi4pa7fzrwyhpadf4dpij";
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
    date = "2016-11-04";
    rev = "97c69685293dce4c0a2d0b19535179bbc976e4d2";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "075bz3ibx6i8mdlkvclnh035fpqrq6ymwcb7jj85ldr6fb7y08p3";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
      prometheus_client_golang
    ];
  };

  go-mssqldb = buildFromGitHub {
    version = 2;
    rev = "aa91b9def474faafb2406c8b562ae1e0e1f89ea4";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "1mfk83wbwx9z8zr2wn4dzvbvqi2ys2pb5yn2inf36rvsjpmd24b3";
    date = "2016-12-15";
    buildInputs = [
      crypto
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 2;
    rev = "3fb0c32e7a4ac7b6340124b1cbfc39e695e1ce63";
    date = "2016-12-17";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "1y2297s7j1gf36gf95mmzvd2dzy2ji4fiw1jd45v232jm76dr6xj";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 2;
    rev = "4b637b03a2bb30b478bba717cafdfebbe8e1f9ae";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "19kpc74jwnb44q15x2kz7vkkqav58ygfzs0kf8k6vzg3d1sdkcaq";
    date = "2016-10-14";
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
    propagatedBuildInputs = [ errwrap ];
  };

  go-multihash = buildFromGitHub {
    version = 2;
    rev = "5be2115933c26c6ae0c4b9c5887a44d8ae5bb753";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "0qj0pkjqpdadsh0c20mvgfwd8mx4dprb5c97i063bsrk9jyxsdy6";
    goPackageAliases = [ "github.com/jbenet/go-multihash" ];
    propagatedBuildInputs = [
      crypto
      go-base58
    ];
    date = "2016-12-12";
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
    rev = "b4a4ad9422aa66c32dce09d8d0fa15587d5f67b2";
    date = "2016-11-10";
    owner  = "whyrusleeping";
    repo   = "go-multistream";
    sha256 = "1s3ihslb48wynn4pnj1g2bl68w4xg55gdxrrn81pldibnrm4k26v";
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
    version = 2;
    date = "2016-12-28";
    rev = "9e117111587506b9dc83b7b38263268bf48352ea";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "1yycxr9wraxaxv5w0hy4s0q6z02al6s6j9i94sd6ks5fmxq72j8v";
    propagatedBuildInputs = [
      cachecontrol
      clockwork
      go-jose_v2
      net
      oauth2
      pkg
    ];
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
    rev = "a8a4c0bc40e56322142649bda7b2b4bb15145b6e";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "1vwilqd283sqlk4s1jva62hwlvj1fpfzja8sy9alvpf9p7p0fc2p";
    date = "2016-12-26";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-plugin = buildFromGitHub {
    version = 1;
    rev = "8cf118f7a2f0c7ef1c82f66d4f6ac77c7e27dc12";
    date = "2016-06-07";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "1mgj52aml4l2zh101ksjxllaibd5r8h1gcgcilmb8p0c3xwf7lvq";
    buildInputs = [ yamux ];
  };

  go-ps = buildFromGitHub {
    version = 1;
    rev = "e2d21980687ce16e58469d98dcee92d27fbbd7fb";
    date = "2016-08-22";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "0b7rlp5ic60d4a9ibchxxb6i2lc4ish9nwwxr0p57wmlbjbq3lbf";
  };

  go-python = buildFromGitHub {
    version = 2;
    owner = "sbinet";
    repo = "go-python";
    date = "2016-08-09";
    rev = "ac4579f132fff506b2f6b3eda4c9282b4be59a08";
    sha256 = "034c9b58c1ef250eff9a46c9ac743014df110f11fa8f580033767907bfbe2750";
    nativeBuildInputs = [
      pkgs.pkgconfig
    ];
    buildInputs = [
      pkgs.python2Packages.python
    ];
  };

  go-querystring = buildFromGitHub {
    version = 1;
    date = "2016-03-10";
    rev = "9235644dd9e52eeae6fa48efd539fdc351a0af53";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "0c0rmm98vz7sk7z6a1r07dp6jyb513cyr2y753sjpnyrc28xhdwg";
  };

  go-radix = buildFromGitHub {
    version = 1;
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  go-reap = buildFromGitHub {
    version = 2;
    rev = "04ce4d0638f3b39b8a8030e2a22c4c90771fa5d6";
    owner  = "hashicorp";
    repo   = "go-reap";
    sha256 = "023ca78dmnwzd0g0yvrbznznmdjix36cang5wp7x054ihws8igd6";
    date = "2016-09-01";
    propagatedBuildInputs = [ sys ];
  };

  go-retryablehttp = buildFromGitHub {
    version = 2;
    rev = "6e85be8fee1dcaa02c0eaaac2df5a8fbecf94145";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "1fssinl8qxdmg3b6wvbyd44p473fbkb03wi792bhqaq15jmysqqy";
    date = "2016-09-29";
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
  };

  go-runewidth = buildFromGitHub {
    version = 2;
    rev = "737072b4e32b7a5018b4a7125da8d12de90e8045";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "15p7kn0wccmd3ynndhxqp536lzmb4ckc48gld16xmhhl00sy3x0a";
    date = "2016-10-12";
  };

  go-semver = buildFromGitHub {
    version = 2;
    rev = "v0.2.0";
    owner  = "coreos";
    repo   = "go-semver";
    sha256 = "0fmah32srkcsrz14mxkx2drry0kcrykhr1ks78qmh98i91nmkpbw";
  };

  go-shellwords = buildFromGitHub {
    version = 2;
    rev = "525bedee691b5a8df547cb5cf9f86b7fb1883e24";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "0ch7f3128mac8ymfh15p2nrsis5472h9yr6dzwmmc6dbcslpvfk1";
    date = "2016-03-15";
  };

  go-simplejson = buildFromGitHub {
    version = 1;
    rev = "v0.5.0";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "09svnkziaffkbax5jjnjfd0qqk9cpai2gphx4ja78vhxdn4jpiw0";
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
    version = 2;
    rev = "8c1d0dc39fc953224ecaa6946f9198ee99c7977b";
    owner  = "hashicorp";
    repo   = "go-sockaddr";
    sha256 = "0myp9crfj2mpcccb89s5nh1v4860klz2qsblbh87f78caacifh08";
    date = "2016-12-21";
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
    rev = "7c9533367ef925dc1078d75e5b7141e10da2c4e8";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "0xaysdjh37nb1ay9cppxascjrs9w77w4xib2l6kx3mfp441nmcjl";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2016-12-12";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 version date;
    subPackages = [
      "journal"
    ];
  };

  go-toml = buildFromGitHub {
    version = 2;
    owner = "pelletier";
    repo = "go-toml";
    rev = "v0.4.0";
    sha256 = "10xsqp69v6w0qqxb7xvj3bv2677xclvyakcvhqyx6fxc4p64727p";
    propagatedBuildInputs = [
      go-buffruneio
    ];
  };

  go-units = buildFromGitHub {
    version = 1;
    rev = "v0.3.1";
    owner = "docker";
    repo = "go-units";
    sha256 = "16qsnzrhdnr8p650558p7ml4v0lkxhfign2jkz6nsdx6s4q2gpnc";
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

  hashicorp-go-uuid = buildFromGitHub {
    version = 1;
    rev = "64130c7a86d732268a38cb04cfbaf0cc987fda98";
    date = "2016-07-16";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "072c84wn90di09qxrg0ml8vjfb5k10zk2n4k0rgxk1n45wyghkjx";
  };

  go-version = buildFromGitHub {
    version = 2;
    rev = "e96d3840402619007766590ecea8dd7af1292276";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "13jrvfmg7vx1zzsjbwyfaxh06y8si7f9drcpy0400pv9fv9fxfs7";
    date = "2016-10-31";
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
    rev = "v0.2.14";
    sha256 = "4a32bc0da7c70933937f20fa0cccd9b47c8fd583155b937b2ab8349998193ad1";
    propagatedBuildInputs = [
      http2curl
      net
    ];
  };

  grafana = buildFromGitHub {
    version = 2;
    owner = "grafana";
    repo = "grafana";
    rev = "v4.0.2";
    sha256 = "1nriwp0szc16mqfmsvn073gn9lszpc2p6qiwax7bcn8pirpnx8nx";
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
    date = "2016-12-16";
    rev = "d092608c065831f1984ac9d332ca5b2c95a11f57";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "0yqb2xli1jsyn168iisiq0parqrpfi59zvf9p9cs1mwpmvk0ivfk";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    version = 2;
    date = "2016-12-28";
    rev = "c8105071640ef29fce843ed96983e864bb18eb0e";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "0qv3dpaqjpbxasiikpmz8ghi1d6kdmal1ph5ig0ignh95kwschjr";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [
      "github.com/grpc/grpc-go"
    ];
    excludedPackages = "\\(test\\|benchmark\\)";
    propagatedBuildInputs = [
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
      net
      protobuf
    ];
    subPackages = [
      "."
      "codes"
    ];
  };

  grpc-gateway = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "1yrfg4pn053hv86aal8cr285cdnk20n7dzvvji9zsm9pp25d6jj3";
    propagatedBuildInputs = [
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
    rev = "v0.10.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "0kyx29qiijanbd3zrx239r1knzy5iglaj0gvsmy4d0kw7ai5isc4";
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
    rev = "v1.4.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "08yl5kvmxb2q21sxlnd8qn79bv3dp1v5jfpli7n32wqahix3rnzi";
    buildInputs = [
      urfave_cli
      fs
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
    version = 2;
    date = "2016-10-24";
    rev = "172fbbbb329cf7e031dd3ab35766186fc2081eab";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "1wd0n5qdprdjzpan5k22s3301vsbm28ri1m8x8dcs1b9f3z5cfxw";
  };

  handlers = buildFromGitHub {
    version = 2;
    owner = "gorilla";
    repo = "handlers";
    rev = "3a5767ca75ece5f7f1440b1d16975247f8d8b221";
    sha256 = "0v2bbgfwl9x3qrzfmmcd75klx8yndliq7anpzcigaijp8nlxlrzz";
    date = "2016-12-05";
  };

  hashstructure = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "b098c52ef6beab8cd82bc4a32422cf54b890e8fa";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "0zg0q20hzg92xxsfsf2vn1kq044j8l7dh82fm7w7iyv03nwq0cxc";
  };

  hcl = buildFromGitHub {
    version = 2;
    date = "2016-12-15";
    rev = "80e628d796135357b3d2e33a985c666b9f35eee1";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "0qcf1flvi3la6ka0fabif8zm4ai66n6n73nwklxd3n2mq053b5v5";
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
    version = 2;
    date = "2016-12-21";
    rev = "5b8d13c8c5c2753e109fab25392a1dbfa2db93d2";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "1gc7kw6bp3kaixqbaiga92ywhqs1mrdablp9297kgvbgnhdz44gn";
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
    date = "2015-03-19";
    rev = "38a7bb71b483e855d35010808143beaf05b67f9d";
    sha256 = "3a98569b08ed14b834fb91c7da0827c74ddec9d1c057356c9d9999440bd45157";
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

  http2curl = buildFromGitHub {
    version = 2;
    owner = "moul";
    repo = "http2curl";
    date = "2016-10-31";
    rev = "4e24498b31dba4683efb9d35c1c8a91e2eda28c8";
    sha256 = "1zzdplidhh77s20l6c51fqvrzppmkf830j7mxdv9lf7z5ry169sp";
  };

  httprouter = buildFromGitHub {
    version = 2;
    rev = "5dd70ee059943e81987a817fa1a755b11dd119c1";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "12xldx6zgx624mm3kqcvxgc654l7kd78rll1ylcwsl2f9ry0gjhi";
    date = "2016-12-03";
  };

  hugo = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "hugo";
    rev = "v0.18.1";
    sha256 = "1har5yv8411f9cyagfmc3dx635rfbwvr354vxdajs79qxv7cf5jr";
    buildInputs = [
      ace
      afero
      amber
      blackfriday
      cast
      cobra
      cssmin
      emoji
      go-i18n
      fsnotify
      fsync
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
    version = 2;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.1.1";
    sha256 = "0c5jcwgniqd2yai7pxmsx968i52r9144f8zg8hh3bcl1m81xg6mb";
    propagatedBuildInputs = [
      bolt
      gollectd
      crypto
      encoding
      go-bits
      go-bitstream
      go-collectd
      hllpp
      jwt-go
      liner
      pat
      pool_v2
      gogo_protobuf
      ratecounter
      snappy
      statik
      toml
      usage-client
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
    version = 2;
    rev = "v1.23.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "0jb3i0nivqnsybgsran6b0w35n97k40x48hdszi4xbiiw3b2n007";
  };

  ini_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.23.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "1x7a9g9njc5ggjvlzc08phpjpd3pkzl4z2fy24r75q3c3i17xfj5";
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

  iter = buildFromGitHub {
    version = 1;
    rev = "454541ec3da2a73fc34fd049b19ee5777bf19345";
    owner  = "bradfitz";
    repo   = "iter";
    sha256 = "0sv6rwr05v219j5vbwamfvpp1dcavci0nwr3a2fgxx98pjw7hgry";
    date = "2014-01-23";
  };

  ipfs = buildFromGitHub {
    version = 2;
    date = "2016-12-21";
    rev = "99d72c27818353eb2b9c05710a9a8eba87518323";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "0bq6ci1gbld1f2h4wdxppw74pzr73z8c9digqz199ilj4qakkdyi";
    gxSha256 = "0qg7yrjjski84wp9apzhd25v3ljkgxg1vl1hm6xnb392pnxx9qiw";
    subPackages = [
      "cmd/ipfs"
      "cmd/ipfswatch"
    ];
    nativeBuildInputs = [
      gx-go.bin
    ];
    # Prevent our Godeps remover from work here
    preConfigure = ''
      mv Godeps "$TMPDIR"
    '';
    postConfigure = ''
      mv "$TMPDIR/Godeps" "go/src/$goPackagePath"
    '';
    meta.useUnstable = true;
  };

  json-filter = buildFromGitHub {
    version = 1;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0y1d6yi09ac0xlf63qrzxsi7dqf10wha3na633qzqjnpjcga97ck";
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
    version = 1;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "33c24e77fb80341fe7130ee7c594256ff08ccc46";
    date = "2016-03-01";
    sha256 = "0w6risn5iwx9b0sn0f6z2yfs3p1gqa22asy3hkix1p81a1xmsidc";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
  };

  jwt-go = buildFromGitHub {
    version = 2;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "v3.0.0";
    sha256 = "0llmcxijl24gz6w75il6rnijc9gzda4byl5kwr4qnzpw9j0q87n9";
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
    rev = "v2.2.3";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "196087z4473psagd0n0wss12knqabcbh4iyikwcbiiw3hx4lx0ix";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    propagatedBuildInputs = [
      template
      units
    ];
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
    propagatedBuildInputs = [ asn1-ber ];
  };

  ledisdb = buildFromGitHub {
    version = 2;
    rev = "380835a0ca70929fb26d78f57444efaaf44abcac";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "1ang2ga75f5r28pp7n3avmyb6895fh1s42i79k0hyjc54456r0vp";
    date = "2016-11-24";
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
    version = 2;
    rev = "ce8fb060cb8361a9ff8b5fb7c2347fa907b6fcac";
    owner = "xenolf";
    repo = "lego";
    sha256 = "1961psx3cqyaz3c2qrmbbnv9q6kdnwqzkl5fc59ynpx9775qzhbi";

    buildInputs = [
      auroradnsclient
      aws-sdk-go
      azure-sdk-for-go
      urfave_cli
      crypto
      dns
      dnspod-go
      weppos-dnsimple-go
      egoscale
      go-autorest
      go-ini
      go-jose_v1
      go-ovh
      goamz
      google-api-go-client
      linode
      memcache
      ns1-go_v2
      oauth2
      net
      vultr
    ];

    subPackages = [
      "."
    ];
    date = "2016-12-27";
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

  liner = buildFromGitHub {
    version = 2;
    rev = "3c5f577f62ec95a012ea48a58dd4de3c48222a35";
    owner = "peterh";
    repo = "liner";
    sha256 = "1fwsa02az6y6mhybadqb3rxb7fxf5p5n381xgqrx5yz134mpd5vb";
    date = "2016-11-03";
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
    rev = "v1.0.5";
    owner  = "cznic";
    repo   = "lldb";
    sha256 = "167s53xghxy7xlxbpf4r48h7rz6yygaq4fqk1h5m5hhivh6vazsq";
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
  };

  log15 = buildFromGitHub {
    version = 2;
    rev = "46a701a619de90c65a78c04d1a58bf02585e9701";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "11fgndc0zjkm1zc1xzr7n1k3p6rkpfa0mykr2w2d995174idgvyi";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
    date = "2016-10-26";
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
    rev = "v0.11.0";
    owner = "Sirupsen";
    repo = "logrus";
    sha256 = "06kc8ss5nrshqkxjnz3b2rbzv4mwj0k9y1jrd29xxkqz0b86n605";
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
    rev = "lxd-2.7";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "01wjjxnfr6jn8xpvm381z5m38yyj1q08gkgjqg77ajan0msbq4kd";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-lxc_v2
      go-sqlite3
      go-systemd
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
    rev = "v1.1.11";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "1c03pdizyqn6q2c56fprmbvfg12wrd605251bfj5py96ag50i8w7";
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
    date = "2016-10-04";
    rev = "a3d8d9c3218bb91d3a21ab40fcd6c94d0c568f30";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "06l4yfi7xb2blmcqxi8zbjx4py3lhmk3lqyy3qhavggrly2w0gwg";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  mapstructure = buildFromGitHub {
    version = 2;
    date = "2016-12-11";
    rev = "bfdb1a85537d60bc7e954e600c250219ea497417";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "043hd3hglxxk080lqh2d653lfy6mbxgw1dsil3chg5hb5ljkwwv4";
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
    date = "2016-10-12";
    rev = "4609a45a9e61188d0d69a5d8ad42600c3df35002";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "02kbxfgnbyvczrcig2cgjf3b1lnd0365cny94wrxfdrcfxblzn30";
    buildInputs = [ bigfft ];
  };

  maxminddb-golang = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "0nwandjs965a9jx8ibki8c2caf7h4h9vy9i6z7c0lpb11lg1lzdm";
    propagatedBuildInputs = [
      sys
    ];
  };

  mc = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "mc";
    rev = "9193eef1c967ec4f96b8ff11097421c9fb650d83";
    sha256 = "10h3v92av770xiswb9wnk0yigqdrlpvw4ym649f3h9hdjic1g5mq";
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
    date = "2016-12-23";
  };

  mdns = buildFromGitHub {
    version = 1;
    date = "2015-12-05";
    rev = "9d85cf22f9f8d53cb5c81c1b2749f438b2ee333f";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "0hsbhh0v0jpm4cg3hg2ffi2phis4vq95vyja81rk7kzvml17pvag";
    propagatedBuildInputs = [
      dns
      net
    ];
  };

  memberlist = buildFromGitHub {
    version = 2;
    date = "2016-12-13";
    rev = "9800c50ab79c002353852a9b1095e9591b161513";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "1niwmp6w2c1xf43fgjgma2bbmrscq7avazi2a4ijd82avazwkara";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
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
    rev = "RELEASE.2016-09-11T17-42-18Z";
    sha256 = "a1e43f383fe94c9e5056c4144d9fa0264d7a44b85bcc12dd7970f1acf9953445";
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
      miniobrowser
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
    rev = "RELEASE.2016-04-17T22-09-24Z";
    sha256 = "41c8749f0a7c6a22ef35f7cb2577e31871bff95c4c5c035a936b220f198ed04e";
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
    version = 2;
    owner = "minio";
    repo = "minio-go";
    rev = "3661e36e23a73b3de0270eeeb025da4786b13430";
    sha256 = "0pw8wy7b9x6djf0grffnnwmh5lw40r4h7i26rh82bhkmd9qzpchp";
    meta.useUnstable = true;
    date = "2016-12-30";
  };

  miniobrowser = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "miniobrowser";
    date = "2016-12-15";
    rev = "2fadda973d210cb8b4f11eda3a677e459bf41e71";
    sha256 = "1f68fmfrl1xgsaawyvd1inw6018807zqihcj751h6wwjpkbqip4x";
    propagatedBuildInputs = [
      go-bindata-assetfs
    ];
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
    version = 1;
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "935e0e8a636ca4ba70b713f3e38a19e1b77739e8";
    sha256 = "1a9s99gwziamlw2yn7i86wh675ag2bqbp5aa13vf8kl2rfc2p6ma";
    date = "2016-05-12";
  };

  mmark = buildFromGitHub {
    version = 2;
    owner = "miekg";
    repo = "mmark";
    rev = "2d4f1dd6f87cad351b9323bbaa6f6c586f0c4bee";
    sha256 = "0r0mrsj0pz60g7ljiij0kl9b5s4r0nyl56fjgwy5fn5rpliakinc";
    buildInputs = [
      toml
    ];
    date = "2016-11-03";
  };

  mongo-tools = buildFromGitHub {
    version = 2;
    rev = "r3.4.0";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "0r5q4b0f8fqpfqq693377dpy6p25zcvc0k06a56wm1vra4la5ibz";
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

  mow-cli = buildFromGitHub {
    version = 2;
    rev = "0de3d3b4ed00f261460d12ecde4efa90fbfcd8ed";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "12pp4f6bwlvqcbk7cs26sg2dqx40cdj03xn3dx4dpasg1vnsxc5s";
    date = "2016-11-23";
  };

  ns1-go_v2 = buildFromGitHub {
    version = 2;
    rev = "d8d10b7f448291ddbdce48d4594fb1b667014c8b";
    owner  = "ns1";
    repo   = "ns1-go";
    sha256 = "157dv79vyp9kap59yy6rny47nqyp2zyxdymiwksb43i9qn99fpwn";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2016-11-04";
  };

  msgp = buildFromGitHub {
    version = 2;
    rev = "v1.0";
    owner  = "tinylib";
    repo   = "msgp";
    sha256 = "1m49ahnqqf40yjj9jij30iargq6jm0cm1alpr191nd3x692sc9ds";
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

  mux = buildFromGitHub {
    version = 2;
    rev = "757bef944d0f21880861c2dd9c871ca543023cba";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1gjn61q6wfvlk6j8fvfqih15037lflx3q5vxdck93na4s7w64fqc";
    propagatedBuildInputs = [
      context
    ];
    date = "2016-09-20";
  };

  muxado = buildFromGitHub {
    version = 1;
    date = "2014-03-12";
    rev = "f693c7e88ba316d1a0ae3e205e22a01aa3ec2848";
    owner  = "inconshreveable";
    repo   = "muxado";
    sha256 = "db9a65b811003bcb48d1acefe049bb12c8de232537cf07e1a4a949a901d807a2";
    meta.autoUpdate = false;
  };

  mysql = buildFromGitHub {
    version = 2;
    rev = "v1.3";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "1jy5ak2ka6qi16i99c06b1k6nvf3fbngcj454dzxk1xwrd5y076h";
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
    version = 2;
    rev = "13fb20a9787c14bfc4c7996ce27d7224aa815812";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "0jdh7n2lvvk23f9pwww911lcb3941iy1lvbwk23yhix9iz1xsz9f";
    date = "2016-12-17";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    version = 2;
    rev = "2c9454e4fc6e2edc1a1c84e64ed3d6e662fb6991";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "0rzlrhh9xyigf6q1iwb56pdzkx4yfwh8p4pmrdaqb4863cw8yl1g";
    date = "2016-12-19";
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
    rev = "v0.5.2";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "11p0i954jzialm8nl3npd3f194yl1bahfl6d00hg8hyqcz4ljsq6";

    buildInputs = [
      gziphandler
      circbuf
      armon_go-metrics
      go-spew
      go-humanize
      go-dockerclient
      cronexpr
      consul_api
      go-checkpoint
      go-cleanhttp
      go-getter
      go-memdb
      ugorji_go
      go-multierror
      go-syslog
      go-version
      hcl
      logutils
      memberlist
      net-rpc-msgpackrpc
      raft_v1
      raft-boltdb_v1
      scada-client
      serf
      yamux
      osext
      mitchellh_cli
      colorstring
      copystructure
      go-ps
      hashstructure
      mapstructure
      runc
      columnize
      gopsutil
      sys
      go-plugin
      tail
      srslog
      consul-template_for_nomad
      sync
      time
      tomb_v2
    ];

    subPackages = [
      "."
    ];

    # Remove deprecated consul api.HealthUnknown
    postPatch = ''
      sed -i nomad/structs/structs.go \
        -e 's/api.HealthUnknown, //' \
        -e '/api.HealthUnknown/d'
    '';
  };

  notify = buildFromGitHub {
    version = 2;
    owner = "rjeczalik";
    repo = "notify";
    date = "2016-08-20";
    rev = "7e20c15e6693a7d6ad269a94b70ed68bc4a875a7";
    sha256 = "f6bd315a30a2e14d1defc64a979d1db4371122b33d330afa62b2e3179328382a";
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
    goPackageAliases = [ "github.com/spacemonkeygo/openssl" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.openssl ];
    propagatedBuildInputs = [ spacelog ];

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,spacemonkeygo/openssl,10gen/openssl,g'
    '';
  };

  osext = buildFromGitHub {
    version = 1;
    date = "2016-08-10";
    rev = "c2c54e542fb797ad986b31721e1baedf214ca413";
    owner = "kardianos";
    repo = "osext";
    sha256 = "0y2fl7f2n7bwfs6vykb8p9qpx8xyp3rl7bb9ax9fhrzgkl112530";
    goPackageAliases = [
      "github.com/bugsnag/osext"
      "bitbucket.org/kardianos/osext"
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
    version = 2;
    owner = "cheggaaa";
    repo = "pb";
    date = "2016-11-21";
    rev = "d7e6ca3010b6f084d8056847f55d7f572f180678";
    sha256 = "1c4gvmwkkiqyj48hvh7iga3jv3sxdp3wjwjv88qmhsgchbsl5k97";
    propagatedBuildInputs = [
      go-runewidth
    ];
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 2;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.7";
    sha256 = "0lvy933pr81isx5n2yxa595iddvwnqmbvan14b7zmwpxws2h24kx";
    goPackagePath = "gopkg.in/cheggaaa/pb.v1";
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
    rev = "2c5fb962da6113d0968907fd81dba3ca35151d1c";
    date = "2016-12-29";
    sha256 = "0sjni0qz026xr4q04j0dzi0jnxnipm86qpic9l4wmxcf2q0bzx1y";
  };

  pflag = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "pflag";
    rev = "25f8b5b07aece3207895bf19f7ab517eb3b22a40";
    date = "2016-12-13";
    sha256 = "1d9qsxi82g30b5lcbsl0ih2vy2vchs0zphcpw1fgz613r54f8w7f";
  };

  pkcs7 = buildFromGitHub {
    version = 2;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "cedaa6c8ea14493515fcf950eabba5eb1530c349";
    date = "2016-12-02";
    sha256 = "1anb2xq1ghdb1cr4frd03p9yix5j1gq3109g4krfi4dcmr95azmk";
  };

  pkg = buildFromGitHub {
    version = 2;
    date = "2016-10-26";
    owner  = "coreos";
    repo   = "pkg";
    rev = "447b7ec906e523386d9c53be15b55a8ae86ea944";
    sha256 = "0yn460gwhzii5b8jbiz5fsynd30w2ikh3hbl13ci9g1ybw60qyrn";
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

  pool_v2 = buildFromGitHub {
    version = 2;
    owner = "fatih";
    repo = "pool";
    date = "2016-07-21";
    rev = "20a0a429c5f93de45c90f5f09ea297c25e0929b3";
    sha256 = "2dad7d86c3724e9f90e373ead150d0f1f6b02bbfb98a2347e801db5ea1c67d07";
    goPackagePath = "gopkg.in/fatih/pool.v2";
  };

  pq = buildFromGitHub {
    version = 2;
    rev = "5bf161122cd640c2a5a2c1d7fa49ea9befff31dd";
    owner  = "lib";
    repo   = "pq";
    sha256 = "18qa6fjgrg9g4553wvgr80x43wb0zy74ssnsib1fzkg5prxhllwg";
    date = "2016-12-20";
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
    version = 2;
    owner = "pkg";
    repo = "profile";
    rev = "v1.2.0";
    sha256 = "02mq7xinxxln3wz3pgqaklpj0ry3ipp8agvzci72l2b56v50aas2";
  };

  prometheus = buildFromGitHub {
    version = 2;
    rev = "v1.4.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "0pb3h7ph2y4aihs2vqnvwx2jxp2adycs1d42caz9cggc5f8yhki4";
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
      grpc
      influxdb_client
      logrus
      net
      prometheus_common
      yaml_v2
    ];
  };

  prometheus_client_golang = buildFromGitHub {
    version = 1;
    rev = "v0.8.0";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "1n92bwbhymz88n3zm4cnv6xhj80g5r8dp720bwpb0ckwaxnzsbag";
    propagatedBuildInputs = [
      goautoneg
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      beorn7_perks
    ];
  };

  prometheus_client_model = buildFromGitHub {
    version = 1;
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
    version = 2;
    date = "2016-12-20";
    rev = "6d76b79f239843a04e8ad8dfd8fcadfa3920236f";
    owner = "prometheus";
    repo = "common";
    sha256 = "0ap1af77mwpnacxpnksrhld3ndw6lkvvzs59wiz30lqkaq3z84jw";
    buildInputs = [
      logrus
      net
      prometheus_client_model
      protobuf
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      httprouter
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
    version = 2;
    rev = "fcdb11ccb4389efb1b210b7ffb623ab71c5fdd60";
    date = "2016-12-06";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "0jm6xqh21sb6mlanzv7idvg7ag2w8zd7prfmmfzv5ciaz0zbzpx6";
  };

  properties = buildFromGitHub {
    version = 2;
    owner = "magiconair";
    repo = "properties";
    rev = "9c47895dc1ce54302908ab8a43385d1f5df2c11c";
    sha256 = "0n4j1zk65icjhi6rfgccdlz0hgyj6vrm8wj77i6zpg0p1b6pd6ak";
    date = "2016-11-28";
  };

  gogo_protobuf = buildFromGitHub {
    version = 1;
    owner = "gogo";
    repo = "protobuf";
    rev = "v0.3";
    sha256 = "1qxlyjw7hi06byzxp3xa5sdvg5dmbq9cc6558xm8acr9xjizf78y";
    excludedPackages = "test";
  };

  pty = buildFromGitHub {
    version = 2;
    owner = "kr";
    repo = "pty";
    rev = "ce7fa45920dc37a92de8377972e52bc55ffa8d57";
    sha256 = "0dggs6g9gli2jvq3ssz14p3mblgw802211yzpn2ap3kxgpk69s40";
    date = "2016-07-16";
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
    version = 1;
    rev = "v1.0.6";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1cw4ilgjkx74pshrf6fzngyy1jj98y3051b6mkq4s7ksmr8s9xpy";
    propagatedBuildInputs = [
      go4
      b
      exp
      lldb
      strutil
    ];
  };

  rabbit-hole = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "1ayyfmp7fbqqwwi5kdmyrq8vp28w82c0i3cg55hf5f7v8daka0lj";
  };

  raft_v1 = buildFromGitHub {
    version = 2;
    date = "2016-08-23";
    rev = "5f09c4ffdbcd2a53768e78c47717415de12b6728";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "87367c09962cfefc09cfc7c7092099086aa98412f7ad174c85c803790635fa83";
    propagatedBuildInputs = [ armon_go-metrics ugorji_go ];
  };

  raft_v2 = buildFromGitHub {
    version = 2;
    date = "2016-11-09";
    # Use the library-v2-stage-one branch until it is merged
    # into master.
    rev = "aaad9f10266e089bd401e7a6487651a69275641b";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "b5a3392c27c22bbd44bc7978ca61f9ce90658caf51bebef7b4db11788d4d5e80";
    propagatedBuildInputs = [
      armon_go-metrics
      logxi
      ugorji_go
    ];
    meta.autoUpdate = false;
  };

  raft-boltdb_v2 = buildFromGitHub {
    version = 2;
    date = "2016-09-13";
    rev = "a8adffd05b79e3d8b1817d46bbe387a112265b3e";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "0kj22b0xk7avzwymkdi98f9vbbgslfd187njd7128nhgmdvfdn0m";
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft_v2
    ];
  };

  raft-boltdb_v1 = buildFromGitHub {
    inherit (raft-boltdb_v2) version rev date owner repo sha256;
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft_v1
    ];
  };

  ratecounter = buildFromGitHub {
    version = 2;
    owner = "paulbellamy";
    repo = "ratecounter";
    rev = "v0.1.0";
    sha256 = "a4f573a38ec36fbbefea687e750abce13bd8dc80134596c87f60d15179e3cbdc";
  };

  ratelimit = buildFromGitHub {
    version = 1;
    rev = "77ed1c8a01217656d2080ad51981f6e99adaa177";
    date = "2015-11-25";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0m7bvg8kg9ffl624lbcq47207n6r54z9by1wy0axslishgp1lh98";
  };

  raw = buildFromGitHub {
    version = 2;
    rev = "095ef29d97267d867c9e0087f7f36159baed8e30";
    owner  = "feyeleanor";
    repo   = "raw";
    sha256 = "1cldfan88dsrv64gk84sz7mlfng87fahfn4hi9whqfvhs74hw7sr";
    date = "2016-12-20";
  };

  rclone = buildFromGitHub {
    version = 2;
    owner = "ncw";
    repo = "rclone";
    rev = "1b2dda8c4cfeba86d72236ec51c29d873d17aa16";
    sha256 = "0jfffh3rrsbpvdk4m0bwjavkx3qzipzh0wdc12cqafccik7nxscp";
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
      oauth2
      open-golang
      pflag
      swift
      sys
      tb
      testify
    ];
    meta.useUnstable = true;
    date = "2016-12-19";
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
    version = 2;
    owner = "minio";
    repo = "redigo";
    date = "2016-07-23";
    rev = "5e2117cd32d677a36dcd8c9c83776a065555653b";
    sha256 = "3991316f879ff46e423e73f4006b26b620a0a98397fd649e0d667ff7cd35093a";
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
    meta.autoUpdate = false;
  };

  reedsolomon = buildFromGitHub {
    version = 2;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2016-10-28";
    rev = "d0a56f72c0d40a6cdde43a1575ad9686a0098b70";
    sha256 = "0w78rwan71zmakaw2xb8zx9cxbi2658ghyhgmg2i9a175pxqg1ph";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  reflectwalk = buildFromGitHub {
    version = 2;
    date = "2016-10-04";
    rev = "9ad27c461a633e32a235a061d523aefe8f18571d";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "02jg1vi3brfi9lnxlf65lkdh6jzwkq7ywbrqiip3p0q6xmvhvm00";
  };

  roaring = buildFromGitHub {
    version = 2;
    rev = "v0.3.4";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1y42gz3r81d7w2n7xvyfvr74lx84ziw63dkviz48xvx0ivyw33hw";
    propagatedBuildInputs = [
      go-unsnap-stream
      msgp
    ];
  };

  roundtrip = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "roundtrip";
    date = "2016-12-09";
    rev = "41588aab7963b48601122368b5c893f13c5c4608";
    sha256 = "1436mpzymknd353nzs0gv3mlw7x6vjj458vxzg0hrldkwvrz86g4";
    propagatedBuildInputs = [
      trace
    ];
  };

  rpc = buildFromGitHub {
    version = 2;
    owner = "gorilla";
    repo = "rpc";
    date = "2016-09-24";
    rev = "22c016f3df3febe0c1f6727598b6389507e03a18";
    sha256 = "0ny16dm38zkd7j6v11vayfx8j5q6bmfhsl3hj855f79c90i4bkaq";
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
    version = 1;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "75b869ab4d184c870de0c203d5466d846c279652ba412f35af7ddeca6835ff5c";
    propagatedBuildInputs = [
      go-units
      logrus
      docker_for_runc
      go-systemd
      protobuf
      gocapability
      netlink
      urfave_cli
      runtime-spec
    ];
    meta.autoUpdate = false;
  };

  runtime-spec = buildFromGitHub {
    version = 1;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "1c112fe3b731835f244a6d7030de25e371ba4f783cdff0ae53e471908a117162";
    buildInputs = [
      gojsonschema
    ];
    meta.autoUpdate = false;
  };

  sanitized-anchor-name = buildFromGitHub {
    version = 2;
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "1dba4b3954bc059efc3991ec364f9f9a35f597d2";
    date = "2016-09-17";
    sha256 = "10gr6fqd9v4q1jfqms4v797a9769x3p9gvrzv3a65ngdqyfnikk5";
  };

  scada-client = buildFromGitHub {
    version = 1;
    date = "2016-06-01";
    rev = "6e896784f66f82cdc6f17e00052db91699dc277d";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "1by4kyd2hrrrghwj7snh9p8fdlqka24q9yr6nyja2acs2zpjgh7a";
    buildInputs = [ armon_go-metrics net-rpc-msgpackrpc yamux ];
  };

  semver = buildFromGitHub {
    version = 1;
    rev = "v3.3.0";
    owner = "blang";
    repo = "semver";
    sha256 = "0vz3bzkclpgy7n55z6vx3yxzl0mgxbcwfa262kyi2bnvfgz1r10r";
  };

  serf = buildFromGitHub {
    version = 2;
    rev = "v0.8.0";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1ci7yav379aykvjc1xrc71fsvzb1h9vnmzk79h4p7ga7mghkkmdd";

    buildInputs = [
      net circbuf armon_go-metrics ugorji_go go-syslog logutils mdns memberlist
      dns mitchellh_cli mapstructure columnize
    ];
  };

  session = buildFromGitHub {
    version = 2;
    rev = "b8a2b5ef7fb4c91c1c8ca23e2a52e29a4bcbb22f";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "10xckq8mkw4d6764g020aa8qzp03i6ywd13pmj921y7ik467q3za";
    date = "2016-11-21";
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
    version = 2;
    owner = "pkg";
    repo = "sftp";
    rev = "4d0e916071f68db74f8a73926335f809396d6b42";
    date = "2016-10-01";
    sha256 = "0bkhab0byjdjq476hxi3as685p7x18l2np7gj2kmrzpadadv1w0a";
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
    date = "2016-12-19";
    rev = "e82e73b775766b9011503e80e6772fc32b9afc5b";
    sha256 = "01pms9fsfjdnlw1n4wj00y7gj36cljjvhvhbmaq7yz86wm96bn48";
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
    version = 1;
    rev = "bb44bb2e4817fe71ba7082d351fd582e7d40e3ea";
    owner  = "feyeleanor";
    repo   = "slices";
    sha256 = "05i934pmfwjiany6r9jgp27nc7bvm6nmhflpsspf10d4q0y9x8zc";
    date = "2013-02-25";
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
    date = "2016-11-28";
    rev = "267ef9ea5540f76d997c723a98b0d413f5b20bfb";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "0sxw0ryv9qjg80dj0szr3xlscc0y6rxcl65swq7ang12558cbgiw";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    version = 2;
    date = "2016-10-13";
    rev = "675b82c74c0ed12283ee81ba8a534c8982c07b85";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "0k0mydv8dn6dwia05v5wz4h20baynrd0xgsrmwp496yhwq8yagkz";
  };

  srslog = buildFromGitHub {
    version = 2;
    rev = "456df3a81436d29ba874f3590eeeee25d666f8a5";
    date = "2016-11-21";
    owner  = "RackSec";
    repo   = "srslog";
    sha256 = "0lxrxpfjhvkmx6j7lxyd20c1840vxmqcpzla52m8iphj41p3wdj2";
  };

  stack = buildFromGitHub {
    version = 1;
    rev = "v1.5.2";
    owner = "go-stack";
    repo = "stack";
    sha256 = "0c75y18wb45n61ppgzb52k59p52g7221zcm435pz3ca0yhjz02q6";
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
    date = "2016-09-06";
    rev = "e383bbf6b2ec1a2fb8492dfd152d945fb88919b6";
    sha256 = "3e7a626af83340a966a52f634198ede41b0a564946902e5fa1b4341a8d0dccdd";
    postPatch = /* Remove recursive import of itself */ ''
      sed -i example/main.go \
        -e '/"github.com\/rakyll\/statik\/example\/statik"/d'
    '';
  };

  structs = buildFromGitHub {
    version = 2;
    date = "2016-12-30";
    rev = "1de5ce037865f641d8eb22007e31cc5292a54e12";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "1ki2gsv23sylbdcvi4rhgcr8cx3rg6wv84pzhj6rc6rh9kv78brg";
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
    version = 1;
    date = "2015-04-30";
    rev = "1eb03e3cc9d345307a45ec82bd3016cde4bd4464";
    owner = "cznic";
    repo = "strutil";
    sha256 = "0ipn9zaihxpzs965v3s8c9gm4rc4ckkihhjppchr3hqn2vxwgfj1";
  };

  suture = buildFromGitHub {
    version = 1;
    rev = "v2.0.0";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0w7v4dp9pjndrrbqkpsl8xlnjs5gv8398gyyvhlb8x5h39v217vp";
  };

  swift = buildFromGitHub {
    version = 2;
    rev = "6c1b1510538e1f00d49a558b7b9b87d71bc454d6";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "1nsyfm1vmj073xlpp91csixcjkhilw9ip7bpbnzmfifryhnw9z66";
    date = "2016-12-13";
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
    version = 2;
    rev = "v0.14.17";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "0knj5y5shgc211j3k75qyay59l5vy72zblwd0x0vy5plq1n1vnm0";
    buildFlags = [ "-tags noupgrade" ];
    buildInputs = [
      go-lz4 du luhn xdr snappy ratelimit osext
      goleveldb suture qart crypto net text rcrowley_go-metrics
      go-nat-pmp glob gateway ql groupcache pq gogo_protobuf
      geoip2-golang sha256-simd go-deadlock
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
    rev = "44e365d423f4f06769182abfeeae2b91be9d529b";
    date = "2016-12-29";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "129zcc9k2xxs16lhv7ncg07b2glfrjzks6rna2zl9ss60q03r6ym";
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
      missinggo_lib
      xstrings
    ];
    meta.autoUpdate = false;
  };

  tail = buildFromGitHub {
    version = 2;
    rev = "915e5feba042395f5fda4dbe9c0e99aeab3088b3";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "00cy0pmnmxdnra2mx7y611kvvmx0qmgvb4hd13pcwsyrdf8bxpyl";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
    ];
    date = "2016-11-25";
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
    version = 2;
    rev = "v1.3.1";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "1dq7kc46k1v28a7yk994sjjbrybv0xr9s85kqcf9p5f1a7shdcdx";
    buildInputs = [
      bolt
      configure
      docker_for_teleport
      etcd_client
      go-oidc
      goterm
      hotp
      httprouter
      gravitational_kingpin
      lemma
      osext
      oxy
      pty
      roundtrip
      trace
      gravitational_ttlmap
      u2f
      pborman_uuid
      yaml_v2
    ];
    excludedPackages = "\\(test\\|suite\\)";
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
    rev = "abe82ce5fb7a42fbd6784a5ceb71aff977e09ed8";
    date = "2016-12-06";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "1zpkfddckx42kzc2g5zg6izx5caz84zsnq6m5fbl4a5g5916pn4a";
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
    version = 1;
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.2.0";
    sha256 = "1sqhi5rx27scpcygdzipbhx4l6x4mjjxkbh5hg00wzqhfwhy4mxw";
    goPackageAliases = [ "github.com/burntsushi/toml" ];
  };

  trace = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "trace";
    rev = "2105b524fbe43c8410eb1f762af1201ac9edbf5c";
    sha256 = "0fgf01dps8jmf8ac6vkv3bxj981iinsx9ib6g8sdd7nygh8931g6";
    date = "2016-12-18";
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
    rev = "5bd2802263f21d8788851d5305584c82a5c75d7e";
    sate = "2015-02-08";
    sha256 = "09qypmzsr71ikqinffr5ryg4b38kclssrfnnh8n3rv0plcx8i5rr";
    date = "2016-07-26";
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
    rev = "cb02a8a1ac94501fb8421531cd94d874360d35b1";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "0cx70k83bccd1kxrwf3v957hhc3pr0dxzdym15bxdkylkrmg6jwk";
    date = "2016-12-20";
    propagatedBuildInputs = [
      envpprof
      missinggo
      anacrolix_sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 2;
    rev = "5007efa264d92316c43112bc573e754bc889b7b1";
    owner = "pborman";
    repo = "uuid";
    sha256 = "02gfmxg9qjvl4g2vnqlqin7yf0ij2sg2xdqqs89i9acqr8598byh";
    date = "2016-12-06";
  };

  satori_uuid = buildFromGitHub {
    version = 1;
    rev = "v1.1.0";
    owner = "satori";
    repo = "uuid";
    sha256 = "19xzrdm1x07s7siavy8ssilhzyn89kqqpprmql1vsbplzljl4zgl";
  };

  vault = buildFromGitHub {
    version = 2;
    rev = "v0.6.4";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "1lpap4b6501hqsfy09piksv64g9pylsglqbqyrkp9pfr9h8hxrx8";

    nativeBuildInputs = [
      pkgs.protobuf-cpp
      protobuf.bin
    ];

    buildInputs = [
      azure-sdk-for-go
      armon_go-metrics
      go-radix
      govalidator
      aws-sdk-go
      speakeasy
      etcd_client
      go-mssqldb
      duo_api_golang
      structs
      pkcs7
      yaml
      ini_v1
      ldap
      mysql
      gocql
      protobuf
      snappy
      go-github
      go-querystring
      hailocab_go-hostpool
      consul_api
      errwrap
      go-cleanhttp
      ugorji_go
      go-multierror
      go-rootcerts
      go-syslog
      hashicorp-go-uuid
      golang-lru
      hcl
      logutils
      net-rpc-msgpackrpc
      scada-client
      serf
      yamux
      go-jmespath
      pq
      go-isatty
      rabbit-hole
      mitchellh_cli
      copystructure
      go-homedir
      mapstructure
      reflectwalk
      swift
      columnize
      go-zookeeper
      crypto
      net
      oauth2
      sys
      appengine
      asn1-ber
      mgo_v2
      grpc
      pester
      logxi
      go-colorable
      go-crypto
      jsonx
      google-cloud-go
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
      structs
      go-cleanhttp
      go-multierror
      go-rootcerts
      mapstructure
      pester
    ];
  };

  viper = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "viper";
    rev = "5ed0fc31f7f453625df314d8e66b9791e8d13003";
    date = "2016-12-13";
    sha256 = "06811p1sbs3157ci7jjxq48gx0mzyiaawacc9spq01k9sv42zm7l";
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
    rev = "1.12.0";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "1wnmdsik9cd1g47aa0w2k2c3cdi2b99paaj3wg4i3b63yrn76gm1";
    propagatedBuildInputs = [
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

  wmi = buildFromGitHub {
    version = 1;
    rev = "f3e2bae1e0cb5aef83e319133eabfee30013a4a5";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "1paiis0l4adsq68v5p4mw7g7vv39j06fawbaph1d3cglzhkvsk7q";
    date = "2015-05-20";
  };

  yaml = buildFromGitHub {
    version = 2;
    rev = "04f313413ffd65ce25f2541bfd2b2ceec5c0908c";
    date = "2016-12-06";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "107j4pq74xmmmvah32d7nxlmj7wkcg6w5pkk4wm279mpkarb7q60";
    propagatedBuildInputs = [
      yaml_v2
    ];
  };

  yaml_v2 = buildFromGitHub {
    version = 2;
    rev = "a5b47d31c556af34a302ce5d659e6fea44d90de0";
    date = "2016-09-28";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "1aggcvz2pw5fn7mpw533iq448s1dzfmv6jg5mqi4vavzn351zjqf";
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
    version = 1;
    rev = "v2.0.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "017k3y66fy2azbv9iymxsixpyda9czz8v3mhpn17750vlg842dsp";
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
    rev = "v0.5.7";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "1vasccmf9is3cpv1dgz7yiink5410l9x1c5qchh77d24jp6vg97s";
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
