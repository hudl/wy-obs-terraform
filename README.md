# AWS EC2 Windows GPU Instance with OBS

Questo progetto Terraform crea un'istanza EC2 Windows con driver GPU e software preinstallato come OBS Studio.

## Prerequisiti

1. **Account AWS** con permessi appropriati
2. **Terraform Cloud workspace** esistente
3. **Terraform CLI** installato localmente
4. **AWS CLI** configurato

## Configurazione

### 1. Terraform Cloud
Prima dell'esecuzione, configura le seguenti variabili nel workspace Terraform Cloud `wyscout-magicbox-prod`:

#### Variabili d'ambiente:
- `AWS_ACCESS_KEY_ID` - AWS credentials (se non usi assume_role)
- `AWS_SECRET_ACCESS_KEY` - AWS credentials (se non usi assume_role)

#### Variabili Terraform:
- `region` - AWS region (default: eu-west-1)
- `instance_type` - EC2 instance type (default: g4dn.xlarge) 
- `key_name` - AWS key pair name for RDP access
- `allowed_cidr_blocks` - CIDR blocks allowed for RDP (default: ["0.0.0.0/0"])
- `aws_provider_role_arn_wyexternal` - IAM role ARN (default: arn:aws:iam::858373385149:role/TerraformRunner)
- `environment` - Environment name (default: beta)

### 2. Configurazione Locale
```bash
# 1. Il progetto è già configurato per l'organizzazione "hudl" e workspace "wyscout-magicbox-prod"
# 2. Login a Terraform Cloud
terraform login

# 3. Inizializza il progetto
terraform init

# 4. Valida la configurazione
terraform validate

# 5. Pianifica le modifiche
terraform plan

# 6. Applica le modifiche
terraform apply
```

## Caratteristiche

- **Istanza EC2 Windows Server 2022** con GPU support
- **Driver NVIDIA** preinstallati
- **OBS Studio** installato automaticamente
- **Security Group** configurato per RDP
- **UserData script** per installazione automatica software

## Risorse Create

- EC2 Instance (Windows Server 2022)
- Security Group per RDP
- IAM Role e Instance Profile (se necessario)

## Output

- `instance_id` - ID dell'istanza EC2
- `public_ip` - IP pubblico dell'istanza
- `rdp_connection` - Comando per connettersi via RDP

## Costi

L'istanza g4dn.xlarge ha un costo approssimativo di €0.47/ora in eu-west-1.

## Note Tecniche

- Utilizza l'organizzazione Terraform Cloud **hudl**
- Configurato per il workspace **wyscout-magicbox-prod**
- Utilizza AWS provider version 4.34.0 per compatibilità
- Supporta assume_role per autenticazione AWS
- Include default tags per Environment e Project
