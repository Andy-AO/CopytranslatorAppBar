
Class CopyTranslator{
  static configFilePath := "config.json"
  ,configFileControler := new JsonFile(CopyTranslator.configFilePath)
  ,MesToastContent := "Press Alt+Shift+z to switch the display / hide status."
  ,MesToast := new MesToast("CopytranslatorAppBar",CopyTranslator.MesToastContent)
  
  ,title := "Copytranslator ahk_exe copytranslator.exe"
  
  ,config := CopyTranslator.configFileControler
  .init(Object("path","C:\Users\" A_UserName "\AppData\Local\Programs\copytranslator\copytranslator.exe"
          ,"widthRatio",0.1
          ,"setBarOnStart",true
          ,"autoRun",true
          ,"winWaitSec",7))
  switch(){
    if(!WinActive(this.title)){
      isExist := false
      try{
        isExist := Switcher.switch(this.title,this.config.path,this.config.winWaitSec)
      }
      catch,ex{
        thePath :=  this.config.path
        MsgBox,Run Failed:%thePath%
        ExitApp
      }
    }
  }
}