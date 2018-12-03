// 检测更新
function checkUpdate(vue,wgtVer,wgtName){
    console.log('run ............')
    plus.nativeUI.showWaiting("检测更新...");
    
    vue.$opsaxios.post("/app/osu/checkEdition",{
        "editionno":wgtVer,
        "appname":wgtName
    }).then((resp) => {
      plus.nativeUI.closeWaiting();
      console.log("检测更新成功："+JSON.stringify(resp));
      console.log(resp.data.data.code)
      if(resp.data.data.code=="1"){

        vue.$messagebox.confirm('有新的版本升级，请点击确认继续？').then((action) => {
            if (action === 'confirm') {
            var w = plus.webview.open(resp.data.data.downloadUrl);

            setTimeout(() => {
                plus.webview.close(w);
            }, 2000);
            
            }
        }).catch((action)=>{})  
      }else if(resp.data.data.code=="2"){
        let newVer = resp.data.data.maxAppEdition.editionno;
        if(wgtVer&&newVer&&(wgtVer!=newVer)){
            downWgt(vue,resp.data.data.downloadUrl);  // 下载升级包
        }
      }
      

    }).catch((error)=> {
      plus.nativeUI.closeWaiting();
      console.log("检测更新失败！"+error);
      plus.nativeUI.alert("检测更新失败,具体错误:"+error);
    });
}

// 下载wgt文件
function downWgt(vue,wgtUrl){
    plus.nativeUI.showWaiting("下载升级文件...");
    plus.downloader.createDownload( wgtUrl, {filename:"_doc/update/"}, function(d,status){
        if ( status == 200 ) { 
            console.log("下载升级成功："+d.filename);
            installWgt(d.filename); // 安装wgt包
        } else {
            console.log("下载升级失败！");
            plus.nativeUI.alert("下载升级失败！");
        }
        plus.nativeUI.closeWaiting();
    }).start();
}

// 更新应用资源
function installWgt(path){
    console.log("安装升级文件..." );
    plus.nativeUI.showWaiting("安装升级文件...");
    plus.runtime.install(path,{force: true},function(){
        plus.nativeUI.closeWaiting();
        console.log("安装升级文件成功！");
        plus.nativeUI.alert("应用资源更新完成！",function(){
            plus.runtime.restart();
        });
    },function(e){
        plus.nativeUI.closeWaiting();
        if(e.code=='-1205')
        {
            console.log("安装升级文件失败["+e.code+"]："+e.message);
        }
        else
        {
            console.log("安装升级文件失败["+e.code+"]："+e.message);
            //plus.nativeUI.alert("安装升级文件失败["+e.code+"]："+e.message);
        }
    });
}

export default{
    checkUpdate
}