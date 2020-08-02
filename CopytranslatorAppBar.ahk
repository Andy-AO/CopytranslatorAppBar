
#Include D:\AHKs\Dev\_CoreLib.ahk
Hotstring("EndChars"," ")
#Hotstring ? O Z

#NoEnv 

#Warn All , StdOut
#Warn ClassOverwrite , MsgBox
#Warn LocalSameAsGlobal, Off

#SingleInstance force

Process, Priority,, High
SetTitleMatchMode 2
SendMode Input
SetFormat,Float,0.2
FileEncoding , UTF-8

#Include D:\AHKs\Dev\_CoreLib.ahk
#NoEnv                                 
SendMode Input                          
SetWorkingDir %A_ScriptDir%            

Menu, Tray, Icon,CopytranslatorAppBar.ico, ,1
          
#Include %A_ScriptDir%\CopyTranslatorClass.ahk


CopyTranslator.MesToast.show() 

uEdge=2                                 ; left=0,top=1,right=2,bottom=3
uAppWidth := Ceil(CopyTranslator.config.widthRatio * A_ScreenWidth)                     ; "ideal" width for a vertical appbar
uAppHeight=136                          ; "ideal" height when horizonal

hProgman := WinExist(CopyTranslator.title)

Gui +LastFound
hGUI := WinExist()
hProgman := DllCall( "FindWindowEx", "uint",0, "uint",0, "str", "Progman", "uint",0)
 
; preserve current positioning

SetBatchLines -1
CoordMode, Mouse  , Screen
CoordMode, Tooltip, Screen
Menu, Tray, NoStandard
HideOrShowFuncObj := new Method(CopyTranslator.ToggleGUI,CopyTranslator)
Menu, Tray, Add, AppBar Hide/Show, %HideOrShowFuncObj%
Menu, Tray, Add
Menu, Tray, Standard
Menu, Tray, Default, AppBar Hide/Show
Menu, Tray, Click, 1

if (uEdge = 2) {
  GX := A_ScreenWidth - uAppWidth
} else {
  GX := 0
}

if (uEdge = 3) {
  GY := A_ScreenHeight - uAppHeight
} else {
  GY := 0
}

if ((uEdge = 0) OR (uEdge = 2)) {
  GW := uAppWidth
  GH := A_ScreenHeight
} else {
  GW := A_ScreenWidth
  GH := uAppHeight
}


ABM := DllCall( "RegisterWindowMessage", Str,"AppBarMsg" )
OnMessage( ABM, "ABM_Callback" )
OnMessage( (WM_MOUSEMOVE := 0x200) , "CheckMousePos" )

; APPBARDATA : http://msdn2.microsoft.com/en-us/library/ms538008.aspx
VarSetCapacity( APPBARDATA , 36, 0 )
Off :=  NumPut(    36, APPBARDATA )     ; cbSize
Off :=  NumPut(CopyTranslator.hwnd, Off+0 )          ; hWnd
Off :=  NumPut(   ABM, Off+0 )          ; uCallbackMessage
Off :=  NumPut( uEdge, Off+0 )          ; uEdge: left=0,top=1,right=2,bottom=3
Off :=  NumPut(    GX, Off+0 )          ; rc.left
Off :=  NumPut(    GY, Off+0 )          ; rc.top
Off :=  NumPut( GX+GW, Off+0 )          ; rc.right
Off :=  NumPut( GY+GH, Off+0 )          ; rc.bottom
Off :=  NumPut(     1, Off+0 )          ; lParam

if(CopyTranslator.config.SelfStart){
  GoSub, RegisterAppBar
}


OnExit(new Method(CopyTranslator.QuitScript,CopyTranslator))
Return


RegisterAppBar:
  CopyTranslator.switch()
  CopyTranslator.ChangeStyle()
  CopyTranslator.hadAppBar := true
  Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_NEW:=0x0),UInt,&APPBARDATA)
  Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_QUERYPOS:=0x2),UInt,&APPBARDATA)
  Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_SETPOS:=0x3),UInt,&APPBARDATA)
  GX := NumGet(APPBARDATA, 16 )
  GY := NumGet(APPBARDATA, 20 )
  GW := NumGet(APPBARDATA, 24 ) - GX
  GH := NumGet(APPBARDATA, 28 ) - GY
  WinMove,% CopyTranslator.ahk_id,, %GX%, %GY%, %GW%, %GH% ;把一个窗口给移动到那个位置
Return

RemoveAppBar:
  CopyTranslator.RestoreStyle()
  DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_REMOVE := 0x1),UInt,&APPBARDATA)
  CopyTranslator.hadAppBar := false
Return


ABM_Callback( wParam, LParam, Msg, HWnd ) {
  return
}


+!z::
  CopyTranslator.ToggleGUI()
return


