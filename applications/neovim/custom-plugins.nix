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
}
