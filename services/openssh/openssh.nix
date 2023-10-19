# SPDX-FileCopyrightText: 2023 Technology Innovation Institute (TII)
#
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  pkgs,
  config,
  ...
}: {
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.KbdInteractiveAuthentication = false;
    settings.PasswordAuthentication = false;
    settings.ClientAliveInterval = 180;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [22];
  # Ban brute force SSH
  services.fail2ban.enable = true;
}
