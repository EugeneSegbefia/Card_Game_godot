extends Node2D

const CardSize = Vector2(125,175)*0.6
const CardBase = preload("res://Assets/Cards/card_base.tscn")
const Data = preload("res://Assets/Cards/Database.gd")
const CardSlot = preload("res://Assets/Cards/card_slot.tscn")
@onready var Deck = Data.new() 
var CardSelected = []
var deckSize = 35 
@onready var player1Hand = 5
var numOfSuits = 3
@onready var ViewportSize = Vector2(get_viewport().size)
@onready var CentreCardOval = ViewportSize*Vector2(0.5, 1.32)
@onready var Hor_rad = get_viewport().size.x*0.45
@onready var Ver_rad = get_viewport().size.y*0.3
@onready var deck_position =$Deck/DeckDraw.position
@onready var discard_position = $Discard/DiscardPile.position
@onready var new_slot = CardSlot.instantiate()
var angle = deg_to_rad(90) - 0.5
var OvalAngleVector = Vector2()
var CardSpread= 0.0023*CardSize.x
var numOfCardsInhand=-1
var Card_Numb= 0
var slotEmpty =[]
enum{InHand,Inplay,InMouse,FocusInHand,MoveDrawnCardToHand,ReOrganisHand,MovingtoDiscard}
# Called when the node enters the scene tree for the first time.
func _ready():
	#var new_slot = CardSlot.instantiate()
	new_slot.size = CardSize
	new_slot.position = get_viewport().size * 0.4
	new_slot.scale *= CardSize/new_slot.size
	$GameSlots.add_child(new_slot)
	slotEmpty.append(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func drawcard():
	angle = PI/2 + CardSpread*(float(numOfCardsInhand)/2 - numOfCardsInhand)
	var new_Card = CardBase.instantiate()
	var  Temp = new_Card.get_node("CardBase")
	Temp.cardDatabase = Deck
	var suit = Temp.cardDatabase.suits[randi_range(0,numOfSuits)]
	print(suit)
	Temp.cardSuit = suit
	Temp.cardInfo = Temp.cardDatabase.DATA[Temp.cardDatabase.get(Temp.cardSuit)]
	print(Temp.cardInfo)
	Temp.suitSize = len(Temp.cardInfo)
	if Temp.suitSize <= 0 :
		Deck.DATA.erase(Temp.cardSuit)
		numOfSuits-=1
		suit = Temp.cardDatabase.suits[randi_range(0,numOfSuits)]
	Temp.cardSuit = suit
	Temp.suitSize = len(Temp.cardInfo)
	print(Temp.suitSize)
	var randNum = randi_range(0,Temp.suitSize)
	var randname = Temp.cardInfo[randi_range(0,Temp.suitSize-1)]
	#print(randname)
	Temp.cardName = randname
	Temp.position = deck_position 
	Temp.DiscardPile = discard_position 
	Temp.scale *= CardSize/Temp.size
	Temp.state = MoveDrawnCardToHand
	Card_Numb =0
	$Cards.add_child(new_Card) 
	deckSize -= (5-player1Hand)
	#Deck.DATA[Deck.get(Temp.cardSuit)].erase(Temp.cardName)
	angle+= 0.25
	player1Hand-=1
	numOfCardsInhand+=1
	OrganiseHand()
	return player1Hand
	#return deckSize

func OrganiseHand():
	for Card in $Cards.get_children():
		angle = PI/2 + CardSpread*(float(numOfCardsInhand)/2 - Card_Numb)
		OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad * sin(angle))
		var TEMP = Card.get_node('CardBase')
		TEMP.endPos = CentreCardOval + OvalAngleVector - Vector2(0,CardSize.y)
		TEMP.CardPos = TEMP.endPos
		TEMP.startRot =TEMP.rotation
		TEMP.endRot = (PI/2 - angle)/4
		TEMP.Card_Numb = Card_Numb
		Card_Numb +=1
		if TEMP.state== InHand:
			TEMP.setup = true
			TEMP.endScale = TEMP.origScale
			TEMP.state= ReOrganisHand
			TEMP.startPos =TEMP.position
		elif TEMP.state == MoveDrawnCardToHand:
			TEMP.t-= 0.1
			TEMP.startPos =  TEMP.endPos -((TEMP.endPos - TEMP.position)/(1-TEMP.t))
		print(" Cards In player Hand :",$Cards.get_child_count())

func ReparentCard(CardNo):
	numOfCardsInhand -= 1
	Card_Numb =0
	var Card = $Cards.get_child(CardNo)
	$Cards.remove_child(Card)
	$CardsInPlay.add_child(Card)
	print( "Cards in play : " ,$CardsInPlay.get_child_count())
	OrganiseHand()






