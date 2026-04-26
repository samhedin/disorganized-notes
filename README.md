# Disorganized: Notes & Todo
A note-taking app that supports tables, lists, reminders, timers, alarms, images, and much more.

[Android](https://play.google.com/store/apps/details?id=com.disorganized.disorganized&pli=1&gl=cn), [iOS](https://apps.apple.com/us/app/disorganized-notes-todo/id6738280174), [web (requires subscription)](https://app.getdisorganized.com/)

Visit our [Discord!](https://discord.gg/UEeughB9Qn)

<img width="258" height="559" alt="2" src="https://github.com/user-attachments/assets/dd56db14-5e9c-44f1-b12b-ad1eddd0e832" />


<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Disorganized](#disorganized)
- [On open sourcing](#on-open-sourcing)
- [Prerequisites](#prerequisites)
  - [Firebase](#firebase)
- [Limitations of the open source build](#limitations-of-the-open-source-build)
- [Code overview](#code-overview)
  - [The note object](#the-note-object)
  - [Working with a note](#working-with-a-note)
  - [Create a section](#create-a-section)
- [Questions and Answers](#questions-and-answers)
  - [I hate Firebase](#i-hate-firebase)
- [Code of conduct](#code-of-conduct)
- [Support the project](#support-the-project)

<!-- markdown-toc end -->


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

# Code overview
The sections (tables, lists, etc) are inside `disorganized.ui.*`, for example `disorganized.ui.list`. 
If there are multiple versions, like `table` and `table2`, then new development should only go into the latest version. 
The main file for the start-page, the list of notes, is inside `read.cljd`, while the note editor is inside `edit.cljd`.

Global data, state management and utils are inside `model.cljd`.

## The note
Below is a a basic note containing just a `Text` section.

Top level keys are turned into clojure keywords when loading the note since they're accessed so frequently, but nested keys are strings.

```
;;:sections is a map of section-id->section
;;Different sections have different keys and the format of the content is different.

;;As a rule of thumb, anything inside content should be emptied when cloning the note.
;;Data that shouldn't be emptied is added as extra keys.
;;For example, for the table2 section all rows are inside "content", and after cloning the table starts with 0 rows.
;;However, the columns should be retained when cloning and are therefore outside "content".

;;This is just a rule of thumb so check the cloning logic if necessary.

{:sections 

	{e5c5c608-9b12-4794-bb28-9d5e80244dfc
		{section-position 0,  ;;Since sections are a map the position is saved this way.
		 id e5c5c608-9b12-4794-bb28-9d5e80244dfc, ;;Duplicating the id of the section, often useful.
		 name Text, ;;Section title/header
		 content I'm some text, ;;content is where most data is, highly variable depending on which type of section
		 type text}}, 

 :tags [], 
 
 :id fff5d1b0-7061-474c-acfa-0bf0dd394e14,
 
 :user_access [<UID>],
 :updated_at Timestamp(seconds=1767105405, nanoseconds=607000000), 
 :title hello, 
 :plaintext , 
 :created_at Timestamp(seconds=1767105383, nanoseconds=311000000), 
 :roles {<UID> owner}, 
 :owner <UID>}
```

## Working with a note
Most code manipulates the current note somehow, and the standard way to make updates is using `::update-current-note`. Example usage:

```
(rd/dispatch [::model/update-current-note
                  (fn [note]
                    (update-in note [:sections section-id "content"]
                              #(str % time)))])
```
This will sync the note with firestore.

Beware when working with a DateTime, because Firebase will convert it to a Timestamp, Use `(.toDate x)` to get back your DateTime.

# Sections
Most code in Disorganized is related to working with sections. While displaying sections is usually straightforward - see `show_grid_note.cljd`, using them during editing can be trickier.
First of all, see the image below for a DETAILED visual understanding of where to start looking.
<img width="1934" height="670" alt="powerful_documentation" src="https://github.com/user-attachments/assets/09c4af9a-3dfa-4cad-bd2e-037b2fdba3f4" />


## Create a section
To create a section:
- Add an entry to `model/default-section-map` which contains the basic data model.
- Create the file `disorganized.ui.<section>` and add the logic.
- Add an entry to `edit/add-section-itembuilder`.
- The section needs to be rendered on the homepage, see `ui.show-grid-note` and add `show-<section-name>`
- Add a stringify function to `prettyprint.cljd`, this is called when exporting notes to markdown. Call the function from `prettyprint/note-to-string`
- Add a reference to the section show function to `edit/show-section`, in the `condp = type` clause.

The text section, `disorganized.ui.text`, is the shortest section so can be used as a starting point.

# Questions and Answers
## I hate Firebase
First of all, that's not a question.

I think that multiplatform and real-time sync are essential for a good note-taking experience, and therefore the app is deeply integrated with Firestore. Replacing and redesigning all pieces that depend on Firebase/Firestore would take a fair chunk of work. Afer that, maintaining two separate versions is a big task in itself.
I believe that it would be misguided to try to pull out Firebase, but if you absolutely want to do it I'm happy to provide pointers and guidance. No guarantee (in fact, it is unlikely) that I'd merge such code though.

And unlike what some people believe, Firestore does not require constant connectivity to function.

# Code of conduct
![no bulli allowed](https://github.com/user-attachments/assets/56ab62aa-deed-4569-b245-7b4f42f9e64c)

# Support the project
Subscribing to the premium version of the app is the best way to support the project!
