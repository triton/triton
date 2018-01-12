rec {
  # Mirrors for mirror://site/filename URIs, where "site" is
  # "sourceforge", "gnu", etc.

  alsa = [
    "ftp://ftp.alsa-project.org/pub"
    "http://alsa.cybermirror.org"
  ];

  apache = [
    https://www.apache.org/dist
    http://apache.mirrors.pair.com
    https://archive.apache.org/dist/ # fallback for old releases
  ];

  # Bioconductor mirrors
  bioc = [
    http://bioconductor.jp/packages/3.2/bioc
    http://bioconductor.statistik.tu-dortmund.de/packages/3.2/bioc
    http://mirrors.ebi.ac.uk/bioconductor/packages/3.2/bioc
    http://mirrors.ustc.edu.cn/bioc/3.2/bioc
  ];

  # BitlBee mirrors, see http://www.bitlbee.org/main.php/mirrors.html
  bitlbee = [
    http://get.us.bitlbee.org
    http://get.bitlbee.org
  ];

  chromium = [
    https://commondatastorage.googleapis.com/chromium-browser-official
    https://gsdview.appspot.com/chromium-browser-official
  ];

  cpan = [
    https://mirrors.kernel.org/CPAN
    http://cpan.pair.com/pub/CPAN
    http://cpan.perl.org
    http://backpan.perl.org/  # for old releases
  ];

  cran = [
    http://watson.nci.nih.gov/cran_mirror
    http://cran.revolutionanalytics.com
    http://cran.mtu.edu
  ];

  debian = [
    https://mirrors.kernel.org/debian
    http://debian.mirrors.pair.com/debian
    http://ftp.debian.org/debian
    ftp://ftp.debian.org/debian
    http://archive.debian.org/debian-archive/debian
  ];

  fedora = [
    https://mirrors.kernel.org/fedora
    http://fedora.mirrors.pair.com
    http://archives.fedoraproject.org/pub/fedora
    http://fedora.osuosl.org
    http://fedora.bhs.mirrors.ovh.net
    http://mirror.csclub.uwaterloo.ca/fedora
    http://ftp.linux.cz/pub/linux/fedora
    http://mirror.1000mbps.com/fedora
    http://archives.fedoraproject.org/pub/archive/fedora
  ];

  gcc = [
    ftp://gcc.gnu.org/pub/gcc
    ftp://ftp.nluug.nl/mirror/languages/gcc
    ftp://ftp.fu-berlin.de/unix/languages/gcc
  ];

  gentoo = [
    https://mirrors.kernel.org/gentoo
    http://gentoo.mirrors.pair.com
    http://distfiles.gentoo.org
  ];

  gnome = [
    http://download.gnome.org
    https://mirrorservice.org/sites/ftp.gnome.org/pub/GNOME
    https://mirror.umd.edu/gnome
  ];

  gnu = [
    https://mirrors.kernel.org/gnu
    http://gnu.mirrors.pair.com

    # This one redirects to a (supposedly) nearby and (supposedly) up-to-date
    # mirror.
    http://ftpmirror.gnu.org

    # This one is the master repository, and thus it's always up-to-date.
    http://ftp.gnu.org/pub/gnu
  ];

  gnupg = [
    https://gnupg.org/ftp/gcrypt
    ftp://ftp.gnupg.org/gcrypt
    ftp://ftp.ring.gr.jp/pub/net/gnupg
  ];

  # Hackage mirrors
  hackage = [
    https://hackage.haskell.org/package
    http://hdiff.luite.com/packages/archive/package
  ];

  # ImageMagick mirrors, see http://www.imagemagick.org/script/download.php
  imagemagick = [
    http://www.imagemagick.org/download
    ftp://ftp.sunet.se/pub/multimedia/graphics/ImageMagick/ # also contains older versions removed from most mirrors
    http://ftp.sunet.se/pub/multimedia/graphics/ImageMagick
    ftp://ftp.imagemagick.org/pub/ImageMagick
    http://ftp.fifi.org/ImageMagick
    ftp://ftp.fifi.org/ImageMagick
    http://imagemagick.mirrorcatalogs.com
    ftp://imagemagick.mirrorcatalogs.com/imagemagick
  ];

  ipfs-cached = [
    https://ipfs.wak.io
  ];

  ipfs-nocache = [
    https://ipfs.io
  ];

  # Mirrors of ftp://ftp.kde.org/pub/kde/.
  kde = [
    http://kde.mirrors.pair.com
    http://mirrors.mit.edu/kde
    http://download.kde.org
    ftp://ftp.kde.org/pub/kde
  ];

  # kernel.org's /pub (/pub/{linux,software}) tree.
  kernel = [
    https://www.kernel.org/pub
    http://mirrors.xmission.com/kernel.org
  ];

  mariadb = [
    http://downloads.mariadb.org/interstitial
    http://sfo1.mirrors.digitalocean.com/mariadb
    http://mirror.jmu.edu/pub/mariadb
  ];

  metalab = [
    ftp://ftp.gwdg.de/pub/linux/metalab
  ];

  mysql = [
    https://cdn.mysql.com/Downloads
    http://mysql.mirrors.pair.com/Downloads
  ];

  nvidia = [
    "https://download.nvidia.com"
    # Some files are only available on the US mirror
    "https://us.download.nvidia.com"
  ];

  openbsd = [
    http://ftp.openbsd.org/pub/OpenBSD
    http://openbsd.mirrors.pair.com
  ];

  opensuse = [
    http://opensuse.temple.edu/distribution
    http://ftp.opensuse.org/pub/opensuse/distribution
  ];
  # Old SUSE distributions.  Unfortunately there is no master site,
  # since SUSE actually delete their old distributions (see
  # ftp://ftp.suse.com/pub/suse/discontinued/deleted-20070817/README.txt).
  oldsuse = [
    ftp://ftp.gmd.de/ftp.suse.com-discontinued
  ];

  postgresql = [
    https://ftp.postgresql.org/pub
    ftp://ftp-archives.postgresql.org/pub
  ];

  pypi = [
    "https://pypi.python.org/packages/source"
  ];

  # Roy marples mirrors
  roy = [
    https://roy.marples.name/downloads
    http://roy.aydogan.net
    http://cflags.cc/roy
  ];

  sagemath = [
    http://boxen.math.washington.edu/home/sagemath/sage-mirror/src
    http://mirrors.hustunique.com/sagemath/src
    http://mirrors.xmission.com/sage/src
    http://sage.asis.io/src
    http://www.mirrorservice.org/sites/www.sagemath.org/src

    # Old versions
    http://www.cecm.sfu.ca/sage/src
    http://sagemath.org/src-old
  ];

  samba = [
    https://download.samba.org/pub
  ];

  savannah = [
    https://download.savannah.gnu.org/releases
    https://download-mirror.savannah.gnu.org/releases

    # These redirect to a random mirror
    http://savannah.nongnu.org/download
  ];

  sourceforge = [
    # These urls don't allow any redirects and don't fail as often as the redirect ones
    "https://sourceforge.mirrorservice.org/\${base:1:1}/\${base:1:2}"  # http://kent.dl.sourceforge.net
    https://cytranet.dl.sourceforge.net/project
    https://newcontinuum.dl.sourceforge.net/project

    # Fall back to the indexed mirrors when the direct references don't work
    http://downloads.sourceforge.net
  ];

  # SourceForge.jp
  sourceforgejp = [
    http://osdn.dl.sourceforge.jp
    http://jaist.dl.sourceforge.jp
  ];

  ubuntu = [
    https://mirrors.kernel.org/ubuntu
    http://ubuntu.mirrors.pair.com
    http://archive.ubuntu.com/ubuntu
    http://old-releases.ubuntu.com/ubuntu
  ];

  videolan = [
    "https://download.videolan.org/videolan"
    "https://ftp.videolan.org/videolan"
    # Mirror CDN
    "http://get.videolan.org"
  ];

  xfce = [
    http://archive.xfce.org
  ];

  xiph = [
    "https://ftp.osuosl.org/pub/xiph/releases"
    "http://downloads.xiph.org/releases"
  ];

  xorg = [
    https://www.x.org/releases
    http://xorg.mirrors.pair.com
    http://mirror.csclub.uwaterloo.ca/x.org
  ];
}
