extends Node
#create a refrence number for each card (0-8) using A dictionary.
#enum{Ace,King,Queen,Jack,Ten,Nine,Eight,Seven,Six}
enum{Diamonds, Spades, Clubs, Hearts}

const suits =["Diamonds", "Spades", "Clubs", "Hearts"]
const DATA = {
	Diamonds:
		["Ace","King","Queen","Jack","Ten","Nine","Eight","Seven","Six"],
	Spades:
		["King","Queen","Jack","Ten","Nine","Eight","Seven","Six"],
	Clubs:
		["Ace","King","Queen","Jack","Ten","Nine","Eight","Seven","Six"],
	Hearts:
		["Ace","King","Queen","Jack","Ten","Nine","Eight","Seven","Six"]
}
var cardDictionary = {
	"Ace": 0,
	"King": 1,
	"Queen": 2, 
	"Jack": 3,
	"Ten": 4,
	"Nine":5,
	"Eight":6,
	"Seven":7,
	"Six":8
}
