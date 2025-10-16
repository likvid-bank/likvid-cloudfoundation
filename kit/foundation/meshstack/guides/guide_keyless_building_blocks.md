# Keyless Building Blocks with Workload Identity Federation

The ${md_workspace_m25_platform_team} wants to offer cloud services (AWS S3, Azure Storage, GCP Storage) through meshStack building blocks, but their organization restricts long-lived secrets. Currently, they must frequently rotate credentials across multiple cloud providers, creating significant operational overhead.

The Platform Engineering team discovers meshStack's Workload Identity Federation (WIF) support, which eliminates the need for stored cloud credentials across AWS, Azure, and Google Cloud Platform.

## Business Challenge

Likvid Bank's security policy requires eliminating long-lived secrets, but traditional building blocks need static credentials:

- **AWS**: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- **Azure**: Service Principal `ARM_CLIENT_SECRET`
- **GCP**: Service Account JSON keys

This creates:

- **Operational Overhead**: Weekly credential rotation across multiple cloud providers and building blocks
- **Security Risk**: Static credentials stored in building block definitions
- **Scalability Issues**: Credential management complexity multiplies with each cloud provider and building block

## Solution: Workload Identity Federation

:::tip Info
In this guide, we will use 3 simple building blocks: AWS S3 Bucket, Azure Storage Account, and GCP Storage Bucket. In a real-world scenario, you would likely use more complex building blocks tailored to your organization's needs.
The resources will be created in the tenants:

- AWS: `${meshstack_tenant_quickstart_aws_spec_local_id}` in workspace ${md_workspace_m25_platform_team}
- Azure: `${meshstack_tenant_quickstart_azure_spec_local_id}` in workspace ${md_workspace_m25_platform_team}
- GCP: `${meshstack_tenant_quickstart_gcp_spec_local_id}` in workspace ${md_workspace_m25_platform_team}
:::

### Step 1: Import Building Blocks from meshStack Hub

The team imports pre-built building blocks for each cloud provider:

1. Navigate to ${md_workspace_m25_platform_team} → **Platform Builder** → **Building Blocks** → **+ Create Building Block Definition**
2. Choose **Import from meshStack Hub**:
   - **AWS** → **AWS S3 Bucket**
   - **Azure** → **Azure Storage Account**
   - **GCP** → **GCP Storage Bucket**

### Step 2: Set Up Backplanes for WIF

1. In each building block in the Hub, a link to "backplane" setup exists with guide on how to set it up.
2. Follow the guide to configure the backplane for each building block.
3. Go back to meshStack and continue with the import wizard to retrieve WIF information.

### Step 3: Configure WIF Authentication

For each building block, during import:

1. **Deselect Standard Authentication**: Uncheck traditional credential options
2. After adding selected, click on "Generate Inputs"
3. **Get WIF Setup Information**: Click the info icon (ℹ️) next to "Workload Identity Federation" and copy provider-specific values

#### AWS Configuration

- **Issuer**
- **Subject**
- **Audience**

#### Azure Configuration

- **Issuer**
- **Subject**

#### GCP Configuration

- **Issuer**
- **Subject**
- **Audience**
- **Token Path**

### Step 4: Deploy and Test

1. **Run Backplanes**: Execute terraform for each cloud provider to create WIF infrastructure
2. **Generate Inputs**: In meshStack, generate WIF inputs for each building block and fill in WIF details
3. **Configure Building Blocks**: Enter the provider-specific role/identity information in meshStack
4. **Test Deployments**: After creating the building block definition, deploy and test building blocks for each provider

## Conclusion

This implementation eliminates credential management overhead while providing seamless access to AWS, Azure, and GCP services through a unified meshStack interface.

- **Zero Static Credentials**: No cloud provider keys stored anywhere
- **Unified Security Model**: Consistent WIF approach across all cloud providers
- **Eliminated Overhead**: No more credential rotation
