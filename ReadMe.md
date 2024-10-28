<p align="center">
<a href="" rel="noopener">
<img width=120px height=120px style="border-radius: 25px" src="https://github.com/tzuntar/SCVideo/blob/master/SCVideo/Assets.xcassets/AppIcon.appiconset/Icon-4.png?raw=true" alt="SCVideo Logo"></a>
</p>

<h3 align="center">SCVideo</h3>

---

<p align="center">Social Network for sharing short-form videos between students at the School Center Velenje.
<br>
</p>

## 📝 Contents

<!-- TOC -->

* [📹 About The Project](#about)
* [💎 Features](#features)
* [🚀 Deployment Instructions](#deployment)
    * [✅ Prerequisites](#prerequisites)
    * [⏳ Compiling & Bundling](#compiling)

<!-- TOC -->


## 📹 About The Project <a name = "about"></a>

This repository contains the source code of the iOS front-end of **SCVideo**.

SCVideo is a social network for sharing short-form videos between students at
the School Center Velenje.

I originally made this as my graduation project finishing the high school
Computer Technician program at ERS Velenje. Shortly before graduating I deployed
it and had several people use it to test it more thoroughly and upload some content.

## 💎 Features <a name = "features"></a>

| Video feed | Record & Publish | User Profiles | Comment Sections |
|------------|------------------|---------------|------------------|
| <img src="https://user-images.githubusercontent.com/35228139/233382967-d725a1bd-0c26-4324-bc5a-394b3f09b447.PNG" width=120px> | <img src="https://user-images.githubusercontent.com/35228139/233382977-5fabeae9-ac51-44cd-a652-a4e1d5ab21ec.PNG" width=120px> | <img src="https://user-images.githubusercontent.com/35228139/233382944-96ea335d-f88a-4fd3-b18e-3684052fdc9c.PNG" width=120px> | <img src="https://user-images.githubusercontent.com/35228139/233382955-aad7942b-2781-442d-8414-5b55dace1803.PNG" width=120px> |

## 🚀 Deployment Instruction <a name = "deployment"></a>

This assumes that you have the back-end already up and running. All that's left to
do for the front-end (ie. this repository) is compiling the app in Xcode.

### ✅ Prerequisites <a name = "prerequisites"></a>

Make sure you have the following:

- Xcode 12.4 or later
- the [CocoaPods](https://cocoapods.org/) package manager
- an iPhone with iOS 14.4 or later
- the back-end up and running -- see [the back-end repo](https://github.com/tzuntar/SCVideo-Backend)).

### ⏳ Compiling & Bundling <a name = "compiling"></a>

1. Register the app on Azure Active Directory, make sure that your *Bundle ID* matches what you've specified on there.
3. Install the dependencies by running `pod install`.
4. Create a file called `Keys.xcconfig` containing the following:
   ```
   MSAL_CLIENT_ID = ID of your app on Azure
   DEFAULT_SERVER_IP = IP of the server running the back-end
   ```
5. Open `SCVideo.xcworkspace` in Xcode (make sure you open that, not the `.xcodeproj`, otherwise
the dependencies won't be properly linked).
6. Connect an iPhone and run the app.
