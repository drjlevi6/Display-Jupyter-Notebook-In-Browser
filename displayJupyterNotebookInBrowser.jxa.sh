#!/usr/bin/env osascript -l JavaScript

//Open the folder of an.ipynb file in the designated browser
/*-----Initialization---------------------------------------------------------*/
(() => {
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const se = Application('System Events');
const finder = Application('Finder');
const terminal = Application('Terminal');
const chrome = Application('Google Chrome');

/*-----Main-------------------------------------------------------------------*/
let selecName = getFinderSelectionName();

numTabs0 = countChromeTabs();

let containerPath = getContainerPath();

doNotebookCommand(containerPath); // Terminal executes jupyter_mac.command

awaitNewChromeTab(numTabs0);
let modURL = setURL_ofSelection(selecName);
setChromeURL(modURL);
/*-----Functions--------------------------------------------------------------*/
function setChromeURL(modURL){ // paste the modified URL into Chrome's text area
	chrome.activate();
	let wBounds = chrome.windows[0].bounds();
	
	// Select the text in Chrome's text area, paste new URL
	let wPosX = wBounds["x"] + parseInt(wBounds["width"]/2);
	let wPosY = wBounds["y"] + 60;
	
	let cliclickCommand = '/usr/local/bin/cliclick c:' + wPosX + ',' + wPosY;

	/*	There are problems with doShellScript (even though following line 
		works.)  So we run the DoShellScript command in a separate file using
		AppleScript, not JXA, passing the command via the clipboard. */
	app.doShellScript(
		"/usr/local/bin/gecho -n '" + cliclickCommand + "' | pbcopy");
	app.runScript(Path("/Users/jonathan/Library/Scripts/" + 
		"Google Chrome Scripts/doShellScript.scpt"));
	chrome.activate();
	delay(0.5);
	se.keystroke(modURL + '\r');
}

function setURL_ofSelection(selecName){ // modify Chrome URL to show selection
	
	let currentURL = '';
		while (!currentURL.startsWith("http://localhost")){
			currentURL = chrome.windows[0].activeTab().url();
		}
	//console.log("currentURL: " + currentURL);
	
	let modSelecName = getmodSelecName(selecName);
	
	let newURL_firstPart = currentURL.replace(
		/(http:\/\/localhost:[0-9]+\/).+/, "$1");
	let newURL_secondPart = "notebooks/" + modSelecName;
	return newURL_firstPart + newURL_secondPart;
}

function getmodSelecName(selecName){ // change all " " to "%20"
	return selecName.replace(/ /g, "%20");
}

function getFinderSelectionName(){ 			// return name of Finder selection
	return finder.selection()[0].name();
}

function doNotebookCommand(containerPath){ // Terminal does jupyter_mac.command
	terminal.activate();
	terminal.doScript("cd '" + dirname(containerPath) + "'" + "\n" +
		'/Users/jonathan/anaconda3/bin/jupyter_mac.command; exit;');
	terminal.activate();
}

function getContainerPath(){ // get Posix path of notebook file's container
	let container = finder.selection()[0].container().url();
	return urlToPosixPath(container);
}

function getDisplayedURL(){ // URL showing in the text area
	chrome.activate();
	let wBounds = chrome.windows[0].bounds();
	let textAreaPosX = wBounds["x"] + parseInt(wBounds["width"]/2);
	let textAreaPosY = wBounds["y"] + 60;
	
	app.doShellScript("/usr/local/bin/cliclick c:" + textAreaPosX + ',' +
		textAreaPosY);
	se.keystroke("a", {using: "command down"});
	se.keystroke("c", {using: "command down"});
	return app.theClipboard();
}

function awaitNewChromeTab(numTabs0){ // delay until new Chrome tab is ready
	//app.activate();
	//delay(1);
	//app.displayDialog("Awaiting new Chrome tab...", {givingUpAfter: 1});
	
	chrome.activate();
	while(true){
		try{
			if ( chrome.windows[0].tabs.length > numTabs0){
				return;
			} else {
				delay(0.1);
			}
		} catch {
			delay(0.1);
		}
	}
}

function countChromeTabs(){
	try{
		return chrome.windows[0].tabs.length;
	} catch { return 0 }
}

function urlToPosixPath(url){
	return url.replace("file://", "").replace(/%20/g, ' ');
}

function dirname(posixpath){
	return posixpath.replace(/(.+)\/[^\/]+$/, "$1");
}

})()