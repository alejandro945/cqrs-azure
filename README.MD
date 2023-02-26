# CQRS Cloud Design pattern 💥

CQRS separates reads and writes into different models, using commands to update data, and queries to read data.

- Commands should be task-based, rather than data centric. ("Book hotel room", not "set ReservationStatus to Reserved").
- Commands may be placed on a queue for asynchronous processing, rather than being processed synchronously.
- Queries never modify the database. A query returns a DTO that does not encapsulate any domain knowledge.

The models can then be isolated, as shown in the following diagram, although that's not an absolute requirement.

## Automatizing using Terraform

### Install the Azure CLI tool

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Authenticate using the Azure CLI

```bash
az login
az login --use-device-code
```

Your browser will open and prompt you to enter your Azure login credentials. After successful authentication, your terminal will display your subscription information. Also, you can experiment a localhost redirection that will be blocked by firewall policies so in this case use device code command instead.

```json
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "XXXX",
    "id": "XXXX",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Azure for Students",
    "state": "Enabled",
    "tenantId": "XXXX",
    "user": {
      "name": "XXXX@u.icesi.edu.co",
      "type": "user"
    }
  }
]
```

Set the account with the Azure CLI.

```bash
az account set --subscription "<<id>>"
```

### Create a Service Principal

A Service Principal is an application within Azure Active Directory with the authentication tokens Terraform needs to perform actions on your behalf.

```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<<id>>"
```

```json
{
  "appId": "XXXX",
  "displayName": "XXXX",
  "password": "XXXX",
  "tenant": "XXXX"
}
```

### Set your environment variables

HashiCorp recommends setting these values as environment variables rather than saving them in your Terraform configuration.

In your terminal, set the following environment variables. Be sure to update the variable values with the values Azure returned in the previous command.

```bash
export ARM_CLIENT_ID="<<appId>>"
export ARM_CLIENT_SECRET="<<password>>"
export ARM_SUBSCRIPTION_ID="<<id>>"
export ARM_TENANT_ID="<<tenant>>"
```

### Write configuration

#### Terraform Block

The terraform {} block contains Terraform settings, including the required providers Terraform will use to provision your infrastructure. For each provider, the source attribute defines an optional hostname, a namespace, and the provider type. Terraform installs providers from the Terraform Registry by default. In this example configuration, the azurerm provider's source is defined as hashicorp/azurerm, which is shorthand for registry.terraform.io/hashicorp/azurerm.

You can also define a version constraint for each provider in the required_providers block. The version attribute is optional, but we recommend using it to enforce the provider version. Without it, Terraform will always use the latest version of the provider, which may introduce **breaking changes**.

#### Providers

The ```provider``` block configures the specified provider, in this case azurerm. A provider is a plugin that Terraform uses to create and manage your resources. You can define multiple provider blocks in a Terraform configuration to manage resources from different providers.

#### Resource

Use ```resource``` blocks to define components of your infrastructure. A resource might be a physical component such as a server, or it can be a logical resource such as a Heroku application.

### Initialize your Terraform configuration
Initialize your learn-terraform-azure directory in your terminal. The terraform commands will work with any operating system.

```bash
terraform init
```

### Apply and destroy commands 🚦

```bash
terraform apply
terraform destroy
```

### Creation of SQL Sync service

1. In each database create the share schema of the entities

```sql
CREATE TABLE Persons(
    ID int NOT NULL,
    FirstName varchar(255),
    Age int,
    PRIMARY KEY (ID)
);
```

2. Go to your hub or source database (Write database) [Tutorial](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-data-sync-sql-server-configure?view=azuresql#add-sync-members).


### Upload your code to azure function

```bash
func azure functionapp publish cqrs-command-varela #Inside command app folder
func azure functionapp publish cqrs-query-varela #Inside query app folder
```