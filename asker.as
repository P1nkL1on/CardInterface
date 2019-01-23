

	class asker {
		static var GUIlayer = back.create_obj(undefined, "empty", "layer");
		
		static var buttonScale = 65;
		
		static function makeButton (
			where, // place (in asker-holder usually)
			txt, // button text
			rgbArr, // color
			X, Y, // coordinates
			resultIndex
		):MovieClip{
			if (where == undefined) where = GUIlayer;
			if (rgbArr == undefined){
				if (resultIndex == resultAccept)rgbArr = colors.buttonAcceptColor;
				if (resultIndex == resultDecline)rgbArr = colors.buttonDeclineColor;
				if (rgbArr == undefined)rgbArr = colors.buttonDefaultColor;
			}
			if (X == undefined) X = 0;
			if (Y == undefined) Y = 0;
			if (resultIndex == undefined)
				resultIndex = resultUnknown;
			var newButton = back.create_obj(where, "btn");
			newButton._x = X; newButton._y = Y;
			newButton._xscale = newButton._yscale = buttonScale;
			colors.colorToRGBArray(newButton.m, rgbArr);
			colors.colorToRGBArray(newButton.l, rgbArr);
			colors.colorToRGBArray(newButton.r, rgbArr);
			
			newButton.info.text = txt;
			var long = Math.max(40, txt.length * 13 - 60);
			newButton.m._width = long;
			newButton.l._x = -long / 2 + 1;
			newButton.r._x = long / 2 - 1;
			newButton.resultWouldBeGiven = resultIndex;
			newButton.selector._width = long + 38 * 2;
			newButton.onMouseDown = function(){ 
				var isInAkser = this._parent.playerToChoose != undefined;
				if (isInAkser && this._parent._visible == true){
					if (this.selector.hitTest(_root._xmouse, _root._ymouse, true))
						this._parent.result = this.resultWouldBeGiven;
				}
			} 
			return newButton;
		}
		
		static var xOffset = 870;
		static var yOffset = 560;
		
		static var resultNotready = 0;
		static var resultUnknown = -1;
		static var resultAccept = 10;
		static var resultDecline = 11;
		
		static function makeAsker(
			forPlayer:Object, 
			description:String, 
			solvingFunction, // this.solvingFunction(this.result, this.playerToChoose, this.params);
			buttons:Array, 
			where,
			params, // params for solvinf function
			awaitTimer
			):MovieClip{
			if (where == undefined) where = GUIlayer;
			if (description == undefined) description = "...?";
			var newAsker = back.create_obj(where, "empty", "asker");
			newAsker.result = resultNotready;
			newAsker.playerToChoose = forPlayer;
			newAsker.description = description;
			//newAsker.
			if (buttons == undefined)
				buttons = new Array('Accept', resultAccept,
									'Decline', resultDecline);
									
			for (var i = 0; i < buttons.length; i+= 2)
				makeButton(newAsker, buttons[i], undefined, 
				forPlayer.map._x + xOffset * gameengine.gameFieldScale,
				forPlayer.map._y + yOffset * gameengine.gameFieldScale - .2 * buttonScale * i,
				buttons[i + 1]);
			newAsker.solvingFunction = solvingFunction;
			newAsker.params = params;
				
			newAsker.awaitTimer = (awaitTimer == undefined)? 0 : awaitTimer;
			if (awaitTimer != undefined) newAsker._visible = false;
			newAsker.clearAllTexts = function(){
				//for (var i = 0; i < this.playerToChoose.game.playerCount; ++i)
				this.playerToChoose.map.info.text = "";
			}
			newAsker.showAllTexts = function(){
				this.playerToChoose.map.info.text = this.description + "?";
				//for (var i = 0; i < this.playerToChoose.game.playerCount; ++i)
				//	this.playerToChoose.game.gameFields[i].info.text = 
				//		((this.playerToChoose.PID != i)? ("Player " + this.playerToChoose._name + " think of ") : ("")) +  this.description + ((this.playerToChoose.PID != i)? "" : "?");
			}
			newAsker.onEnterFrame = function (){
				if (--this.awaitTimer == -1){ this._visible = true; this.showAllTexts();}
				if (this.result == resultNotready)
					return; // waiting for  a normal answer
				this.solvingFunction(this.result, this.playerToChoose, this.params);
				this.clearAllTexts();
				this.removeMovieClip();
			}
			return newAsker;
		}
		
		static function makePersonalSolutionAwaiter (gameObject:Object, requiredPlayerCount:Number, afterFunction, afterFunctionParams):MovieClip{
			if (gameObject.newWaiter != undefined){
				trace('!!! Critical Error! Last solution awaiter was not deleted!');
				return null;
			}
		
			var newWaiter = back.create_obj(GUIlayer, "empty", "solutionAwaiter");
			newWaiter.requiredPlayerCount = requiredPlayerCount;
			newWaiter.answered = 0;
			newWaiter.game = gameObject;
			newWaiter.afterFunction = afterFunction;
			newWaiter.afterFunctionParams = afterFunctionParams;
			newWaiter.onEnterFrame = function (){
				
				if (this.lastAnswered != this.answered){
					trace('Awaiting for ' + (this.requiredPlayerCount - this.answered)+'/'+this.requiredPlayerCount + " player's solutions");
					this.lastAnswered = this.answered;
				}
				if (this.answered >= this.requiredPlayerCount){
					trace('All players answered for solution! Go further!');
					this.game.currentWaiter = undefined;
					this.afterFunction(this.afterFunctionParams);
					
					this.removeMovieClip();
				}
				// do not let the game timer goes long, because of waiting
				this.game.framesTimeout = Math.max(20, this.game.framesTimeout);
			}
			
			gameObject.currentWaiter = newWaiter;
			return newWaiter;
		}
		
		static function startMulliganAsker(forPlayer:Object, cardCount){
			//player.playerShuflesDeck(forPlayer);
			//player.playerDrawsCards(forPlayer, cardCount);
			
			var parameters = new Array(); 
			parameters.push(8); 
			mulliganAsker(resultDecline, forPlayer, parameters);
		}
		
		static function mulliganAsker(lastResult:Number, playerO:Object, parameters){
			var cardCount = parameters[0];
			
			var gameO = playerO.game;
			if (lastResult == resultAccept){
				trace(playerO._name + ' starts game with ' + cardCount);
				gameO.currentWaiter.answered++;
				return;
			}
			if (lastResult == resultDecline && cardCount == 2){
				trace(playerO._name + ' starts game with ' + 1);
				gameO.thenPersonal(player.playerPutHandToDeck, typ.gameCase(playerO));
				gameO.thenPersonal(player.playerShuflesDeck, typ.gameCase(playerO));
				gameO.thenPersonal(player.playerDrawsCards, typ.gameCase(playerO, 1));
				gameO.currentWaiter.answered++;
				return;
			}
			cardCount--;
			//playerPutHandToDeck
			gameO.thenPersonal(player.playerPutHandToDeck, typ.gameCase(playerO));
			gameO.thenPersonal(player.playerShuflesDeck, typ.gameCase(playerO));
			gameO.thenPersonal(player.playerDrawsCards, typ.gameCase(playerO, cardCount));
			
			trace(playerO._name + ' mulligans to ' + cardCount);
			var newParams = new Array();
			newParams.push(cardCount);
			var str = "Keep theese " + cardCount + " cards or mulligan it to " + (cardCount -1) + " cards";
			makeAsker(playerO, str, mulliganAsker, new Array('Keep', resultAccept, 'Mulligan', resultDecline), undefined, newParams, 250);
		}
		
		static function addTimer (gameObject:Object):MovieClip{
			var timer = back.create_obj(undefined, "empty", "gametimer");
			timer.gameObject = gameObject;
			gameObject.timer = timer;
			
			timer.onEnterFrame = function (){
				// personal queues
				for (var pid = 0; pid < this.gameObject.playerCount; ++pid){
					var pl = this.gameObject.getPlayer(pid);
					if (pl.personalTimeOut > 0){ pl.personalTimeOut --; continue; }
					if (pl.actionQueue.length == 0) continue;
					
					var gameWasTimeOut = this.gameObject.framesTimeout;
					trace('Execute ' + pl._name + ' thread event!');
					pl.actionQueue[0](pl.actionQueue[1]);
					pl.actionQueue.splice(0,2);
					pl.personalTimeOut = this.gameObject.framesTimeout - gameWasTimeOut;
					this.gameObject.framesTimeout = gameWasTimeOut;
				}
				
				// main thread
				if (this.gameObject.framesTimeout > 0){
					this.gameObject.framesTimeout --;
					return;
				}
				if (this.gameObject.actionQueue.length == 0)
					return;
				// execute first function	
				trace('Execute main thread event!');
				// watch for some timer changes
				this.gameObject.actionQueue[0](this.gameObject.actionQueue[1]);
				this.gameObject.actionQueue.splice(0,2);
			}
			
			return timer;
		}
	}