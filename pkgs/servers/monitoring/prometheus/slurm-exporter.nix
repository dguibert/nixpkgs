{ stdenv, lib, buildGoPackage, fetchFromGitHub, slurm }:

buildGoPackage rec {
  pname = "prometheus-slurm-exporter";
  version = "0.8-3-g7881b06";

  goPackagePath = "github.com/vpenso/prometheus-slurm-exporter";

  goDeps = ./slurm-exporter_deps.nix;

  src = fetchFromGitHub {
    owner = "vpenso";
    repo = "prometheus-${pname}";
    rev = "${version}";
    sha256 = "sha256-wEvz0kk0LqU2iR92e1FG4TvQYpD3+bV5gGNtgJNMduk=";
  };

  doCheck = false; # slurm installed?

  # cpus.go:        cmd := exec.Command("sinfo", "-h", "-o %C")
  # nodes.go:       cmd := exec.Command("sinfo", "-h", "-o %n,%T")
  # queue.go:       cmd := exec.Command("squeue", "-a", "-r", "-h", "-o %A,%T,%r", "--states=all")
  # scheduler.go:  cmd := exec.Command("sdiag")
  postPatch = ''
    sed -i -e 's@exec.Command("@exec.Command("${slurm}/bin/@' cpus.go
    sed -i -e 's@exec.Command("@exec.Command("${slurm}/bin/@' nodes.go
    sed -i -e 's@exec.command("@exec.command("${slurm}/bin/@' queue.go
    sed -i -e 's@exec.Command("@exec.Command("${slurm}/bin/@' scheduler.go
  '';

  meta = with lib; {
    description = "Prometheus exporter for performance metrics from Slurm";
    homepage = "https://github.com/vpenso/prometheus-slurm-exporter";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
