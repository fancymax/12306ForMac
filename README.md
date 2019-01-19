# 12306ForMac

仅做学习参考，随着12306接口的变更可能无法正常使用。

Mac版12306 订票/捡票 助手。

以前要么开Windows虚拟机，要么使用官方Web，现在可以使用12306ForMac订票助手。

注意系统要求  **OS X10.11**  以上

![demo](screenshot/12306ForMac.jpg)

# 开发

1. OS X 10.13/Xcode 9.0/Swift 3.2/brew
2. $ brew install carthage
3. $ git clone --recursive https://github.com/fancymax/12306ForMac.git 
5. $ cd 12306ForMac
4. $ carthage update --platform macOS

# 感谢

本项目基于 Alamofire、PromiseKit、FMDB、MASPreferences等进行开发，在此表示感谢。

