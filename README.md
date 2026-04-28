# Disorganized: Notes & Todo
A note-taking app that supports tables, lists, reminders, timers, alarms, images, and much more.

[Android](https://play.google.com/store/apps/details?id=com.disorganized.disorganized&pli=1&gl=cn), [iOS](https://apps.apple.com/us/app/disorganized-notes-todo/id6738280174), [web (requires subscription)](https://app.getdisorganized.com/)

Visit our [Discord!](https://discord.gg/UEeughB9Qn)



<img width="258" height="559" alt="2" src="https://github.com/user-attachments/assets/dd56db14-5e9c-44f1-b12b-ad1eddd0e832" />


<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Disorganized: Notes & Todo](#disorganized-notes--todo)
- [Documentation](#documentation)
- [On open sourcing](#on-open-sourcing)
- [Prerequisites](#prerequisites)
  - [Firebase](#firebase)
- [Limitations of the open source build](#limitations-of-the-open-source-build)
- [Questions and Answers](#questions-and-answers)
  - [I hate Firebase](#i-hate-firebase)
    - [I don't trust Firestore/Firebase](#i-dont-trust-firestorefirebase)
- [Code of conduct](#code-of-conduct)
- [Support the project](#support-the-project)

<!-- markdown-toc end -->

# Documentation
[READ HERE](docs.md)

# On open sourcing
Disorganized has been a closed-source private project since its inception, and
some parts of the codebase are consequences of that. I'll clean it up with time.

# Prerequisites
ClojureDart: https://github.com/Tensegritics/ClojureDart?tab=readme-ov-file#your-first-app

Flutter: https://docs.flutter.dev/reference/create-new-app

The web version should be easiest to get started with, then Android and lastly iOS.

## Firebase
Disorganized uses many Firebase features, but to get started
the most important ones are Firestore and Auth.

1. Set up a project on Firebase: https://firebase.google.com/
2. Install and authenticate the firebase cli using `curl -sL firebase.tools | bash`
3. Run `firebase init` inside this directory. 
4. Mark at least `Firestore` when selecting features.

Then in your browser open `console.firebase.google.com`:
```
console.firebase.google.com/project/PROJECT-ID → Build → Firestore Database → click "Create database"
```

Then navigate to `Firestore Database` and create these collections:
1. `notes2`
2. `reminders`
3. `devices`
4. `users`

Then, switch to the rules tab and paste this (if required).

**JUST FOR DEVELOPMENT PURPOSES, THIS LEAVES YOUR DATA IN THE OPEN**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Allow all access to all documents in all collections
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

Next, run `firebase deploy --only firestore:indexes` to get the required indexes.

Finally, run `flutterfire configure` to generate `lib/firebase_options.dart` (gitignored, you generate it for your own Firebase project).

The app uses revenuecat to handle subscriptions. Copy `lib/secrets.dart.example` to `lib/secrets.dart` and fill in your own keys from app.revenuecat.com. This is also in gitignore. 

Finally, to run the web version you can use:
`clj -M:cljd flutter -d chrome --web-port 7357 --web-hostname localhost`
Running the mobile versions is also possible but will require more setup, see the flutter docs for more info.

# Limitations of the open source build

- Reminders won't work because they are sent via a cloud function with code that isn't open source (but just let me know if that's important to you and I'll help out).
- media2 section requires cloud storage to work so you'll need to set that up.
- The AI features requires Gemini which you can enable via firebase.

# Questions and Answers
## I hate Firebase
First of all, that's not a question.

I think that multiplatform and real-time sync are essential for a good note-taking experience, and therefore the app is deeply integrated with Firestore. Replacing and redesigning all pieces that depend on Firebase/Firestore would take a fair chunk of work. Afer that, maintaining two separate versions is a big task in itself.
I believe that it would be misguided to try to pull out Firebase, but if you absolutely want to do it I'm happy to provide pointers and guidance. No guarantee (in fact, it is unlikely) that I'd merge such code though.

And unlike what some people believe, Firestore does not require constant connectivity to function.

### I don't trust Firestore/Firebase
By default notes are encrypted at rest. If you want double security you can encrypt your notes on your device, there is already limited support for it.
You can just extend the encryption to support the things you care about - it will be easier than swapping out
the hosting entirely.


# Code of conduct
![no bulli allowed](https://github.com/user-attachments/assets/56ab62aa-deed-4569-b245-7b4f42f9e64c)

# Support the project
Subscribing to the premium version of the app is the best way to support the project!
