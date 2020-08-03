
global APPBARDATA

Class CopyTranslator{
  static configFilePath := "config.json"
  ,ToolName := "Copytrans" "latorAppBar"
  ,configFileControler := new JsonFile(CopyTranslator.configFilePath)
  ,MesToastContent := "Press Alt+Shift+z or click the tray icon to switch the display / hide status."
  ,MesToast := new MesToast(CopyTranslator.ToolName,CopyTranslator.MesToastContent)
  ,title := "Copytranslator ahk_exe copytranslator.exe"
  ,config := CopyTranslator.initConfig()
  ,initConfigCount := 0
  ,initConfigCountLimit := 3
  ,hadAppBar := false
  
    initConfigBase(){
        return CopyTranslator.configFileControler
          .init(Object("path","C:\Users\" A_UserName "\AppData\Local\Programs\copytranslator\copytranslator.exe"
                  ,"widthRatio",0.1
                  ,"SelfStart",true
                  ,"winWaitSec",7))      
    }
    initConfig(){
      try{
        return CopyTranslator.initConfigBase()
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
    
    RegisterAppBar(){
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
      return
    }
    
    RemoveAppBar(){
      CopyTranslator.RestoreStyle()
      DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_REMOVE := 0x1),UInt,&APPBARDATA)
      CopyTranslator.hadAppBar := false
      return 
    }
    
    ToggleGUI(ItemName := "", ItemPos := "", MenuName := ""){
      if(CopyTranslator.hadAppBar){
        CopyTranslator.RemoveAppBar()
      } Else {
        CopyTranslator.RegisterAppBar()
      }
      return
    }

    RestoreStyle(){
      if(CopyTranslator.hadAppBar){
        WinSet, Style, +0xC00000,% CopyTranslator.ahk_id ; Restore the window's title bar
        WinSet, ExStyle, -0x80,% CopyTranslator.ahk_id   ; Restore it to the alt-tab list ;恢复到原来的属性
        WinSet, ExStyle, +0x00040000,% CopyTranslator.ahk_id   ; Turn on WS_EX_APPWINDOW
        
        thePos := CopyTranslator.pos
        ,HX := thePos.X,HY := thePos.Y
        ,HW := thePos.W,HH := thePos.H,
        
        WinMove, % CopyTranslator.ahk_id,, %HX%, %HY%, %HW%, %HH% ;恢复到原来的位置
        return
      }
    }
    
    ahk_id[]{ 		
        get {
            Type.assertNumber(this.hwnd)
            return "ahk_id" " " this.hwnd
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
    ;  This un-does the earlier SetParent
    DllCall( "SetParent", "uint", CopyTranslator.hwnd, "uint", 0 )
    ExitApp
  }

  ChangeStyle(){
    if(!CopyTranslator.hadAppBar){
      CopyTranslator.hadAppBar := true
      WinGetPos, HX,HY,HW,HH, % CopyTranslator.ahk_id ;保存一下当前的位置
      CopyTranslator.pos := Object("X",HX,"Y",HY,"W",HW,"H",HH)
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
    if(this.Switcher = ""){
      this.Switcher := new Switcher()
      this.Switcher.Options := ""
    }
    return this.Switcher
  }
  switch(){
    if(!WinActive(this.title)){
      isExist := false
      try{
        isExist := this.getSwitcher().switch(this.title,this.config.path,this.config.winWaitSec)
        CopyTranslator.hwnd := WinExist(CopyTranslator.title)
      }
      catch,ex{
        thePath :=  this.config.path
        PathInRootDir := CopyTranslator.findPathInRootDir()
        if(thePath != PathInRootDir){
          this.config.path := PathInRootDir
          if(this.config.path != "")
            this.configFileControler.store(this.config) 
          return this.switch()
        }

        theOption := 4+48
        ,theTitle := CopyTranslator.ToolName
        ,theContent := "Run Failed:" "`r`n" thePath "`r`n" "`r`n" "Do you want to find the path of copyTranslator.exe?"
        MsgBox , % theOption, %theTitle% , %theContent%
        IfMsgBox Yes
        { 
          this.config.path := this.findPathOfCopyTranslator()
          if(this.config.path != "")
            this.configFileControler.store(this.config) 
          return this.switch()
        }
        else
            ExitApp
      }
    }
  }
}