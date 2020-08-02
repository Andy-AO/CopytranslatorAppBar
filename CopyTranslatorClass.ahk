

CopyTranslator.initConfig()

Class CopyTranslator{
  static configFilePath := "config.json"
  ,configFileControler := new JsonFile(CopyTranslator.configFilePath)
  ,MesToastContent := "Press Alt+Shift+z to switch the display / hide status."
  ,MesToast := new MesToast("CopytranslatorAppBar",CopyTranslator.MesToastContent)
  ,title := "Copytranslator ahk_exe copytranslator.exe"
  ,config := ""
  ,initConfigCount := 0
  ,initConfigCountLimit := 3
    initConfig(){
      try{
        this.config := CopyTranslator.configFileControler
          .init(Object("path","C:\Users\" A_UserName "\AppData\Local\Programs\copytranslator\copytranslator.exe"
                  ,"widthRatio",0.1
                  ,"setBarOnStart",true
                  ,"autoRun",true
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
    
   findPathOfCopyTranslator(){
    Options := 1
    ,Filter := "*.exe"
    FileSelectFile, path , %Options%, , Title, %Filter%
    return path
   }
   
  switch(){
    if(!WinActive(this.title)){
      isExist := false
      try{
        isExist := Switcher.switch(this.title,this.config.path,this.config.winWaitSec)
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