{ pkgs, buildVimPlugin, buildVimPluginFrom2Nix }:

{
  lsp-zero = buildVimPlugin rec {
    pname = "lsp-zero";
    version = "eb581c105321e26b2dc3f8e83f0ebdbbc3701865";
    src = pkgs.fetchFromGitHub {
      owner = "VonHeikemen";
      repo = "lsp-zero.nvim";
      rev = version;
      sha256 = "92/jQKMVzf5/QeABLVwbxvpnonRgeMwcW+jpi7+tLic=";
    };
  };

  mason-nvim = buildVimPluginFrom2Nix {
    pname = "mason.nvim";
    version = "2022-07-31";

    src = pkgs.fetchFromGitHub {
      owner = "williamboman";
      repo = "mason.nvim";
      rev = "5676d6d63850ca63fe468a578387fed9eb0f69a3";
      sha256 = "06b594lv8akxmd54sa18g5w18z1blcvs8zk2p9dnczx9107099yx";
    };
  };

  mason-lspconfig-nvim = buildVimPluginFrom2Nix {
    pname = "mason-lspconfig.nvim";
    version = "2022-07-31";

    src = pkgs.fetchFromGitHub {
      owner = "williamboman";
      repo = "mason-lspconfig.nvim";
      rev = "f87c5796603aa3436d9cb1d36dbe5b2e579e4034";
      sha256 = "01d4y5qlsl3faxq3a03p7d1cqfclfrhy42m5yyrbzg3q2wmpgvqq";
    };

    meta.homepage = "https://github.com/williamboman/mason-lspconfig.nvim";
  };

  LuaSnip = buildVimPluginFrom2Nix {
    pname = "LuaSnip";
    version = "2022-07-31";

    src = pkgs.fetchFromGitHub {
      owner = "L3MON4D3";
      repo = "LuaSnip";
      rev = "52f4aed58db32a3a03211d31d2b12c0495c45580";
      sha256 = "0drc847m55xwiha1wa2ykd5cwynmvd5ik2sys9v727fb4fbqmpa0";
    };

    meta.homepage = "https://github.com/L3MON4D3/LuaSnip";
  };

  telescope-ghq = buildVimPluginFrom2Nix {
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

  nvim-ts-rainbow = buildVimPluginFrom2Nix {
    pname = "nvim-ts-rainbow";
    version = "2022-12-28";

    src = pkgs.fetchFromGitHub {
      owner = "p00f";
      repo = "nvim-ts-rainbow";
      rev = "064fd6c0a15fae7f876c2c6dd4524ca3fad96750";
      sha256 = "Uct+2jg9qZD7V3eSnICLNu2jpaQLc3ugW8qunPiAynM=";
    };

    meta.homepage = "https://github.com/p00f/nvim-ts-rainbow";
  };

}
