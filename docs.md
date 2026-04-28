

# Code overview
The sections (tables, lists, etc) are inside `disorganized.ui.*`, for example `disorganized.ui.list`. 
If there are multiple versions, like `table` and `table2`, then new development should only go into the latest version. 
The main file for the start-page, the list of notes, is inside `read.cljd`, while the note editor is inside `edit.cljd`.

Global data, state management and utils are inside `model.cljd`.

The screen that lists all notes is unintuitively named `read.cljd`.

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
Most code in Disorganized is related to working with sections. While displaying sections is usually straightforward - see `show_grid_note.cljd`, editing them can be trickier.
First of all, see the image below to understand that things related to the header (title, reordering, section properties) are found via `edit.cljd` while the main body is inside `<section>.cljd`
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


# What is OverlayPortal?
Some buttons and sections are wrapped in OverlayPortal, which is what displays 
the floating text fields during onboarding. OverlayPortal can mostly be ignored during regular development, but it does make the code more difficult to read.
