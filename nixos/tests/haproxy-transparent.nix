import ./make-test-python.nix ({pkgs, ...}: let

  runWithOpenSSL = file: cmd: pkgs.runCommand file {
    buildInputs = [ pkgs.openssl ];
  } cmd;

  ca_key = runWithOpenSSL "ca-key.pem" "openssl genrsa -out $out 2048";
  ca_pem = runWithOpenSSL "ca.pem" ''
    openssl req \
      -x509 -new -nodes -key ${ca_key} \
      -days 10000 -out $out -subj "/CN=haproxy-ca"
  '';

  ### Generate a unique private key (KEY)
  server_key = runWithOpenSSL "server-key.pem" "openssl genrsa -out $out 2048";
  ### Generating a Certificate Signing Request (CSR)
  server_csr = runWithOpenSSL "server.csr" ''
    openssl req \
       -new -key ${server_key} \
       -out $out -subj "/CN=server" \
       -config ${openssl_cnf}
  '';
  ### Creating a Self-Signed Certificate (CRT)
  server_crt = runWithOpenSSL "server.crt" ''
    openssl x509 \
      -req -in ${server_csr} \
      -CA ${ca_pem} -CAkey ${ca_key} \
      -CAcreateserial -out $out \
      -days 365 -extensions v3_req \
      -extfile ${openssl_cnf}
  '';
  ### Append KEY and CRT to mydomain.pem
  server_pem = pkgs.runCommand "server.pem" {} ''
    cat ${server_key} ${server_crt} > $out
  '';

  openssl_cnf = pkgs.writeText "openssl.cnf" ''
    ions = v3_req
    distinguished_name = req_distinguished_name
    [req_distinguished_name]
    [ v3_req ]
    basicConstraints = CA:FALSE
    keyUsage = digitalSignature, keyEncipherment
    extendedKeyUsage = serverAuth
    subjectAltName = @alt_names
    [alt_names]
    DNS.1 = server
  '';

  haproxy_internal_ip = "192.168.127.254";

in {
  name = "haproxy-transparent";

  nodes = {
    server = { pkgs, lib, config, ... }: {
      networking.firewall.allowedTCPPorts = [ 443 4443 22 44322 ];
      networking.interfaces.eth1.ipv6.addresses = [
        {
          address = "fe00:aa:bb:cc::2";
          prefixLength = 64;
        }
      ];
      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.netdevs."40-haproxy" = {
        netdevConfig = {
          Name="haproxy";
          Kind="dummy";
        };
      };
      systemd.network.networks."40-haproxy" = {
        name = "haproxy";
        networkConfig.Address="${haproxy_internal_ip}/32";
        routingPolicyRules=[
          {
            From = "${haproxy_internal_ip}";
            Table = "103";
          }
        ];
        routes = [
          {
            Destination = "0.0.0.0/0";
            Type = "local";
            Table = "103";
          }
        ];
      };
#EOF
      # sslh is really slow when reverse dns does not work
      networking.hosts = {
        "fe00:aa:bb:cc::2" = [ "server" ];
        "fe00:aa:bb:cc::1" = [ "client" ];
      };
      services.haproxy = {
        enable = true;
        transparent = true;
        # https://dgl.cx/2010/01/haproxy-ssh-and-ssl-on-same-port
        config = ''
          defaults
            timeout connect 5s
            timeout client 50s
            timeout server 20s
            log  global
            #option tcplog

          global
            log stdout local0  debug

          listen sslh
            bind :443 transparent
            tcp-request inspect-delay 15s
            tcp-request content accept if { req.ssl_hello_type 1 }
            default_backend http

            acl ssh_payload req.payload(0,7) -m str "SSH-2.0"
            tcp-request content accept if !ssh_payload
            use_backend ssh if ssh_payload

            timeout client 2h
            log  global

          listen ssh_listen
            bind :44322 transparent
            server ssh ${haproxy_internal_ip}:22 source 0.0.0.0 usesrc clientip
            timeout server 2h
            log  global

          backend http
            mode tcp
            server httpd ${haproxy_internal_ip}:4443 source 0.0.0.0 usesrc clientip
            log  global

          backend ssh
            mode tcp
            server ssh ${haproxy_internal_ip}:22
            source 0.0.0.0 usesrc clientip
            timeout server 2h
            log  global

          listen https_server
            bind :4443 ssl crt ${server_pem} transparent
            bind [::1]:4443 ssl crt ${server_pem} transparent
            mode http
            server httpd ${haproxy_internal_ip}:8000 source 0.0.0.0 usesrc clientip
            http-request use-service prometheus-exporter if { path /metrics }
            log  global
        '';
        user = "root";
      };
      services.openssh.enable = true;
      services.openssh.listenAddresses = [
        { addr = "*"; port = 22; }
        { addr = "${haproxy_internal_ip}"; port = 22; }
      ];
      users.users.root.openssh.authorizedKeys.keyFiles = [ ./initrd-network-ssh/id_ed25519.pub ];
      services.httpd = {
        enable = true;
        virtualHosts.localhost = {
          documentRoot = pkgs.writeTextDir "index.txt" "We are all good!";
          adminAddr = "notme@yourhost.local";
          listen = [{
            ip = "${haproxy_internal_ip}";
            port = 8000;
          }];
        };
      };
    };
    client = { ... }: {
      networking.interfaces.eth1.ipv6.addresses = [
        {
          address = "fe00:aa:bb:cc::1";
          prefixLength = 64;
        }
      ];
      networking.hosts."fe00:aa:bb:cc::2" = [ "server" ];
      environment.etc.sshKey = {
        source = ./initrd-network-ssh/id_ed25519; # dont use this anywhere else
        mode = "0600";
      };
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("multi-user.target")
    server.wait_for_unit("haproxy.service")
    server.wait_for_unit("httpd.service")
    server.wait_for_unit("sshd.service")
    server.wait_for_open_port(4443)
    server.wait_for_open_port(22)

    for arg in ["-4"]: #, "-6"]:
        for port in ["4443", "443"]:
            assert "We are all good!" in server.succeed(f"curl -fk {arg} https://localhost:{port}/index.txt")
            assert "haproxy_process_pool_allocated_bytes" in server.succeed(
                f"curl -fk {arg} https://localhost:{port}/metrics"
            )

    #server.wait_for_open_port(443)
    for arg in ["-4"]: #, "-6"]:
        for port in ["443"]:
            assert "We are all good!" in client.succeed(f"curl -fk {arg} https://server:{port}/index.txt")
            assert "haproxy_process_pool_allocated_bytes" in client.succeed(
                f"curl -fk {arg} https://server:{port}/metrics"
            )

    for arg in ["-4"]: #, "-6"]:
        client.wait_until_succeeds(f"ping {arg} -c1 server")

        # check that ssh works
        #client.succeed( f"ssh {arg} -p 22 -i /etc/sshKey -o StrictHostKeyChecking=accept-new server 'echo $SSH_CONNECTION'")

        # check that ssh_listen through haproxy works
        client.succeed(
            f"ssh {arg} -p 44322 -i /etc/sshKey -o StrictHostKeyChecking=accept-new server 'echo $SSH_CONNECTION > /tmp/foo{arg}'"
        )

        # check that ssh through haproxy works
        client.succeed(
            f"ssh {arg} -p 443 -i /etc/sshKey -o StrictHostKeyChecking=accept-new server 'echo $SSH_CONNECTION > /tmp/foo{arg}'"
        )

        # check that 1/ the above ssh command had an effect 2/ transparent proxying really works
        ip = "fe00:aa:bb:cc::1" if arg == "-6" else "192.168.1.1"
        server.succeed(f"cat /tmp/foo{arg}")
        server.succeed(f"grep '{ip}' /tmp/foo{arg}")

        # check that http through haproxy works
        assert "We are all good!" in client.succeed(f"curl -fk {arg} https://server:443/index.txt")
  '';
})
