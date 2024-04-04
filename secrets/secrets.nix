let
  charlie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwCrkUq76rnolIfL8eApseG7rlmxCWDlqPx2Xti/fYH chwiegand@proton.me";
  # system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhpfgRj6BrVcJ160+D54X7OVlZOVdYYmlGPwQmWdKdH root@emily";
  allKeys = [charlie];
in {
  "hashedUserPassword.age".publicKeys = allKeys;
  "sambaPassword.age".publicKeys = allKeys;
  "smtpPassword.age".publicKeys = allKeys;
  "telegramChannelId.age".publicKeys = allKeys;
  "telegramApiKey.age".publicKeys = allKeys;
  "wireguardCredentials.age".publicKeys = allKeys;
  "cloudflareDnsApiCredentials.age".publicKeys = allKeys;
  "invoiceNinja.age".publicKeys = allKeys;
  "radarrApiKey.age".publicKeys = allKeys;
  "readarrApiKey.age".publicKeys = allKeys;
  "sonarrApiKey.age".publicKeys = allKeys;
  "tailscaleAuthKey.age".publicKeys = allKeys;
  "paperless.age".publicKeys = allKeys;
  "resticBackblazeEnv.age".publicKeys = allKeys;
  "resticPassword.age".publicKeys = allKeys;
  "wireguardPrivateKey.age".publicKeys = allKeys;
  "wireguardPrivateKeyAlison.age".publicKeys = allKeys;
  "bwSessionFish.age".publicKeys = allKeys;
  "icloudDrive.age".publicKeys = allKeys;
  "icloudDriveUsername.age".publicKeys = allKeys;
  "pingvinCloudflared.age".publicKeys = allKeys;
  "jellyfinApiKey.age".publicKeys = allKeys;
  "jellyseerrApiKey.age".publicKeys = allKeys;
  "duckDNSDomain.age".publicKeys = allKeys;
  "duckDNSToken.age".publicKeys = allKeys;
}
