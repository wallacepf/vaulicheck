# This is a small app to check if Vault is working properly

Vaulicheck is a small webapp that retrieves `/sys/health` infos and queries a secret from Kv-v2.

## How to setup:

Vaulicheck uses K8s native authentication method to be able to retrieve the secret from KV. Also, it relies on three different ENV VARS. These ENV VARS are:

`VAULT_ADDR` - Vault's Cluster Address \
`SECRET_FILE` - Secret file's path (ex: /vault/secret/mysecret.txt) \
`SECRET_PATH` - Path where the secret was created in Vault (ex: secrets/data/myapp/test) \

Once this was made to be used in K8s deployments, you will find an example of Deployment inside `deployments` folder.

## Vault Server

1. Insert a secret in your KV
   ```bash
   vault kv put secret/demoapp/test demosecret=test123
   ```
2. Create a read-only policy
   ```bash
   vault policy write vaulicheck - <<EOF
   path "secret/data/demoapp/test" {
      capabilities=["read"]
   }
   EOF
   ```
3. Create a new kubernetes role to match the Service Account that will be used for this app.
   ```bash
   vault write auth/kubernetes/role/vaulicheck \
        bound_service_account_names=vaulicheck \
        bound_service_account_namespaces=* \
        policies=vaulicheck \
        ttl=24h
   ```

## Screenshot

![App Screenshot](https://raw.githubusercontent.com/wallacepf/vaulicheck/master/screenshot/image.png)

PS: This app was made for testing purposes, do not use it in your production environment.

## Contributing

If you need new functions or in case of any bug, please open an issue.
