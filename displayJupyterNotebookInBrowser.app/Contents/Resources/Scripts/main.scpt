JsOsaDAS1.001.00bplist00�Vscript_3/*
 * Open a double-clicked Jupyter notebook (a file with suffix "ipynb")
 * in a Google Chrome window.
 */
 
var app = Application.currentApplication();
app.includeStandardAdditions = true;

// Change path of following script as needed
app.doShellScript('$HOME/bin/displayJupyterNotebookInBrowser.jxa.sh')
                              I jscr  ��ޭ