
global Version := 0.1

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

#Include %A_ScriptDir%\BeanLib\BeanLib.ahk


global ToolName := "Copytrans" "latorAppBar"

OnError("ErrorHandler")

ErrorHandler(ex){
    theOption := 4+48
    ,theTitle := ToolName
    ,theContent := "Unhandled exception:" "`r`n" "`r`n"  "There is an error in the program. Do you want to try again?"
    MsgBox , % theOption, %theTitle% , %theContent%
    IfMsgBox Yes
    { 
      Reload
    }
    else
        ExitApp
    return
}

#NoEnv                                 
SendMode Input                          
SetWorkingDir %A_ScriptDir%            

Menu, Tray, Icon,CopytranslatorAppBar.ico, ,1
          
#Include %A_ScriptDir%\CopyTranslatorClass.ahk

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
Menu, Tray, Add, About, ShowAbout
Menu, Tray, Add
Menu, Tray, Standard
Menu, Tray, Default, AppBar Hide/Show
Menu, Tray, Click, 1

ShowAbout(ItemName := "", ItemPos := "", MenuName := ""){
  MsgBox,Version  %Version%
  return ErrorLevel
}

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

; APPBARDATA : http://msdn.microsoft.com/en-us/library/ms538008.aspx
;~ https://docs.microsoft.com/zh-cn/windows/win32/api/shellapi/ns-shellapi-appbardata?redirectedfrom=MSDN

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
  CopyTranslator.RegisterAppBar()
}

OnExit(new Method(CopyTranslator.QuitScript,CopyTranslator))

CopyTranslator.MesToast.show() 

return

ABM_Callback( wParam, LParam, Msg, HWnd ) {
  return
}

+!z::
  CopyTranslator.ToggleGUI()
return
