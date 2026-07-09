extends Label

func update_label(label: String = "") -> void:
	if label == "":
		self.hide()
	else:
		self.text = label
		self.show()
