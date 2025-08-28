# AWS EC2 Windows GPU Instance with OBS

This Terraform project creates an AWS EC2 Windows instance with GPU drivers and pre-installed software like OBS Studio, accessible via Amazon DCV.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform Cloud workspace** existing (`wyscout-magicbox-prod`)
3. **Terraform CLI** installed locally
4. **AWS CLI** configured

## Configuration

### 1. Terraform Cloud
Before execution, configure the following variables in the Terraform Cloud workspace `wyscout-magicbox-prod`:

#### Environment Variables:
- `AWS_ACCESS_KEY_ID` - AWS credentials (if not using assume_role)
- `AWS_SECRET_ACCESS_KEY` - AWS credentials (if not using assume_role)

#### Terraform Variables:
- `region` - AWS region (default: eu-west-1)
- `instance_type` - EC2 instance type (default: g4dn.xlarge) 
- `key_name` - AWS key pair name for DCV access
- `allowed_cidr_blocks` - CIDR blocks allowed for DCV (default: ["0.0.0.0/0"])
- `aws_provider_role_arn_wyexternal` - IAM role ARN (default: arn:aws:iam::858373385149:role/TerraformRunner)
- `environment` - Environment name (default: beta)

### 2. Local Configuration
```bash
# 1. Project is already configured for "hudl" organization and "wyscout-magicbox-prod" workspace
# 2. Login to Terraform Cloud (only needed for local development)
terraform login

# 3. Initialize the project (only needed for local development)
terraform init

# 4. Validate the configuration
terraform validate

# 5. Plan the changes (optional - will also run automatically via Git)
terraform plan

# 6. For production deployment: Push to master branch
git push origin master
```

## Deployment Workflow

### Via Terraform Cloud (Recommended)
1. **Configure workspace** `wyscout-magicbox-prod` in Terraform Cloud
2. **Connect GitHub repository**: `https://github.com/hudl/wy-obs-terraform`
3. **Set trigger branch**: `master`
4. **Configure required variables** (see Variables section above)
5. **Push to master** → Automatic deployment

### Via Local CLI (Development Only)
```bash
terraform init
terraform plan
terraform apply
```

## Features

- **EC2 Windows Server 2022** with GPU support
- **NVIDIA drivers** pre-installed
- **OBS Studio** automatically installed
- **Amazon DCV** for secure remote access
- **Security Group** configured for DCV
- **UserData script** for automatic software installation

## Resources Created

- EC2 Instance (Windows Server 2022)
- Security Group for DCV
- IAM Role and Instance Profile (if needed)

## Outputs

- `instance_id` - EC2 instance ID
- `public_ip` - Instance public IP
- `dcv_connection` - URL to connect via DCV

## Instance Access

After deployment, access the instance via Amazon DCV:

### Step 1: Get Connection URL
Use the URL provided in the `dcv_connection` output:
```
https://[PUBLIC_IP]:8443
```

### Step 2: Browser Access
1. Open a web browser
2. Navigate to the DCV URL
3. Accept the SSL certificate warning (self-signed certificate)

### Step 3: Login
- **Username**: `Administrator`
- **Password**: `WyObs2025!` (configured automatically)

### Step 4: Use the Desktop
Once connected, you'll have access to:
- Windows desktop with GPU acceleration
- OBS Studio (desktop shortcut available)
- All installed streaming software

### Alternative Access Methods
- **DCV Native Client**: Download from AWS for better performance
- **AWS Console**: Use EC2 Instance Connect for troubleshooting

## Costs

The g4dn.xlarge instance has an approximate cost of €0.47/hour in eu-west-1.

## Technical Notes

- Uses Terraform Cloud organization **hudl**
- Configured for workspace **wyscout-magicbox-prod**
- Uses AWS provider version 4.34.0 for compatibility
- Supports assume_role for AWS authentication
- Includes default tags for Environment and Project
- **Amazon DCV** provides high-performance remote access for graphics applications
