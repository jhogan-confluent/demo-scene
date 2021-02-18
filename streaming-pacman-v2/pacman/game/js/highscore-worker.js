importScripts('shared.js');

var highestScore = 0;

function getHighestScore() {

	loadHighestScore(function(hgs){
		
		var cipp = hgs?hgs:highestScore;
		postMessage(cipp);	
		
	});
    
	//GN TODO
    //setTimeout("getHighestScore()", 5000);

}

//GN TODO
//getHighestScore();
