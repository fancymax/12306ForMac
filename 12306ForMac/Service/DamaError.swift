//
//  DamaError.swift
//  12306ForMac
//
//  Created by fancymax on 16/8/13.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

struct DamaError {
    static let Domain = "com.Dama2.error"
    
    static let errorDic = [
        -1:	"系统错误",
        -100:	"无效软件KEY",
        -101:	"黑名单机器信息",
        -102:	"黑名单IP",
        -103:	"用户不存在",
        -104:	"用户密码错",
        -105:	"用户被停用",
        -106:	"无效服务器类型",
        -107:	"无效用户类型",
        -108:	"动态码校验失败，需要发送动态码",
        -109:	"无效的黑名单类型",
        -110:	"参数为空",
        -111:	"验证码字符类型校验错误",
        -112:	"APPCODETYPEID不存在",
        -113:	"CODETYPEID不存在",
        -114:	"无效充值卡密",
        -115:	"无效的验证码结果状态",
        -116:	"无效的提现模式",
        -117:	"无效软件类型",
        -118:	"无效动态验证码发送类型",
        -119:	"打码工人选择了错误的字符类型",
        -200:	"无负载均衡服务器",
        -201:	"均衡服务器未配置",
        -202:	"没有配置全客户端类型的版本",
        -203:	"没有可用验证码",
        -204:	"提交验证码结果时，没有指定的验证码",
        -205:	"没有打码工人统计数据",
        -206:	"没有指定的验证码ID记录",
        -300:	"COOKIE长度溢出",
        -301:	"用户名重复",
        -302:	"报告验证码结果状态失败（没更新到数据）",
        -303:	"验证码尚未打码完成",
        -304:	"余额不足，题分不足",
        -305:	"验证码状态不允许",
        -306:	"用户动态码发送配置不正确",
        -400:	"动态验证码发送超限",
        -401:	"动态码超时",
        -402:	"功能不支持",
        -403:	"发送动态验证码失败",
        -404:	"参数非法",
        -406:	"用户无权使用该APP",
        -9990:	"decrypt password error",
        -9991:	"appID error",
        -9992:	"用户不存在",
        -9993:	"用户密码错",
        -9994:	"no file",
        -9995:	"id error",
        -9996:	"email error",
        -9997:	"tel error",
        -9998:	"db name error",
        -9999:	"encrypt key error",
        -10000:	"busy",
        -10020:	"program error",
        -10021:	"db error",
        -10022:	"db execute error",
        -10023:	"URL错误",
        -10025:	"POST数据中包含了多个文件",
        -10027:	"sign error",
        -10028:	"extName error",
        -10029:	"fileData error/fileDataBase64 error"]

    static func errorWithCode(_ code:Int)->NSError{
        if errorDic.keys.contains(code) {
            return errorWithCode(code, failureReason: "打码兔错误: \(errorDic[code]!)")
        }
        else {
            return errorWithCode(code, failureReason: "未知错误, 错误码 = \(code)")
        }
    }
    
    static func errorWithCode(_ code: Int, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Domain, code: code, userInfo: userInfo)
    }
    
}
