## 说明

脚本需要配合[CopyTranslator](https://copytranslator.github.io/)的Windows版使用，后续可能会内嵌。

## 介绍

有时需要高频率使用[CopyTranslator](https://copytranslator.github.io/)，置顶会遮挡其他窗口，只能手动排列来避免遮挡，但切换窗口时可能需要需要二次调整，比较繁琐。

CopyTranslatorAppBar脚本，能够利用AppBar，很好的解决这个问题。

> Windows上有个机制叫做AppBar，可以在屏幕上划定区域，让其他窗口自动的避让(任务栏就是通过这个机制实现的)，避免手动操作，从而大幅度提高使用效率。
>

用语言描述起来可能有点困难，脚本打包后<2MB，建议直接[下载使用](https://github.com/Andy-AO/CopytranslatorAppBar/releases/)，也可以参考下[录屏演示](##录屏演示)。

## 下载

- [GitHub](https://github.com/Andy-AO/CopytranslatorAppBar/releases/)

## 用法

[下载](https://github.com/Andy-AO/CopytranslatorAppBar/releases/)并运行本程序，并单击图标或按下`Alt+Shift+Z`，启动AppBar。

### 路径寻找

程序会首先寻找CopyTranslator.exe的路径，如果在默认安装目录和当前目录中找不到，则需要手动寻找，当然也可以在配置文件中直接写入路径。

### 启用/禁用

单击任务栏图标或者按下快捷键`Alt+Shift+Z`。

## 配置

配置位于当前目录下的`config.json`文件。

默认值如下

```JSON
{
    "path": "C:\\Users\\%YourUserName%\\AppData\\Local\\Programs\\copytranslator\\copytranslator.exe",
    "SelfStart": 1,
    "widthRatio": "0.1",
    "winWaitSec": 7,
    "uEdge":2
}
```

窗口停靠位置：`uEdge` left=0,top=1,right=2,bottom=3，默认是 `2`，也就是在右侧停靠窗口

### path

CopyTranslator.exe路径。

### selfStart

是否在本程序运行时，自动启用AppBar功能。

### widthRatio

AppBar占据屏幕宽度的比例。

### winWaitSec

当[CopyTranslator](https://copytranslator.github.io/)未运行的时候，脚本会试图拉起它，这个参数是启动时间的上限，超过则视为拉起失败。

## 录屏演示


在第1个动画中，因为没有AppBar，为了防止窗口遮挡，需要手动的调整窗口；在第2个动画中，因为右侧被划为AppBar，所有的窗口都自动避开了[CopyTranslator](https://copytranslator.github.io/)。
### 没有AppBar

![没有AppBar](README.assets/NotWithAppBar.gif)

### 有AppBar
![有AppBar](README.assets/WithAppBar.gif)
