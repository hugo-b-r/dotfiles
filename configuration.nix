# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
 
let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Adwaita'
        '';
  };


in

{
  imports = [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.initrd.kernelModules = [ "radeon" ];
  boot.supportedFilesystems = [ "ntfs" ];
  
  # for Southern Islands (SI ie. GCN 1) cards
  boot.kernelParams = [ "radeon.si_support=1" "amdgpu.si_support=0" "radeon.cik_support=1" "amdgpu.cik_support=0" ];
  
  
  networking.hostName = "777"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.utf8";
    LC_IDENTIFICATION = "fr_FR.utf8";
    LC_MEASUREMENT = "fr_FR.utf8";
    LC_MONETARY = "fr_FR.utf8";
    LC_NAME = "fr_FR.utf8";
    LC_NUMERIC = "fr_FR.utf8";
    LC_PAPER = "fr_FR.utf8";
    LC_TELEPHONE = "fr_FR.utf8";
    LC_TIME = "fr_FR.utf8";
  };
  
  # Flatpak
  services.flatpak.enable = true;
    
  # Gnome keyring
  services.gnome.gnome-keyring.enable = true;
  
  # backlight
  programs.light.enable = true;
  
  # Enable gpg
  services.pcscd.enable = true;
  programs.gnupg.agent = {
       enable = true;
       enableSSHSupport = true;
  };
    
  
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      i3status-rust
      wlr-randr
      swaylock
      swayidle
      wl-clipboard
      wf-recorder
      mako # notification daemon
      grim
      slurp
      alacritty # Alacritty is the default terminal in the config
      wofi
      gnome.adwaita-icon-theme
      swappy
    ];
  };
  
  services.dbus.enable = true;
  
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  fonts.fonts = with pkgs; [
    jetbrains-mono
    cm_unicode
    terminus-nerdfont
  ];
    
   
  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Vulkan
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
  hardware.opengl.extraPackages = with pkgs; [
      amdvlk
    ];
  
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
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hugo = {
    isNormalUser = true;
    description = "Hugo";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
      firefox
      git
      helix
      tectonic
      yadm
      #  thunderbird
    ];
    shell = pkgs.zsh;
  };
  
    security.sudo.extraRules= [
        {  users = [ "privileged_user" ];
            commands = [
                { command = "ALL" ;
                    options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
                }
            ];
        }
    ];  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xorg.xf86videoati xorg.xf86videoamdgpu xorg.xf86videointel gcc gimp gcc-arm-embedded git helix parted wget yadm
  ];
  
  system.stateVersion = "22.11"; # Did you read the comment?

}

