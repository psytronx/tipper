Tipper
==================

Tip Calculator app for CodePath

Time spent: 40 hours total (20+ hours was spent on implementing cost breakdown per person. This was not required, but I really wanted to implement it.)

Completed user stories:

* [x] Required: Basic tip calculator functionality
* [x] Required: Settings page
* [x] Optional: Remember the bill amount across app restarts (within 60 seconds)
* [x] Optional: Use locale specific currency and currency thousands separators
* [x] Additional: Showing both pre-tax and after-tax bill amounts. Both are editable fields.
* [x] Additional: Option to exclude tax from the tip calculation. Tax rate is specified in Settings view.
* [x] Additional: Cost breakdown per person. This turned out to be a pretty complex feature. It involved two more views, working with UITableView, extra math calculations, and the usage of delegation to pass data between views, among other things. As noted above, this feature took the majority of my time. I learned a lot doing it.

Notes:
This only works for iPhone 5 in Portrait orientation. I did not spend any time making the app look right in other screen sizes and Landscape orientation.

**Walkthrough:**

![](TipperDemo.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

