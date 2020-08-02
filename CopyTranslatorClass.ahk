

CopyTranslator.initConfig()

Class CopyTranslator{
  static configFilePath := "config.json"
  ,configFileControler := new JsonFile(CopyTranslator.configFilePath)
  ,MesToastContent := "Press Alt+Shift+z or click the tray icon to switch the display / hide status."
  ,MesToast := new MesToast("CopytranslatorAppBar",CopyTranslator.MesToastContent)
  ,title := "Copytranslator ahk_exe copytranslator.exe"
  ,config := ""
  ,initConfigCount := 0
  ,initConfigCountLimit := 3
  ,hadAppBar := false
    initConfig(){
      try{
        this.config := CopyTranslator.configFileControler
          .init(Object("path","C:\Users\" A_UserName "\AppData\Local\Programs\copytranslator\copytranslator.exe"
                  ,"widthRatio",0.1
                  ,"SelfStart",true
                  ,"winWaitSec",7))
      }
      catch,ex{
        FileDelete,% this.configFilePath
        this.initConfigCount++
        if(this.initConfigCount > this.initConfigCountLimit)
          throw(_EX.RetryFail)
        return this.initConfig()
      }
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


  QuitScript(ExitReason, ExitCode){
    GoSub, RemoveAppbar
    ;  This un-does the earlier SetParent
    DllCall( "SetParent", "uint", CopyTranslator.hwnd, "uint", 0 )
    ExitApp
  }

  ChangeStyle(){
    if(!CopyTranslator.hadAppBar){
      CopyTranslator.isChangedStyle := true
      WinGetPos, HX,HY,HW,HH, % CopyTranslator.ahk_id ;保存一下当前的位置
      CopyTranslator.pos := Object("X",HX,"Y",HY,"W",HW,"H",HH)
      WinSet, Style, -0xC00000, % CopyTranslator.ahk_id  ; Remove the window's title bar 删除窗口的标题栏
      WinSet, ExStyle, +0x80, % CopyTranslator.ahk_id    ; Remove it from the alt-tab list 让他从切换栏中也移除
      WinSet, ExStyle, -0x00040000, % CopyTranslator.ahk_id    ; Turn off WS_EX_APPWINDOW 这个看不懂，反正也是去掉某一个窗口属性
    }
    return
  }
  
  switch(){
    if(!WinActive(this.title)){
      isExist := false
      try{
        isExist := Switcher.switch(this.title,this.config.path,this.config.winWaitSec)
        CopyTranslator.hwnd := WinExist(CopyTranslator.title)
      }
      catch,ex{
        thePath :=  this.config.path
        ,theOption := 4+48
        ,theTitle := "Copytranslator"
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