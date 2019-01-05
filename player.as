

	class player {
	
		
	
		static function createPlayer(
			playerIndex:Number, // is player index in gameEngine.as machine
			playerName:String,
			playerCards:Array	// array of cards
		):Object 	// return the player
		{
			var newPlayer = new Object();
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
			
			// also parameters
			newPlayer.canCastSpellFilters = new Array(); // where from you can cast spells?  by default
			newPlayer.canCastSpellFilters.push(			// cast ANY (-1) SPELL //  from HAND
				function (spell:Object, playerO:Object):Boolean { 
					if (spell.isin != places.hand){
						consts.LOG("..Rule0 : can't be casted from somewhere else than 'hand'");
						return false;	// spell can be casted from hand only
					}
					if (abilities.has(spell, abilities.flash)){
						consts.LOG("..Rule0 : can be casted at any time and any turn, cause has 'flash' ability");
						return true; 
					}					// can be cast at any point of game
					var isMyTurn = (gameengine.game.currentTurnPlayerIndex == playerO.PID); 
					
					var phase = gameengine.game.phase;
					// can be only casted in main n second main during your turn
					var res = (isMyTurn && (phase == gameengine.main || phase == gameengine.secondMain));
					if (!res) consts.LOG("..Rule0 : can be casted only during your main phases");
					return res;
				}
			);
			// if at least one rule resolve, than you can cast it
			newPlayer.canCast = function (cardObj:Object):Boolean { 
				for (var i = 0; i < this.canCastSpellFilters.length; ++i)
					if (this.canCastSpellFilters[i](cardObj, this) == true){
						consts.LOG("...." + cardObj._name  + " casting is accepted by Rule" + (i));
						return true;
					}
				return false; // no way to cast!
			}
			
			return newPlayer;
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
				var cardsFromDeckIndexes = new Array();
				var cardsFromDeck = new Array();
				for (var i = 0; i < playerObject.cards.length; ++i)
					if (playerObject.cards[i].isin == places.deck){
						cardsFromDeck.push(playerObject.cards[i]);
						cardsFromDeckIndexes.push(i);
						playerObject.cards[i].isVisibleTo = new Array(); // make a acrd invincible
					}
				var needLength = cardsFromDeck.length;
				var cardsShuffled = new Array();
				while(cardsShuffled.length < needLength)
				{
				   var rnd = Math.floor( Math.random() * cardsFromDeck.length );
				   cardsShuffled.push( cardsFromDeck[rnd] );
				   cardsFromDeck.splice( rnd, 1 ); // remove the random result
				}		
				for (var i = 0; i < cardsFromDeckIndexes.length; ++i)
					playerObject.cards[cardsFromDeckIndexes[i]] = cardsShuffled[i];
					
				consts.LOG(playerObject._name + " shuffled their deck");
				//traceAllPlayerCardsFrom(playerObject, places.deck);
			}
		
			static function playerDrawsCards(playerObject:Object, cardCount:Number):Void{
				var deckEmpty = playerMoveCards(playerObject, cardCount, places.deck, places.hand);
				if (!deckEmpty);
					// LOST THE GAME!
			}
			static function playerPutTopCardsToGraveyard(playerObject:Object, cardCount:Number):Void{
				playerMoveCards(playerObject, cardCount, places.deck, places.graveyard);
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
						moveCardTo(curCard, to);
						
						--cardCount;
						if (cardCount <= 0)
							return true;
					}
				}
				if (from == 0 && to == 1)
					consts.LOG(playerObject._name + " need to draw (" + cardCount + ") more card(s), but hs deck is empty!" );
				return false;
			}
			
			// move a card of player from somewhere to somewhere
			static function moveCardTo(curCard:Object, to:Number):Void{
				var wasIn = curCard.isin;
				curCard.isin = to;
				if (to == places.hand) curCard.isVisibleTo.push(curCard.host.PID);
				if (to >= 2) curCard.isVisibleTo = gameengine.game.allPlayersIDS;
				curCard.update();
				consts.LOG(curCard.host._name + " move " + card.cardNamePIDVisible(curCard) + "  " + places.placeToString(wasIn) +" -> "+ places.placeToString(to));
			}
			
			static function playerMoveExactCards(playerObject:Object, cards:Array, to:Number):Void{
				for (var i = 0; i < cards.length; ++i)
					moveCardTo(cards[i], to);
			}
			
			static function playerTapsPermanent(playerObject:Object, permanent:Object):Boolean{
				if (permanent.isin != places.battlefield || permanent.tapped == true)
					return false; // cannot tap an permanent
				permanent.tapped = true;
				return true;
			}
			
			static function playerCastASpell(playerObject:Object, cardObj:Object):Boolean{
				consts.LOG(playerObject._name + " select " + cardObj._name + " to cast");
				var canBeCasted = playerObject.canCast(cardObj);
				if (!canBeCasted) return false;
				consts.LOG(cardObj._name + " can be casted. ");
				// lands has no cost, can not be countered, they do not went to stack
				var isLandDrop = (card.isType(cardObj, typ.Land));
				if (!isLandDrop){
					consts.LOG("You cannot play nonlands, because fuck you, tahts why.");
					return false;
				}
				// landdrop case
				moveCardTo(cardObj, places.battlefield);
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