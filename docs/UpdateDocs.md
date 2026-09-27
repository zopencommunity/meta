# Updating the docs

To make changes to the docs, please:
 - `git clone git@github.com:zopencommunity/meta.git`
 - `cd meta/docs`
 - make updates
 - validate your changes, locally on port 5173, as follows:
   - `npm install`
   - `npm run serve`
   - bring up your browser on localhost:5173 and validate
 - create a PR as you would for any other code for your changes

> [!NOTE]
> Dynamic documentation pages (`/Latest`, `/Vulnerabilities`, `/Progress`, and `/reference`) are generated automatically in CI. To generate and preview them locally, run:
> ```bash
> npm run docs:generate
> # or from repo root: ./cicd/generate_docs.sh
> ```
