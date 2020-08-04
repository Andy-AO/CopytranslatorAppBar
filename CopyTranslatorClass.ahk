
global APPBARDATA

CopyTranslator.main()

Class CopyTranslator{
  static configFilePath := "config.json"
  ,ToolName := "Copytrans" "latorAppBar"
  ,configFileControler := ""
  ,MesToastContent := "Press Alt+Shift+z or click the tray icon to switch the display / hide status."
  ,MesToast := ""
  ,title := "Copytranslator ahk_exe copytranslator.exe"
  ,config := ""
  ,initConfigCount := 0
  ,initConfigCountLimit := 3
  ,hadAppBar := false
  ,wait := false
  
  main(){
    CopyTranslator.MesToast := new MesToast(CopyTranslator.ToolName,CopyTranslator.MesToastContent)
    CopyTranslator.configFileControler := new JsonFile(CopyTranslator.configFilePath)
    CopyTranslator.initConfig()
    return
  }

    initConfig(){
      try{
        CopyTranslator.config := CopyTranslator.configFileControler
              .init(Object("path","C:\Users\" A_UserName "\AppData\Local\Programs\copytranslator\copytranslator.exe"
                      ,"widthRatio",0.1
                      ,"SelfStart",true
                      ,"winWaitSec",7))  
      }
      catch,ex{
        if(_EX.isRuntimeException(ex))
          return CopyTranslator.initConfigBase()
        FileDelete,% CopyTranslator.configFilePath
        CopyTranslator.initConfigCount++
        if(CopyTranslator.initConfigCount > CopyTranslator.initConfigCountLimit)
          throw(_EX.RetryFail)
        return CopyTranslator.initConfig()
      }
    }
    
    PosSave(){
      WinGetPos, HX,HY,HW,HH, % CopyTranslator.ahk_id 
      CopyTranslator.pos := Object("X",HX,"Y",HY,"W",HW,"H",HH)
      return
    }
    
    PosChange(){
      Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_NEW:=0x0),UInt,&APPBARDATA)
      Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_QUERYPOS:=0x2),UInt,&APPBARDATA)
      Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_SETPOS:=0x3),UInt,&APPBARDATA)
      
      GX := NumGet(APPBARDATA, 16 )
      GY := NumGet(APPBARDATA, 20 )
      GW := NumGet(APPBARDATA, 24 ) - GX
      GH := NumGet(APPBARDATA, 28 ) - GY
     
      WinMove,% CopyTranslator.ahk_id,, %GX%, %GY%, %GW%, %GH% 
      return
    }
    
    RegisterAppBar(){
      CopyTranslator.switch()
      CopyTranslator.PosSave()
      CopyTranslator.ChangeStyle()
      CopyTranslator.PosChange()
      CopyTranslator.hadAppBar := true
      return
    }
    
    PosRecover(){
      thePos := CopyTranslator.pos
      HX := thePos.X,HY := thePos.Y
      ,HW := thePos.W,HH := thePos.H,
      WinMove, % CopyTranslator.ahk_id,, %HX%, %HY%, %HW%, %HH%
    }
    
    RemoveAppBar(){
      CopyTranslator.PosRecover()
      CopyTranslator.RestoreStyle()
      DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_REMOVE := 0x1),UInt,&APPBARDATA)
      CopyTranslator.hadAppBar := false
      return 
    }
    
    ToggleGUI(ItemName := "", ItemPos := "", MenuName := ""){
      if(CopyTranslator.wait = false){
        CopyTranslator.wait := true
        if(CopyTranslator.hadAppBar){
          CopyTranslator.RemoveAppBar()
        } Else {
          CopyTranslator.RegisterAppBar()
        }
        CopyTranslator.wait := false
      }
      return
    }

    RestoreStyle(){
      if(CopyTranslator.hadAppBar){
        WinSet, Style, +0xC00000,% CopyTranslator.ahk_id ; Restore the window's title bar
        WinSet, ExStyle, -0x80,% CopyTranslator.ahk_id   ; Restore it to the alt-tab list ;恢复到原来的属性
        WinSet, ExStyle, +0x00040000,% CopyTranslator.ahk_id   ; Turn on WS_EX_APPWINDOW
        return
      }
    }
    
    ahk_id[]{ 		
        get {
            Type.assertNumber(CopyTranslator.hwnd)
            return "ahk_id" " " CopyTranslator.hwnd
        }
        set {
            return
        }
    }
    
   findPathOfCopyTranslator(){
    Options := 1
    ,Filter := "*.exe"
    FileSelectFile, path , %Options%, , Title, %Filter%
    return path
   }


  QuitScript(ExitReason := "", ExitCode := ""){
    CopyTranslator.RemoveAppBar()
    ExitApp
  }

  ChangeStyle(){
    if(!CopyTranslator.hadAppBar){
      WinSet, Style, -0xC00000, % CopyTranslator.ahk_id  ; Remove the window's title bar 删除窗口的标题栏
      WinSet, ExStyle, +0x80, % CopyTranslator.ahk_id    ; Remove it from the alt-tab list 让他从切换栏中也移除
      WinSet, ExStyle, -0x00040000, % CopyTranslator.ahk_id    ; Turn off WS_EX_APPWINDOW 这个看不懂，反正也是去掉某一个窗口属性
    }
    return
  }
  
  findPathInRootDir(){
    return A_ScriptDir "\" "copytranslator.exe"
  }
  
  getSwitcher(){
    if(CopyTranslator.Switcher = ""){
      CopyTranslator.Switcher := new Switcher()
      CopyTranslator.Switcher.Options := ""
    }
    return CopyTranslator.Switcher
  }
  switch(){
    if(!WinActive(CopyTranslator.title)){
      isExist := false
      try{
        isExist := CopyTranslator.getSwitcher().switch(CopyTranslator.title,CopyTranslator.config.path,CopyTranslator.config.winWaitSec)
        CopyTranslator.hwnd := WinExist(CopyTranslator.title)
      }
      catch,ex{
        thePath :=  CopyTranslator.config.path
        PathInRootDir := CopyTranslator.findPathInRootDir()
        if(thePath != PathInRootDir){
          CopyTranslator.config.path := PathInRootDir
          if(CopyTranslator.config.path != "")
            CopyTranslator.configFileControler.store(CopyTranslator.config) 
          return CopyTranslator.switch()
        }

        theOption := 4+48
        ,theTitle := CopyTranslator.ToolName
        ,theContent := "Run Failed:" "`r`n" thePath "`r`n" "`r`n" "Do you want to find the path of copyTranslator.exe?"
        MsgBox , % theOption, %theTitle% , %theContent%
        IfMsgBox Yes
        { 
          CopyTranslator.config.path := CopyTranslator.findPathOfCopyTranslator()
          if(CopyTranslator.config.path != "")
            CopyTranslator.configFileControler.store(CopyTranslator.config) 
          return CopyTranslator.switch()
        }
        else
            ExitApp
      }
    }
  }
}