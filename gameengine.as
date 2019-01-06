

	class gameengine {
	
		static function test(){
			var map = back.create_obj(back.base_layer(), "map" );
			var g = initialiseGame(
				new Array(
					"Ivan", 
					"Bobby"
				), 
				new Array(
					new Array(
					7 + random(1)+10, "Basic Island",
					7 + random(10), "Basic Plane", 
					7 + random(10), "Basic Forest", 
					7 + random(10), "Basic Mountain",
					7 + random(10), "Basic Swamp",
					4, "Test Creature",
					4, "Test Wizard",
					4, "Test Dogo",
					4, "Test Ogre",
					4, "Test Artifact",
					4, "Test Robot"), 
					new Array(20, "Basic Forest")
				));
			
			var ivan = g.getPlayer(0);
			player.playerShuflesDeck(ivan);
			drawing.createMcForEveryPlayerCard(ivan);
			drawing.placeDecksForPlayer(ivan);
			//player.playerDrawsCards(ivan, 7);
			
			// emblem! 
			// at the begginig of each unkeep all player untap all shit he has
			// then all the shit abilities works
			// at the end of each unkeep that player draws a card
			
			// player can play only 1 land dureing his turn
			
			game = g;
		}
	
	
		static var game:Object = null;	// last instantiated game copy
		
		static function initialiseGame(
			players:Array,		// { "player1", "player2 ", ...} 
			playerCards:Array 	// {"array = deck of player1", "arrary = deck of player 2", ...}
		):Object			// return the Game object
		{
			var newGame = new Object();
			newGame.allPlayersIDS = new Array();
			newGame.players = new Array(); // player objects array
			for (var i = 0; i < players.length; ++i){
				newGame.players.push(player.createPlayer(newGame, i, players[i], playerCards[i]));
				newGame.allPlayersIDS.push(i);
			}
			newGame.playerCount = newGame.players.length; 					// number of players
			newGame.currentTurnPlayerIndex = 0;//random(newGame.playerCount);	// will start the game
			
			newGame.getPlayer = function (PID:Number):Object{return this.players[PID];}
			newGame.getCurrentPlayer = function ():Object{return this.getPlayer(this.currentTurnPlayerIndex);}
			newGame.phase = main;
			
			game = newGame;	// assign a last copy
			return game;
		}
		
		static var main = 20;
		static var secondMain = 30;
	}