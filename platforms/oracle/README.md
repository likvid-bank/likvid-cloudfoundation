# Oracle Cloud Infrastructure (OCI) Platform

This directory contains Terraform modules for managing Oracle Cloud Infrastructure (OCI) cloud foundation resources.

## Overview

The OCI platform implementation provides:

- **Bootstrap**: IAM groups and policies scoped to foundation compartment
- **Security**: Audit logging and vulnerability scanning
- **Landing Zones**: Pre-configured compartment structures for different workload types

## Architecture

```
platforms/oracle/
├── bootstrap/              # IAM setup
├── security/              # Security monitoring and compliance
└── landingzones/
    ├── cloud-native/      # Modern application workloads
    └── sandbox/           # Experimentation environment
```

## Security Features

This implementation includes:

- **Identity and Access Management**: IAM groups and policies with compartment-scoped permissions
- **Audit Logging**: 365-day retention at tenancy level
- **Vulnerability Scanning**: Host and container scanning recipes

## Prerequisites

- **OCI Tenancy**: Active Oracle Cloud Infrastructure tenancy with foundation compartment already created
- **Admin Access**: User with permissions to manage IAM and create resources in the foundation compartment
- **Terraform**: Version 1.0 or higher
- **OCI Provider**: Version 7.30.0
- **Terragrunt**: For stack deployment and DRY configuration

### Foundation Compartment

This setup requires an existing "foundation compartment" where all resources will be scoped:
- All resources (except IAM groups which must be at tenancy level) are created within this compartment
- Provides isolation and limits blast radius for testing
- Configure in `platforms/oracle/bootstrap/terragrunt.hcl`

## Deployment

Deploy the entire Oracle platform stack with a single command:

```bash
cd platforms/oracle/
terragrunt stack run apply
```

This will automatically:
- Discover all modules (bootstrap, security, landing zones)
- Resolve dependencies between modules
- Apply them in the correct order

### Individual Module Deployment

If you need to deploy modules individually:

1. **Bootstrap**: Sets up IAM foundation
   ```bash
   cd bootstrap/
   terragrunt apply
   ```

2. **Security**: Configures security monitoring and scanning
   ```bash
   cd ../security/
   terragrunt apply
   ```

3. **Landing Zones**: Deploy as needed for your workloads
   ```bash
   cd ../landingzones/cloud-native/
   terragrunt apply
   ```

## Module Documentation

- [Bootstrap Module](./bootstrap/README.md) - IAM and Cloud Guard setup
- [Security Module](./security/README.md) - Security monitoring and compliance
- [Cloud-Native Landing Zone](./landingzones/cloud-native/README.md) - Modern application workloads
- [Sandbox Landing Zone](./landingzones/sandbox/README.md) - Experimentation environment

## Configuration

### Authentication

Two sets of credentials are required:

1. **OCI API Authentication** (for Terraform provider):
   - Configure via `~/.oci/config` file (recommended)
   - Or set environment variables: `OCI_TENANCY_OCID`, `OCI_USER_OCID`, `OCI_FINGERPRINT`, `OCI_PRIVATE_KEY_PATH`, `OCI_REGION`

2. **Customer Secret Keys** (for S3-compatible backend):
   - Create in OCI Console: Profile → Customer Secret Keys
   - Export as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

### Configuration

Configure the foundation settings in `platforms/oracle/bootstrap/terragrunt.hcl`. See the file for available inputs.

## Security Considerations

### Safe for Testing

This implementation is scoped to a foundation compartment with these safety measures:

- **Compartment Scoping**: All resources (except IAM groups) limited to foundation compartment
- **No Tenancy-Wide Impact**: Changes don't affect tenancy root or other compartments
- **Limited Permissions**: Platform engineers policy only grants access within foundation compartment
- **Audit Trail**: All API calls logged with 365-day retention at tenancy level
- **Vulnerability Management**: Automated scanning for hosts and containers

### Before Production

Consider enabling when moving to production:

- **Cloud Guard**: Not enabled (requires home region subscription and additional cost)
- **Network Management**: No VCN or hub-spoke networking configured
- **Key Management**: No Vault or Key Management Service configured
- **Additional Landing Zones**: Only cloud-native and sandbox included

## Limitations

This implementation intentionally excludes:

- **Cloud Guard**: Not available in all tenancies, removed to ensure compatibility
- **Network Management**: No VCN or network topology configured
- **Building Blocks**: No reusable workload components
- **meshplatform Integration**: Oracle platform not yet supported by meshStack

These can be added based on requirements and availability.

## Support

For issues or questions:

1. Check module-specific README files
2. Review [OCI Terraform Provider documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
3. Consult [CIS OCI Foundations Benchmark](https://www.cisecurity.org/benchmark/oracle_cloud)

## Contributing

When adding new modules:

1. Follow the existing module structure
2. Include comprehensive README documentation
3. Use OCI provider version 7.30.0
4. Validate against CIS OCI Benchmark requirements
5. Test in a non-production environment first
