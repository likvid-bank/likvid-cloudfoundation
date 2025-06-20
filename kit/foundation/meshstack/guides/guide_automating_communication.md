# Automating Communication via meshStack API

This demo story shows how Likvid Bank's GCP architect, Phil, automates communication about GCP Deny Policies to affected teams using meshStack's API.

## Business Context

Phil is a GCP architect at **Likvid Bank**, a large bank that operates heavily in Google Cloud (GCP). His team is responsible for **ensuring that all GCP services used across the company meet strict internal security standards**.

When a GCP service fails to meet these standards, the team creates a **Deny Policy** in GCP to prevent its use. However, **informing all relevant application teams about these new restrictions is currently manual and inefficient**, involving direct messages and updates in various tools.

## Challenges

- **Manual process**: Currently, reaching out to affected teams requires a manual process of identifying the user of the service via GCP and sending an email to those teams responsible for the GCP project.
- **Ownership visibility**: It is difficult to identify **who owns the GCP projects** using the restricted services and retrieve their **contact information** (e.g., email addresses) for communication.
- **Verification gap**: There is **no structured or automated way** to ensure that teams actually **deprecate the usage** of the denied service after being notified. This creates follow-up overhead and potential compliance gaps.

## Implementation Steps

[Watch the Demo on Storylane](https://app.storylane.io/share/nyykaczmecli)

### Service Usage Assessment

Phil’s team collects service usage data from GCP via a script, **identifying which GCP projects** are consuming the now-restricted services. They identify the platform tenant ID.

### Identify Tenant UUID in meshStack

With the GCP project ID in hand, the team uses the [meshObject API]() to retrieve the associated tenant UUID via the [List meshTenant](https://docs.meshcloud.io/api/index.html#mesh_tenant_v4) API call and filtering for `platformTenantId` using the GCP project id.

```bash
curl -X GET 'https://${meshstack_api_url}/api/meshobjects/meshtenants?platformTenantId=gcp-project-12345' \
--header 'Accept: application/vnd.meshcloud.api.meshtenant.v4-preview.hal+json' \
--header 'Authorization: Bearer <YOUR_API_TOKEN>'
```

This will return the meshTenant object, including its UUID.

### Automated Communication

The team uses the meshStack communications definitions and communications API to send the “Action Required” communication to all affected workspaces, including a due date for confirming the deprecation.

### Create Communication Definition

A `meshCommunicationDefinition` stores a message as a reusable template and helps you keep track
of all affected tenants that have received the same message and their resolution status.

`meshCommunications` are instances of a definition and are sent to a specific target (e.g. a `meshWorkspace` or as in our example a `meshTenant`).

First, create a communication definition with the message to be sent.

```bash
curl -X POST 'https://${meshstack_api_url}/api/meshobjects/meshcommunicationdefinitions' \
--header 'Authorization: Bearer <YOUR_API_TOKEN>' \
--header 'Content-Type: application/vnd.meshcloud.api.meshcommunicationdefinition.v1-preview.hal+json;charset=UTF-8' \
--header 'Accept: application/vnd.meshcloud.api.meshcommunicationdefinition.v1-preview.hal+json' \
--data-raw '{
  "apiVersion": "v1-preview",
  "kind": "meshCommunicationDefinition",
  "spec": {
    "displayName": "Deprecation of GCP Service",
    "communication": {
      "title": "### 🚨 Action Required: Deprecation of Cloud Vision API",
      "message": "Hi Team,\n\nYour GCP project is currently using Cloud Vision API service, which does **not meet Likvid Bank’s security requirements**.\n\nA **Deny Policy** will be applied to restrict its use.\n\n#### ✅ What you need to do:\n1. Stop using Cloud Vision API in your project by 31st July 2025.\n2. Confirm deprecation by confirming via meshPanel.\n3. Reach out via security@likvidbank.io if you need support.  \n\nThanks for helping keep our cloud environment secure.\n\n– **Phil**, GCP Architect",
      "type": "ACTION_REQUIRED",
      "dueDate": "2025-08-30"
    }
  }
}'
```

The API will return the created definition, including its UUID.

### Create Communications Referencing the Communication Definition UUID

Now, create a `meshCommunication` for each affected `meshTenant`.
This attaches the message to the tenant and makes it visible in the corresponding workspace's communication center.

```bash
curl -X POST 'https://${meshstack_api_url}/api/meshobjects/meshcommunications' \
--header 'Authorization: Bearer <YOUR_API_TOKEN>' \
--header 'Content-Type: application/vnd.meshcloud.api.meshcommunication.v1-preview.hal+json;charset=UTF-8' \
--header 'Accept: application/vnd.meshcloud.api.meshcommunication.v1-preview.hal+json' \
--data-raw '{
  "kind": "meshCommunication",
  "apiVersion": "v1-preview",
  "spec": {
    "targetMeshObjectRef": {
      "kind": "meshTenant",
      "name": "<TENANT_UUID>"
    },
    "communicationDefinitionRef": {
      "uuid": "<COMMUNICATION_DEFINITION_UUID>"
    }
  }
}'
```

### Workspaces Respond

meshStack now determines the responsible owners based on project and workspace role assignment.
These owners will be notified by meshStack via email that there is a new communication requiring their action in meshStack.
Phil and his team can track in the communication center how many of these communications were resolved.

## Conclusion

By integrating external GCP usage data with meshStack using the **GCP project id** and **meshStack meshObject API**, Likvid Bank’s cloud security team has:

- **Automated communications** with impacted workspaces
- **Eliminated manual overhead**, saving hours of repetitive effort
- Ensured **fast, consistent, and traceable notifications** across teams

This demo story highlights how meshStack can be extended to support security-driven governance workflows at scale, enabling better compliance, team coordination, and operational efficiency.
