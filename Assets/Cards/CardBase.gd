extends MarginContainer
# remember to put everything in the ready function
@onready var cardDatabase = preload("res://Assets/Cards/Database.gd").new()
#@onready var Deck = preload("res://Deck.gd").new()
var cardSuit = "Diamonds"
@onready var cardInfo= cardDatabase.DATA[cardDatabase.get(cardSuit)]
@onready var suitSize = len(cardInfo)
var cardName = "Ace"
var cardPosition 
@onready var origScale = scale
@onready var CardImg = str("res://Assets/Cards/Playing Cards/",cardName,"_",cardSuit,"_white.png")

var startPos = Vector2() 
var endPos = Vector2()
var startScale =Vector2()
var CardPos = Vector2()
var InDrag = false 
var startRot = 0 
var endRot = 0
var t = 0
var DRAWTIME = 1
var state = InHand
var setup = true
var ZoomInSize = 1.5
var ORGANISETIME =0.5
var ZOOMINTIME = 0.1
var neighborsReorganised = true
var numOfCardsInhand =0
var Card_Numb= 0
var next_card 
var next_card_moved_check = false
var oldstate 
var CARD_SELECTED =true
var MouseTime = 0.1
var DragStatus = false #false is still in Drag true means it's no longer in Drag
var movingToPlay =false
var endScale= Vector2()
var DiscardPile=Vector2()
var cardToBeDiscarded =false
var gameSlotPos = Vector2()
var gameSlotSize = Vector2()
var oldpos =Vector2()
var CardinPlay= false
var Zooming_In = false
var oldscale =Vector2()
var ZoomInSizeInPlay = 1.5
var mousepos =Vector2()
var reParent = true
@onready var GameSlots =$'../../../GameSlots'
@onready var  slotEmpty =$'../../../'.slotEmpty
enum{
	InHand,
	Inplay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganisHand,
	MovingtoDiscard
}

func _ready():
	print(cardName)
	var CardSize = size
	$Border.scale *= CardSize/$Border.texture.get_size()
	$cardface.texture = load(CardImg)
	$cardface.scale *= CardSize/$cardface.texture.get_size()
	$cardback.scale *= CardSize/$cardback.texture.get_size()
	$focus.scale *= CardSize/$focus.get_size()
	cardPosition = cardDatabase.cardDictionary[cardName]

func _input(event):
	if event.is_action_pressed("left_click"):
		if state == FocusInHand:
			if CARD_SELECTED:
				print("InDrag")
				#oldstate = state 
				state = InMouse
				setup = true 
				CARD_SELECTED = false
	if event.is_action_released("left_click"):
		#print("button released")
		if CARD_SELECTED==false:
			#print("out of drag")
			if oldstate == InHand || oldstate ==ReOrganisHand:
				#print(GameSlots.get_child_count())
				for i in range( GameSlots.get_child_count()):
					if slotEmpty[i]:
						gameSlotPos= GameSlots.get_child(i).position
						gameSlotSize= GameSlots.get_child(i).size*GameSlots.get_child(i).scale
						mousepos = get_global_mouse_position()
						if mousepos.x < gameSlotPos.x + gameSlotSize.x && mousepos.x > gameSlotPos.x \
							&& mousepos.y < gameSlotPos.y + gameSlotSize.y && mousepos.y > gameSlotPos.y:
							#if GameSlots.get_child(i).InFocus:
							slotEmpty[i] = false
							print('in slot')
							setup =true
							movingToPlay =true
							#GameSlots.get_child(i).InFocus = false
							endPos = gameSlotPos
							#CardPos = endPos
							print(endPos)
							endScale = gameSlotSize/size
							#GameSlots.get_child(i).cardInPlace = true
							endScale = Vector2(gameSlotSize.y,gameSlotSize.x)/size
							state = Inplay
							CARD_SELECTED =true
							CardinPlay = true
							break

					if state != Inplay:
						setup = true
						endPos =CardPos
						endScale = origScale
						state = ReOrganisHand
						CARD_SELECTED =true
			else:
				if CARD_SELECTED==false:
					setup =true
					movingToPlay =true
					state = Inplay
					CARD_SELECTED = true
					if CardinPlay:
						endPos = oldpos
						endScale = oldscale

#func _input_event(event):
#	match  state:
#		InHand,InMouse,FocusInHand:
#			if event.is_action_pressed('left click') :
#				if CARD_SELECTED:
#					oldstate = state 
#					state = InMouse
#					setup = true 
#					CARD_SELECTED = false
#					InDrag= true
#			else:
#				InDrag = false

#func _process(delta):
#	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or InDrag:
#		oldstate =state
#		state = InMouse
#	if InDrag == false:
#		oldstate = state
#		state = ReleasedfromMouse

func MoveCard(delta, state, timescale, endPos, endScale, endRot ):
	var finished = false
	if setup:
		Setup()
		if state == Inplay:
			if reParent:
				$'../../../'.ReparentCard(Card_Numb)
				reParent = false
	elif state == FocusInHand:
		if CardinPlay==false:
			if neighborsReorganised:
				neighborsReorganised =false
				numOfCardsInhand = $'../../../'.numOfCardsInhand -1
				if Card_Numb -1 >= 0:
					move_next_card(Card_Numb-1,true,1)#true left
				if Card_Numb -2 >= 0:
					move_next_card(Card_Numb-2,true,0.25)
				if Card_Numb +1 <= numOfCardsInhand:
					move_next_card(Card_Numb+1,false,1) # false right
				if Card_Numb +2 <= numOfCardsInhand:
					move_next_card(Card_Numb+2,false,0.25)
	elif state == ReOrganisHand:
		if next_card_moved_check:
			next_card_moved_check= false
	if t<=1:
		if state==ReOrganisHand && CardinPlay == false:
			if neighborsReorganised==false:
						neighborsReorganised=true
						if Card_Numb -1 >= 0:
							reset_card(Card_Numb-1)#true left
						if Card_Numb -2 >= 0:
							reset_card(Card_Numb-2)
						if Card_Numb +1 <= numOfCardsInhand:
							reset_card(Card_Numb+1) # false right
						if Card_Numb +2 <= numOfCardsInhand:
							reset_card(Card_Numb+2)
		position = startPos.lerp(endPos,t)
		rotation = startRot*(1-t) + endRot*t 
		if state==MoveDrawnCardToHand:
			scale.x= origScale.x * abs(2*t-1)
			if $cardback.visible:
				if t >=0.5:
					$cardback.visible =false
		else:
			scale = startScale*(1-t) + endScale*t
		t+= delta/float(timescale)
	else:
		position = endPos 
		rotation = endRot
		scale = endScale
		finished =true
		return finished
func _physics_process(delta):
	match state:
		InHand:
			pass
		Inplay:
			if movingToPlay:
				if MoveCard(delta,Inplay,MouseTime,endPos,endScale,endRot):
					movingToPlay= false
		InMouse:
			MoveCard(delta,InMouse,MouseTime,get_global_mouse_position() -$'../../../'.CardSize/2,origScale,0)
			#check focus in hand and reorganiseHand function they  seem to be moving and shrinking to nothing
		FocusInHand:
			if Zooming_In:
				if MoveCard(delta,FocusInHand,ZOOMINTIME,endPos,endScale,endRot):
					Zooming_In = false
		MoveDrawnCardToHand:
			if MoveCard(delta,MoveDrawnCardToHand,DRAWTIME,endPos,origScale,endRot):
				state = InHand
		ReOrganisHand:
			if MoveCard(delta,ReOrganisHand,ORGANISETIME,endPos,endScale,endRot):
				if CardinPlay:
					state =Inplay
				else:
					state = InHand
		MovingtoDiscard:
			if cardToBeDiscarded:
				if MoveCard(delta,MovingtoDiscard,DRAWTIME,endPos,origScale,0):
					cardToBeDiscarded =false
# Check the indexing on  card base to get the necessary values
func move_next_card(Cardnumb, left , spreadfactor ):
	next_card = $'../../'.get_child(Cardnumb).get_node('CardBase')
	if left:
		next_card.endPos = next_card.CardPos - spreadfactor*Vector2($'../../../'.CardSize.x/2,0)
	else:
		next_card.endPos = next_card.CardPos + spreadfactor*Vector2($'../../../'.CardSize.x/2,0)
	next_card.setup = true
	next_card.state = ReOrganisHand
	next_card.endScale = origScale
	next_card.next_card_moved_check = true

func reset_card(Cardnumb):
	if next_card.next_card_moved_check:
		next_card.next_card_moved_check = false
	if next_card.next_card_moved_check == false:
		next_card = $'../../'.get_child(Cardnumb).get_node('CardBase')
		if next_card.state != FocusInHand:
			next_card.state = ReOrganisHand
			next_card.endScale = origScale
			next_card.endPos = next_card.CardPos
			next_card.setup = true

func Setup():
	startPos = position
	startRot = rotation
	startScale = scale
	t=0 
	setup = false

func _on_focus_mouse_entered():
	match state:
		InHand, ReOrganisHand, Inplay:
			if CardinPlay == true:
				oldstate = Inplay
				oldpos = endPos
				oldscale = endScale 
				endPos = CardPos+ gameSlotSize*0.5*(ZoomInSizeInPlay -1)#$'../../'.CardSize.x/2
				setup = true
				#endPos.y =get_viewport().size.y - $'../../'.CardSize.y*ZoomInSize
				Zooming_In = true
				state = FocusInHand
				endScale = ZoomInSizeInPlay *Vector2(gameSlotSize.y,gameSlotSize.x)/size
			else:
				oldstate = state
				setup = true
				endPos.x = CardPos.x -$'../../../'.CardSize.x/2
				endPos.y =get_viewport().size.y - $'../../../'.CardSize.y*ZoomInSize
				Zooming_In=true
				state = FocusInHand
				endRot= 0
				endScale = origScale*ZoomInSize

func _on_focus_mouse_exited():
	match state:
		FocusInHand:
			setup = true
			state = ReOrganisHand
			if CardinPlay:
				endPos = oldpos
				endScale = oldscale
			else:
				endPos = CardPos
				endScale = origScale
