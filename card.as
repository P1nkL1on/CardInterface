

	class card {
	
		// a function, that creates a bard, using its unique name. 
		// all special card functions watch below this
		static function createCardByName(cardName:String, cardHost:Object):Object{
			switch(cardName){
				case "Basic Island": return createCard(cardName, colors.blue, new Array(typ.Basic, typ.Land), typ.Island, cardHost);
				case "Basic Forest": return createCard(cardName, colors.green, new Array(typ.Basic, typ.Land), typ.Forest, cardHost);
				case "Basic Plane": return  createCard(cardName, colors.white, new Array(typ.Basic, typ.Land), typ.Plane, cardHost);
				case "Basic Swamp": return  createCard(cardName, colors.black, new Array(typ.Basic, typ.Land), typ.Swamp, cardHost);
				case "Basic Mountain": return  createCard(cardName, colors.red, new Array(typ.Basic, typ.Land), typ.Mountain, cardHost);
				
				case "Test Creature": return createCard(cardName, colors.green, typ.Creature, typ.Beast, cardHost);
				case "Test Wizard": return createCard(cardName, new Array(colors.white, colors.blue), typ.Creature, new Array(typ.Human, typ.Wizard), cardHost);
				case "Test Ogre": return createCard(cardName, colors.red, typ.Creature, typ.Ogr, cardHost);
				case "Test Dogo": return createCard(cardName, colors.black, typ.Creature, typ.Dog, cardHost);
				case "Test Artifact": return createCard(cardName, colors.none, typ.Artifact, new Array(), cardHost);
				case "Test Robot": return createCard(cardName, colors.none, new Array(typ.Artifact, typ.Creature), new Array(), cardHost);
				
				//case "Divination": return createCard(cardName, colors.blue, typ.Sorcery, new Array(), cardHost, new Array(),);
				default: return null;
			}
			return null;
		}
		//case "Test All": return createCard(cardName, new Array(5,3,2,4,1), new Array(201,200,30,31,102,103,105,101,100,51,50), new Array()); 
	
		
		
		static var uniqueCardIndex = -1;
		static function createCard(
			cardName:String,
			cardColor,	// number or array, like  3, or {2,3}
			cardType,	// same number or array	    watch "typ.as", like {20, 101} -- legendary creature
			cardSubType,   // same number or array   watch "typ.as", like {50, 51}, {5102} == Basic Land -- Island
			cardHost:Object,	// instance of PlayerObject. Sets to 'null' if none player given
			cardAbilities,		// array of functions
			cardCastCost:Object	// cost of playing a card. if none given, card will have no cost, like a Land
			
		):Object // return a card object
		{
			var newCard = new Object();
			newCard.PID = ++uniqueCardIndex;
			// NAME HOST
				newCard._name = cardName;
				newCard.host = ((cardHost == undefined)? null : cardHost);	// original card's host
				newCard.currentHost = newCard.host;			// card can be temporary under someone's elses control
				newCard.cCurrentHost = function ():Object {return (this.isin == places.battlefield)? newCard.currentHost : newCard.host;}
			// TYPES SUBTYPES COLORS
				newCard.cardType = consts.makeSortedNumberArray(cardType);			// basic color and types of card
				newCard.cardSubType = consts.makeSortedNumberArray(cardSubType);
				newCard.cardColor = consts.makeSortedNumberArray(cardColor);				
				newCard.added_cardType = new Array();								// added colors and types, for example
				newCard.added_cardSubType = new Array();							// enchanted creature is black zombie to addition!
				newCard.added_cardColor = new Array();								// or become LandCreature!
				
				// currently resulted types, subtypes and colors as Arrays
				newCard.cColors = function():Array{ return consts.uniqArray(this.cardColor, this.added_cardColor);}
				newCard.cTypes = function():Array{ return consts.uniqArray(this.cardType, this.added_cardType);}
				newCard.cSubTypes = function():Array{ return consts.uniqArray(this.cardSubType, this.added_cardSubType);}
			
			// BASICS
				newCard.tapped = false;			 	// is card tapped
				newCard.cannotBeUntappedAtTheTurnStart = 0;		// can be untapped at the turn start
					// if it parameter is 3 - means, for next 3 turns it cannot be untapepd, and removes by 1 each turn start
				newCard.isin = places.deck;			// current place of card
				newCard.isVisibleTo = new Array();	// is visible for players with PIDS, {2,3,4} - visible to third, 4d, 5th players, where 3rd is owner, for example
													// default it is none, cause card is invisible in deck.
				newCard.isVisibleBy = function (whoID:Number):Boolean{ for (var i = 0; i < this.isVisibleTo.length; ++i) if (this.isVisibleTo[i] == whoID) return true; return false; }
			// CARD COST
				newCard.castingCost = new Array();
				newCard.castingCost.push((cardCastCost != undefined)? cardCastCost : cost.noCost());
				newCard.castingFrom = new Array();
				newCard.castingFrom.push (places.hand);
				newCard.makeUnseen = function (){ this.isVisibleTo = new Array(); for (var i = 0; i < this.mcs.length; ++i)this.mcs[i].gotoAndStop('unseen'); }
				// for example:
				// cCost = {5, 6},, cFrom = {hand, graveyard} -- can be cast from hand for 5, from graveyard for 6
			
			// SOME PARAMETERS BASED ON A TYPE
				newCard.abilities = new Array(); // zero array or card abilities
				if (cardAbilities != undefined) for (var i = 0; i < cardAbilities.length; ++i) newCard.abilities.push(cardAbilities[i]); // add all abilities
				newCard.asCreature = null;
				if (card.isType(newCard, typ.Creature)){
					newCard.everWasCreature = true; // to check a transofmation from land to creature and back
					newCard.asCreature = defaultStats.createAsCreatureObject(cardName);
				}
			
			// CARD VISIBLE
				newCard.update = function (){if (this.mcs != undefined) for (var i = 0; i < this.mcs.length; ++i)drawing.traceToMovieClip(this, this.mcs[i]);}
			consts.LOG("Card added to game: " + cardNameTypeColorCostOwnerToString(newCard));
			return newCard;
		}
		
		// FIND FUNCTIONS
		static function isType(co:Object, typeFinding:Number, onlyDefault:Boolean):Boolean{
			var types = (onlyDefault == true)? co.cardSubType : co.cTypes();
			for (var i = 0; i < types.length; ++i)
				if (types[i] == typeFinding)
					return true;
			return false;
		}
		static function isSubType(co:Object, subtypeFinding:Number, onlyDefault:Boolean):Boolean{
			var types = (onlyDefault == true)? co.cardSubType : co.cSubTypes();
			for (var i = 0; i < types.length; ++i)
				if (types[i] == subtypeFinding)
					return true;
			return false;
		}
		
		// TRACE FUNCTIONS
		static function cardNamePIDVisible(newCard:Object):String{
			var vis = cardVisibleTo(newCard);
			return ((vis == unseen)? "" : newCard._name) + " " + cardPID(newCard) + " " + vis;
		}
		static function cardNameTypeColorCostOwnerToString(newCard:Object):String{
			return ("'"+newCard._name+"' is  " + cardColorFormat(newCard) + " "+cardTypeFormat(newCard)+", owned by " + newCard.host._name+", " 
					+  cost.costToString(newCard.castingCost, newCard.castingFrom));
		}
		static function traceCardInfoToText(newCard, to):Void{
			//var to = newCard.onField().infoTextBox;
			to.text = "";
			to.text += "'" + newCard._name +"'  " + cardPID(newCard) + "\n";
			to.text += "is a " + cardColorFormat(newCard) + " "+cardTypeFormat(newCard) + "\n";
			if (newCard.asCreature != null)
				to.text += "has " + newCard.asCreature.baseStats() + " (power/toughness)\n";
			to.text += "owned by " + newCard.host._name + "\n";
			var costs = cost.costToStringArray(newCard.castingCost, newCard.castingFrom);
			for (var i = 0; i < costs.length; ++i)
				to.text += costs[i] + "\n";
		}
		static function traceCardNoInfoToText(newCard, to):Void{
			to.text = "Unknown card in " + places.placeToString(newCard.isin);
		}
		
		
		// TRACE FUNCTIONS
		static function cardPID(newCard:Object):String{
			return "(" + newCard.PID + ")";
		}
		static var unseen = "unseen card";
		static function cardVisibleTo(newCard:Object):String{
			return (newCard.isVisibleTo.length > 0)? (" visible to " + newCard.isVisibleTo) : (unseen);
		}
		// is current == is it black zombie also, or not
		static function cardTypeFormat(cardObject:Object):String{
			var res = "";
			var l = cardObject.cardType.length;
			var l1 = cardObject.cardSubType.length;
			var tps = cardObject.cTypes();
			var stps = cardObject.cSubTypes();
			for (var i = 0; i < tps.length; ++i)
				res += formatA2(i, l, tps.length - 1, typ.typToString(tps[i]));
			if (l1 == 0)
				return res;
			res += " - ";
			for (var i = 0; i < stps.length; ++i)
				res += formatA2(i, l1, stps.length - 1, typ.subTypToString(stps[i]));
			return res;
		}
		static function cardSubTypeFormat(cardObject:Object):String{
			var res = "";
			var l1 = cardObject.cardSubType.length;
			var stps = cardObject.cSubTypes();
			for (var i = 0; i < stps.length; ++i)
				res += formatA2(i, l1, stps.length - 1, typ.subTypToString(stps[i]));
			return res;
		}
		static function cardColorFormat(cardObject:Object):String{
			var res = "";
			var l1 = cardObject.cardColor.length;
			var scls = cardObject.cColors();
			for (var i = 0; i < scls.length; ++i)
				res += formatA2(i, l1, scls.length - 1, colors.colorToString(scls[i]));
			return res;
		}
		static function formatA(i:Number, mx:Number, var1:String, var2:String):String {return ((i < mx)? var1 : var2);}
		static function formatA2(i, mx1, mx2, S):String {return ( formatA(i, mx1, "", "*") + S  + formatA(i, mx1, "", "*") + formatA(i, mx2, " ", ""));}
	}