/**
 * plusReady
 *
 * @author xiang.li
 * @date 2017/11/15
 */
function listenPlusReady(Vue, router) {
    let v = new Vue();
    document.addEventListener("plusready", function () {
        // messagePush();

        // 扩展API加载完毕，现在可以正常调用扩展API
        plus.runtime.getProperty(plus.runtime.appid, function (inf) {
            let wgtVer = inf.version;
            let name = inf.name;
            console.log(name + ",当前应用版本：" + JSON.stringify(inf));
            sessionStorage.setItem('version', wgtVer);
            sessionStorage.setItem('appname', name);
        });
        document.addEventListener("netchange", function () {
            onNetChange(v);
        }, false);
        //设置sessionStorage，用于后续验证扩展加在完毕
        sessionStorage.setItem('plusready', 'done');
        localStorage.setItem('plusready', 'done');
        console.log('plus is ready')
        //获取状态栏高度 - 禁止沉浸式状态栏
        var immersed = 0;
        var ms = (/Html5Plus\/.+\s\(.*(Immersed\/(\d+\.?\d*).*)\)/gi).exec(navigator.userAgent);
        if (ms && ms.length >= 3) { // 当前环境为沉浸式状态栏模式
            immersed = parseFloat(ms[2]); // 获取状态栏的高度
            console.log(immersed);
        }
        //设置系统状态栏样式（状态栏前景文字为黑色）
        plus.navigator.setStatusBarStyle('dark');
        localStorage.setItem('statusbarH', immersed);
        console.log("statusbarH" + immersed + "+" + plus.screen.scale + "+" + plus.navigator.getStatusbarHeight());


        //优化IOS输入框
        var nativeWebview, imm, InputMethodManager;

        if (plus.os.name == "Android") {
            console.log("mainAndroid")
            var main = plus.android.runtimeMainActivity();
            var Context = plus.android.importClass("android.content.Context");
            InputMethodManager = plus.android.importClass("android.view.inputmethod.InputMethodManager");
            imm = main.getSystemService(Context.INPUT_METHOD_SERVICE);
        } else {
            nativeWebview = plus.webview.currentWebview().nativeInstanceObject();
        }

        pushMsgHandler(v, router)
    }, false);
}


function pushMsgHandler(v, router) {
    plus.push.addEventListener('click', (msg) => {
        router.push({
            name: 'task_todo'
        })
    })

    plus.push.addEventListener('receive', (msg) => {
        plus.nativeUI.confirm('您有新的待办任务，是否立即查看？', (e) => {
            if (e.index === 0) {
                router.push({
                    name: 'task_todo'
                })
            }
        }, '待办任务通知', ['查看', '忽略'])
    })
}


function onNetChange(v) {
    v.$message.closeAll();
    var nt = plus.networkinfo.getCurrentType();

    switch (nt) {
        case plus.networkinfo.CONNECTION_ETHERNET:
        case plus.networkinfo.CONNECTION_WIFI:
            console.log("Wifi网络！");
            //v.$message.info("Switch to Wifi networks!");
            break;
        case plus.networkinfo.CONNECTION_CELL2G:
            console.log("2G网络！");
            v.$message({
                message: "当前网络不稳定，请耐心等待!",
                center: true,
                duration: 10000,
                type: "warning"
            })
            break;
        case plus.networkinfo.CONNECTION_CELL3G:
        case plus.networkinfo.CONNECTION_CELL4G:
            console.log("3G 4G 网络！");
            //v.$message.info("Switch to Cellular networks!");
            break;
        default:
            v.$message({
                message: "当前网络不可用，请检查!",
                center: true,
                duration: 3000,
                showClose: true,
                type: "error"
            });
            break;
    }
}

export {
    listenPlusReady
}



function messagePush() {
    message = document.getElementById("message");
    // 监听点击消息事件
    plus.push.addEventListener("click", function (msg) {
        // 判断是从本地创建还是离线推送的消息
        switch (msg.payload) {
            case "LocalMSG":
                outSet("点击本地创建消息启动：");
                break;
            default:
                outSet("点击离线推送消息启动：");
                break;
        }
        // 提示点击的内容
        plus.ui.alert(msg.content);
        // 处理其它数据
        logoutPushMsg(msg);
    }, false);
    // 监听在线消息事件
    plus.push.addEventListener("receive", function (msg) {
        if (msg.aps) {
            // Apple APNS message
            outSet("接收到在线APNS消息：");
        } else {
            outSet("接收到在线透传消息：");
        }
        logoutPushMsg(msg);
    }, false);
}
