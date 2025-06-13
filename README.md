# Voice_Summary

A new Flutter project to showcase Google Gemini API capabilities & Google Cloud APIs.

<img width="547" alt="image" src="https://github.com/user-attachments/assets/c88d72a5-660a-4711-9c8c-c62875ae1326" />


## Getting Started

This project is a starting point for a Flutter application.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Create a Service Account

### Before you can run this project, you need to create a Google Cloud Service Account.

A service account is a special Google account that belongs to your app or a virtual machine (not a human). It allows your app to authenticate securely and access Google Cloud services, such as Cloud Storage API or Speech-to-Text.

Think of it like a digital employee with specific permissions for your app.

<img width="1724" alt="Screenshot 2025-06-12 at 16 28 43" src="https://github.com/user-attachments/assets/a7f324c4-873e-48cf-972a-f32554010feb" />



### How to Create a Service Account in Google Cloud:

#### Step 1: Open Google Cloud Console
- Go to Google Cloud Console
- Make sure you're in the right project (top-left project selector)

#### Step 2: Go to the IAM & Admin Section
- In the left sidebar menu, go to:
- IAM & Admin → Service Accounts

#### Step 3: Create a New Service Account
- Click the “+ CREATE SERVICE ACCOUNT” button at the top.
- Fill in the details:
- Service account name: e.g., voice-summary-service
- Service account ID: will auto-fill based on the name
- Click Create and Continue
  
#### Step 4: Grant the Service Account Access
- Now you assign roles. What this account can do. You can select roles like:
- Speech-to-Text User – for using Speech-to-Text
- Storage Object Viewer – for accessing files in Cloud Storage
- Click Continue
- Creating and Downloading a Service Account Key (Important!)
- Now, let’s create a key file (a .json file) that your app will use for authentication.

#### Step 6: Create a Key
- Find your service account in the list.
- Click the 3-dot menu on the right → Click Manage keys
- Under the Keys section, click Add Key → Create new key
- Choose
- Key type: JSON (most common and supported by SDKs)
- Click Create
- The .json file will be automatically downloaded; store it securely.

### Summary
#### Setting up Gemini AI  and  using Google Cloud involves:
- Creating and configuring your Google Cloud project
- Enabling Gemini and Speech-to-Text APIs
- Creating and securing your API keys
- Monitoring usage and managing costs carefully

