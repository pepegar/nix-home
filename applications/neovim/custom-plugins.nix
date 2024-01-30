{ pkgs, buildVimPlugin }:

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

  mason-nvim = buildVimPlugin {
    pname = "mason.nvim";
    version = "2023-01-09";

    src = pkgs.fetchFromGitHub {
      owner = "williamboman";
      repo = "mason.nvim";
      rev = "8a1a49b9e8147b4c1a3314739720357c0ba1ed1a";
      sha256 = "sha256-/B7W9w//Hu1NGkImfAimT/vGM+JYik7dFo1QAqFckIs=";
    };
  };

  mason-lspconfig-nvim = buildVimPlugin {
    pname = "mason-lspconfig.nvim";
    version = "2023-01-09";

    src = pkgs.fetchFromGitHub {
      owner = "williamboman";
      repo = "mason-lspconfig.nvim";
      rev = "3751eb5c56c67b51e68a1f4a0da28ae74ab771c1";
      sha256 = "sha256-wEqFUCXN9QLoWXQsbUySeDNBmFH2wW8sSCKrpvR89xw=";
    };

    meta.homepage = "https://github.com/williamboman/mason-lspconfig.nvim";
  };

  LuaSnip = buildVimPlugin {
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

  nvim-ts-rainbow = buildVimPlugin {
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

  golden-size = buildVimPlugin {
    pname = "golden_size";
    version = "2022-12-28";

    src = pkgs.fetchFromGitHub {
      owner = "dm1try";
      repo = "golden_size";
      rev = "301907c3bd877912ca3d4125c602a23f8c4a7c95";
      sha256 = "NJF8uVudwAU3xEPGDjDjjuxbj4V35n5igdA9CQ2q2AU=";
    };

    meta.homepage = "https://github.com/dm1try/golden_size";
  };
}
