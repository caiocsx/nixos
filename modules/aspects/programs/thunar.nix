{ ... }:
{
  den.aspects.thunar = {
    nixos =
      { pkgs, ... }:
      {
        programs = {
          thunar = {
            enable = true;
            plugins = with pkgs; [
              thunar-archive-plugin
              thunar-volman
            ];
          };
          xfconf.enable = true;
        };

        services = {
          gvfs.enable = true;
          tumbler.enable = true;
        };

        environment.systemPackages = with pkgs; [
          file-roller
          ffmpegthumbnailer
          gvfs
          glib
        ];
      };

    homeManager = { ... }: {
      home.sessionVariables.FILE_MANAGER = "thunar";

      xdg = {
        configFile."Thunar/uca.xml".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
            <action>
              <icon>utilities-terminal</icon>
              <name>Open Terminal Here</name>
              <unique-id>1700000000000</unique-id>
              <command>sh -c '$TERMINAL --working-directory "$1"' _ %f</command>
              <description>Open terminal in this folder</description>
              <patterns>*</patterns>
              <startup-notify>false</startup-notify>
              <directories/>
            </action>
            <action>
              <icon>accessories-text-editor</icon>
              <name>Edit File</name>
              <unique-id>1700000000001</unique-id>
              <command>sh -c '$TERMINAL -e $EDITOR "$1"' _ %f</command>
              <description>Edit file with default editor</description>
              <patterns>*</patterns>
              <startup-notify>false</startup-notify>
              <text-files/>
            </action>
          </actions>
        '';

        mimeApps.defaultApplications = {
          "inode/directory" = "thunar.desktop";
          "application/x-directory" = "thunar.desktop";

          "application/vnd.rar" = "org.gnome.FileRoller.desktop";
          "application/x-rar" = "org.gnome.FileRoller.desktop";
          "application/x-rar-compressed" = "org.gnome.FileRoller.desktop";

          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/x-zip-compressed" = "org.gnome.FileRoller.desktop";
          "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";
          "application/x-gzip" = "org.gnome.FileRoller.desktop";
          "application/x-bzip2" = "org.gnome.FileRoller.desktop";
        };

        dataFile = {
          "applications/thunar-settings.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Thunar Settings
            Exec=true
            NoDisplay=true
          '';
          "applications/thunar-bulk-rename.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Thunar Bulk Rename
            Exec=true
            NoDisplay=true
          '';
          "applications/thunar-volman-settings.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Thunar Volman Settings
            Exec=true
            NoDisplay=true
          '';
        };
      };
    };
  };
}
