# **Branding of E-mails

> This demo story is also available as an [interactive demo](https://app.storylane.io/share/5jjhgbmxckib).

## Motivation / Business Context

**Likvid Bank** is rolling out an Internal Developer Platform (IDP) using meshStack to streamline cloud access for its development teams.
To drive adoption and ensure professional communication, the platform team wants all email notifications to reflect the company’s internal brand identity.

## Challenges

- The platform team needs to establish **brand recognition** and **credibility** through every communication.
- Developers ignore system-generated emails that feel generic or come from unknown sources.

## Implementation Steps

- In **meshPanel**, navigate to **Settings → Appearance → Email**.

- Set **internal name** to `Likvid Developer Platform`. This will be the "From" name in emails.
- Tick **prefix internal name to all email subjects**. This ensures all emails start with “Likvid Developer Platform” for consistency.
- Set the **sender email address** to `likvid-developer-platform@likvidbank.com`.
- Set the **reply-to email address** to `likvid-developer-platform@likvidbank.com`.
- Set the **email header logo** to the following file: ![image](https://raw.githubusercontent.com/likvid-bank/likvid-cloudfoundation/1e5d5e9b99c105060d10bc604c0cf8f1aafef414/kit/foundation/meshstack/guides/likvid_logo.png).
- Set the **button color** to **Likvid Bank Blue** (`#0072C6`) for consistency with the brand.
- Set the **button text** to `Open Likvid Developer Platform` to provide a clear call to action.
- Set the e-mail signature to
```
Best regards,
The Likvid Developer Platform Team

Need help? Reach us at <a href="mailto:likvid-developer-platform@likvidbank.com">likvid-developer-platform@likvidbank.com</a>
```

You will be able to preview the email template on the right side of the screen.

Click "Save" to apply the changes. meshStack will now use these settings for all email notifications.

## Conclusion

With meshStack’s email customization, Likvid Bank delivers branded, relevant communication that builds developer trust and supports platform adoption.
