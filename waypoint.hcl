project = "vaulicheck"

app "vaulicheck-file" {
  labels = {
    "env" = "dev"
  }

  config {
    env = {
      VAULT_ADDR  = "http://vault.default.svc:8200"
      SECRET_FILE = "/vault/secrets/secret.txt"
      SECRET_PATH = var.secret_path
    }
  }

  build {
    use "pack" {
      ignore = ["README.md", "*.hcl", "/deployments"]
    }
    registry {
      use "docker" {
        image    = "wallacepf/vaulicheck"
        tag      = "latest"
        username = var.docker_username
        password = var.docker_password
      }
    }
  }

  deploy {
    use "kubernetes" {
      annotations = {
        "vault.hashicorp.com/agent-inject" : "true"
        "vault.hashicorp.com/role" : "vaulicheck"
        "vault.hashicorp.com/agent-inject-secret-secret.txt" : var.secret_path
        "vault.hashicorp.com/agent-inject-template-secret.txt" : "{{- with secret \"secret/data/mytestapp/test\" -}}{{ .Data.data.demosecret }}{{- end -}}"
      }
      namespace       = "default"
      service_account = "vaulicheck"
      service_port    = "8080"
    }
  }

  release {
    use "kubernetes" {
      load_balancer = true
    }
  }

}

app "vaulicheck-wp" {
  labels = {
    "env" = "dev"
  }

  config {
    env = {
      VAULT_ADDR = "http://vault.default.svc:8200"
      #      SECRET_FILE = "/vault/secrets/secret.txt"
      SECRET_PATH = var.secret_path
      MY_SECRET = dynamic("vault", {
        path = "secret/data/mytestapp/test"
        key  = "demosecret"
      })
    }
  }

  build {
    use "pack" {
      ignore = ["README.md", "*.hcl", "/deployments"]
    }
    registry {
      use "docker-pull" {
        image = "wallacepf/vaulicheck"
        tag   = "latest"
        username = var.docker_username
        password = var.docker_password
      }
    }
  }

  deploy {
    use "kubernetes" {
      #      annotations = {
      #        "vault.hashicorp.com/agent-inject" : "true"
      #        "vault.hashicorp.com/role" : "vaulicheck"
      #        "vault.hashicorp.com/agent-inject-secret-secret.txt" : var.secret_path
      #        // TODO Alterar para variavel o caminho do segredo
      #        "vault.hashicorp.com/agent-inject-template-secret.txt" : "{{- with secret \"secret/data/mytestapp/test\" -}}{{ .Data.data.demosecret }}{{- end -}}"
      #      }
      namespace = "default"
      #      service_account = "vaulicheck"
      service_port = "8080"
    }
  }

  #  release {
  #    use "kubernetes" {
  #      load_balancer = true
  #    }
  #  }

}

variable "docker_password" {}
variable "docker_username" {}
variable "secret_path" {}

