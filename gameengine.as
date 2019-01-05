

	class gameengine {
	
		static function test(){
			var g = initialiseGame(
				new Array(
					"Ivan", 
					"Bobby"
				), 
				new Array(
					new Array(14, "Basic Island", 6, "Basic Plane"), 
					new Array(20, "Basic Forest")
				));
			
			var ivan = g.getPlayer(0);
			player.playerShuflesDeck(ivan);
			player.playerDrawsCards(ivan, 7);
			
			// emblem! 
			// at the begginig of each unkeep all player untap all shit he has
			// then all the shit abilities works
			// at the end of each unkeep that player draws a card
			
			// player can play only 1 land dureing his turn
		}
	
	
		static var game:Object = null;	// last instantiated game copy
		
		static function initialiseGame(
			players:Array,		// { "player1", "player2 ", ...} 
			playerCards:Array 	// {"array = deck of player1", "arrary = deck of player 2", ...}
		):Object			// return the Game object
		{
			var newGame = new Object();
			newGame.players = new Array(); // player objects array
			for (var i = 0; i < players.length; ++i)
				newGame.players.push(player.createPlayer(i, players[i], playerCards[i]));
			newGame.playerCount = newGame.players.length; 					// number of players
			newGame.currentTurnPlayerIndex = random(newGame.playerCount);	// will start the game
			
			newGame.getPlayer = function (PID:Number):Object{return this.players[PID];}
			newGame.getCurrentPlayer = function ():Object{return this.getPlayer(this.currentTurnPlayerIndex);}
			
			game = newGame;	// assign a last copy
			return game;
		}
	}