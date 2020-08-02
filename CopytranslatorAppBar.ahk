
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

theMesToast := new MesToast("","Press Alt+Shift+z to switch the display / hide status.")

theMesToast.show() 

Class GlobalWin{
  static title := "Copytranslator ahk_exe copytranslator.exe"
  static path := "C:\Users\Andy\AppData\Local\Programs\copytranslator\copytranslator.exe"
}

if(!WinActive(GlobalWin.title)){
  isExist := false
  try{
    isExist := Switcher.switch(GlobalWin.title,GlobalWin.path,8)
  }
  catch,ex{
    thePath :=  GlobalWin.path
    MsgBox,Run Failed:%thePath%
    ExitApp
  }

}


uEdge=2                                 ; left=0,top=1,right=2,bottom=3
uAppWidth=200                           ; "ideal" width for a vertical appbar
uAppHeight=136                          ; "ideal" height when horizonal

DetectHiddenWindows, On

hAB := WinExist(GlobalWin.title)
hProgman := WinExist(GlobalWin.title)

Gui +LastFound
hGUI := WinExist()
hProgman := DllCall( "FindWindowEx", "uint",0, "uint",0, "str", "Progman", "uint",0)
 
; preserve current positioning
WinGetPos, HX,HY,HW,HH, ahk_id %hAB% ;保存一下当前的位置

SetBatchLines -1
CoordMode, Mouse  , Screen
CoordMode, Tooltip, Screen
Menu, Tray, NoStandard
Menu, Tray, Add, AppBar Hide/Show, ToggleGUI
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

if (uEdge in 0,2) {
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
Off :=  NumPut(   hAB, Off+0 )          ; hWnd
Off :=  NumPut(   ABM, Off+0 )          ; uCallbackMessage
Off :=  NumPut( uEdge, Off+0 )          ; uEdge: left=0,top=1,right=2,bottom=3
Off :=  NumPut(    GX, Off+0 )          ; rc.left
Off :=  NumPut(    GY, Off+0 )          ; rc.top
Off :=  NumPut( GX+GW, Off+0 )          ; rc.right
Off :=  NumPut( GY+GH, Off+0 )          ; rc.bottom
Off :=  NumPut(     1, Off+0 )          ; lParam
GoSub, RegisterAppBar

ChangeStyle(hAB)

OnExit, QuitScript
Return


RegisterAppBar:
  Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_NEW:=0x0),UInt,&APPBARDATA)
  Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_QUERYPOS:=0x2),UInt,&APPBARDATA)
  Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_SETPOS:=0x3),UInt,&APPBARDATA)
  GX := NumGet(APPBARDATA, 16 )
  GY := NumGet(APPBARDATA, 20 )
  GW := NumGet(APPBARDATA, 24 ) - GX
  GH := NumGet(APPBARDATA, 28 ) - GY
  WinMove, ahk_id %hAB%,, %GX%, %GY%, %GW%, %GH% ;把一个窗口给移动到那个位置
Return

RemoveAppBar:
  DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_REMOVE := 0x1),UInt,&APPBARDATA)
Return

QuitScript:
  GoSub, RemoveAppbar
  ;  This un-does the earlier SetParent
  DllCall( "SetParent", "uint", hAB, "uint", 0 )
  RestoreStyle(hAB)
  WinMove, ahk_id %hAB%,, %HX%, %HY%, %HW%, %HH% ;恢复到原来的位置
  WinShow, ahk_id %hAB%
  ExitApp
Return

ABM_Callback( wParam, LParam, Msg, HWnd ) {
  return
}


+!z::
  ToggleGUI:
    If DllCall("IsWindowVisible", UInt,hAB) {
      WinHide, ahk_id %hAB% ;隐藏和展示
      GoSub, RemoveAppBar
    } Else {
      WinShow, ahk_id %hAB%
      GoSub, RegisterAppBar
    }
  Return
return

ChangeStyle(hAB){
  WinSet, Style, -0xC00000, ahk_id %hAB%  ; Remove the window's title bar 删除窗口的标题栏
  WinSet, ExStyle, +0x80, ahk_id %hAB%    ; Remove it from the alt-tab list 让他从切换栏中也移除
  WinSet, ExStyle, -0x00040000, ahk_id %hAB%    ; Turn off WS_EX_APPWINDOW 这个看不懂，反正也是去掉某一个窗口属性
  return
}


RestoreStyle(hAB){
  WinSet, Style, +0xC00000, ahk_id %hAB%  ; Restore the window's title bar
  WinSet, ExStyle, -0x80, ahk_id %hAB%    ; Restore it to the alt-tab list ;恢复到原来的属性
  WinSet, ExStyle, +0x00040000, ahk_id %hAB%    ; Turn on WS_EX_APPWINDOW
  return
}
