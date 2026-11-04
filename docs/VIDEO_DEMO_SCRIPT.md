# Practical Implementation Video — Slide/Screen-wise Speaking Script

**Suggested length:** 5–7 minutes (adjust to faculty instructions).

This is a separate practical video, not the SEC211 content-summary presentation.

## 1. Opening — 20–30 seconds

"Hello. This video demonstrates a small DevSecOps pipeline developed as a student implementation inspired by the AWS re:Invent 2024 SEC211 session on ICE's developer-focused security workflow. The objective is to integrate automated dependency and infrastructure security checks into a CI build, enforce a security gate, remediate the findings and verify the result with a second build."

## 2. GitHub repository — 40 seconds

[Open the GitHub repository.]

"This repository contains a small Node.js sample application, its package manifest, a CloudFormation infrastructure template and the CodeBuild buildspec. The dependency and infrastructure examples are intentionally insecure for static testing only. The CloudFormation template will not be deployed."

Point out `package.json`, `index.js`, `infra/s3-bucket.yaml` and `buildspec.yml`.

## 3. Snyk and secure token handling — 30–40 seconds

[Open Snyk dashboard briefly, then Parameter Store.]

"Snyk is used for Software Composition Analysis and Infrastructure as Code scanning. Its API token is stored in AWS Systems Manager Parameter Store as a SecureString. CodeBuild retrieves it using its IAM service role. The token value is intentionally hidden and is not stored in GitHub."

Show the parameter name and type only. Never reveal the value.

## 4. CodeBuild configuration — 45–60 seconds

[Open the CodeBuild project details.]

"The CodeBuild project is connected to the GitHub repository. The build environment uses a managed Linux image with Node.js 22. The buildspec installs dependencies and the Snyk CLI, then runs two scans: `snyk test` for open-source dependency vulnerabilities and `snyk iac test` for the CloudFormation template. The selected threshold is medium and above."

## 5. First build — 60–90 seconds

[Open the actual first build logs.]

"This is the initial scan. The SCA stage checks the Node.js dependency tree. The IaC stage checks the S3 bucket configuration. The logs report each scan independently and then evaluate the security gate. Here is the actual result from this run."

Point to the actual Snyk finding(s), exit code(s), final marker and CodeBuild status. Do not claim a finding if the scan did not produce one. If the build failed because of authentication, network or project-detection errors, explain and fix that before recording the final practical.

## 6. Remediation — 45–60 seconds

[Show the changed files and Git commit.]

"After reviewing the results, the dependency was updated to a version that must be re-checked against the current Snyk database, and the infrastructure template was changed to block public access and enable default encryption. The corrected files were committed and pushed to the repository."

## 7. Second build and verification — 60–90 seconds

[Open the second build logs and status.]

"The second build repeats the same checks against the remediated files. The SCA and IaC outcomes are shown separately. Both must complete with exit code zero for the pipeline to print `SECURITY_PIPELINE_RESULT=PASSED`. The CodeBuild status confirms whether this execution succeeded. This is the verification stage of the remediation cycle."

If either check still finds an issue, show the real result, correct it and run again. Do not edit logs or describe a failed scan as passed.

## 8. Closing — 20–30 seconds

"This implementation demonstrates how SCA and IaC scanning can be integrated into an AWS CI build. The security gate prevents a build from passing when the configured policy is violated, and a new scan verifies remediation. It illustrates shift-left security, automation and developer feedback—principles related to those discussed in the ICE SEC211 session. Thank you."

## Recording checklist

- Use actual AWS console screens and actual CodeBuild logs.
- Hide account IDs if required by your institution, and always hide the Snyk token.
- Show the first and second build IDs/statuses.
- Make the scan findings readable; pause the recording while showing important log lines.
- Do not show a green/pass result unless both scanner commands actually returned zero.
- State that this is a student implementation inspired by SEC211, not ICE's internal production system.
