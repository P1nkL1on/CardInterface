

	class player {
	
		
	
		static function createPlayer(
			gameInstance:Object, // connection to a game, player is playing
			playerIndex:Number, // is player index in gameEngine.as machine
			playerName:String,
			playerCards:Array	// array of cards
		):Object 	// return the player
		{
			var newPlayer = new Object();
			newPlayer.game = gameInstance;
			newPlayer.PID = playerIndex;						// special idnex
			newPlayer.health = consts.playerStartingLifeTotal;	
			newPlayer._name = playerName;
			//transform from ' playerCards = new Array(14, "Island", 10, "Varmountain"); ' to real card examples
			newPlayer.cards = new Array();
			newPlayer.timer = 0;
			for (var i = 0; i < playerCards.length; i += 2){
				var cardCount = playerCards[i];
				var cardName = playerCards[i + 1];
				consts.LOG(playerName + "'s deck contains " + cardCount + " card(s), named " + cardName);
				while (cardCount --)
					newPlayer.cards.push(card.createCardByName(cardName, newPlayer));
			}
			
			// default filters, which allow to play a card from where and when
			newPlayer.canCastSpellFilters = defaultcanCastFilter();
			// if at least one rule resolve, than you can cast it
			newPlayer.canCast = function (cardObj:Object):Boolean { 
				for (var i = 0; i < this.canCastSpellFilters.length; ++i)
					if (this.canCastSpellFilters[i](cardObj, this) == false){
						consts.LOG(cardObj._name  + " casting is rejected");
						return false;
					}
				consts.LOG(cardObj._name  + " casting is available");
				return true; // no way to cast!
			}
			
			return newPlayer;
		}
		
		static function defaultcanCastFilter():Array{
			var res = new Array(); // where from you can cast spells?  by default
			res.push(			// cast ANY (-1) SPELL //  from HAND
				function (spell:Object, playerO:Object):Boolean { 
					var isMyTurn = (gameengine.game.currentTurnPlayerIndex == playerO.PID); 
					var phase = gameengine.game.phase;
					var isMainPhase = (phase == gameengine.main || phase == gameengine.secondMain);
					var hasFlash = abilities.has(spell, abilities.flash);
					var isInstant = card.isType(spell, typ.Instant);
					var isInHand = spell.isin == places.hand;
					
					consts.LOG(spell._name  + " is :");
					consts.LOG("  your turn?     " + isMyTurn);
					consts.LOG("  main phase?    " + isMainPhase);
					consts.LOG("  is instant?    " + isInstant);
					consts.LOG("  has flash?     " + hasFlash);
					return (isInstant || hasFlash || (isMyTurn && isMainPhase));
				}
			);
			// now you can not play creatures just because
			res.push(function (spell:Object, playerO:Object):Boolean 
				{ 
					return !(card.isType(spell, typ.Creature)); 
				}
			);
			return res;
		}
		
		// NORMAL FUNCTIONS 
			// for each card in players hand/graveyard/deck, do sometihng(card)
			static function forEachCardIn(playerObject:Object, place:Number, action):Void{
			
				for (var i = 0; i < playerObject.cards.length; ++i)
					if (playerObject.cards[i].isin == place)
						action(playerObject.cards[i]);
						
			}
			// count of cards in player's something
			static function cardCountIn(playerObject:Object, place:Number):Number{
				var res = 0;
				for (var i = 0; i < playerObject.cards.length; ++i)
					res += 1 * (playerObject.cards[i].isin == place);
				return res;
			}
			// count of cards in player's something
			static function defaultFilter (ccard:Object):Boolean { return true; }
			static function filterCreatures (ccard:Object):Boolean { return card.isType(ccard, typ.Creature); }
			static function filterLand (ccard:Object):Boolean { return card.isType(ccard, typ.Land);}
			
			// return array of something with paramaters
			static function eachCardInFilter(playerObject:Object, place:Number, filter):Array{
				//trace('Find all in '+place);
				var res = new Array();
				if (filter == undefined)
					filter = defaultFilter; 
					
				for (var i = 0; i < playerObject.cards.length; ++i)
					if (playerObject.cards[i].isin == place && filter(playerObject.cards[i]) == true)
							res.push(playerObject.cards[i]);
				/* for (var i = 0; i < res.length; ++i)
					trace(res[i]._name + ":" + card.cardPID(res[i])); */
				return res;
			}
			// count of cards in player's something whith parameters
			static function cardCountInFilter(playerObject:Object, place:Number, filter):Number{
				var res = 0;
				if (filter == undefined)
					filter = defaultFilter; 
				for (var i = 0; i < playerObject.cards.length; ++i)
					res += 1 * (playerObject.cards[i].isin == place && filter(playerObject.cards[i]) == true);
				return res;
			}
			
			// force a target player to shuffle his deck
			
			static function playerShuflesDeck (playerObject:Object):Void{
				playerDoWithCads(playerObject, places.deck, randomlyShuffleArray);
			}
			static function playerShuflesHand (playerObject:Object):Void{
				playerDoWithCads(playerObject, places.hand, randomlyShuffleArray);
			}
			
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
				drawing.updatePlayerCardHolders(playerObject, where);
			
			}
			
			static function randomlyShuffleArray(cardsFromDeck:Array):Array{
				var needLength = cardsFromDeck.length;
				var cardsShuffled = new Array();
				while(cardsShuffled.length < needLength)
				{
				   var rnd = Math.floor( Math.random() * cardsFromDeck.length );
				   cardsShuffled.push( cardsFromDeck[rnd] );
				   cardsFromDeck.splice( rnd, 1 ); // remove the random result
				}	
				return cardsShuffled;
			}
		
			static function playerDrawsCards(playerObject:Object, cardCount:Number):Void{
				var deckEmpty = playerMoveCards(playerObject, cardCount, places.deck, places.hand);
				if (!deckEmpty);
					// LOST THE GAME!
			}
			static function playerPutTopCardsToGraveyard(playerObject:Object, cardCount:Number):Void{
				playerMoveCards(playerObject, cardCount, places.deck, places.graveyard);
			}
			
			static function updateViewAfterCardMove(playerObject:Object, from:Number, to:Number):Void{
				trace("Required update for " + places.placeToString(from) + " & " + places.placeToString(to));
				drawing.updatePlayerCardHolders(playerObject, to);
				if (from != places.deck) drawing.updatePlayerCardHolders(playerObject, from);
			}
			
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
			
			// move a card of player from somewhere to somewhere
			static function moveCardTo(playerOb:Object, curCard:Object, to:Number):Void{
				var wasIn = curCard.isin;
				curCard.isin = to;
				if (to == places.hand) curCard.isVisibleTo.push(curCard.host.PID);
				if (to >= 2) curCard.isVisibleTo = playerOb.game.allPlayersIDS;
				curCard.update();
				consts.LOG(curCard.host._name + " move " + card.cardNamePIDVisible(curCard) + "  " + places.placeToString(wasIn) +" -> "+ places.placeToString(to));
			}
			
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
			
			static function playerTapsPermanent(playerObject:Object, permanent:Object):Boolean{
				if (permanent.isin != places.battlefield || permanent.tapped == true)
					return false; // cannot tap an permanent
				permanent.tapped = true;
				return true;
			}
			
			static function playerCastASpell(playerObject:Object, cardObj:Object):Boolean{
				var cardwasin = cardObj.isin;
				consts.LOG(playerObject._name + " select " + cardObj._name + " to cast");
				var canBeCasted = playerObject.canCast(cardObj);
				if (!canBeCasted) return false;
				
				// lands has no cost, can not be countered, they do not went to stack
				
				var isLandDrop = (card.isType(cardObj, typ.Land));
				// do not place into stack, so just put a land to the battlefield
				if (isLandDrop)
					moveCardTo(playerObject, cardObj, places.battlefield);
				else{
				
					moveCardTo(playerObject, cardObj, places.stack);
				}
					
				updateViewAfterCardMove(playerObject, cardwasin, cardObj.isin);
				return true;//?
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