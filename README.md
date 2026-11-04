# ICE DevSecOps Demonstration (Implementation)

A small, real CI security pipeline inspired by the developer-focused DevSecOps principles discussed in AWS re:Invent 2024 session SEC211: *How ICE implemented a developer-focused DevSecOps workflow*.

> **Scope note:** This is an educational student implementation. It does not reproduce ICE's internal systems or claim that ICE used this exact AWS architecture. The project demonstrates related principles with GitHub, AWS CodeBuild, AWS Systems Manager Parameter Store and Snyk.

## What it demonstrates

1. **SCA** – Snyk checks the Node.js dependency manifest/lockfile for known open-source vulnerabilities.
2. **IaC scanning** – Snyk checks a CloudFormation template for insecure infrastructure configuration.
3. **Security gate** – CodeBuild fails the build when either scanner reports policy findings at or above the configured `medium` threshold.
4. **Error separation** – A scan finding (Snyk exit code `1`) is distinguished from scanner/configuration errors (exit codes other than `0` or `1`).
5. **Remediation and re-verification** – The developer fixes the dependency and infrastructure template, pushes a new commit, and CodeBuild runs the checks again.

## Repository structure

```text
ICE_DevSecOps_Demo_Complete/
├── package.json
├── index.js
├── buildspec.yml
├── .gitignore
├── infra/
│   └── s3-bucket.yaml             # intentionally insecure; scan only
├── examples/
│   └── fixed/
│       └── s3-bucket.yaml         # corrected example
└── docs/
    ├── IAM_POLICY.json
    ├── SETUP_AND_DEMO_GUIDE.md
    └── VIDEO_DEMO_SCRIPT.md
```

## Before starting

- An AWS account with access to AWS CodeBuild, IAM and Systems Manager Parameter Store.
- A GitHub account and a repository for this project.
- A Snyk account with an API token.
- Use the AWS region `ap-south-1` (Mumbai), unless your account/faculty requires another region.
- Use the CodeBuild on-demand EC2 compute type `general1.small` to stay within the published 100 build-minute monthly CodeBuild Free Tier allowance. Check the current AWS billing page and your account's actual usage before running builds.

## Quick start

1. Create a GitHub repository named `ice-devsecops-demo`.
2. Upload the contents of this folder to the repository root.
3. Run `npm install` locally in this directory and commit the generated `package-lock.json`.
4. Create a Snyk API token.
5. In AWS Systems Manager Parameter Store, create a **Standard / SecureString** parameter named `/CodeBuild/devsecops-demo/snyk-token` and store the token as its value.
6. Create a CodeBuild project connected to the GitHub repository. Choose a current Ubuntu standard image that supports Node.js 22, `general1.small`, and use the repository's `buildspec.yml`.
7. Use a new CodeBuild service role. Check that it can read the exact parameter in Parameter Store. If it cannot, add the least-privilege permission shown in `docs/IAM_POLICY.json`, replacing `ACCOUNT_ID` and region as required. For a customer-managed KMS key, also grant `kms:Decrypt` on that key.
8. Run the first build. Review the SCA and IaC logs separately. Record the actual result; do not assume both checks will flag findings until verified.
9. Remediate as described in `docs/SETUP_AND_DEMO_GUIDE.md` and run a second build.
10. Save screenshots of the initial scan findings, first build result, remediation commit, second scan results and build history.

## Important safety and accuracy notes

- **Do not deploy** `infra/s3-bucket.yaml`. It is intentionally insecure and is only for static scanning.
- The `minimist@0.0.8` dependency is an intentionally old test dependency. Snyk findings can change as its vulnerability database and policies change. If it does not trigger the selected threshold in your account, inspect the scan output and use a currently vulnerable package version listed by Snyk; do not fabricate results.
- The corrected example uses `minimist@1.2.8` as a demonstration target. Confirm the current Snyk scan result before stating it is clean.
- A successful scan means no findings were returned at or above the selected threshold; it does **not** prove that the application is completely secure.
- A failed scan can be caused by vulnerabilities (exit code `1`) or a scanner/setup error (typically exit code `2` or `3`). The buildspec reports these differently.
- Snyk Free plan quotas and AWS free allowances can change. Check current pricing pages before use.

## Official references

- AWS CodeBuild pricing: https://aws.amazon.com/codebuild/pricing/
- AWS CodeBuild available runtimes: https://docs.aws.amazon.com/codebuild/latest/userguide/available-runtimes.html
- CodeBuild Parameter Store permissions: https://docs.aws.amazon.com/codebuild/latest/userguide/change-project.html
- Snyk CLI `test`: https://docs.snyk.io/developer-tools/snyk-cli/commands/test
- Snyk CLI `iac test`: https://docs.snyk.io/developer-tools/snyk-cli/commands/iac-test
- Snyk pricing: https://snyk.io/plans/
