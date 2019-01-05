

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
			//trace(newPlayer._name+":"+newPlayer.cards+":"+newPlayer.health)
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
				var moveString = "  " + places.placeToString(from) +" -> "+ places.placeToString(to);
				while (cardCount && nowCardInd < playerObject.cards.length){
					++nowCardInd;
					curCard = playerObject.cards[nowCardInd];
					if (curCard.isin == from){
						curCard.isin = to;
						if (to == places.hand) curCard.isVisibleTo.push(playerObject.PID);
						if (to >= 2) curCard.isVisibleTo = gameengine.game.allPlayersIDS;
						curCard.update();
						
						--cardCount;
						consts.LOG(playerObject._name + " move " + card.cardNamePIDVisible(curCard) + moveString);
						if (cardCount <= 0)
							return true;
					}
				}
				// 
				if (from == 0 && to == 1)
					consts.LOG(playerObject._name + " need to draw (" + cardCount + ") more card(s), but hs deck is empty!" );
				return false;
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