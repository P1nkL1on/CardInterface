

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
			newButton.onMouseDown = function(){ if (this.selector.hitTest(_root._xmouse, _root._ymouse, true)){
				var isInAkser = this._parent.playerToChoose != undefined;
				if (isInAkser){
					//trace(this._parent.playerToChoose._name + " selects code " + this.resultWouldBeGiven);
					this._parent.result = this.resultWouldBeGiven;
				}
			} }
			return newButton;
		}
		
		static var xOffset = 870;
		static var yOffset = 560;
		
		static var resultNotready = 0;
		static var resultUnknown = -1;
		static var resultAccept = 10;
		static var resultDecline = 11;
		
		static function makeAsker(forPlayer:Object, description:String, solvingFunction, buttons:Array, where, params):MovieClip{
			if (where == undefined) where = GUIlayer;
			if (description == undefined) description = "...?";
			var newAsker = back.create_obj(where, "empty", "asker");
			newAsker.result = resultNotready;
			newAsker.playerToChoose = forPlayer;
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
			newAsker.onEnterFrame = function (){
				if (this.result == resultNotready)
					return; // waiting for  a normal answer
				this.solvingFunction(this.result, this.playerToChoose.game, this.playerToChoose, this.params);
				this.removeMovieClip();
			}
			return newAsker;
		}
		
		
		static function test(){
			//makeButton(_root, 'Accept', colors.buttonAcceptColor, 300, 300 + .4 * buttonScale);
			//makeButton(_root, 'Decline', colors.buttonDeclineColor, 300, 300);
			//makeAsker(gameengine.game.getPlayer(1), 'select y/n');
			//makeAsker(gameengine.game.getPlayer(1), 'select y/n');
			//makeAsker(gameengine.game.getPlayer(0), 'Keep theese cards, or mulligan -- shuffle your hand to library and draw one less card?');
			startMulliganAsker(gameengine.game.getPlayer(0), 7);
		}
		
		static function startMulliganAsker(forPlayer:Object, cardCount){
			//player.playerShuflesDeck(forPlayer);
			//player.playerDrawsCards(forPlayer, cardCount);
			
			var g = forPlayer.game;
			g.then(player.playerShuflesDeck, typ.gameCase(forPlayer.game, forPlayer));
			//g.then(player.playerDrawsCards, typ.gameCase(forPlayer.game, forPlayer, 7));
			
			var parameters = new Array(); 
			parameters.push(8); 
			mulliganAsker(resultDecline, forPlayer.game, forPlayer, parameters);
		}
		
		static function mulliganAsker(lastResult:Number, gameO:Object, playerO:Object, parameters){
			var cardCount = parameters[0];
			
			if (lastResult == resultAccept){
				trace(playerO._name + ' starts game with ' + cardCount);
				return;
			}
			if (lastResult == resultDecline && cardCount == 2){
				trace(playerO._name + ' starts game with ' + 1);
				return;
			}
			cardCount--;
			trace(playerO._name + ' mulligans to ' + cardCount);
			var newParams = new Array();
			newParams.push(cardCount);
			var str = "Keep theese " + cardCount + " cards or mulligan it to " + (cardCount -1) + " cards?";
			makeAsker(playerO, str, mulliganAsker, new Array('Keep', resultAccept, 'Mulligan', resultDecline), undefined, newParams);
		}
		
		static function addTimer (gameObject:Object):MovieClip{
			var timer = back.create_obj(undefined, "empty", "gametimer");
			timer.gameObject = gameObject;
			gameObject.timer = timer;
			
			timer.onEnterFrame = function (){
				if (this.gameObject.framesTimeout > 0){
					this.gameObject.framesTimeout --;
					return;
				}
				if (this.gameObject.actionQueue.length == 0)
					return;
				// execute first function	
				trace('Execute ' + this.gameObject.actionQueue.length);
				// watch for some timer changes
				this.gameObject.actionQueue[0](this.gameObject.actionQueue[1]);
				this.gameObject.actionQueue.splice(0,2);
			}
			
			return timer;
		}
	}