{
  pkgs,
  buildVimPlugin,
}: {
  telescope-ghq = buildVimPlugin {
    pname = "telescope-ghq";
    version = "2022-12-23";

    src = pkgs.fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope-ghq.nvim";
      rev = "dc1022f91100ca06c9c7bd645f08e2bf985ad283";
      sha256 = "Uct+2jg9qZD7V3eSnICLNu2jpaQLc3ugW8qunPiAynM=";
    };

    meta.homepage = "https://github.com/nvim-telescope/telescope-ghq.nvim";
  };
  kdl = buildVimPlugin {
    pname = "kdl.vim";
    version = "2022-12-23";

    src = pkgs.fetchFromGitHub {
      owner = "imsnif";
      repo = "kdl.vim";
      rev = "b84d7d3a15d8d30da016cf9e98e2cfbe35cddee5";
      sha256 = "Uct+2jg9qZD7V3eSnICLNu2jpaQLc3ugW8qunPiAynM=";
    };

    meta.homepage = "https://github.com/imsnif/kdl.vim";
  };
}
