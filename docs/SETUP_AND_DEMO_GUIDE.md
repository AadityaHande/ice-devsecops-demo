# Step-by-step setup and practical demonstration guide

## Part A — Prepare the GitHub repository

1. Extract this ZIP.
2. Create a public or private GitHub repository named `ice-devsecops-demo` (private is fine if CodeBuild has repository access).
3. Upload the contents of this folder to the **repository root**. Do not upload the parent folder as an extra nested level.
4. On your Windows machine, open PowerShell in the extracted project folder and run:

   ```powershell
   npm install
   ```

   This creates `package-lock.json`. Commit and push it. The build uses `npm install` so it can also generate a lockfile if needed, but committing the lockfile makes dependency resolution more repeatable.
5. Confirm the repository root contains `package.json`, `index.js`, `buildspec.yml`, `infra/s3-bucket.yaml`, and `package-lock.json`.

## Part B — Create a Snyk token

1. Sign up/sign in at https://app.snyk.io/.
2. Open account settings and create/copy an API token. The menu wording may vary.
3. Do not put the token in GitHub, the project files, screenshots or the video.
4. Snyk Free currently lists SCA, SAST, IaC and Container capabilities with product-specific limits. This project uses SCA and IaC only. Check your account's current usage limits.

## Part C — Save the token in Parameter Store

1. Sign in to the existing AWS account.
2. Select `Asia Pacific (Mumbai) ap-south-1` in the region selector (or use the region chosen for your class).
3. Open **Systems Manager → Parameter Store → Create parameter**.
4. Set:
   - Name: `/CodeBuild/devsecops-demo/snyk-token`
   - Tier: `Standard`
   - Type: `SecureString`
   - KMS key: default AWS-managed key, unless your course environment specifies otherwise
   - Value: the Snyk token
5. Create the parameter.
6. For screenshots, show only the name and type. Never reveal the value.

## Part D — Create the CodeBuild project

1. Open **AWS CodeBuild → Build projects → Create build project**.
2. Project name: `ice-devsecops-build`.
3. Source provider: GitHub. Connect/authorize the GitHub account if prompted, then select the repository `ice-devsecops-demo` and branch `main`.
4. Environment:
   - Provisioning model: On-demand
   - Environment image: Managed image
   - Compute: EC2 on-demand `general1.small`
   - Operating system/image: choose a current Ubuntu standard image that offers Node.js 22 (for example, Ubuntu standard:8.0 where available)
   - Environment type: Linux
5. Buildspec: use the `buildspec.yml` file at the repository root.
6. Create a **new service role** when prompted. The generated CodeBuild role may include SSM access only for `/CodeBuild/` parameters, which is why this guide stores the token below `/CodeBuild/`.
7. Create the project.
8. Open **IAM → Roles → the CodeBuild service role** and inspect its policies. Confirm it can call `ssm:GetParameters` on the ARN for `/CodeBuild/devsecops-demo/snyk-token`. If it cannot, add the least-privilege statement from `IAM_POLICY.json`, replacing `ACCOUNT_ID` and region. If you use a customer-managed KMS key, also grant `kms:Decrypt` for that specific key. Do not grant broad `ssm:*` or `kms:*` permissions.
9. If desired, enable the GitHub webhook after a manual first build works. A push to the configured branch can then trigger another build automatically.

## Part E — Run the initial security scan

1. Open the CodeBuild project and select **Start build**.
2. Open the build details and then **Build logs**.
3. Find these sections in the logs:
   - `SCA CHECK: Open-source dependency vulnerabilities`
   - `IaC CHECK: Infrastructure configuration`
   - `SCA_RESULT=...`
   - `IAC_RESULT=...`
   - `SECURITY_PIPELINE_RESULT=...`
4. Save screenshots of actual scan output and build status.
5. Interpret the exit states correctly:
   - `0`: scan completed and no findings at/above the selected threshold.
   - `1`: scan completed and findings require action.
   - `2` or `3`: tool/configuration/project-detection failure; investigate, do not present it as a vulnerability finding.
6. The buildspec exits with failure if there are policy findings or a scanner/setup error, but prints different messages for each condition.

## Part F — Remediate and run verification

### Fix the dependency

In PowerShell, from the project root:

```powershell
npm install minimist@1.2.8 --save-exact
```

Review the updated `package.json` and `package-lock.json`. If Snyk still reports an issue, follow the remediation guidance in the live Snyk result and use a currently supported non-vulnerable version. Do not assume a version is safe without rescanning.

### Fix the IaC configuration

Copy the secure example over the scanned template:

```powershell
Copy-Item .\examples\fixed\s3-bucket.yaml .\infra\s3-bucket.yaml -Force
```

This adds S3 public-access blocking and default server-side encryption configuration. It is a template for static scanning only; do not deploy it for this assignment.

### Push the remediation

```powershell
git add package.json package-lock.json infra/s3-bucket.yaml
git commit -m "fix: remediate dependency and S3 configuration findings"
git push origin main
```

If the webhook is enabled, a new build should start. Otherwise, select **Start build** manually.

### Verify the output

- Confirm the SCA scan completed and its result.
- Confirm the IaC scan completed and its result.
- Confirm `SECURITY_PIPELINE_RESULT=PASSED` only if both scans returned exit code `0`.
- Confirm CodeBuild status is `SUCCEEDED`.
- If a scan still reports findings, follow the current Snyk remediation advice and repeat; do not edit logs or manufacture a pass.

## Part G — Screenshots to include

1. GitHub repository root with project files.
2. Parameter Store parameter name and SecureString type (value hidden).
3. CodeBuild project configuration showing GitHub, environment and buildspec.
4. Initial SCA scan output.
5. Initial IaC scan output.
6. First build status and logs.
7. GitHub remediation commit showing the dependency and IaC change.
8. Second SCA and IaC scan output.
9. Second build status and build history showing both executions.

## Part H — Practical demonstration video sequence

1. Introduce the student implementation and its relationship to SEC211 principles.
2. Show the GitHub repository and explain the sample app, vulnerable dependency and IaC template.
3. Show Parameter Store and explain secure token handling (keep its value hidden).
4. Show the CodeBuild project and explain the source, Node runtime, IAM role, buildspec and scan commands.
5. Open the first build log. Explain the SCA and IaC results separately. Show the actual failed status if the scan reports findings.
6. Show the remediation commit.
7. Open the second build and explain the re-scan.
8. Show the actual final status and explain what it proves—and what it does not prove.
9. Conclude by connecting SCA, IaC scanning, automated policy gates and remediation verification to shift-left DevSecOps.

## Troubleshooting

### Parameter Store access denied
- Confirm the parameter is in the same region as CodeBuild.
- Confirm the variable path exactly matches the buildspec.
- Confirm the CodeBuild service role has `ssm:GetParameters` on the parameter ARN.
- For a customer-managed KMS key, confirm `kms:Decrypt` on that key.

### Snyk authentication error
- Confirm the token is current and stored as SecureString.
- Confirm the CodeBuild buildspec has the exact parameter path.
- Never print `$SNYK_TOKEN` to logs.

### Snyk reports no supported project
- Confirm `package.json` is at the repository root.
- Confirm `npm install` completed and produced `package-lock.json`.
- Confirm `snyk test` executes from the project root.

### IaC scan does not detect the expected issue
- Confirm the file path is `infra/s3-bucket.yaml`.
- Confirm the source file still contains `AccessControl: PublicRead` for the initial run.
- Inspect whether Snyk IaC supports and flags that exact CloudFormation rule in the current plan/CLI. If not, use an insecure sample configuration that Snyk's live scan explicitly identifies and document the actual result.

### The fixed build still fails
- Read the actual Snyk report; there may be additional vulnerabilities.
- Fix or upgrade according to the current Snyk remediation guidance.
- Check if the failure is exit code `2` or `3` (tool/configuration problem) rather than a finding.
- Re-run only after correcting the underlying issue.

## Cleanup to avoid unnecessary charges

- Disable/delete the CodeBuild GitHub webhook if no longer needed.
- Delete the CodeBuild project after grading if it is no longer required.
- Delete the Parameter Store parameter when finished.
- Remove the IAM inline policy/role if created only for this project and no longer used.
- Review AWS Billing and CloudWatch Logs. Do not delete resources used by other coursework.
- Do not deploy the intentionally insecure template.
