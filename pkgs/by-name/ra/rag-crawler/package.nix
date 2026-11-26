{
  lib,
  mkYarnPackage,
  fetchYarnDeps,
  fetchFromGitHub,
  jq,
}:

mkYarnPackage rec {
  pname = "rag-crawler";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "sigoden";
    repo = "rag-crawler";
    rev = "v${version}";
    hash = "sha256-82MOa5aJFAL4QgG0xGzryLi5rrGOVmXr1Q921N/EUi8=";
  };

  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;

  offlineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-V9/8bn0tdDLefKgHQvFyxjO3qHGpzecMCILiWBNhky4=";
  };

  distPhase = "true";

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    yarn --offline build

    runHook postBuild
  '';

  postInstall = ''
    chmod +x $out/bin/rag-crawler
  '';

  meta = with lib; {
    description = "Crawl a website to generate knowledge file for RAG";
    homepage = "https://github.com/sigoden/rag-crawler";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "rag-crawler";
  };
}
