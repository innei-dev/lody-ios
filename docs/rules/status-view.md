# Status view and pin sections (iOS)

Read before changing the Home Pinned area, the Status grouping (Focus / Later / Settled), their gestures, menus and sheets, or the conversation page's status actions. Intended behavior: Lody `specs/sidebar-status-view.md` (Phones) and `specs/pinned-session-sections.md`; design and JSON contract: Lody `.agents/notes/proposed/architecture/2026-11-21-status-view-on-phones.md`. These rules bind every caller of the area, not only files in its directory.

- The shared runtime computes the list. The catalog snapshot carries `statusView: { mine, team }` and `pinSections`, decoded in `Sessions/StatusView.swift` (`StatusViewLayouts`, lossy per row and per section). Swift never sorts or classifies these rows: the Pinned area in every grouping and the whole Status grouping list exactly the layout's sections, rows and children in its order (`InboxSections.home` with `layout`). Only time and project buckets keep native grouping, and they skip every id the layout pins. Without a layout (a runtime or catalog cache older than it) Pinned falls back to the flagged families and Status to time buckets; never reintroduce a native tier classifier.

- Session content (title, project, branch, PR, status mark) comes from the catalog; unread, activity time, the Later countdown and the offered actions come from the layout row (`InboxSections.decorate`). The local viewed watermark still clears unread emphasis. Rows the catalog lacks are skipped; an Outbox creation the catalog has not read back (`SessionItem.pending`) shows at the top of Focus.

- Pin sections are list sections `pinned` (the default) and `pinned:<id>`; a user section stays as a labelled, empty drop target. Focus, Later and Settled are `focus`, `later` and `settled`. Later and Settled start collapsed and show their count while collapsed (`ChatGroupFolds`, device-local); Settled folds past `settledLimit` top-level rows behind Show all. A section's scope-hidden count is a non-interactive line under its rows.

- Writes are `StatusViewCommand`s sent through `SessionSource.statusCommand` to the runtime's `statusViewCommand`, which plans keys, jitter and opened-children rules against its replica. A move names the row it lands in front of (`beforeId`, nil for the end), never an index or a key. `StatusViewRuntime` decodes the note's JSON into the generated params, so only the method names couple Swift to the contract. Later presets come from `snoozePresets()`.

- Offer status actions only from the row's `canManage` and pin placement only from `canPrefer`; section management is offered while any row has `canPrefer`. Read-only rows have no status swipe, menu, drag or accessibility move.

- Long press opens the menu: Later ▸ (presets with resolved times, Custom time…, Move to Focus while snoozed), Settle or Move to Focus, Pin / Unpin, Move to Section ▸ (top of another section, or New Section…), Move to Top, then the existing items. Moving while pressed turns the lifted row into a local UIKit drag (`ChatListStatusHooks`): only top-level rows lift; Focus reorders, pin sections reorder and exchange rows, a drop into the Pinned area pins, a Later or Settled row dropped into Focus is restored; pinned rows leave through Unpin. A drop on a collapsed section lands at its top. Each crossed slot ticks a selection haptic. VoiceOver rows offer Move up and Move down within their area.

- While a drag is in flight the list defers incoming projections and applies the latest when it ends. A drop, Move to Top, Move to Section or accessibility move shows its order at once through `StatusViewHold` until the catalog shows the row there, the write fails, or a newer layout arrives after the write was accepted.

- Trailing swipe: Settle and Later on Focus and Later rows, Archive on Settled rows; leading swipe pins or unpins. Never full-swipe.

- Later opens a bottom sheet with the presets and a custom date and time; past times are refused there and again before sending. A preset picked from the menu is resolved again first. Settle and Later confirm with an Undo notice that restores the previous tier (`StatusViewPlanning.undo`). When the conversation has active opened sub-conversations, Settle, Later and Move to Focus first ask, as desktop, whether they follow; drags never ask.

- Pin section labels carry a ⋯ menu: New Section… on every section; Rename, Move Up, Move Down and Delete on user sections (the default section stays first). Sections reorder only through Move Up / Move Down; deleting asks first and its conversations return to the default section.

- The conversation page's More menu carries the row's Later / Settle / Move to Focus, read from whichever scope's layout lists it.

- Verification: `apps/ios/verification/kit/session-rows` (decoding, row mapping, drop and accessibility planning, holds, undo, countdown, command JSON). The Debug list preview `--ui-review-status` renders a fixture layout.
