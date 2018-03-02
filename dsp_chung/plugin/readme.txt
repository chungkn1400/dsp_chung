plugin support :

you can add a plugin in the /plugin/ /plugin2/ /plugin3/ folders 
myecho.dll/my3band.dll with its code source is provided as an example

the following cdecl dll functions must be defined and are dynamicaly loaded :

plugininit  : your init sub 
startpluginmain  : start your gui window edit
closepluginmain : called to close the gui window edit
mypluginproc  : called as sample=mypluginproc(sample) in the audio loop

