
# Maintaing Security Contacts with meshStack

## Motivation / Business Context

At Likvid Bank, maintaining up-to-date security contact information for every cloud environment is a critical requirement for our incident management process. This information is the basis for automating security responses and ensuring that the right people are notified in case of a security event. You can find an example of a process building on this information in our guide on [Automating Incident Communication](./guide_automating_incident_communication.md).

## Challenges

A key challenge is that security contacts are not always individual users. In many cases, they are shared inboxes or ticket systems (e.g., Jira or ServiceNow queues). This means there is no direct 1:1 mapping to meshStack users.

To ensure the contact information is always current, we need a process to periodically ask workspace owners to review and update their designated security contacts.

## Implementation Steps

We can use meshStack to manage security contacts and automate the update process.

:::tip
For a hands-on walkthrough of this solution, checkout the interactive demo on Storylane: [View the Interactive Demo](https://app.storylane.io/share/nyykaczmecli). This demo will guide you step-by-step through the process of maintaining security contacts with meshStack.
:::

### 1. Tag Workspaces with Security Contact

We use a custom tag `${tags_SecurityContact}` in meshStack to store the security contact for each workspace. This could be an email address for a distribution list or the inbox for a ticketing system.

### 2. Request Updates via Communication Center

To ensure this information stays up-to-date, we send a communication with an **Action Required** type to all workspace owners via the meshStack Communication Center. This communication requests that they review and update the `${tags_SecurityContact}` tag for their workspaces.

The built-in reporting features of the Communication Center allow us to track the resolution of these requests.

### 3. Notifications

All workspace owners are automatically notified via email and see a reminder in meshPanel, ensuring that the request does not get missed.

## Conclusion

By using the meshStack Communication Center and a simple tagging convention, Likvid Bank can effectively manage security contact information across all cloud workspaces. This automated process ensures that contact details remain accurate, which is fundamental for a robust incident management and security response capability.
