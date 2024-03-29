# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

# let 
#   # bash script to let dbus know about important env variables and
#   # propagate them to relevent services run at the end of sway config
#   # see
#   # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
#   # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
#   # some user services to make sure they have the correct environment variables
#   dbus-sway-environment = pkgs.writeTextFile {
#     name = "dbus-sway-environment";
#     destination = "/bin/dbus-sway-environment";
#     executable = true;

#     text = ''
#       dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
#       systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
#       systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
#     '';
#     };

#   # currently, there is some friction between sway and gtk:
#   # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
#   # the suggested way to set gtk settings is with gsettings
#   # for gsettings to work, we need to tell it where the schemas are
#   # using the XDG_DATA_DIR environment variable
#   # run at the end of sway config
# configure-gtk = pkgs.writeTextFile {
#   name = "configure-gtk";
#   destination = "/bin/configure-gtk";
#   executable = true;
#   text = let
#     schema = pkgs.gsettings-desktop-schemas;
#     datadir = "${schema}/share/gsettings-schemas/${schema.name}";
#   in ''
#     export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
#     gnome_schema=org.gnome.desktop.interface
#     gsettings set $gnome_schema gtk-theme 'Dracula'
#   '';
# };

# in

{
  imports =
    [ # Include the results of the hardware scan.
      # <nixos-hardware/common/gpu/disable.nix>
      # <nixos-hardware/common/pc/laptop/acpi_call.nix>
      # <nixos-hardware/common/cpu/intel/cpu-only.nix>
      <nixos-hardware/lenovo/thinkpad/x1-extreme/default.nix>


      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "teg3"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # boot kernel parameters
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  boot.initrd.availableKernelModules = [ "battery" ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.trackpoint.device = "TPPS/2 Elan TrackPoint";


  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # NVIDIA F*** YOU

  # This runs only intel/amdgpu igpus and nvidia dgpus do not drain power.

  # ##### disable nvidia, very nice battery life.
  # boot.extraModprobeConfig = ''
  #   blacklist nouveau
  #   options nouveau modeset=0
  # '';
  
  # services.udev.extraRules = ''
  #   # Remove NVIDIA USB xHCI Host Controller devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

  #   # Remove NVIDIA USB Type-C UCSI devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

  #   # Remove NVIDIA Audio devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

  #   # Remove NVIDIA VGA/3D controller devices
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  # '';
  # boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

   hardware.nvidia = {

     # Modesetting is required.
     modesetting.enable = true;

     # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
     powerManagement.enable = true; 
     # Fine-grained power management. Turns off GPU when not in use.
     # Experimental and only works on modern Nvidia GPUs (Turing or newer).
     powerManagement.finegrained = true;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modulescompatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
     open = false;

      # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
     nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
     package = config.boot.kernelPackages.nvidiaPackages.stable;

     prime = {
       offload = {
         enable = true;
         enableOffloadCmd = true;
       };
       intelBusId = "PCI:0:2:0";
       nvidiaBusId = "PCI:1:0:0";
     };
    
   };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.monitorSection = ''
    DisplaySize 344 215
  '';


  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hugo = {
    isNormalUser = true;
    description = "Hugo Berthet-Rambaud";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      fish
      helix
      firefox
      alacritty
      gh
      git
      yadm
      zathura
      nerdfonts
      pciutils
      vlc
      # networkmanager-openconnect
    #  thunderbird
    ];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # gnome extensions
    gnomeExtensions.dash-to-dock
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.battery-time-2
    gnomeExtensions.pano
    gnome.gnome-tweaks
    gnome.gnome-shell-extensions

    wget
    htop
    # Fetch
    cpufetch
    neofetch
    nitch

    # Sway & etc.
    sway
    fuzzel
    # dbus
    # dbus-sway-environment
    alacritty
    # wayland
    swaylock
    swayidle
    grim
    slurp
    # wl-clipboard
    mako
    # wdisplays
    i3status-rust
    # networkmanagerapplet
    font-awesome
    dejavu_fonts
  ];

  programs.fish.enable = true;
  services.flatpak.enable = true;

  # services.dbus.enable = true;
  programs.sway = {
    enable = true;
    # wrapperFeatures.gtk = true;
    extraOptions = ["--unsupported-gpu"];
  };


  # laptop services
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
     battery = {
        governor = "powersave";
        turbo = "never";
     };
     charger = {
        governor = "performance";
        turbo = "auto";
     };
   };


  # Better scheduling for CPU cycles - thanks System76!!!
  services.system76-scheduler.settings.cfsProfiles.enable = true;

  # Enable TLP (better than gnomes internal power manager)
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; 

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  services.power-profiles-daemon.enable = false;

  # Enable powertop
  powerManagement.powertop.enable = true;

  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
