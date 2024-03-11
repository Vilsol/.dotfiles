{
  programs.git = {
    enable = true;
    userName = "Vilsol";
    userEmail = "me@vil.so";
    lfs.enable = true;
    signing = {
      key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhRBxUUPgkEoruyuKJHSjhXeAOybE2HoYwyOf18j37EiarZ6kJDEwM/6F7vgnTxr/qBzGUWz5iw1evyvEePm3mxNDntsvxzV1E8ATsTXZ3VPBJbN76WEOcer4gCOkbu7gbqgfpI23SQBM9IM0NczIj1MwWd9XPewVm+cCva6MHX7DGNOh5ErdXEgiVgkwA2MrvXF9U4ouCjesBx9cSmFpR69YujuANgtDCfMR5fEZ2Iy+L9F+UgP6l3E5A0Z5LZKqZzySOGiukjsXqHVD0GQFIbLt4a/+hyyrj4leFJTt6YEQ8y7u5si1mzjTKBDIdEHLjDMmuW8lR4m5w/Qb1s9nd";
      signByDefault = true;
      gpgPath = "";
    };
    extraConfig = {
      gpg = {
        format = "ssh";
        ssh = {
          program = "/run/current-system/sw/bin/op-ssh-sign";
        };
      };
      diff.lockdb = {
        textconf = "bun";
        binary = true;
      };
    };
  };
}
