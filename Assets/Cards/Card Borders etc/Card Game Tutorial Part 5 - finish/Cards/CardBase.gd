extends MarginContainer


# Declare member variables here. Examples:
onready var CardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
var Cardname = 'Mentor'
onready var CardInfo = CardDatabase.DATA[CardDatabase.get(Cardname)]
onready var CardImg = str("res://Assets/Cards/",CardInfo[0],"/",Cardname,".png")
var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var t = 0
var DRAWTIME = 1
var ORGANISETIME = 0.5
onready var Orig_scale = rect_scale
enum{
	InHand
	InPlay
	InMouse
	FocusInHand
	MoveDrawnCardToHand
	ReOrganiseHand
	MoveDrawnCardToDiscard
}
var state = InHand
# Called when the node enters the scene tree for the first time.
func _ready():
#	print(CardInfo)
	var CardSize = rect_size
	$Border.scale *= CardSize/$Border.texture.get_size()
	$Card.texture = load(CardImg)
	$Card.scale *= CardSize/$Card.texture.get_size()
	$CardBack.scale *= CardSize/$CardBack.texture.get_size()
	$Focus.rect_scale *= CardSize/$Focus.rect_size
	
	var Attack = str(CardInfo[1])
	var Retaliation = str(CardInfo[2])
	var Health = str(CardInfo[3])
	var Cost = str(CardInfo[4])
	var Name = str(CardInfo[5])
	var SpecialText = str(CardInfo[6])
	$Bars/TopBar/Name/CenterContainer/Name.text = Name
	$Bars/TopBar/Cost/CenterContainer/Cost.text = Cost
	$Bars/SpecialText/Text/CenterContainer/Type.text = SpecialText
	$Bars/BottomBar/Health/CenterContainer/Health.text = Health
	$Bars/BottomBar/Attack/CenterContainer/AandR.text = str(Attack,'/',Retaliation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var setup = true
var startscale = Vector2()
var Cardpos = Vector2()
var ZoomInSize = 2
var ZOOMINTIME = 0.2
var ReorganiseNeighbours = true
var NumberCardsHand = 0
var Card_Numb = 0
var NeighbourCard
var Move_Neightbour_Card_Check = false
var Zooming_In = true
var oldstate = INF
var CARD_SELECT = true
var INMOUSETIME = 0.1
var MovingtoInPlay = false
var targetscale = Vector2()
var DiscardPile = Vector2()
var MovingtoDiscard = false
func _input(event):
	match state:
		FocusInHand, InMouse, InPlay:
			if event.is_action_pressed("leftclick"): # pick up card
				if CARD_SELECT:
					oldstate = state
					state = InMouse
					setup = true
					CARD_SELECT = false
			if event.is_action_released("leftclick"):
				if CARD_SELECT == false:
					if oldstate == FocusInHand: # putting a card into a cardslot
						var CardSlots = $'../../CardSlots'
						var CardSlotEmpty = $'../../'.CardSlotEmpty
						for i in range(CardSlots.get_child_count()):
							
							if CardSlotEmpty[i]:
								var CardSlotPos = CardSlots.get_child(i).rect_position
								var CardSlotSize = CardSlots.get_child(i).rect_size
								var mousepos = get_global_mouse_position()
								if mousepos.x < CardSlotPos.x + CardSlotSize.x && mousepos.x > CardSlotPos.x \
									&& mousepos.y < CardSlotPos.y + CardSlotSize.y && mousepos.y > CardSlotPos.y:
										setup = true
										MovingtoInPlay = true
										targetpos = CardSlotPos - $'../../'.CardSize/2
										targetscale = CardSlotSize/rect_size
										state = InPlay
										CARD_SELECT = true
										
										break
						if state != InPlay:
							setup = true
							targetpos = Cardpos
							state = ReOrganiseHand
							CARD_SELECT = true
					else: # handle once the card is in play
						var Enemies = $'../../Enemies'
						for i in range(Enemies.get_child_count()):
							var EnemyPos = Enemies.get_child(i).rect_position
							var EnemySize = Enemies.get_child(i).rect_size
							var mousepos = get_global_mouse_position()
							if mousepos.x < EnemyPos.x + EnemySize.x && mousepos.x > EnemyPos.x \
								&& mousepos.y < EnemyPos.y + EnemySize.y && mousepos.y > EnemyPos.y:
									# deal with damage
									var AttackNo = int($Bars/BottomBar/Attack/CenterContainer/AandR.text.left(1))
									Enemies.get_child(i).ChangeHealth(AttackNo)
									setup = true
									MovingtoDiscard = true
									state = MoveDrawnCardToDiscard
#									MovingtoInPlay = true
#									state = InPlay
									CARD_SELECT = true
									break
						if CARD_SELECT == false:
							setup = true
							MovingtoInPlay = true
							state = InPlay
							CARD_SELECT = true


func _physics_process(delta):
	match state:
		InHand:
			pass
		InPlay:
			if MovingtoInPlay:
				if setup:
					Setup()
				if t <= 1: # Always be a 1
					rect_position = startpos.linear_interpolate(targetpos, t)
					rect_rotation = startrot * (1-t) + 0*t
					rect_scale = startscale * (1-t) + targetscale*t
					t += delta/float(INMOUSETIME)
				else:
					rect_position = targetpos
					rect_rotation = 0
					rect_scale = targetscale
					MovingtoInPlay = false
					$'../../'.ReParentCard(Card_Numb)
		InMouse:
			if setup:
				Setup()
			if t <= 1: # Always be a 1
				rect_position = startpos.linear_interpolate(get_global_mouse_position() - $'../../'.CardSize, t)
				rect_rotation = startrot * (1-t) + 0*t
				rect_scale = startscale * (1-t) + Orig_scale*t
				t += delta/float(INMOUSETIME)
			else:
				rect_position = get_global_mouse_position() - $'../../'.CardSize
				rect_rotation = 0
				
		FocusInHand:
			if Zooming_In:
				if setup:
					Setup()
				if t <= 1: # Always be a 1
					rect_position = startpos.linear_interpolate(targetpos, t)
					rect_rotation = startrot * (1-t) + 0*t
					rect_scale = startscale * (1-t) + Orig_scale*2*t
					t += delta/float(ZOOMINTIME)
					if ReorganiseNeighbours:
						ReorganiseNeighbours = false
						NumberCardsHand = $'../../'.NumberCardsHand - 1 # offset for zeroth item
						if Card_Numb - 1 >= 0:
							Move_Neighbour_Card(Card_Numb - 1,true,1) # true is left!
						if Card_Numb - 2 >= 0:
							Move_Neighbour_Card(Card_Numb - 2,true,0.25)
						if Card_Numb + 1 <= NumberCardsHand:
							Move_Neighbour_Card(Card_Numb + 1,false,1)
						if Card_Numb + 2 <= NumberCardsHand:
							Move_Neighbour_Card(Card_Numb + 2,false,0.25)
				else:
					rect_position = targetpos
					rect_rotation = 0
					rect_scale = Orig_scale*ZoomInSize
					Zooming_In = false
		MoveDrawnCardToHand: # animate from the deck to my hand
			if setup:
				Setup()
			if t <= 1: # Always be a 1
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation = startrot * (1-t) + targetrot*t
				rect_scale.x = Orig_scale.x * abs(2*t - 1)
				if $CardBack.visible:
					if t >= 0.5:
						$CardBack.visible = false
				t += delta/float(DRAWTIME)
			else:
				rect_position = targetpos
				rect_rotation = targetrot
				state = InHand
		ReOrganiseHand:
			if setup:
				Setup()
			if t <= 1: # Always be a 1
				if Move_Neightbour_Card_Check:
					Move_Neightbour_Card_Check = false
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation = startrot * (1-t) + targetrot*t
				rect_scale = startscale * (1-t) + Orig_scale*t
				t += delta/float(ORGANISETIME)
				if ReorganiseNeighbours == false:
					ReorganiseNeighbours = true
					if Card_Numb - 1 >= 0:
						Reset_Card(Card_Numb - 1) # true is left!
					if Card_Numb - 2 >= 0:
						Reset_Card(Card_Numb - 2)
					if Card_Numb + 1 <= NumberCardsHand:
						Reset_Card(Card_Numb + 1)
					if Card_Numb + 2 <= NumberCardsHand:
						Reset_Card(Card_Numb + 2)
			else:
				rect_position = targetpos
				rect_rotation = targetrot
				rect_scale = Orig_scale
				state = InHand
		MoveDrawnCardToDiscard:
			if MovingtoDiscard:
				if setup:
					Setup()
					targetpos = DiscardPile
				if t <= 1: # Always be a 1
					rect_position = startpos.linear_interpolate(targetpos, t)
					rect_scale = startscale * (1-t) + Orig_scale*t
					t += delta/float(DRAWTIME)
				else:
					rect_position = targetpos
					rect_scale = Orig_scale
					MovingtoDiscard = false
				

func Move_Neighbour_Card(Card_Numb,Left,Spreadfactor):
	NeighbourCard = $'../'.get_child(Card_Numb)
	if Left:
		NeighbourCard.targetpos = NeighbourCard.Cardpos - Spreadfactor*Vector2(65,0)
	else:
		NeighbourCard.targetpos = NeighbourCard.Cardpos + Spreadfactor*Vector2(65,0)
	NeighbourCard.setup = true
	NeighbourCard.state = ReOrganiseHand
	NeighbourCard.Move_Neightbour_Card_Check = true
	
func Reset_Card(Card_Numb):
#	if NeighbourCard.Move_Neightbour_Card_Check:
#		NeighbourCard.Move_Neightbour_Card_Check = false
	if NeighbourCard.Move_Neightbour_Card_Check == false:
		NeighbourCard = $'../'.get_child(Card_Numb)
		if NeighbourCard.state != FocusInHand:
			NeighbourCard.state = ReOrganiseHand
			NeighbourCard.targetpos = NeighbourCard.Cardpos
			NeighbourCard.setup = true

func Setup():
	startpos = rect_position
	startrot = rect_rotation
	startscale = rect_scale
	t = 0
	setup = false

func _on_Focus_mouse_entered():
	match state:
		InHand, ReOrganiseHand:
			setup = true
			targetpos = Cardpos
			targetpos.y = get_viewport().size.y - $'../../'.CardSize.y*ZoomInSize
			Zooming_In = true
			state = FocusInHand


func _on_Focus_mouse_exited():
	match state:
		FocusInHand:
			setup = true
			targetpos = Cardpos
			state = ReOrganiseHand
