extends Node
## SIGNAL BUS ## 

#region Ethans Explanations and tips and stuff
## GlobalSignal Custom Class ##
"""
Created a custom 'GlobalSignal' class resource. It stores a String value 
for the signal name (used to broadcast the signal), plus an array that
parameters can be added to(in case you need to pass other stuff when 
broadcasting a signal).
"""

## SignalLibrary Custom Class ##
""" 
Custom resource for storing created GlobalSignal custom resources in 
an array. SignalBus uses the info in this array to create any Signals
needed for the game as soon as the SignalBus initialises
"""

## Connecting to Signal Bus ##
"""
Any script that wants to call a function when a specific signal is broadcast
by the SignalBus needs to connect to that signal directly aswell as have a 
function to run when the signal is recieved. 
Use connect_signal(connecting_node: Node, signal_name: String, function_name: String = "", one_shot: bool = false)
"""

## Awaiting Signal Bus signals inside other scripts ##
"""
To await a signal without having to connect to the SignalBus use 
await Signal(SignalBus, "signal_name")
"""
#endregion

# Constants #
#Debug print colors
const BLUE: String = "light_blue"
const CYAN: String = "cyan"
const RED: String = "red"
const GREEN: String = "green"

# Exported Variables #
@export var debug: bool = false
@export var signal_library: SignalLibrary##Custom resource containing all the global signals

# Variables #
var global_signals: Array[GlobalSignal]##Stores the signals found in the signal_library resource



# Initialisiation #
func _ready() -> void:
	create_global_signals()

func create_global_signals() -> void:
	_debug("Creating all global user signals")

	# Make sure we have a SignalLibrary attatched
	if not signal_library:
		printerr("No SignalLibrary resource assigned to SignalBus!!")
		return
	
	# Store the signals in a local variable
	global_signals = signal_library.global_signals
	
	# Loop through each GlobalSignal resource in the SignalLibrary resource
	_debug("Signals", CYAN)
	_debug("──────────────────────────────────────", CYAN)
	for global_signal in global_signals:
		# Get the signal name - global_signal is already the GlobalSignal resource
		var signal_name: String = global_signal.signal_name
		_debug("Signal: " + signal_name)
		
		# No parameters required, create the signal
		if global_signal.parameters.is_empty():
			add_user_signal(signal_name)
			print()
			continue
	
		# Found required parameters for signal. Create signal with parameters
		var parameters: Array = global_signal.parameters
		_debug("With Parameters: " + str(parameters))
		add_user_signal(signal_name, parameters)
		print()
	
	_debug("Successfully initialised all signals and associated parameters", GREEN)
	print()


# Connecting callable functions from other scripts to Global Signals #
func connect_signal(connecting_node: Node, signal_name: String, function_name: String = "", one_shot: bool = false):##Called by any node that needs to connect to a global signal.	
	# If no function_name is set then apply the default funciton name: "_on_" + signal_name
	if function_name == "":
		function_name = "_on_" + signal_name
	_debug("Connecting signal: " + signal_name + " to " + connecting_node.name+"."+function_name, "light_blue")
	
	# Create the callable function 
	var callable = Callable(connecting_node, function_name)
	
	# Make sure the connecting node has the function
	if has_signal(signal_name) and not connecting_node.has_method(function_name):
		printerr("Failed to connect ",signal_name, " to ", connecting_node," function: ",function_name,"(). Could not find method in connecting_node")
		return
	
	# Make sure the signal is declared in the Signal Bus
	if not has_signal(signal_name) and connecting_node.has_method(function_name):
		printerr("Failed to connect ",signal_name, " to ", connecting_node," function: ",function_name,"(). Signal not declared in Signal Bus")
		return
		
	# Connect the signal to the connecting nodes function	
	if one_shot:
		connect(signal_name, callable, CONNECT_ONE_SHOT)
	else:
		connect(signal_name, callable)

func connect_signals(connecting_node: Node, signals_array: Array):##Called by any node that needs to connect to a global signal. For connecting an array of signals at once rather than one at a time
	# Loop through the array and create a GlobalSignal for each signal in the array and connect the target nodes callable function
	for signal_name in signals_array:
		
		# Create the function name
		var function_name: String
		function_name = "_on_" + signal_name
		_debug("Connecting signal: " + signal_name + " to " + connecting_node.name+"."+function_name, "light_blue")
		
		# Create the callable 
		var callable = Callable(connecting_node, function_name)
		
		# Make sure the connecting node has the function
		if has_signal(signal_name) and not connecting_node.has_method(function_name):
			printerr("Failed to connect ",signal_name, "to ", connecting_node,".",function_name,". Could not find method in connecting_node")
			return
		
		# Make sure the signal is declared in the Signal Bus
		if not has_signal(signal_name) and connecting_node.has_method(function_name):
			printerr("Failed to connect ",signal_name, "to ", connecting_node,".",function_name,". Signal not declared in Signal Bus")
			return
			
		# Connect the signal to the connecting nodes callable function	
		connect(signal_name, callable)


# Bread And Butter #
func broadcast_signal(signal_name: String, parameters: Array = []):## This function is the SignalBus's bread and butter. Brodcasts a signal to everywhere, only connected nodes will recieve the broadcasted signal.
	_debug("Broadcasting signal: ", BLUE)
	# Check the custom resource in the exported variable if it contains the requested signal
	if not has_signal(signal_name):
		printerr("No signal with that name in SignalBus. signal_name: ", signal_name)
		return
	
	# If no parameters then emit the signal
	if parameters.is_empty():
		_debug("Signal Name: " + signal_name, BLUE)
		emit_signal(signal_name)
		return
	
	# If parameters, use callv to ensure parameters are passed as an array
	_debug("Signal Name: " + signal_name, BLUE)
	_debug("Parameters: " + str(parameters), BLUE)
	callv("emit_signal", [signal_name] + parameters)


# Helper Functions #
func _debug(message: String, text_color: String = BLUE) -> void:
	"""
	Helper function that prints in different colours and adds the 
	printing nodes name to the message automatically. Use instead of print()
	"""
	
	# Setting debug to false disables all prints from this script
	if not debug:
		return
	
	var color_tag_open = "[color=" + text_color + "]"
	var color_tag_close = "[/color]"
	print_rich(color_tag_open + "SIGNAL BUS: " + message + color_tag_close)
