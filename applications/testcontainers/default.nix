{...}: {
  home.file.testcontainers = {
    target = ".testcontainers.properties";
    text = ''
      testcontainers.reuse.enable=true
    '';
  };
}
