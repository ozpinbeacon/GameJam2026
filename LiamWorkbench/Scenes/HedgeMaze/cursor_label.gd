extends Label

# Is sent a signal from Main, will be blank if no item is currently colliding
# with the cursor

func update_label(label: String = "") -> void:
	# If the received signal is an empty string, hide the label, else display
	# it's contents
	if label == "":
		self.hide()
	else:
		self.text = label
		self.show()
