/*

  WARNING/NOTE: whenever you want to add an option here you need to
  either

  * mark it as an optional one with `?` suffix,
  * or make sure it works for all the versions in nixpkgs,
  * or check for which kernel versions it will work (using kernel
    changelog, google or whatever) and mark it with `versionOlder` or
    `versionAtLeast`.

  Then do test your change by building all the kernels (or at least
  their configs) in nixpkgs or else you will guarantee lots and lots
  of pain to users trying to switch to an older kernel because of some
  hardware problems with a new one.

*/

{ stdenv, version, extraConfig, features }:

with stdenv.lib;

''
  # Compress kernel modules for a sizable disk space savings.
  ${optionalString (versionAtLeast version "3.18") ''
    MODULE_COMPRESS y
    MODULE_COMPRESS_XZ y
  ''}

  # Debugging.
  DEBUG_KERNEL y
  TIMER_STATS y
  BACKTRACE_SELF_TEST n
  CPU_NOTIFIER_ERROR_INJECT? n
  DEBUG_DEVRES n
  DEBUG_NX_TEST n
  DEBUG_STACK_USAGE n
  ${optionalString (!(features.grsecurity or false)) ''
    DEBUG_STACKOVERFLOW n
  ''}
  RCU_TORTURE_TEST n
  SCHEDSTATS n
  DETECT_HUNG_TASK y

  # Unix domain sockets.
  UNIX y

  # Power management.
  ${optionalString (versionOlder version "3.19") ''
    PM_RUNTIME y
  ''}
  PM_ADVANCED_DEBUG y
  PM_AUTOSLEEP y
  PM_WAKELOCKS y
  ${optionalString (versionAtLeast version "3.11") ''
    X86_INTEL_LPSS y
  ''}
  ${optionalString (versionAtLeast version "3.10") ''
    X86_INTEL_PSTATE y
  ''}
  INTEL_IDLE y
  CPU_FREQ_DEFAULT_GOV_PERFORMANCE y
  ${optionalString (versionOlder version "3.10") ''
    USB_SUSPEND y
  ''}
  ACPI_PCI_SLOT y
  ACPI_HOTPLUG_MEMORY y
  ACPI_BGRT y
  ACPI_APEI y
  CPU_IDLE_GOV_LADDER y

  HOTPLUG_PCI_ACPI y
  HOTPLUG_PCI_CPCI y

  # Support drivers that need external firmware.
  STANDALONE n

  # Make /proc/config.gz available.
  IKCONFIG y
  IKCONFIG_PROC y

  # Optimize with -O2, not -Os.
  CC_OPTIMIZE_FOR_SIZE n

  # Enable the kernel's built-in memory tester.
  MEMTEST y

  # Include the CFQ I/O scheduler in the kernel, rather than as a
  # module, so that the initrd gets a good I/O scheduler.
  IOSCHED_CFQ y
  BLK_CGROUP y # required by CFQ

  # Enable NUMA.
  NUMA y
  NUMA_BALANCING y

  # Disable some expensive (?) features.
  PM_TRACE_RTC n

  # Enable various subsystems.
  ACCESSIBILITY y # Accessibility support
  AUXDISPLAY y # Auxiliary Display support
  DONGLE y # Serial dongle support
  HIPPI y
  MTD_COMPLEX_MAPPINGS y # needed for many devices
  ${optionalString (versionOlder version "3.2") ''
    NET_POCKET y # enable pocket and portable adapters
  ''}
  SCSI_LOWLEVEL y # enable lots of SCSI devices
  SCSI_LOWLEVEL_PCMCIA y
  SCSI_SAS_ATA y  # added to enable detection of hard drive
  SPI y # needed for many devices
  SPI_MASTER y
  WAN y

  # Networking options.
  IP_PNP n
  ${optionalString (versionOlder version "3.13") ''
    IPV6_PRIVACY y
  ''}
  IP_MROUTE_MULTIPLE_TABLES y
  IPV6_ROUTER_PREF y
  IPV6_ROUTE_INFO y
  IPV6_OPTIMISTIC_DAD y
  IPV6_SIT_6RD y
  IPV6_SUBTREES y
  IPV6_MULTIPLE_TABLES y
  IPV6_MROUTE_MULTIPLE_TABLES y
  IPV6_MROUTE y
  IPV6_PIMSM_V2 y
  NETWORK_PHY_TIMESTAMPING y
  NETFILTER_ADVANCED y
  IP_VS_PROTO_TCP y
  IP_VS_PROTO_UDP y
  IP_VS_PROTO_ESP y
  IP_VS_PROTO_AH y
  IP_VS_PROTO_SCTP y
  IP_DCCP_CCID3 n # experimental
  CLS_U32_PERF y
  CLS_U32_MARK y
  ${optionalString (stdenv.system == "x86_64-linux") ''
    BPF_JIT y
  ''}
  NF_CONNTRACK_ZONES y
  NF_CONNTRACK_EVENTS y
  NF_CONNTRACK_TIMEOUT y
  NF_CONNTRACK_TIMESTAMP y
  NETFILTER_NETLINK_GLUE_CT y
  IP_VS_IPV6 y
  IP_DCCP_CCID3 y
  SCTP_DEFAULT_COOKIE_HMAC_SHA1 y
  SCTP_COOKIE_HMAC_SHA1 y
  SCTP_COOKIE_HMAC_MD5 y
  L2TP_V3 y
  NET_CLS_IND y
  BATMAN_ADV_BATMAN_V y
  BATMAN_ADV_DAT y
  BATMAN_ADV_NC y
  BATMAN_ADV_MCAST y
  NET_SWITCHDEV y
  NET_L3_MASTER_DEV y

  BNX2X_VXLAN y
  BNX2X_GENEVE y
  IXGBE_VXLAN y
  I40E_VXLAN y
  I40E_GENEVE y
  FM10K_VXLAN y
  MLX5_CORE_EN y
  QLCNIC_VXLAN y
  VIA_RHINE_MMIO y
  DEFXX_MMIO y

  ISDN y
  NVM y

  # Random Devices
  SSB_PCMCIAHOST y
  SSB_SDIOHOST y
  SSB_SILENT y
  SSB_DRIVER_GPIO y
  BCMA_HOST_SOC y
  BCMA_DRIVER_GMAC_CMN y
  BCMA_DRIVER_GPIO y
  MEDIA_ANALOG_TV_SUPPORT y
  MEDIA_RADIO_SUPPORT y
  MEDIA_SDR_SUPPORT y
  MEDIA_CONTROLLER y
  VIDEO_AU0828_RC y
  MEDIA_PCI_SUPPORT y
  V4L_PLATFORM_DRIVERS y
  V4L_MEM2MEM_DRIVERS y
  DVB_PLATFORM_DRIVERS y
  RADIO_SI470X y
  DRM_DP_AUX_CHARDEV y
  DRM_RADEON_USERPTR y
  DRM_AMDGPU_CIK y
  DRM_AMDGPU_USERPTR y
  DRM_AMD_POWERPLAY y
  DRM_VMWGFX_FBCON y
  FIRMWARE_EDID y
  LOGO y
  HID_BATTERY_STRENGTH y
  USB_DYNAMIC_MINORS y
  USB_MUSB_DUAL_ROLE y
  ASYNC_TX_DMA y
  VME_BUS y
  PWM y
  POWERCAP y
  ISCSI_IBFT_FIND y

  CAN_LEDS y

  # Wireless networking.
  CFG80211_WEXT? y # Without it, ipw2200 drivers don't build
  IPW2100_MONITOR? y # support promiscuous mode
  IPW2200_MONITOR? y # support promiscuous mode
  HOSTAP_FIRMWARE? y # Support downloading firmware images with Host AP driver
  HOSTAP_FIRMWARE_NVRAM? y
  ATH9K_WOW y
  ATH9K_PCI y # Detect Atheros AR9xxx cards on PCI(e) bus
  ATH9K_AHB y # Ditto, AHB bus
  ${optionalString (versionAtLeast version "3.2") ''
    B43_PHY_HT? y
  ''}
  BCMA_HOST_PCI? y

  # Enable various FB devices.
  FB y
  FB_EFI y
  FB_NVIDIA_I2C y # Enable DDC Support
  FB_RIVA_I2C y
  FB_ATY_CT y # Mach64 CT/VT/GT/LT (incl. 3D RAGE) support
  FB_ATY_GX y # Mach64 GX support
  FB_SAVAGE_I2C y
  FB_SAVAGE_ACCEL y
  FB_SIS_300 y
  FB_SIS_315 y
  FB_3DFX_ACCEL y
  FB_SIMPLE y
  FB_VESA y
  FRAMEBUFFER_CONSOLE y
  FRAMEBUFFER_CONSOLE_ROTATION y
  ${optionalString (versionOlder version "3.9" || stdenv.system == "i686-linux") ''
    FB_GEODE y
  ''}

  # Video configuration.
  # Enable KMS for devices whose X.org driver supports it.
  ${optionalString (versionOlder version "4.3" && !(features.chromiumos or false)) ''
    DRM_I915_KMS y
  ''}
  # Allow specifying custom EDID on the kernel command line
  DRM_LOAD_EDID_FIRMWARE y
  ${optionalString (versionOlder version "3.9") ''
    DRM_RADEON_KMS? y
  ''}
  # Hybrid graphics support
  VGA_SWITCHEROO y

  # Sound.
  SND_DYNAMIC_MINORS y
  SND_AC97_POWER_SAVE y # AC97 Power-Saving Mode
  SND_HDA_INPUT_BEEP y # Support digital beep via input layer
  SND_USB_CAIAQ_INPUT y
  SND_HDA_RECONFIG y
  SND_HDA_PATCH_LOADER y
  SND_HDA_CODEC_CA0132_DSP y
  PSS_MIXER y # Enable PSS mixer (Beethoven ADSP-16 and other compatible)

  # USB serial devices.
  USB_SERIAL_GENERIC y # USB Generic Serial Driver
  USB_SERIAL_KEYSPAN_MPR y # include firmware for various USB serial devices
  USB_SERIAL_KEYSPAN_USA28 y
  USB_SERIAL_KEYSPAN_USA28X y
  USB_SERIAL_KEYSPAN_USA28XA y
  USB_SERIAL_KEYSPAN_USA28XB y
  USB_SERIAL_KEYSPAN_USA19 y
  USB_SERIAL_KEYSPAN_USA18X y
  USB_SERIAL_KEYSPAN_USA19W y
  USB_SERIAL_KEYSPAN_USA19QW y
  USB_SERIAL_KEYSPAN_USA19QI y
  USB_SERIAL_KEYSPAN_USA49W y
  USB_SERIAL_KEYSPAN_USA49WLC y

  # Filesystem options - in particular, enable extended attributes and
  # ACLs for all filesystems that support them.
  FANOTIFY y
  EXT2_FS n
  EXT3_FS n
  EXT4_FS_POSIX_ACL y
  EXT4_FS_SECURITY y
  REISERFS_FS n
  JFS_FS n
  XFS_QUOTA y
  XFS_POSIX_ACL y
  XFS_RT y # XFS Realtime subvolume support
  OCFS2_DEBUG_MASKLOG? n
  BTRFS_FS_POSIX_ACL y
  F2FS_FS_SECURITY y
  F2FS_FS_ENCRYPTION y
  FS_DAX y
  FANOTIFY_ACCESS_PERMISSIONS y
  FSCACHE_STATS y
  FSCACHE_HISTOGRAM y
  NTFS_RW y
  HFSPLUS_FS_POSIX_ACL y
  UBIFS_FS_ADVANCED_COMPR y
  UBIFS_ATIME_SUPPORT y
  ${optionalString (versionAtLeast version "4.6") ''
    FAT_DEFAULT_UTF8 y
  ''}
  JFFS2_FS_XATTR y
  JFFS2_COMPRESSION_OPTIONS y
  JFFS2_LZO y
  JFFS2_CMODE_FAVOURLZO y
  ${optionalString (versionAtLeast version "4.0" && versionOlder version "4.6") ''
    NFSD_PNFS y
  ''}
  NFSD_V2_ACL y
  NFSD_V3 y
  NFSD_V3_ACL y
  NFSD_V4 y
  ${optionalString (versionAtLeast version "3.11") ''
    NFSD_V4_SECURITY_LABEL y
  ''}
  NFS_FSCACHE y
  ${optionalString (versionAtLeast version "3.6") ''
    NFS_SWAP y
  ''}
  NFS_V3_ACL y
  ${optionalString (versionAtLeast version "3.11") ''
    NFS_V4_1 y  # NFSv4.1 client support
    NFS_V4_2 y
    NFS_V4_SECURITY_LABEL y
  ''}
  CIFS_STATS y
  CIFS_UPCALL y
  CIFS_ACL y
  CIFS_XATTR y
  CIFS_POSIX y
  CIFS_FSCACHE y
  CIFS_DFS_UPCALL y
  CIFS_SMB2 y
  CIFS_SMB311 y
  ${optionalString (versionAtLeast version "3.12") ''
    CEPH_FSCACHE y
  ''}
  ${optionalString (versionAtLeast version "3.14") ''
    CEPH_FS_POSIX_ACL y
  ''}
  CEPH_LIB_USE_DNS_RESOLVER y
  ${optionalString (versionAtLeast version "3.13") ''
    SQUASHFS_FILE_DIRECT y
    SQUASHFS_DECOMP_MULTI_PERCPU y
  ''}
  SQUASHFS_XATTR y
  SQUASHFS_ZLIB y
  SQUASHFS_LZO y
  SQUASHFS_XZ y
  ${optionalString (versionAtLeast version "3.19") ''
    SQUASHFS_LZ4 y
  ''}

  # Security related features.
  STRICT_DEVMEM y # Filter access to /dev/mem
  SECURITY_SELINUX_BOOTPARAM_VALUE 0 # Disable SELinux by default
  ${optionalString (!(features.grsecurity or false)) ''
    DEVKMEM n # Disable /dev/kmem
  ''}
  ${if versionOlder version "3.14" then ''
    CC_STACKPROTECTOR? y # Detect buffer overflows on the stack
  '' else ''
    CC_STACKPROTECTOR_REGULAR? y
  ''}
  ${optionalString (versionAtLeast version "3.12") ''
    USER_NS y # Support for user namespaces
  ''}

  # AppArmor support
  SECURITY_APPARMOR y
  DEFAULT_SECURITY_APPARMOR y

  # Microcode loading support
  MICROCODE y
  MICROCODE_INTEL y
  MICROCODE_AMD y
  ${optionalString (versionAtLeast version "3.11" && versionOlder version "4.4") ''
    MICROCODE_EARLY y
    MICROCODE_INTEL_EARLY y
    MICROCODE_AMD_EARLY y
  ''}

  # Misc. options.
  EXPERT y
  STRIP_ASM_SYMS y
  UNUSED_SYMBOLS y
  PERSISTENT_KEYRINGS y
  BIG_KEYS y
  SECURITY_NETWORK_XFRM y
  DDR y
  FONTS y
  MOUSE_PS2_VMMOUSE y
  I2C_DESIGNWARE_BAYTRAIL y
  GPIO_SYSFS y
  CHARGER_MANAGER y
  POWER_RESET y
  POWER_RESET_RESTART y
  POWER_AVS y
  WATCHDOG_SYSFS y
  8139TOO_8129 y
  8139TOO_PIO n # PIO is slower
  AIC79XX_DEBUG_ENABLE n
  AIC7XXX_DEBUG_ENABLE n
  AIC94XX_DEBUG n
  ${optionalString (versionAtLeast version "3.3" && versionOlder version "3.13") ''
    AUDIT_LOGINUID_IMMUTABLE y
  ''}
  ${optionalString (versionOlder version "4.4") ''
    B43_PCMCIA? y
  ''}
  BLK_DEV_CMD640_ENHANCED y # CMD640 enhanced support
  BLK_DEV_IDEACPI y # IDE ACPI support
  BLK_DEV_INTEGRITY y
  BSD_PROCESS_ACCT_V3 y
  BT_HCIUART_BCSP? y
  BT_HCIUART_H4? y # UART (H4) protocol support
  BT_HCIUART_LL? y
  ${optionalString (versionAtLeast version "3.4") ''
    BT_RFCOMM_TTY? y # RFCOMM TTY support
  ''}
  BT_BNEP_MC_FILTER y
  BT_BNEP_PROTO_FILTER y
  BT_LEDS y
  BT_HCIUART_ATH3K y
  BT_HCIUART_3WIRE y
  BT_HCIUART_INTEL y
  BT_HCIUART_BCM y
  BT_HCIUART_QCA y
  BT_HCIUART_AG6XX y
  MAC80211_MESH y
  MAC80211_RC_MINSTREL_VHT y
  RFKILL_INPUT y
  NFC_SHDLC y
  CRASH_DUMP? n
  ${optionalString (versionOlder version "3.1") ''
    DMAR? n # experimental
  ''}
  NFTL_RW y
  MTD_NAND_ECC_SMC y
  MTD_NAND_ECC_BCH y
  ZRAM_LZ4_COMPRESS y
  DVB_DYNAMIC_MINORS? y # we use udev
  EFI_STUB y
  EFI_MIXED y
  FHANDLE y # used by systemd
  FUSION y # Fusion MPT device support
  IDE_GD_ATAPI y # ATAPI floppy support
  IRDA_ULTRA y # Ultra (connectionless) protocol
  JOYSTICK_IFORCE_232? y # I-Force Serial joysticks and wheels
  JOYSTICK_IFORCE_USB? y # I-Force USB joysticks and wheels
  JOYSTICK_XPAD_FF? y # X-Box gamepad rumble support
  JOYSTICK_XPAD_LEDS? y # LED Support for Xbox360 controller 'BigX' LED
  LDM_PARTITION y # Windows Logical Disk Manager (Dynamic Disk) support
  LEDS_TRIGGER_IDE_DISK y # LED IDE Disk Trigger
  LOGIRUMBLEPAD2_FF y # Logitech Rumblepad 2 force feedback
  LOGO n # not needed
  MEDIA_ATTACH y
  MEGARAID_NEWGEN y
  ${optionalString (versionAtLeast version "3.15") ''
    MLX4_EN_VXLAN y
  ''}
  MODVERSIONS y
  MOUSE_PS2_ELANTECH y # Elantech PS/2 protocol extension
  MTRR_SANITIZER y
  NET_FC y # Fibre Channel driver support
  ${optionalString (versionAtLeast version "3.11") ''
    PINCTRL_BAYTRAIL y # GPIO on Intel Bay Trail, for some Chromebook internal eMMC disks
  ''}
  MMC_BLOCK_MINORS 32 # 8 is default. Modern gpt tables on eMMC may go far beyond 8.
  PPP_MULTILINK y # PPP multilink support
  PPP_FILTER y
  REGULATOR y # Voltage and Current Regulator Support
  ${optionalString (versionAtLeast version "3.6") ''
    RC_DEVICES? y # Enable IR devices
  ''}
  ${optionalString (versionAtLeast version "3.10") ''
    RT2800USB_RT55XX y
  ''}
  SCSI_MQ_DEFAULT y
  DM_MQ_DEFAULT y
  DM_UEVENT y
  DM_VERITY_FEC y
  SCSI_SCAN_ASYNC y
  SCSI_DH y
  SCSI_LOGGING y # SCSI logging facility
  SERIAL_8250 y # 8250/16550 and compatible serial support
  SLIP_COMPRESSED y # CSLIP compressed headers
  SLIP_SMART y
  HWMON y
  THERMAL_HWMON y # Hardware monitoring support
  ${optionalString (versionAtLeast version "3.15") ''
    UEVENT_HELPER n
  ''}
  ${optionalString (versionOlder version "3.15") ''
    USB_DEBUG? n
  ''}
  USB_EHCI_ROOT_HUB_TT y # Root Hub Transaction Translators
  USB_EHCI_TT_NEWSCHED y # Improved transaction translator scheduling
  X86_CHECK_BIOS_CORRUPTION y
  X86_MCE y

  # PCI-Expresscard hotplug support
  HOTPLUG_PCI_PCIE y

  # Linux containers.
  NAMESPACES? y #  Required by 'unshare' used by 'nixos-install'
  RT_GROUP_SCHED? y
  CGROUP_DEVICE? y
  ${if versionAtLeast version "3.6" then ''
    MEMCG y
    MEMCG_SWAP y
  '' else ''
    CGROUP_MEM_RES_CTLR y
    CGROUP_MEM_RES_CTLR_SWAP y
  ''}
  CGROUP_PIDS y
  DEVPTS_MULTIPLE_INSTANCES y
  BLK_DEV_THROTTLING y
  CFQ_GROUP_IOSCHED y
  CFS_BANDWIDTH y

  # Enable staging drivers.  These are somewhat experimental, but
  # they generally don't hurt.
  STAGING y

  # PROC_EVENTS requires that the netlink connector is not built
  # as a module.  This is required by libcgroup's cgrulesengd.
  CONNECTOR y
  PROC_EVENTS y

  # Tracing.
  FTRACE y
  KPROBES y
  FUNCTION_TRACER y
  FTRACE_SYSCALLS y
  SCHED_AUTOGROUP y
  SCHED_TRACER y
  STACK_TRACER y
  ${optionalString (versionAtLeast version "3.10") ''
    UPROBE_EVENT y
  ''}
  FUNCTION_PROFILER y
  RING_BUFFER_BENCHMARK n

  USERFAULTFD y

  # Devtmpfs support.
  DEVTMPFS y

  X86_AMD_PLATFORM_DEVICE y

  PREEMPT y
  MEMORY y
  MEMORY_HOTPLUG y
  MEMORY_HOTREMOVE y
  MEMORY_FAILURE y
  HZ_300 y
  KEXEC_FILE y
  KEXEC_JUMP y

  # Easier debugging of NFS issues.
  ${optionalString (versionAtLeast version "3.4") ''
    SUNRPC_DEBUG y
  ''}

  # Virtualisation.
  PARAVIRT? y
  ${optionalString (!(features.grsecurity or false))
    (if versionAtLeast version "3.10" then ''
      HYPERVISOR_GUEST y
    '' else ''
      PARAVIRT_GUEST? y
    '')
  }
  KVM_APIC_ARCHITECTURE y
  KVM_ASYNC_PF y
  ${optionalString (versionOlder version "3.7") ''
    KVM_CLOCK? y
  ''}
  ${optionalString (versionAtLeast version "4.0") ''
    KVM_COMPAT? y
  ''}
  ${optionalString (versionAtLeast version "3.10") ''
    KVM_DEVICE_ASSIGNMENT? y
  ''}
  ${optionalString (versionAtLeast version "4.0") ''
    KVM_GENERIC_DIRTYLOG_READ_PROTECT y
  ''}
  ${optionalString (!features.grsecurity or true) ''
    KVM_GUEST y
  ''}
  KVM_MMIO y
  ${optionalString (versionAtLeast version "3.13") ''
    KVM_VFIO y
  ''}
  XEN? y
  XEN_DOM0? y
  ${optionalString ((versionAtLeast version "3.18") && (features.xen_dom0 or false))  ''
    PCI_XEN? y
    HVC_XEN? y
    HVC_XEN_FRONTEND? y
    XEN_SYS_HYPERVISOR? y
    SWIOTLB_XEN? y
    XEN_BACKEND? y
    XEN_BALLOON? y
    XEN_BALLOON_MEMORY_HOTPLUG? y
    XEN_EFI? y
    XEN_HAVE_PVMMU? y
    XEN_MCE_LOG? y
    XEN_PVH? y
    XEN_PVHVM? y
    XEN_SAVE_RESTORE? y
    XEN_SCRUB_PAGES? y
    XEN_SELFBALLOONING? y
    XEN_STUB? y
    XEN_TMEM? y
  ''}
  KSM y
  ${optionalString (stdenv.targetSystem == stdenv.lib.head stdenv.lib.platforms.i686-linux) ''
    HIGHMEM64G? y # We need 64 GB (PAE) support for Xen guest support.
  ''}
  ${optionalString (versionAtLeast version "3.9") ''
    VFIO_PCI_VGA y
  ''}
  VIRTIO_MMIO_CMDLINE_DEVICES y
  VIRT_DRIVERS y
  INTEL_IOMMU_SVM y

  # Media support.
  ${optionalString (versionAtLeast version "3.6") ''
    MEDIA_DIGITAL_TV_SUPPORT y
    MEDIA_CAMERA_SUPPORT y
    MEDIA_RC_SUPPORT y
  ''}
  ${optionalString (versionAtLeast version "3.7") ''
    MEDIA_USB_SUPPORT y
  ''}

  # Our initrd init uses shebang scripts, so can't be modular.
  ${optionalString (versionAtLeast version "3.10") ''
    BINFMT_SCRIPT y
  ''}

  # Enable the 9P cache to speed up NixOS VM tests.
  9P_FSCACHE y
  9P_FS_POSIX_ACL y
  9P_FS_SECURITY y

  # Enable transparent support for huge pages.
  TRANSPARENT_HUGEPAGE? y
  TRANSPARENT_HUGEPAGE_ALWAYS? n
  TRANSPARENT_HUGEPAGE_MADVISE? y

  # zram support (e.g for in-memory compressed swap).
  ${optionalString (versionAtLeast version "3.4") ''
    ZSMALLOC y
  ''}
  ZRAM m

  # Enable PCIe and USB for the brcmfmac driver
  BRCMFMAC_USB? y
  BRCMFMAC_PCIE? y

  # Support x2APIC (which requires IRQ remapping).
  ${optionalString (stdenv.system == "x86_64-linux") ''
    X86_X2APIC y
    IRQ_REMAP y
  ''}

  # Disable the firmware helper fallback, udev doesn't implement it any more
  FW_LOADER_USER_HELPER_FALLBACK n

  # ChromiumOS support
  ${optionalString (features.chromiumos or false) ''
    CHROME_PLATFORMS y
    VGA_SWITCHEROO n
    MMC_SDHCI_PXAV2 n
    NET_IPVTI n
    IPV6_VTI n
    REGULATOR_FIXED_VOLTAGE n
    TPS6105X n
    CPU_FREQ_STAT y
    IPV6 y
    MFD_CROS_EC y
    MFD_CROS_EC_LPC y
    MFD_CROS_EC_DEV y
    CHARGER_CROS_USB_PD y
    I2C y
    MEDIA_SUBDRV_AUTOSELECT n
    VIDEO_IR_I2C n
    BLK_DEV_DM y
    ANDROID_PARANOID_NETWORK n
    DM_VERITY n
    DRM_VGEM n
    CPU_FREQ_GOV_INTERACTIVE n
    INPUT_KEYRESET n
    DM_BOOTCACHE n
    UID_CPUTIME n

    ${optionalString (versionAtLeast version "3.18") ''
      CPUFREQ_DT n
      EXTCON_CROS_EC n
      DRM_POWERVR_ROGUE n
      CHROMEOS_OF_FIRMWARE y
      TEST_RHASHTABLE n
      BCMDHD n
      TRUSTY n
    ''}

    ${optionalString (versionOlder version "3.18") ''
      MALI_MIDGARD n
      DVB_USB_DIB0700 n
      DVB_USB_DW2102 n
      DVB_USB_PCTV452E n
      DVB_USB_TTUSB2 n
      DVB_USB_AF9015 n
      DVB_USB_AF9035 n
      DVB_USB_ANYSEE n
      DVB_USB_AZ6007 n
      DVB_USB_IT913X n
      DVB_USB_LME2510 n
      DVB_USB_RTL28XXU n
      USB_S2255 n
      VIDEO_EM28XX n
      VIDEO_TM6000 n
      USB_DWC2 n
      USB_GSPCA n
      SPEAKUP n
      XO15_EBOOK n
      USB_GADGET n
    ''}
  ''}

  ${extraConfig}
''
