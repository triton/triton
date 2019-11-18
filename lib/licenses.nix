# https://spdx.org/licenses/
# https://github.com/gentoo/gentoo/blob/master/profiles/license_groups

rec {

  AFL_1-1 = {
    id = "AFL-1.1";
    name = "Academic Free License v1.1";
    url = https://spdx.org/licenses/AFL-1.1.html;
    #file = ./license-files/afl/afl-1.1.txt;
    free = true;
    redistributable = true;
    gpl-compatible = false;
    osi-approved = false;
    fsf-approved = false;
  };

  AFL_1-2 = {
    id = "AFL-1.2";
    name = "Academic Free License v1.2";
    url = https://spdx.org/licenses/AFL-1.2.html;
    free = true;
    redistributable = true;
    gpl-compatible = false;
    osi-approved = false;
    fsf-approved = false;
  };

  AFL_2-0 = {
    id = "AFL-2.0";
    name = "Academic Free License v2.0";
    url = https://spdx.org/licenses/AFL-2.0.html;
    free = true;
    redistributable = true;
    gpl-compatible = false;
    osi-approved = false;
    fsf-approved = false;
  };

  AFL_2-1 = {
    id = "AFL-2.1";
    name = "Academic Free License v2.1";
    url = https://spdx.org/licenses/AFL-2.1.html;
    free = true;
    redistributable = true;
    gpl-compatible = false;
    osi-approved = false;
    fsf-approved = true;
  };

  AFL_3-0 = {
    id = "AFL-3.0";
    name = "Academic Free License v3.0";
    url = https://spdx.org/licenses/AFL-3.0.html;
    free = true;
    redistributable = true;
    gpl-compatible = false;
    osi-approved = true;
    fsf-approved = true;
  };

  agpl3 = {
    spdxId = "AGPL-3.0";
    fullName = "GNU Affero General Public License v3.0";
  };

  agpl3Plus = {
    spdxId = "AGPL-3.0+";
    fullName = "GNU Affero General Public License v3.0 or later";
  };

  amazonsl = {
    fullName = "Amazon Software License";
    url = http://aws.amazon.com/asl/;
    free = false;
  };

  amd = {
    fullName = "AMD License Agreement";
    url = http://developer.amd.com/amd-license-agreement/;
  };

  apsl20 = {
    spdxId = "APSL-2.0";
    fullName = "Apple Public Source License 2.0";
  };

  artistic1 = {
    spdxId = "Artistic-1.0";
    fullName = "Artistic License 1.0";
  };

  artistic2 = {
    spdxId = "Artistic-2.0";
    fullName = "Artistic License 2.0";
  };

  asl20 = {
    spdxId = "Apache-2.0";
    fullName = "Apache License 2.0";
  };

  boost = {
    spdxId = "BSL-1.0";
    fullName = "Boost Software License 1.0";
  };

  bsd2 = {
    spdxId = "BSD-2-Clause";
    fullName = ''BSD 2-clause "Simplified" License'';
  };

  bsd3 = {
    spdxId = "BSD-3-Clause";
    fullName = ''BSD 3-clause "New" or "Revised" License'';
  };

  bsdOriginal = {
    spdxId = "BSD-4-Clause";
    fullName = ''BSD 4-clause "Original" or "Old" License'';
  };

  cc0 = {
    spdxId = "CC0-1.0";
    fullName = "Creative Commons Zero v1.0 Universal";
  };

  cc-by-nc-sa-20 = {
    spdxId = "CC-BY-NC-SA-2.0";
    fullName = "Creative Commons Attribution Non Commercial Share Alike 2.0";
  };

  cc-by-nc-sa-25 = {
    spdxId = "CC-BY-NC-SA-2.5";
    fullName = "Creative Commons Attribution Non Commercial Share Alike 2.5";
  };

  cc-by-nc-sa-30 = {
    spdxId = "CC-BY-NC-SA-3.0";
    fullName = "Creative Commons Attribution Non Commercial Share Alike 3.0";
  };

  cc-by-nc-sa-40 = {
    spdxId = "CC-BY-NC-SA-4.0";
    fullName = "Creative Commons Attribution Non Commercial Share Alike 4.0";
  };

  cc-by-sa-25 = {
    spdxId = "CC-BY-SA-2.5";
    fullName = "Creative Commons Attribution Share Alike 2.5";
  };

  cc-by-30 = {
    spdxId = "CC-BY-3.0";
    fullName = "Creative Commons Attribution 3.0";
  };

  cc-by-sa-30 = {
    spdxId = "CC-BY-SA-3.0";
    fullName = "Creative Commons Attribution Share Alike 3.0";
  };

  cc-by-40 = {
    spdxId = "CC-BY-4.0";
    fullName = "Creative Commons Attribution 4.0";
  };

  cc-by-sa-40 = {
    spdxId = "CC-BY-SA-4.0";
    fullName = "Creative Commons Attribution Share Alike 4.0";
  };

  cddl = {
    spdxId = "CDDL-1.0";
    fullName = "Common Development and Distribution License 1.0";
  };

  cecill20 = {
    spdxId = "CECILL-2.0";
    fullName = "CeCILL Free Software License Agreement v2.0";
  };

  cecill-b = {
    spdxId = "CECILL-B";
    fullName  = "CeCILL-B Free Software License Agreement";
  };

  cecill-c = {
    spdxId = "CECILL-C";
    fullName  = "CeCILL-C Free Software License Agreement";
  };

  cpl10 = {
    spdxId = "CPL-1.0";
    fullName = "Common Public License 1.0";
  };

  efl10 = {
    spdxId = "EFL-1.0";
    fullName = "Eiffel Forum License v1.0";
  };

  efl20 = {
    spdxId = "EFL-2.0";
    fullName = "Eiffel Forum License v2.0";
  };

  epl10 = {
    spdxId = "EPL-1.0";
    fullName = "Eclipse Public License 1.0";
  };

  fdl12 = {
    spdxId = "GFDL-1.2";
    fullName = "GNU Free Documentation License v1.2";
  };

  fdl13 = {
    spdxId = "GFDL-1.3";
    fullName = "GNU Free Documentation License v1.3";
  };

  free = {
    fullName = "Unspecified free software license";
  };

  gpl1 = {
    spdxId = "GPL-1.0";
    fullName = "GNU General Public License v1.0 only";
  };

  gpl1Plus = {
    spdxId = "GPL-1.0+";
    fullName = "GNU General Public License v1.0 or later";
  };

  gpl2 = {
    spdxId = "GPL-2.0";
    fullName = "GNU General Public License v2.0 only";
  };

  gpl2ClasspathPlus = {
    fullName = "GNU General Public License v2.0 or later (with Classpath exception)";
    url = https://fedoraproject.org/wiki/Licensing/GPL_Classpath_Exception;
  };

  gpl2Oss = {
    fullName = "GNU General Public License version 2 only (with OSI approved licenses linking exception)";
    url = http://www.mysql.com/about/legal/licensing/foss-exception;
  };

  gpl2Plus = {
    spdxId = "GPL-2.0+";
    fullName = "GNU General Public License v2.0 or later";
  };

  gpl3 = {
    spdxId = "GPL-3.0";
    fullName = "GNU General Public License v3.0 only";
  };

  gpl3Plus = {
    spdxId = "GPL-3.0+";
    fullName = "GNU General Public License v3.0 or later";
  };

  gpl3ClasspathPlus = {
    fullName = "GNU General Public License v3.0 or later (with Classpath exception)";
    url = https://fedoraproject.org/wiki/Licensing/GPL_Classpath_Exception;
  };

  # Intel's license, seems free
  iasl = {
    fullName = "iASL";
    url = http://www.calculate-linux.org/packages/licenses/iASL;
  };

  icu = {
    spdxId = "ICU";
    fullName = "ICU License";
    url = http://source.icu-project.org/repos/icu/icu/trunk/license.html;
  };

  ijg = {
    spdxId = "IJG";
    fullName = "Independent JPEG Group License";
  };

  imagemagick = {
    spdxId = "ImageMagick";
    fullName = "ImageMagick License";
  };

  inria = {
    fullName  = "INRIA Non-Commercial License Agreement";
    url       = "http://compcert.inria.fr/doc/LICENSE";
  };

  ipa = {
    spdxId = "IPA";
    fullName = "IPA Font License";
  };

  ipl10 = {
    spdxId = "IPL-1.0";
    fullName = "IBM Public License v1.0";
  };

  isc = {
    spdxId = "ISC";
    fullName = "ISC License";
  };

  lgpl2 = {
    spdxId = "LGPL-2.0";
    fullName = "GNU Library General Public License v2 only";
  };

  lgpl2Plus = {
    spdxId = "LGPL-2.0+";
    fullName = "GNU Library General Public License v2 or later";
  };

  lgpl21 = {
    spdxId = "LGPL-2.1";
    fullName = "GNU Library General Public License v2.1 only";
  };

  lgpl21Plus = {
    spdxId = "LGPL-2.1+";
    fullName = "GNU Library General Public License v2.1 or later";
  };

  lgpl3 = {
    spdxId = "LGPL-3.0";
    fullName = "GNU Lesser General Public License v3.0 only";
  };

  lgpl3Plus = {
    spdxId = "LGPL-3.0+";
    fullName = "GNU Lesser General Public License v3.0 or later";
  };

  libpng = {
    spdxId = "Libpng";
    fullName = "libpng License";
  };

  libtiff = {
    spdxId = "libtiff";
    fullName = "libtiff License";
  };

  llgpl21 = {
    fullName = "Lisp LGPL; GNU Lesser General Public License version 2.1 with Franz Inc. preamble for clarification of LGPL terms in context of Lisp";
    url = http://opensource.franz.com/preamble.html;
  };

  lppl12 = {
    spdxId = "LPPL-1.2";
    fullName = "LaTeX Project Public License v1.2";
  };

  lppl13c = {
    spdxId = "LPPL-1.3c";
    fullName = "LaTeX Project Public License v1.3c";
  };

  lpl-102 = {
    spdxId = "LPL-1.02";
    fullName = "Lucent Public License v1.02";
  };

  # spdx.org does not (yet) differentiate between the X11 and Expat versions
  # for details see http://en.wikipedia.org/wiki/MIT_License#Various_versions
  mit = {
    spdxId = "MIT";
    fullName = "MIT License";
  };

  mpl10 = {
    spdxId = "MPL-1.0";
    fullName = "Mozilla Public License 1.0";
  };

  mpl11 = {
    spdxId = "MPL-1.1";
    fullName = "Mozilla Public License 1.1";
  };

  mpl20 = {
    spdxId = "MPL-2.0";
    fullName = "Mozilla Public License 2.0";
  };

  msrla = {
    fullName  = "Microsoft Research License Agreement";
    url       = "http://research.microsoft.com/en-us/projects/pex/msr-la.txt";
  };

  ncsa = {
    spdxId = "NCSA";
    fullName  = "University of Illinois/NCSA Open Source License";
  };

  notion_lgpl = {
    url = "https://raw.githubusercontent.com/raboof/notion/master/LICENSE";
    fullName = "Notion modified LGPL";
  };

  ofl = {
    spdxId = "OFL-1.1";
    fullName = "SIL Open Font License 1.1";
  };

  openldap = {
    spdxId = "OLDAP-2.8";
    fullName = "Open LDAP Public License v2.8";
  };

  openssl = {
    id = "OpenSSL";
    name = "OpenSSL License";
    url = https://spdx.org/licenses/OpenSSL.html;
    free = true;
    redistributable = true;
    gpl-compatible = true;
    osi-approved = false;
    fsf-approved = false;
  };

  php301 = {
    spdxId = "PHP-3.01";
    fullName = "PHP License v3.01";
  };

  postgresql = {
    spdxId = "PostgreSQL";
    fullName = "PostgreSQL License";
  };

  psf-2 = {
    spdxId = "Python-2.0";
    fullName = "Python Software Foundation License version 2";
    #url = http://docs.python.org/license.html;
  };

  publicDomain = {
    fullName = "Public Domain";
  };

  qpl = {
    spdxId = "QPL-1.0";
    fullName = "Q Public License 1.0";
  };

  qwt = {
    fullName = "Qwt License, Version 1.0";
    url = http://qwt.sourceforge.net/qwtlicense.html;
  };

  ruby = {
    spdxId = "Ruby";
    fullName = "Ruby License";
  };

  sgi-b-20 = {
    spdxId = "SGI-B-2.0";
    fullName = "SGI Free Software License B v2.0";
  };

  sleepycat = {
    spdxId = "Sleepycat";
    fullName = "Sleepycat License";
  };

  tcltk = {
    spdxId = "TCL";
    fullName = "TCL/TK License";
  };

  ufl = {
    fullName = "Ubuntu Font License 1.0";
    url = http://font.ubuntu.com/ufl/ubuntu-font-licence-1.0.txt;
  };

  unfree = {
    fullName = "Unfree";
    free = false;
  };

  unfreeRedistributable = {
    fullName = "Unfree redistributable";
    free = false;
  };

  unfreeRedistributableFirmware = {
    fullName = "Unfree redistributable firmware";
    # Note: we currently consider these "free" for inclusion in the
    # channel and NixOS images.
  };

  unlicense = {
    spdxId = "Unlicense";
    fullName = "The Unlicense";
  };

  vim = {
    spdxId = "Vim";
    fullName = "Vim License";
  };

  vsl10 = {
    spdxId = "VSL-1.0";
    fullName = "Vovida Software License v1.0";
  };

  w3c = {
    spdxId = "W3C";
    fullName = "W3C Software Notice and License";
  };

  wadalab = {
    fullName = "Wadalab Font License";
    url = https://fedoraproject.org/wiki/Licensing:Wadalab?rd=Licensing/Wadalab;
  };

  wtfpl = {
    spdxId = "WTFPL";
    fullName = "Do What The F*ck You Want To Public License";
  };

  zlib = {
    id = "Zlib";
    name = "Zlib License";
    url = https://spdx.org/licenses/Zlib.html;
    free = true;
    redistributable = true;
    gpl-compatible = true;
    osi-approved = false;
    fsf-approved = false;
  };

  zpt20 = { # FIXME: why zpt* instead of zpl*
    spdxId = "ZPL-2.0";
    fullName = "Zope Public License 2.0";
  };

  zpt21 = {
    spdxId = "ZPL-2.1";
    fullName = "Zope Public License 2.1";
  };

}
