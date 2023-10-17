#!/usr/bin/env osascript -l JavaScript
/* Opens a Jupyter notebook (.ipynb file) in a Google Chrome window
 *    when the file is double-clicked.
 * Can be invoked on the command line, but is meant to be called by a wrapper
 *    JavaScript for Automation (JXA) application, 
 *    "displayJupyterNotebookInBrowser.app"
 *    (.ipynb files must be set to be opened by this wrapper using Finder’s 
 *    "Get Info", etc.)
 */

/*-----Initialization---------------------------------------------------------*/
var app = Application.currentApplication();
app.includeStandardAdditions = true;

const finder = Application('Finder');
const SE = Application('System Events');
const finderP = SE.applicationProcesses.byName('Finder');
const google = Application("Google Chrome")
google.includeStandardAdditions = true;
const googleP = SE.applicationProcesses.byName("Google Chrome")
const terminal = Application('Terminal')
terminal.includeStandardAdditions = true
const terminalP = SE.applicationProcesses.byName('Terminal')

/*-----Main-------------------------------------------------------------------*/
fname = getFinderSelection()
dirname = getFolderOfFinderSelection()
makeTerminalAtFinderFrontWindow(dirname)
awaitGoogle()
googleOpenLocation(fname)


/*-----Functions--------------------------------------------------------------*/
function googleOpenLocation(fname){
	const myDelay = 0.3
	SE.keystroke("l", {using: "command down"})
	delay(myDelay)	// 0.5
	SE.keystroke("c", {using: "command down"})
	delay(myDelay)
	clipdata = app.doShellScript('echo `pbpaste`').replace('http:\/\/', '')
	delay(myDelay)
	clipdata = clipdata.replace('tree', 'notebooks/' + fname)
	SE.keystroke(clipdata + '\r')
}

function awaitGoogle(){	// waits for Google Chrome to display tree for 
												// Finder window of selected .ipynb
	google.activate();
	do{
		delay(0.1)
	}while(!googleP.exists());
	do{
		delay(0.1)
	}while(googleP.frontmost() == false)

	do{
		delay(0.1)
	}while(!google.windows[0].activeTab.exists())

	do{
		delay(0.1)
	}while(!google.windows[0].activeTab.url().
		match(/(https:\/\/)?localhost:.*\/tree/))
}

function getFolderOfFinderSelection(){
	finder.activate()
	delay(0.3)
	var currentTarget = finder.finderWindows[0].target()
	var posixPath = 
		Application('Finder').selection()[0].url().replace(/^file:\/\//, '').
		replace(/%20/g, ' ')
	return '"' + posixPath.replace(/(.+\/)[^\/]+$/, "$1") + '"';
}

function getFinderSelection(){	// returns name of selected Finder .ipynb file
	return finder.selection()[0].name()
}

function makeTerminalAtFinderFrontWindow(dirname){
	terminal.doScript("cd " + dirname) // else make a new window
	terminal.activate()
	terminal.doScript("jupyter-notebook", {in: terminal.windows[0]})
}
