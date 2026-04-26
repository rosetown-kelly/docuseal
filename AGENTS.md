# AGENTS.md

## Local Customization Summary

This fork includes a few small branding and local-preview changes:

- Added a GitHub icon in the main navbar linking to this fork:
  `https://github.com/rosetown-kelly/docuseal`.
- Removed the upstream DocuSeal GitHub star badge/button from the navbar.
- Added a footer to the main application layout:
  `Powered by the DocuSeal open-source project.`
- Simplified the unauthenticated public homepage to show only the logo, title, and this description:
  `A self-hosted and open-source web platform that provides secure and efficient digital document signing and processing.`
- Added optional tagline support via the `TAGLINE` environment variable on the public homepage and top-left navbar logo.
- Removed DocuSeal footer branding from outgoing HTML emails by stopping the mailer layout from rendering the shared email attribution partial.
- Removed recipient-facing DocuSeal attribution/footer branding from the signing flow pages under `app/views/start_form/*` and `app/views/submit_form/*`.
- Removed the same attribution from the send-copy/completed recipient screens:
  `app/views/send_submission_email/success.html.erb` and `app/views/submissions_preview/completed.html.erb`.
- Removed the frontend completion-screen `Powered by DocuSeal - open source documents software` block from `app/javascript/submission_form/completed.vue`.
- Added `docker-compose.preview.yml` for easy local preview without installing Ruby, Yarn, or Postgres locally.
- Ignored preview runtime data directories in `.gitignore`:
  `/preview_data` and `/preview_pg_data`.

## Local Preview

Run the current checkout locally with:

```bash
docker compose -f docker-compose.preview.yml up --build
```

Then visit:

```text
http://localhost:3000
```

If the preview database is fresh, complete `/setup` once, then sign out or open an incognito/private browser window to view the public homepage.
