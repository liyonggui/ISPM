/** HTML5+ 拍照及相册功能封装 */

let showActionSheet = (callback, num, maxNum,watermarkText) => {
    let actionSheetButtons = [{
        title: "拍照"
    }, {
        title: "从相册选择"
    }]

    plus.nativeUI.actionSheet({
        cancel: "取消",
        buttons: actionSheetButtons
    }, (e) => {
        if (e.index == 1) {
            captureImage(callback,watermarkText)
        } else if (e.index == 2) {
            showImageGallery(callback, num, maxNum,watermarkText)
        }
    })
}

/**拍照功能 */
let captureImage = (callback,watermarkText) => {
    let cmr = plus.camera.getCamera();
    cmr.captureImage((p) => {
        /**通过URL参数获取文件实体对象 */
        plus.io.resolveLocalFileSystemURL(p, (entry) => {
            compressImage(entry.toLocalURL(), entry.name,watermarkText, callback);
        }, (e) => {
            plus.nativeUI.toast("读取拍照文件错误：" + e.message)
        });
    }, (e) => {}, {
        filter: 'image'
    })
}

/**选择相册照片 multiple */
let showImageGallery = (callback, picsNum, maxNum,watermarkText) => {
    plus.gallery.pick(e => {

        e.files.forEach(item => {
            plus.io.resolveLocalFileSystemURL(item, (entry) => {
                compressImage(entry.toLocalURL(), entry.name, watermarkText,callback);
            })
        });
    }, err => {
        plus.nativeUI.toast("读取照片文件错误：" + e.message)
    }, {
        filter: 'image',
        multiple: true,
        maximum: maxNum-picsNum,
        onmaxed() {
            plus.nativeUI.alert('最多只能选择' + maxNum + '张照片')
        }
    })
}

// /**对图片文件进行压缩 */
// let compressImage = (url, filename, callback) => {
//     let name = '_doc/upload/' + filename
//     plus.zip.compressImage({
//         src: url,
//         dst: name,
//         quality: 40,
//         overwrite: true
//     }, (zip) => {
//         // callback 显示图片
//         callback(zip, filename)
//     }, (e) => {
//         plus.nativeUI.toast("压缩图片失败，请稍候再试")
//     })
// }

/**对图片文件进行压缩 */
let compressImage = (url, filename,watermarkText, callback) => {
    let name = '_doc/upload/' + filename
    var img = new Image();
    img.src = url;        // 传过来的图片路径在这里用。
    img.onload = function () {
 
        //生成canvas
        //图片压缩百分比
        let quality = img.height<1024?1:(1024/img.height)
        let width = img.width*quality;
        let height = img.height*quality;
        console.log("width:"+width);
        let canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        let ctx = canvas.getContext('2d');
        ctx.drawImage(img,0,0,width,height);
        //水印
        if(watermarkText)
        {
            let fontSize = width/document.body.clientHeight *20
            ctx.font=fontSize+"px microsoft yahei";
            ctx.textAlign="right";
            ctx.fillStyle = "rgba(255,255,255,0.8)";
            ctx.fillText(watermarkText,width-100 ,height-10);
        }
        let dataURI = canvas.toDataURL('image/jpeg', 1 );   //1最清晰，
            let bitmap = new plus.nativeObj.Bitmap();
            // 从本地加载Bitmap图片 
            bitmap.loadBase64Data(dataURI, () => {
                //    console.log('加载图片成功'); 
                bitmap.save(name , {
                    overwrite: true,
                    quality: 100
                }, (i) => {
                    console.log('保存图片成功：' + JSON.stringify(i));
                    callback(i,filename) 
                }, (e) => {
                    console.log('保存图片失败：' + JSON.stringify(e));
                });
            }, (e) => {
                console.log('加载图片失败：' + JSON.stringify(e));
            });
    }
}

/**获取 url */
let getFileEntity = (fileSrc, callback) => {
    //根据路径读取到文件 
    plus.io.resolveLocalFileSystemURL(fileSrc, (entry) => {
        entry.file((file) => {
            console.log(file)
            callback(file)
        });
    });
}

let uploadFile = (url, fileSrc, fileName, callback) => {
    let task = plus.uploader.createUpload(url, {
        method: 'post'
    }, (t, status) => {
        callback(t, status)
    })

    task.setRequestHeader("token", sessionStorage.token);
    task.addFile(fileSrc, {
        key: 'file'
    })
    task.start()
}


export {
    showActionSheet,
    getFileEntity,
    uploadFile
}
