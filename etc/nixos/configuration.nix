# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # layouts
  nixpkgs.overlays = [
    (self: super: 
      {
        polybar = (super.polybar.override (prev: rec{
    		
        })).overrideAttrs (oldAttrs: rec{
          pname = "polybar";
          version = "3.7.0";
          src = super.fetchFromGitHub {
            owner = pname;
            repo = pname;
            rev = version;
            hash = "sha256-Z1rL9WvEZHr5M03s9KCJ6O6rNuaK7PpwUDaatYuCocI=";
            fetchSubmodules = true;
          };
        });   

        hyprland = (super.hyprland.override (prev: rec{
    		  
        })).overrideAttrs (oldAttrs: rec{
          mesonFlags = builtins.concatLists [
            ["-Dauto_features=disabled"]
            ["-Dxwayland=enabled"]
            ["-Dlegacy_renderer=enabled"]
            ["-Dsystemd=enabled"]
          ];
        });    		
      }
    ) 
  ];
  
  
  # powerManagement.cpuFreqGovernor = "performance"; 
  # Often used values: “ondemand”, “powersave”, “performance”

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/ata-MidasForce_SSD_120GB_AA000000000000003126"; # change with your storage device id
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.theme = pkgs.nixos-grub2-theme;
  boot.loader.grub.extraEntries = ''  
  menuentry "Nixos livecd" --class installer {
    set isofile="/nixos.iso"      
    loopback loop (hd0,2)$isofile 
    #configfile (loop)/EFI/grub/grub.cfg
    linux (loop)/boot/bzImage findiso=/$isofile init=/nix/store/0x1xgnlgs3p73khg3m45g1n7qmh46pmz-nixos-system-nixos-23.05.3759.261abe8a44a7/init root=LABEL=nixos-23.05-x86_64 boot.shell_on_fail nohibernate loglevel=4 
    initrd (loop)/boot/initrd
  }
  menuentry "Slax (Persistent changes) from ISO" {
    loopback loop (hd0,2)/slax.iso
    linux (loop)/slax/boot/vmlinuz vga=normal load_ramdisk=1 prompt_ramdisk=0 rw printk.time=0 consoleblank=0 slax.flags=perch,automount fromiso=/slax.iso
    initrd (loop)/slax/boot/initrfs.img
  }
  
  '';
  #boot.loader.grub.extraEntriesBeforeNixOS = true;
  #boot.loader.grub.timeoutStyle = "hidden";
  #boot.plymouth.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nvidia driver
  services.xserver.videoDrivers = [ "fbdev" ];
  #nixpkgs.config.nvidia.acceptLicense = true;   
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
  #hardware.nvidia.modesetting.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # kernel
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # virtual camera
  # Make some extra kernel modules available to NixOS
  boot.extraModulePackages = with config.boot.kernelPackages;[ v4l2loopback.out ];  
  boot.kernelModules = [ "v4l2loopback" ];  
  boot.extraModprobeConfig = '' options v4l2loopback exclusive_caps=1 card_label="Virtual Camera" '';
  
  #zram
  zramSwap.enable = true;
  zramSwap.memoryPercent = 300;  
  
  #filesystem
  boot.supportedFilesystems = [
      "btrfs"
      "ntfs"
      "fat32"
      "exfat"
  ];  

  # waydroid
  #virtualisation = {
    #waydroid.enable = true;
    #lxd.enable = true;
    #lxc.enable = true;
  #};

  # lxc
  #virtualisation.lxc.defaultConfig = ''
    #lxc.net.0.type = veth
    #lxc.net.0.link = lxdbr0
    #lxc.net.0.flags = up
  #'';

   
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.hostName = "NixOS"; # Define your hostname.
  networking.networkmanager.enable = true;
  
  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.UTF-8";
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };

  # ENV
  environment.variables = {
    "WLR_NO_HARDWARE_CURSORS" = "1";
    "WLR_RENDERER" = "pixman";
    "WLR_RENDERER_ALLOW_SOFTWARE" = "1";
    "LIBGL_ALWAYS_SOFTWARE" = "1";
  };

  # Fonts  
  fonts.packages = with pkgs; [ nerdfonts ];

  # gvfs 
  services.gvfs.enable = true;

  # picom
  services.picom.enable = true;
  services.picom.fade = true;
  #services.picom.shadow = true;
  #services.picom.fadeExclude = [ 
  #  "window_type *= 'menu'"
  #];
  #services.picom.fadeSteps = [
  #  0.04
  #  0.04
  #];  
  

  # Enable the X11 display server.
  services.xserver.enable = true;

  # Login Manager.
  services.xserver.displayManager.lightdm.enable = true;

  # window manager
  # swaywm
    #programs.sway.enable = true;  
    #programs.sway.extraPackages = with pkgs; [
    #  waybar rofi slurp grim wf-recorder
    #  fuzzel foot
    #];

  # hypr
  services.xserver.windowManager.hypr.enable = true;

  # hyprland
  #programs.hyprland.enable = true;
  #programs.hyprland.enableNvidiaPatches = true;

  # openbox
  #services.xserver.windowManager.openbox.enable = true;

  # Desktop Environtmen
  #services.xserver.desktopManager.lxqt.enable = true;
  #services.xserver.desktopManager.budgie.enable = true;
  #services.xserver.desktopManager.deepin.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.desktopManager.pantheon.enable = true;
  #services.xserver.desktopManager.mate.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.desktopManager.enlightenment.enable = true;
  
  # plasma5 exclude
  environment.plasma5.excludePackages = with pkgs; [
    libsForQt5.elisa
    libsForQt5.gwenview
    libsForQt5.konsole
    libsForQt5.okular
    libsForQt5.spectacle    
    libsForQt5.ark
    orca
  ];

  # gnome exclude
  services.gnome.evolution-data-server.enable = pkgs.lib.mkForce false;
  services.gnome.gnome-online-accounts.enable = pkgs.lib.mkForce false;
  programs.gnome-terminal.enable = pkgs.lib.mkForce false;
  environment.gnome.excludePackages = with pkgs; [
    gnome.gnome-terminal
    gnome.gnome-system-monitor
    gnome.gnome-screenshot
    gnome.gnome-music
    gnome.gnome-keyring
    gnome.file-roller
    gnome.eog
    gnome.yelp
    gnome.totem
    gnome.gedit
    gnome.geary
    gnome.cheese
    orca
    epiphany
    gnome-text-editor
    gnome.nautilus
    gnome.gnome-contacts
    gnome.gnome-weather
    gnome.simple-scan
    gnome-photos
    evince
    gnome.gnome-disk-utility    
    gnome-tour
  ];
  
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.  
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;    
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ramuni = {
    isNormalUser = true;
    description = "Ramuni muni";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];    
  };
  
  # editable nix store
  #boot.readOnlyNixStore = false;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [       
    gimp
    inkscape-with-extensions
    chromium 
    libreoffice-qt jre
    krdc
    krfb
    kget
    pdfarranger
    gparted    
    simplescreenrecorder
    vlc
    xorg.xhost pulseaudio wget onboard ffmpeg_5-full
    xfce.mousepad
    lxde.lxtask htop btop neofetch    
    p7zip       
  ] ++ (
    if (config.services.xserver.desktopManager.lxqt.enable == true)
    then with pkgs; [
      libsForQt5.kwin
      libsForQt5.systemsettings
      libsForQt5.kglobalaccel
      libsForQt5.qt5.qttools    
      networkmanagerapplet       
    ] else with pkgs; [
      lxqt.screengrab
      lxqt.pavucontrol-qt
      lxqt.qterminal
      lxqt.pcmanfm-qt
      lxmenu-data
      menu-cache    
      lxqt.lximage-qt
      lxqt.lxqt-archiver
      lxqt.lxqt-sudo
      libsForQt5.breeze-icons
    ]
  ) ++ (
    if(config.services.xserver.desktopManager.plasma5.enable == true)
    then with pkgs;[
        libsForQt5.applet-window-buttons
    ] else with pkgs;[

    ]
  ) ++ (
    if(config.services.xserver.windowManager.hypr.enable == true)
    then with pkgs;[
      feh
      polybar
      rofi    
      networkmanagerapplet
      lxappearance
      apple-cursor
      udiskie
      lxqt.lxqt-policykit
      dunst
      libnotify
      volumeicon
      clipit
      gnome.zenity
      numlockx      
      xorg.setxkbmap
    ] else [

    ]
  );

  #virtualbox
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.guest.x11 = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;
    
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
  
  # ftp
  #services.vsftpd.enable = false;
  #services.vsftpd.writeEnable =true;
  #services.vsftpd.localUsers = true;
  #services.vsftpd.anonymousUser = true;
  #services.vsftpd.anonymousUserHome = "/home/ftp/";
  #services.vsftpd.anonymousUserNoPassword = true;
  #services.vsftpd.anonymousUploadEnable = true;
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 5900 21 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  # webserver
  #services.httpd.enable = true;
  #services.httpd.virtualHosts.localhost.documentRoot = "/home/ramuni/Public/";

  # my dot file  
  home-manager.users.ramuni = {    
    # hypr.conf
    home.file.".config/hypr/hypr.conf".text = ''
gaps_in=3
border_size=3
gaps_out=3
rounding=7
max_fps=60 # max fps for updates of config & animations
focus_when_hover=1 # 0 - do not switch the focus when hover (only for tiling)
main_mod=SUPER # For moving, resizing
intelligent_transients=1 # keeps transients always on top.
no_unmap_saving=1 # disables saving unmapped windows (seems to break sometimes)
scratchpad_mon=0 # self-explanatory

# Layout
layout=0 # 0 - dwindle (default), 1 - master
layout {
    no_gaps_when_only=1 # disables gaps and borders when only window on screen
}

# Bar config
Bar {
    height=20
    monitor=0
    enabled=0
    mod_pad_in=8
    # using this doesnt save the tray between reloads but fixes an issue with the bar disappearing.
    no_tray_saving=1 

    font.main=Noto Sans
    font.secondary=Noto Sans
    col.bg=0xff111111
    col.high=0xffff3333
    module=left,X,0xff8000ff,0xffffffff,1,workspaces
    module=pad,left,10
    module=left,,0xff7000dd,0xff7000dd,1,tray
    module=right,X,0xffffffff,0xff00ff33,1000,$date +%a,\ %b\ %Y\ \ %I:%M\ %p$
}

# colors
col.active_border=0x77ff3333
col.inactive_border=0x77222222

# animations
Animations {
    enabled=1
    speed=3 # for workspaces
    window_resize_speed=3 # for windows
    cheap=1 # highly recommended
    borders=0
    workspaces=1 # not really recommended
}

# keybinds
bind=SUPER,Q,exec,pkill Hypr
bind=SUPER,RETURN,exec,rofi -show drun
bind=SUPER,G,exec,google-chrome-stable
bind=SUPER,Space,togglefloating
bind=SUPER,C,killactive,
bind=,Print,exec,screengrab
bind=SUPER,P,exec,pcmanfm-qt
bind=SUPER,M,exec,mousepad
bind=SUPER,T,exec,qterminal
bind=SUPER,F,fullscreen,
# focus
bind=SUPER,LEFT,movefocus,l
bind=SUPER,RIGHT,movefocus,r
bind=SUPER,UP,movefocus,u
bind=SUPER,DOWN,movefocus,d
# switch workspace
bind=SUPERCTRL,1,workspace,1
bind=SUPERCTRL,2,workspace,2
bind=SUPERCTRL,3,workspace,3
bind=SUPERCTRL,4,workspace,4
bind=SUPERCTRL,5,workspace,5
bind=SUPERCTRL,6,workspace,6
bind=SUPERCTRL,7,workspace,7
bind=SUPERCTRL,8,workspace,8
bind=SUPERCTRL,9,workspace,9
bind=SUPERCTRL,Right,nextworkspace
bind=SUPERCTRL,Left,lastworkspace
# move app to workspace
bind=SUPERALT,1,movetoworkspace,1
bind=SUPERALT,2,movetoworkspace,2
bind=SUPERALT,3,movetoworkspace,3
bind=SUPERALT,4,movetoworkspace,4
bind=SUPERALT,5,movetoworkspace,5
bind=SUPERALT,6,movetoworkspace,6
bind=SUPERALT,7,movetoworkspace,7
bind=SUPERALT,8,movetoworkspace,8
bind=SUPERALT,9,movetoworkspace,9
bind=SUPERALT,Right,movetorelativeworkspace,+
bind=SUPERALT,Left,movetorelativeworkspace,-
#window rule
windowrule=float,class:zenity
windowrule=move 500 250,class:zenity
windowrule=size 350 220,class:zenity
windowrule=float,role:pop-up
# autostart
exec-once=feh --bg-fill background.png
exec-once=polybar top
exec-once=dunst
exec-once=lxqt-policykit-agent 
exec-once=udiskie -tnf pcmanfm-qt
exec-once=nm-applet
exec=pcmanfm-qt --desktop -d
exec-once=clipit
exec=pactl unload-module module-echo-cancel
exec=pactl load-module module-echo-cancel
exec=volumeicon
    '';

    # polybar conf
    home.file.".config/polybar/config.ini".text = ''
[bar/top]
width = 100%
height = 19pt
;radius = 10
bottom = 0
;border-left-size = 0.5%
;border-right-size = 0.5%
border-top-size = 1
border-bottom-size = 1
padding-left = 1
padding-right = 1
module-margin = 0
;dpi = 96
background = #99000000
foreground = #ffffff
;fixed-center = true
border-color = #00000000
font-0 = monospace:size=11;1
font-1 = 3270 Nerd Font:style=Regular
font-2 = Font Awesome 6 Free Solid:style=Solid
line-size = 3pt
override-redirect = false
wm-restack = generic
modules-left = launcher xworkspaces
modules-center = xwindow
modules-right =  ara us tray date exit

[module/ara]
type = custom/text
content = "ar "
click-left = setxkbmap -layout ara
;background = #bbffffff

[module/us]
type = custom/text
content = "us"
click-left = setxkbmap -layout us
;background = #bbffffff

[module/exit]
type = custom/text
content = " "
click-left = zenity --question --title="Logout" --text "Are you sure to logout?" && pkill Hypr
;background = #bbffffff

[module/launcher]
type = custom/text
content = " NixOS "
click-left = rofi -show drun
click-right = pkill rofi
;background = #bbffffff

[module/xworkspaces]
type = internal/xworkspaces

label-active = %name%
label-active-background = #99373B41
label-active-underline= #F0C674
label-active-padding = 1

label-occupied = %name%
label-occupied-padding = 1

label-urgent = %name%
label-urgent-background = #A54242
label-urgent-padding = 1

label-empty = %name%
label-empty-foreground = #707880
label-empty-padding = 1

[module/xwindow]
type = internal/xwindow
label = %title:0:60:...%

[module/xkeyboard]
type = internal/xkeyboard
blacklist-0 = num lock
label-layout = %layout%
label-layout-foreground = #F0C674
label-indicator-padding = 2
label-indicator-margin = 1
label-indicator-foreground = #bb282A2E
label-indicator-background = #8ABEB7

[module/date]
type = internal/date
interval = 1
date = %a, %e %b %Y %H:%M
;date-alt = %d %m %Y %H:%M
label = %date%
#label-foreground = \$\{colors.primary\}

[module/tray]
type = internal/tray
format-margin = 8px
tray-spacing = 8px
;tray-background = #ffffffff

[settings]
screenchange-reload = true
pseudo-transparency = true

; vim:ft=dosini

    '';
    
    # rofi conf
    home.file.".config/rofi/config.rasi".text = ''
configuration {
    drun-display-format: "{name}";
    disable-history: true;
}
* {
    foreground:  white;
    backlight:   #ccffeedd;
    background-color:  transparent;
    dark: #1c1c1c;
    // Black
    black:       #000000;
    lightblack:  #554444;
    tlightblack:  #554444cc;
    //
    // Red
    red:         #cd5c5c;
    lightred:    #cc5533;
    //
    // Green
    green:       #86af80;
    lightgreen:  #88cc22;
    //
    // Yellow
    yellow:      #e8ae5b;
    lightyellow:     #ffa75d;
    //
    // Blue
    blue:      #6495ed;
    lightblue:     #87ceeb;
    //
    // Magenta
    magenta:      #deb887;
    lightmagenta:     #996600;
    //
    // Cyan
    cyan:      #b0c4de;
    tcyan:      #ccb0c4de;
    lightcyan:     #b0c4de;
    //
    // White
    white:      #bbaa99;
    lightwhite:     #ddccbb;
    //
    // Bold, Italic, Underline
    highlight:     underline bold #ffffff;

    transparent: rgba(0,0,0,0);
    font: "Source Code Pro 10";
}
   
window {
    height:   70%;
    width: 50%;
    location: north;
    anchor:   north;

    border-color: grey;
    text-color: white;
    
    border-radius: 5px;
    y-offset: 120px;
    x-offset: 10px;
    children: [ inputbar, message, listview ];

    transparency: "screenshot";
    padding: 10px;
    border:  1px;
    border-radius: 10px;
    color: white;
    background-color: rgba(0,0,0,0.75);
    spacing: 0;

}
scrollbar {
    width: 0px ;
    border: 0;
    handle-width: 0px ;
    padding: 0;
}

message {
    border-color: @foreground;
    border:  0px 2px 2px 2px;
//    border-radius: 10px;
    padding: 5;
    background-color: @tcyan;
}
message {
    font: "Source Code Pro 8";
    color: @black;
}
inputbar {
    color: grey;
    padding: 5px;
    background-color: rgba(0,0,0,0.5);
    border: 1px;
    border-radius:  5px;

    font: "Source Code Pro 10";
    children: [ icon-k, entry ];
}

    icon-k {
    expand: false;
    filename: "gohome";
    size: 24;
    vertical-align: 0.5;

}

entry,prompt,case-indicator {
    text-font: inherit;
    text-color:inherit;
    padding: 2px;
}
prompt {
    margin:     0px 0.3em 0em 0em ;
}
listview {
    padding: 3px;
    border-radius: 0px 0px 0px 0px;

    border: 0px;
    background-color: rgba(0,0,0,0);
    dynamic: false;
    reverse: false;
    cycle: false;
}
element {
    padding: 1px;
    vertical-align: 0.5;
//    border: 2px;
    border-radius: 1px;
    background-color: rgba(0,0,0,0);
    color: white;
    font: inherit;
    children: [ element-icon, element-text ];
}
element-text {
    background-color: inherit;
    text-color:       inherit;
}
element.selected.normal {
    background-color: @blue;
}
element.normal.active {
    foreground: @lightblue;
}
element.normal.urgent {
    foreground: @lightred;
}
element.alternate.normal {
    background-color: rgba(0,0,0,0);
}
element.normal.normal {
    background-color: rgba(0,0,0,0);
}

element.alternate.active {
    foreground: @lightblue;
}
element.alternate.urgent {
    foreground: @lightred;
}
element.selected.active {
    background-color: @lightblue;
    foreground: @dark;
}
element.selected.urgent {
    background-color: @lightred;
    foreground: @dark;
}
vertb {
    expand: false;
    children: [ dummy0, mode-switcher, dummy1  ];
}
dummy0,  dummy1 {
    expand: true;
}
mode-switcher {
    expand: false;
    orientation: vertical;
    spacing: 0px;
    border: 0px 0px 0px 0px;
}
button {
    font: "FontAwesome 22";
    padding: 6px;
    border: 2px 0px 2px 2px;
    border-radius: 4px 0px 0px 4px;
    background-color: @tlightblack;
    border-color: @foreground;
    color: @foreground;
    horizontal-align: 0.5;
}
button selected normal {
    color: @dark;
    border: 2px 0px 2px 2px;
    background-color: @backlight;
    border-color: @foreground;
}
error-message {
    expand: true;
    background-color: red;
    border-color: darkred;
    border: 2px;
    padding: 1em;
}    
    '';
    
    home.stateVersion = "23.05";    
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  
}
