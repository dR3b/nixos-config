{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0gSy7qdULWLSpGuGM6BAoFztX123g/cbW6x3TfzKo0s59y9OrzHrCSTYg3QN9BY1jLRp5DSMjHvsPS1Z/yp3EIJJS/dDso5/noDqOMBLOQgIdCLKipTudngpFDvnCAAg0IQl6iuVRznQvq9Xww65uYyR3OAv4DMvHFQn0qa5G3ZHCoj7I6FATTwGDKPeuqVF2MtdXC1XXx7v7zsar1sBhibUlbWSWhSvw+vhM+Qtj95wkHzI8O93Xy8Vqb5/OoXQDGyA0MnORCLeE8t7EvUi9ukXGz6QMwRX/T1RTLBP+pvrT5UyPtchzgZigbxvegnAy8HRA7I9TlUSFnTVvN6sg6z7n/F09HX1ETBv1qce/uuDc+npfM6Kdykz93ydro1ZfnPabD6rvie972EK5IVsO6n5066vVVhUt9QxDl2CDa0tLBxnGovvV1nmtcjq2AewOX2vj5qD0U256AiiS8tNA0i9GQLW90x6o1/Ih2xaPagfrRmpQjR1ecbEFYxT34Lp5ZuC9x5Nm67RGb4JvvbMrz3qjR5YARKOiryJ5owrN3TUJmYp75xT7QBGkXBwhQJZwwBFhg5rKC5BJIj5x4PGJXrwHHuk6gpbLRbgoT69NmJYIkKZaPSIt+oOzVmgKBM5LTtI4JI8kPs2CHo2FwuYAnP9XAfGoTuB/Ir9ECkFoEQ== davidak" ];
}
