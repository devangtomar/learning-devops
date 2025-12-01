# 🚀 How to Write a Custom AWS IAM Policy (From Scratch)

AWS IAM (Identity and Access Management) policies define **who can do what** in your AWS account. Custom policies allow you to match permissions exactly to your needs.

This guide explains how IAM policies work and how to build one from the ground up.

---

## 🧩 1. Understand the Structure of an IAM Policy

An IAM policy is a **JSON document** with the following main parts:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow" | "Deny",
      "Action": ["service:operation"],
      "Resource": ["arn:aws:service:region:account-id:resource"],
      "Condition": { ... }   // (optional)
    }
  ]
}
```

### Breakdown

* **Version**
  Always use `"2012-10-17"`—the latest policy language version.

* **Statement**
  A list of individual permission blocks.

* **Effect**

  * `"Allow"` → grants permission
  * `"Deny"` → explicitly blocks permission

* **Action**
  AWS API operations such as:

  * `"s3:PutObject"`
  * `"ec2:DescribeInstances"`
  * `"dynamodb:*"` (wildcard)

* **Resource**
  ARN (Amazon Resource Name) of the resources affected.

* **Condition** (optional)
  Add logic-based filters (e.g., IP address, MFA required).

---

## 🛠️ 2. Steps to Create a Custom IAM Policy

### **Step 1: Identify what the policy should allow**

Example: Allow writing objects to a specific S3 bucket.

### **Step 2: Find actions in AWS documentation**

Each AWS service has an “Actions, Resources, and Condition Keys” page.

Example: `s3:PutObject`, `s3:GetObject`

### **Step 3: Determine the resource ARNs**

Example S3 bucket object ARN:

```
arn:aws:s3:::my-bucket/*  
```

### **Step 4: Build the JSON policy**

Start with effect → actions → resources → (optionally) conditions.

---

## 📘 3. Example: Allow Uploading to a Specific S3 Bucket

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3Uploads",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

---

## 🔐 4. Example: Deny Access Unless MFA Is Enabled

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

---

## 🧪 5. Validate Your Policy

AWS provides tools to verify your policy:

* **IAM Policy Validator** (console)
* **IAM Policy Simulator**:
  Test actions against users/roles to confirm behavior.

---

## 🎯 6. Attach the Policy

You can attach custom policies to:

* IAM Users
* IAM Groups
* IAM Roles

AWS recommends attaching to **roles and groups** rather than directly to users.

---

## 📚 7. Tips for Writing Secure Policies

✔ Use **least privilege**: grant only what is necessary
✔ Prefer `"Allow"` with limited scope instead of blanket allow
✔ Use **Conditions** to tighten security
✔ Avoid `"*"` (wildcards) unless absolutely needed
✔ Test policies before deploying to production
