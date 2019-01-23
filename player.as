

	class player {
	
		
		// create an instance of player in game via name, cards, ID
		static function createPlayer(
			gameInstance:Object, // connection to a game, player is playing
			playerIndex:Number, // is player index in gameEngine.as machine
			playerName:String,
			playerCards:Array	// array of cards
		):Object 	// return the player
		{
			var newPlayer = new Object();
			newPlayer.game = gameInstance;
			newPlayer.PID = playerIndex;						// special personal idnex for rules
			newPlayer.health = consts.playerStartingLifeTotal;	
			newPlayer._name = playerName;
			newPlayer.personalTimeOut = 0;
			newPlayer.actionQueue = new Array();
			//transform from ' playerCards = new Array(14, "Island", 10, "Varmountain"); ' to real card examples
			newPlayer.cards = new Array();
			newPlayer.timer = 0;
			// pushing a card one by one to deck, to avaoid a memory linkage
			for (var i = 0; i < playerCards.length; i += 2){
				var cardCount = playerCards[i];
				var cardName = playerCards[i + 1];
				consts.LOG(playerName + "'s deck contains " + cardCount + " card(s), named " + cardName);
				while (cardCount --)
					newPlayer.cards.push(card.createCardByName(cardName, newPlayer));
			}
			newPlayer.cardPlayingRules = rule.defaultPlayerPlayCardRules(newPlayer);
			rule.addCanPlayResolveFunction (newPlayer);
			return newPlayer;
		}
		
		
		// NORMAL FUNCTIONS 
			// for each card in players hand/graveyard/deck, do sometihng(card)
			static function forEachCardIn(playerObject:Object, place:Number, action):Void{
			
				for (var i = 0; i < playerObject.cards.length; ++i)
					if (playerObject.cards[i].isin == place)
						action(playerObject.cards[i]);
						
			}
			// count of cards in player's somewhere
			static function cardCountIn(playerObject:Object, place:Number):Number{
				var res = 0;
				for (var i = 0; i < playerObject.cards.length; ++i)
					res += 1 * (playerObject.cards[i].isin == place);
				return res;
			}
			// default filters for function eachCardInFilter
			static function defaultFilter (ccard:Object):Boolean { return true; }
			static function filterPermanent (ccard:Object):Boolean { for (var i = 0; i < typ.permantntTypes.length; ++i) if (card.isType(ccard, typ.permantntTypes[i])) return true; return false;}
			static function filterCreatures (ccard:Object):Boolean { return card.isType(ccard, typ.Creature); }
			static function filterLand (ccard:Object):Boolean { return card.isType(ccard, typ.Land);}
			static function filterNon(filter){ return function (ccard:Object):Boolean{ return !filter(ccard); } }
			// return array of cards of a player in hand/graveyard/deck/etc, that allowed by specified filter
			static function eachCardInFilter(playerObject:Object, place:Number, filter):Array{
				//trace('Find all in '+place);
				var res = new Array();
				if (filter == undefined)
					filter = defaultFilter; 
					
				for (var i = 0; i < playerObject.cards.length; ++i)
					if (playerObject.cards[i].isin == place && filter(playerObject.cards[i]) == true)
							res.push(playerObject.cards[i]);
				return res;
			}
			// filter given array to new array with only filter accepted cards
			static function filterCards(cards:Array, filter):Array{
				var res = new Array();
				if (filter == undefined)
					filter = defaultFilter; 
				for (var i = 0; i < cards.length; ++i)
					if (filter(cards[i]) == true)
							res.push(cards[i]);
				return res;
			}
			// return count of cards of a player in hand/graveyard/deck/etc, that allowed by specified filter
			static function cardCountInFilter(playerObject:Object, place:Number, filter):Number{
				var res = 0;
				if (filter == undefined)
					filter = defaultFilter; 
				for (var i = 0; i < playerObject.cards.length; ++i)
					res += 1 * (playerObject.cards[i].isin == place && filter(playerObject.cards[i]) == true);
				return res;
			}
			
			
			
			// force a player to do something with his cards in hand/graveyard/deck/etc and do something with their order
			// like shuffle or sort
			static function playerDoWithCads (playerObject:Object, where:Number, action):Void{
				var cardsFromDeckIndexes = new Array();
				var cardsFromDeck = new Array();
				for (var i = 0; i < playerObject.cards.length; ++i)
					if (playerObject.cards[i].isin == where){
						cardsFromDeck.push(playerObject.cards[i]);
						cardsFromDeckIndexes.push(i);
						playerObject.cards[i].isVisibleTo = new Array(); 
						}
						
				var cardsShuffled = action(cardsFromDeck); 
				
				for (var i = 0; i < cardsFromDeckIndexes.length; ++i)
					playerObject.cards[cardsFromDeckIndexes[i]] = cardsShuffled[i];
					
				consts.LOG(playerObject._name + " shuffled their " + places.placeToString(where));
				drawing.updateCardsOfPlayer(playerObject, where);
			}
			// sort action for playerDoWithCads
			static function randomlyShuffleArray(cardsFromDeck:Array):Array{
				var needLength = cardsFromDeck.length;
				var cardsShuffled = new Array();
				while(cardsShuffled.length < needLength)
				{
				    var rnd = Math.floor( Math.random() * cardsFromDeck.length );
				    var pickedCard = cardsFromDeck[rnd];
				    if (pickedCard.isin == places.deck)
						pickedCard.makeUnseen();
				    cardsShuffled.push(pickedCard);
				    cardsFromDeck.splice( rnd, 1 ); // remove the random result
				}	
				return cardsShuffled;
			}
			// sort action for playerDoWithCads
			static function sortByCardProperty(func){
				return function (cardsFromDeck:Array):Array{
					var cardsSorted = new Array();
					var cardTypes = new Array();
					for (var i = 0; i < cardsFromDeck.length; ++i)
						cardTypes.push(func(cardsFromDeck[i]));
					var inds = cardTypes.sort(Array.RETURNINDEXEDARRAY);
					for (var i = 0; i < inds.length; ++i)
						cardsSorted.push(cardsFromDeck[inds[i]]);
					return cardsSorted;
				}
			}
			
			// force a target player to shuffle his deck
			static function playerShuflesDeck (playerObject:Object):Void{
				if (playerObject.isCase != true)
					playerDoWithCads(playerObject, places.deck, randomlyShuffleArray);
				else
					playerDoWithCads(playerObject.player, places.deck, randomlyShuffleArray);
			}
			// force a player to draw 'cardCount' cards
			static function playerDrawsCards(playerObject:Object, cardCount:Number):Void{
				var deckEmpty = false;
				if (playerObject.isCase != true)
					playerMoveCards(playerObject, cardCount, places.deck, places.hand);
				else
					playerMoveCards(playerObject.player, playerObject.parameters, places.deck, places.hand);
				if (!deckEmpty);
			}
			// put 'cardCount' from the top of players deck into thrie graveyard
			static function playerPutTopCardsToGraveyard(playerObject:Object, cardCount:Number):Void{
				playerMoveCards(playerObject, cardCount, places.deck, places.graveyard);
			}
			// force a player to discard his hand
			static function playerDiscardHand(playerObject:Object):Void{
				if (playerObject.isCase != true)
					playerMoveCards(playerObject, player.cardCountIn(playerObject, places.hand), places.hand, places.graveyard);
				else
					playerMoveCards(playerObject.player, player.cardCountIn(playerObject.player, places.hand), places.hand, places.graveyard);
			}
			// force a player to discard his hand
			static function playerPutHandToDeck(playerObject:Object):Void{
				if (playerObject.isCase != true)
					playerMoveCards(playerObject, player.cardCountIn(playerObject, places.hand), places.hand, places.deck);
				else
					playerMoveCards(playerObject.player, player.cardCountIn(playerObject.player, places.hand), places.hand, places.deck);
			}
			// elemental operation of moving card without any view updates
			static function moveCardTo(playerOb:Object, curCard:Object, to:Number):Void{
				var wasIn = curCard.isin;
				curCard.isin = to;
				if (to == places.hand) curCard.isVisibleTo.push(curCard.host.PID);
				if (to >= 2) curCard.isVisibleTo = playerOb.game.allPlayersIDS;
				curCard.update();
				consts.LOG(curCard.host._name + " move " + card.cardNamePIDVisible(curCard) + "  " + places.placeToString(wasIn) +" -> "+ places.placeToString(to));
			}
			// move EXACT cards from 'from' to 'to'. then, 'updateViewAfterCardMove'
			static function playerMoveExactCards(playerObject:Object, cards:Array, to:Number):Void{
				var cardsWereIn = new Array();
				for (var i = 0; i < cards.length; ++i){
					var addPlace = cards[i].isin; var needAdd = true;	// check all places where from was cards moved to update them later
					for (var j = 0; j < cardsWereIn.length; ++j)
						if (cardsWereIn[j] == addPlace)
							needAdd = false;
					if (needAdd) cardsWereIn.push(addPlace);
					
					moveCardTo(playerObject, cards[i], to);
				}
				for (var i = 0; i < cardsWereIn.length; ++i)
					updateViewAfterCardMove(playerObject, cardsWereIn[i], to);
			}
			// move FIRST 'cardCount' cards from 'from' to 'to'. then, 'updateViewAfterCardMove'
			static function playerMoveCards(playerObject:Object, cardCount:Number, from:Number, to:Number):Boolean{
				if (cardCount == undefined) cardCount = 1;
				var nowCardInd = -1;
				var curCard = null;
				//var moveString = "  " + places.placeToString(from) +" -> "+ places.placeToString(to);
				while (cardCount && nowCardInd < playerObject.cards.length){
					++nowCardInd;
					curCard = playerObject.cards[nowCardInd];
					if (curCard.isin == from){
						moveCardTo(playerObject, curCard, to);
						
						--cardCount;
						if (cardCount <= 0){
							updateViewAfterCardMove(playerObject, from, to);
							return true;
						}
					}
				}
				if (from == 0 && to == 1)
					consts.LOG(playerObject._name + " need to draw (" + cardCount + ") more card(s), but hs deck is empty!" );
				updateViewAfterCardMove(playerObject, from, to);
				return false;
			}
			// update view of places between which card was moved. 
			static function updateViewAfterCardMove(playerObject:Object, from:Number, to:Number):Void{
				trace("Required update for " + places.placeToString(from) + " & " + places.placeToString(to));
				drawing.updateCardsOfPlayer(playerObject, to);
				if (from != places.deck) drawing.updateCardsOfPlayer(playerObject, from);
				drawing.updateCoutners(playerObject);
			}
			
			
			// force choosen player to tap his permanent. using for tapping? 
			// well, not using now
			static function playerTapsPermanent(playerObject:Object, permanent:Object):Boolean{
				if (permanent.isin != places.battlefield || permanent.tapped == true)
					return false; // cannot tap an permanent
				permanent.tapped = true;
				return true;
			}
			// function to hold a player play card process
			static function playerPlayACard(playerObject:Object, cardObj:Object):Boolean{
				var cardwasin = cardObj.isin;
				consts.LOG(playerObject._name + " select " + cardObj._name + " to cast");
				
				var canBeCasted = playerObject.canCast(cardObj);
				if (!canBeCasted) return false;
	
				// do not place into stack, so just put a land to the battlefield
				var isLandDrop = (card.isType(cardObj, typ.Land));
				var succ = true;
				if (isLandDrop){
					moveCardTo(playerObject, cardObj, places.battlefield);
				}else{
					succ = playerWantCastASpell(playerObject, cardObj);
				}
					
				//playerDoWithCads(playerObject, places.battlefield, sortByCardProperty(card.cardColorFormat));
				updateViewAfterCardMove(playerObject, cardwasin, cardObj.isin);
				return succ;
				
			}
			// spell casting
			static function playerWantCastASpell(playerObject:Object, cardObj:Object):Boolean{
				var cardwasin = cardObj.isin;
				// pay the cost
				
				// if cant return false
				
				// move to stack
				
				// if all approves
				moveCardTo(playerObject, cardObj, places.battlefield);
				return true;
			}
		// TRACE FUNCTIONS
			
			// type to console all players cards, separated by their position in game
			// in hand, in deck, e.t.c.
			static function traceAllPlyaerCards(playerObject:Object):Void{
				for (var i = 0; i <= 5; ++i)
					traceAllPlayerCardsFrom(playerObject, i);
				
			}
			
			static function traceAllPlayerCardsFrom(playerObject:Object, place:Number, showFirstLast:Boolean):Void{
				trace(playerObject._name + "'s " + places.placeToString(place) + ":");
				if (showFirstLast == undefined)
					showFirstLast = (place == places.deck);
				if (showFirstLast) trace("  ^  TOP");
				var tab = (showFirstLast)? "  ^ " : "    ";
				for (var j = 0; j <= playerObject.cards.length; ++j)
						if (playerObject.cards[j].isin == place)
							trace(tab + card.cardNamePIDVisible(playerObject.cards[j]));
				if (showFirstLast) trace("  BOTTOM");
			}
	}