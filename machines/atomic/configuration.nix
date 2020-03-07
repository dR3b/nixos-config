{ config, pkgs, lib, ... }:

let
  pubkey = import ../../services/pubkey.nix;
  secrets = import /root/secrets.nix;
in
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ../../profiles/server.nix
      ../../modules/satzgenerator.nix
    ];

  boot.loader.grub.device = "/dev/sda";

  boot.kernel.sysctl = {
    # recommended by mysqltuner
    "vm.swappiness" = 10;
    "fs.aio-max-nr" = 1048576;
  };

  networking = rec {
    # hostname from mnemonic encoding word list
    # http://web.archive.org/web/20091003023412/http://tothink.com/mnemonic/wordlist.txt
    # you could also consider one of these lists https://namingschemes.com/
    hostName = "atomic";
    domain = "davidak.de";

    interfaces = {
      ens3.ipv4.addresses = [
        # external 138.201.246.37
        { address = "172.31.1.100"; prefixLength = 24; }
      ];
      ens3.ipv6.addresses = [
        # davidak
        { address = "2a01:04f8:0c17:5c0e::1"; prefixLength = 64; }
        # aquaregia
        { address = "2a01:04f8:0c17:5c0e::2"; prefixLength = 64; }
        # brennblatt
        { address = "2a01:04f8:0c17:5c0e::4"; prefixLength = 64; }
        # meinsack
        { address = "2a01:04f8:0c17:5c0e::8"; prefixLength = 64; }
        # kf
        { address = "2a01:04f8:0c17:5c0e::16"; prefixLength = 64; }
        # satzgenerator
        { address = "2a01:04f8:0c17:5c0e::32"; prefixLength = 64; }
        # chan
        { address = "2a01:04f8:0c17:5c0e::64"; prefixLength = 64; }
        # gutesoftware
        { address = "2a01:04f8:0c17:5c0e::128"; prefixLength = 64; }
      ];
    };

    nameservers = [ "213.133.99.99" "213.133.98.98" "213.133.100.100" ];
    defaultGateway = { address = "172.31.1.1"; interface = "ens3"; };
    defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 80 443 8384 31416 19999 64738 ];
      allowedUDPPorts = [];
    };

    useDHCP = false;
  };

  # Monitoring
  services.netdata = {
    enable = true;
    config = {
      global = {
        "default port" = "19999";
        "bind to" = "*";
        # 1 day
        "history" = "86400";
        "error log" = "syslog";
        "debug log" = "syslog";
      };
    };
  };
  systemd.enableCgroupAccounting = true;
  services.vnstat.enable = true;

  # MariaDB
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    extraOptions = ''
      query_cache_type = 1
      query_cache_limit = 2M
      query_cache_size = 4M
      thread_cache_size = 4
      innodb_buffer_pool_size = 325M
      innodb_buffer_pool_instances = 1
      # smallest value since it's not used
      aria_pagecache_buffer_size = 128K
      # values should be equal
      tmp_table_size = 30M
      max_heap_table_size = 30M
    '';
  };

  services.mysqlBackup = {
    enable = true;
    databases = [ "mysql" "piwik" "satzgenerator" ];
    user = "root";
    calendar = "04:00:00";
    singleTransaction = true;
  };

  # Create webspaces and users
  system.activationScripts.create-varwww = "mkdir -p -m 0755 /var/www";
  users.mutableUsers = false;
  users.extraUsers = lib.genAttrs [
    "aquaregia"
    "aww"
    "brennblatt"
    "chan"
    "davidak"
    "default"
    "gnaclan"
    "kf"
    "meinsack"
    "personen"
    "piwik"
    "gutesoftware"
  ] (user:  {
    isNormalUser = true;
    home = "/var/www/${user}";
    openssh.authorizedKeys.keys = [ pubkey.davidak ];
  });
  system.activationScripts.webspace = "for dir in /var/www/*/; do chmod 0755 \${dir}; mkdir -p -m 0755 \${dir}/{web,log}; chown \$(stat -c \"%U:%G\" \${dir}) \${dir}/web; chown caddy:users \${dir}/log; done";
  system.activationScripts.default-site = "touch /var/www/default/web/index.html";

  # PHP-FPM
  services.phpfpm = {
    #phpPackage = pkgs.php56;
    phpOptions =
    ''
      date.timezone = "Europe/Berlin"
      ;memory_limit = 256M
      ;max_execution_time = 60

      zend_extension = ${pkgs.php}/lib/php/extensions/opcache.so
      opcache.enable = 1
      opcache.memory_consumption = 64
      opcache.interned_strings_buffer = 16
      opcache.max_accelerated_files = 10000
      opcache.max_wasted_percentage = 5
      opcache.use_cwd = 1
      opcache.validate_timestamps = 1
      opcache.revalidate_freq = 2
      opcache.fast_shutdown = 1
    '';
    pools = {
      piwik = {
        user = "piwik";
        group = "users";
        settings = {
          "listen.owner" = "caddy";
          "listen.group" = "caddy";
          "listen.mode" = "0660";

          "pm" = "dynamic";
          "pm.max_children" = "10";
          "pm.start_servers" = "2";
          "pm.min_spare_servers" = "1";
          "pm.max_spare_servers" = "3";
          "pm.max_requests" = "500";

          "php_admin_value[always_populate_raw_post_data]" = "-1";
        };
      };
    gnaclan = {
      user = "gnaclan";
      group = "users";
      settings = {
        "listen.owner" = "caddy";
        "listen.group" = "caddy";
        "listen.mode" = "0660";

        "pm" = "dynamic";
        "pm.max_children" = "10";
        "pm.start_servers" = "2";
        "pm.min_spare_servers" = "1";
        "pm.max_spare_servers" = "3";
        "pm.max_requests" = "500";
      };
    };
    chan = {
      user = "chan";
      group = "users";
      settings = {
        "listen.owner" = "caddy";
        "listen.group" = "caddy";
        "listen.mode" = "0660";

        "pm" = "dynamic";
        "pm.max_children" = "10";
        "pm.start_servers" = "2";
        "pm.min_spare_servers" = "1";
        "pm.max_spare_servers" = "3";
        "pm.max_requests" = "500";
      };
    };
    };
  };

  # Caddy Webserver
  services.caddy = {
    enable = true;
    email = "post@davidak.de";
    agree = true;
    config = ''
    import /var/www/*/web/Caddyfile

    satzgenerator.net www.satzgenerator.net www.satzgenerator.de {
      redir https://satzgenerator.de{uri}
    }

    satzgenerator.de {
      proxy / ${config.services.satzgenerator.bind} {
        transparent
      }
    }

    :80 {
      root /var/www/default/web
      header / X-Backend-Server {hostname}
    }
    '';
  };

  services.satzgenerator = {
    enable = true;
    bind = "127.0.0.1:8000";
    workers = 5;
    database = {
      host = "127.0.0.1";
      user = secrets.satzgenerator_mysql_user;
      password = secrets.satzgenerator_mysql_password;
      name = "satzgenerator";
    };
  };

  # Cron
  services.cron = {
    enable = true;
    mailto = "root";
    systemCronJobs = [
      "5 * * * * piwik ${pkgs.php}/bin/php /var/www/piwik/web/console core:archive --url=https://stats.davidak.de/ > /var/www/piwik/piwik-archive.log"
    ];
  };

  services.murmur = {
    enable = true;
    clientCertRequired = true;
    hostName = "172.31.1.100 2a01:04f8:0c17:5c0e::1";
    registerName = "Knochtensprech";
    registerHostname = "davidak.de";
    welcometext = "Willkommen auf unserem Mumble-Server!";
    bandwidth = 128000;
  };

  # Packages
  environment.systemPackages = with pkgs; [ vnstat php ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";
}
