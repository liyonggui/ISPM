<template>
<div>
    <div class="vue-uploader">
        <div class="file-list">
            <section v-if="status == 'ready'" class="file-item draggable-item">
                <van-row gutter="2">
                    <van-col>
                        <div id="fileSelectFront" @click="showActionSheet('front')" v-if="isFrontLoad" class="add needsclick">
                            <img v-lazy="imagesPrew[0]" alt="" ondragstart="return false;">

                            <div class="text needsclick">添加正面照片</div>
                        </div>
                        <div id="fileSelectFront" v-if="!isFrontLoad" class="add needsclick" @click="showActionSheet('front')">
                            <div> <img src="../assets/login/zhengmian.png" /> </div>
                            <div class="text needsclick">添加正面照片</div>
                        </div>
                    </van-col>
                    <van-col>
                        <div id="fileSelectBack" @click="showActionSheet('back')" class="add needsclick" v-if="isBackLoad">
                            <img v-lazy="imagesPrew[1]" alt="" ondragstart="return false;">
                            <div class="text needsclick">添加背面照片</div>
                        </div>
                        <div id="fileSelectBack" v-if="!isBackLoad" class="add needsclick" @click="showActionSheet('back')">
                            <div> <img src="../assets/login/fanmian.png" /> </div>
                            <div class="text needsclick">添加背面照片</div>
                        </div>
                    </van-col>
                </van-row>
            </section>
        </div>
        <input type="file" accept="image/jpg,image/jpeg,image/png" capture="video" @change="fileChanged" ref="file">
    </div>
    <van-popup v-model="showCut" position="right" :overlay="true">
        <tms-page>
            <nav-bar title="裁剪" slot="tms-header" left-arrow left-text="返回" @click-left="showCut=false" />
            <div class="child" slot="tms-content">
                <div style="background: rgba(0,0,0,.5);height:.5rem; font-size: .3rem; color: white;">
                    <van-col span="12">
                        <van-icon name="qingchu" style="font-weight: bolder;margin-top: 0.1rem; margin-left:0.8rem;" @click="showCut=false" />
                    </van-col>
                    <van-col span="12">
                        <van-icon name="success" style="margin-top: 0.1rem; margin-left:0.8rem;" @click="onFinishcutImage" />
                    </van-col>
                </div>
                <vue-cropper :autoCrop="true" v-model="showCut" :canScale="true" :canMove="true" :canMoveBox="true" outputType="base64" :fixedBox="true" :fixed="true" :fixedNumber="[1.6,1]" ref="cropper" :img="cutImage"></vue-cropper>
            </div>
        </tms-page>
    </van-popup>
</div>
</template>

<script>
import VueCropper from 'vue-cropper'
export default {
    components: {
        'vue-cropper': VueCropper
    },
    props: {
        //只读属性
        readonly: {
            type: Boolean,
            default: false
        },
        //传入图片base64,array[0]身份证正面,array[1]身份证反面
        imagesData: { // 根据服务器返回的路径回显图片
            type: Array,
            default: function () {
                return []
            }
        }
    },
    data() {
        return {
            status: 'ready',
            files: [],
            imagesPrew: [],
            tmpfiles: [],
            point: {},
            popupshow: false,
            popupimage: "",
            popupindex: "",
            uploading: false,
            percent: 0,
            images: [], // 图片上传到服务器之后的返回的路径
            isFrontLoad: false,
            isBackLoad: false,
            uploadType: "",
            showCut: false,
            cutImage: "",
        }
    },
    watch: { // 监听图片信息
        imagesData(val) {
            this.imagesPrew = this.imagesData;
            if (val.length > 0) {
                if (val[0]) {
                    this.isFrontLoad = true;
                    this.convertBase64UrlToBlob(val[0], "front");
                }
                if (val[1]) {
                    this.isBackLoad = true;
                    this.convertBase64UrlToBlob(val[1], "back");
                }

            }
        },
    },
    methods: {
        showActionSheet(type) {

            this.uploadType = type;
            if (!this.readonly) {
                if (sessionStorage.plusready === 'done') {
                    //手机端上传
                    var actionbuttons = [{
                        title: "拍照"
                    }, {
                        title: "相册选取"
                    }];
                    var actionstyle = {
                        title: "选择照片",
                        cancel: "取消",
                        buttons: actionbuttons
                    };
                    plus.nativeUI.actionSheet(actionstyle, (e) => {
                        if (e.index == 1) {
                            this.getImage();
                        } else if (e.index == 2) {
                            this.galleryImg();
                        }
                    });
                } else {
                    //web端上传
                    this.$refs.file.click();
                }
            }
        },
        // 拍照上传 
        getImage(type) {
            var cmr = plus.camera.getCamera();
            var res = cmr.supportedImageResolutions[0];
            var fmt = "jpg";
            console.log("Resolution: " + res + ", Format: " + fmt);
            cmr.captureImage((e) => {
                console.log(e);
                plus.io.resolveLocalFileSystemURL(e, (entry) => {
                        this.compressImageUpload(entry.toLocalURL(), entry.name);
                    },
                    (error) => {
                        console.log("Capture image failed: " + error.message);
                    }, {
                        resolution: res,
                        format: fmt
                    }
                )
            })
        },
        //选择图片上传
        galleryImg(type) {
            plus.gallery.pick((e) => {
                //alert(e.files.length);

                console.log(e);
                plus.io.resolveLocalFileSystemURL(e, (entry) => {
                    console.log("path" + entry.toLocalURL());
                    console.log("item.file", entry.toLocalURL());
                    this.compressImageUpload(entry.toLocalURL(), entry.name);
                }, (e) => {
                    plus.nativeUI.toast("读取拍照文件错误：" + e.message);
                });

            }, (e) => {
                console.log("取消选择图片");
            }, {
                filename: "_doc/camera/",
                filter: "image"
            });
        },
        //压缩图片
        compressImageUpload(path, imageName) {
            var fileSize;
            plus.io.resolveLocalFileSystemURL(path, (entry) => {
                entry.file((file) => {
                    fileSize = file.size;
                    console.log(file.size + '--' + file.name);
                });
            }, (e) => {
                alert("Request file system failed:" + e.message);
            });
            let quality = 80;
 
            let dst = plus.io.convertLocalFileSystemURL(("_doc/camera/" + imageName));

            console.log("path" + path);
            console.log("imageName" + imageName);
            console.log("dst" + dst);
            plus.zip.compressImage({
                    src: path,
                    dst: dst,
                    overwrite: true,
                    quality: quality,
                    width: plus.screen.resolutionWidth+"px",
                    height: plus.screen.resolutionHeight+"px",
                },
                (event) => {
                    console.log('压缩后路径' + event.target)
                    console.log('压缩转换后图片大小:' + event.size)
                    this.onUpload(event.target);
                },
                (error) => {
                    console.log("Compress error, errorcode:" + error.code + ';errormsg:' + error.message);
                });
        },
        //上传图片
        onUpload(path) {
            plus.io.resolveLocalFileSystemURL(path, (entry) => {
                entry.file((file) => {
                    var reader = new plus.io.FileReader();
                    reader.readAsDataURL(file);
                    reader.onloadend = ((e) => {
                        this.cutImage = e.target.result;
                        this.showCut = true;

                    });

                }, function (e) {
                    alert(e.message);
                });

            }, function (e) {
                alert("Resolve file URL failed: " + e.message);
            });

        },

        //Web端直接上传
        submit(item) {

            if (this.files.length === 0) {
                console.warn('no file!');
                return
            }

            const formData = new FormData()
            formData.append(item.name, item.file)
            this.onUpload_Web(item.file);
        },
        finished() {
            this.files = []
            this.status = 'ready'
        },
        show(image, index) {
            _.clone
            this.popupimage = image;
            this.$emit('show', this.popupimage, _.clone(this.imagesPrew), this.readonly ? null : index);
        },
        //删除照片
        remove(index) {

            if (!this.readonly) {
                this.$messagebox.confirm('确认删除该图片？').then((action) => {
                    if (action === 'confirm') {
                        this.files.splice(index, 1, '');
                        this.images.splice(index, 1, '');
                        this.imagesPrew.splice(index, 1, '');
                        this.$emit('toBack');

                        this.$emit('outside', this.images);
                        if (index == 0) {
                            this.isFrontLoad = false
                        } else if (index == 1) {
                            this.isBackLoad = false
                        }
                    }
                }).catch((action) => {})
            }
        },
        fileChanged() {
            const list = this.$refs.file.files
            for (let i = 0; i < list.length; i++) {
                if (!this.isContain(list[i])) {
                    const item = {
                        name: list[i].name,
                        size: list[i].size,
                        file: list[i]
                    }

                    this.files.push(item)
                    this.submit(item);
                }
            }
            this.$refs.file.value = '';
        },
        isContain(file) {
            this.files.forEach((item) => {
                if (item.name === file.name && item.size === file.size) {
                    return true
                }
            })
            return false
        },
        //上传图片
        onUpload_Web(path) {
            var reader = new FileReader();
            reader.readAsDataURL(path);
            reader.onload = ((e) => {
                this.cutImage = e.target.result;
                this.showCut = true;

                console.log("this.uploadType" + this.uploadType);

            });
        },
        //完成裁剪图片
        onFinishcutImage() {
            this.$refs.cropper.getCropData((data) => {

                if (this.uploadType == "front") {
                    this.files.splice(0, 1, '');
                    this.images.splice(0, 1, '');
                    this.imagesPrew.splice(0, 1, '');
                    this.isFrontLoad = true;
                    this.imagesPrew[0] = data;
                    this.convertBase64UrlToBlob(data, this.uploadType)
                } else if (this.uploadType == "back") {
                    this.files.splice(1, 1, '');
                    this.images.splice(1, 1, '');
                    this.imagesPrew.splice(1, 1, '');
                    this.isBackLoad = true;
                    this.imagesPrew[1] = data;
                    this.convertBase64UrlToBlob(data, this.uploadType)
                }

                this.showCut = false;
            })
        },

        /**
         ** 将以base64的图片url数据转换为Blob
         * @param dataURI
         **身份证正反面,front、back
         * @param type
         * 用url方式表示的base64图片数据
         * @returns {Blob}
         */
        convertBase64UrlToBlob(dataURI, type) {
            var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
            //获取文件类型如.jpg
            var filetype = '.' + mimeString.split('/')[1];

            if (sessionStorage.plusready === 'done') {
                var bitmap = new plus.nativeObj.Bitmap();
                // 从本地加载Bitmap图片 
                bitmap.loadBase64Data(dataURI, () => {
                    //    console.log('加载图片成功'); 
                    bitmap.save("_doc/" + type + filetype, {
                        overwrite: true,
                        quality: 100
                    }, (i) => {
                        console.log('保存图片成功：' + JSON.stringify(i));
                        if (type == 'front') {
                            this.images[0] = i.target;
                        } else {
                            this.images[1] = i.target;
                        }
                        this.$emit('outside', this.images);
                    }, (e) => {
                        console.log('保存图片失败：' + JSON.stringify(e));
                    });
                }, (e) => {
                    console.log('加载图片失败：' + JSON.stringify(e));
                });
            } else {
                var byteString = atob(dataURI.split(',')[1]);

                var ab = new ArrayBuffer(byteString.length);
                var ia = new Uint8Array(ab);
                for (var i = 0; i < byteString.length; i++) {
                    ia[i] = byteString.charCodeAt(i);
                }
                if (type == 'front') {
                    this.images[0] = new File([ab], type + filetype, {
                        type: mimeString
                    });;
                } else {
                    this.images[1] = new File([ab], type + filetype, {
                        type: mimeString
                    });;
                }
                this.$emit('outside', this.images);
            }
        }

    }
}
</script>

<style scoped>
.vue-uploader {
    border: 1px solid #e5e5e5;
}

.vue-uploader .file-list {
    padding: .1rem 0rem;
}

.vue-uploader .file-list:after {
    content: '';
    display: block;
    clear: both;
    visibility: hidden;
    line-height: 0;
    height: 0;
    font-size: 0;
}

.vue-uploader .file-list .file-item {
    float: left;
    position: relative;
    text-align: center;
    flex-direction: row
}

.vue-uploader .file-list .file-item img {
    width: 2.4rem;
    height: 1.4rem;
    border: 1px solid #ececec;
}

.vue-uploader .file-list .file-item .file-remove {
    position: absolute;
    right: 12px;
    display: none;
    top: 4px;
    width: 14px;
    height: 14px;
    color: white;
    cursor: pointer;
    line-height: 12px;
    border-radius: 100%;
    transform: rotate(45deg);
    background: rgba(0, 0, 0, 0.5);
}

.vue-uploader .file-list .file-item:hover .file-remove {
    display: inline;
}

.vue-uploader .file-list .file-item .file-name {
    margin: 0;
    height: 40px;
    word-break: break-all;
    font-size: 14px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

.vue-uploader .add {
    margin-left: .5rem;
    margin-top: .1rem;
    float: left;
    text-align: center;
    border: 1px dashed #ececec;
    font-size: 14px;
    cursor: pointer;
}

.vue-uploader .text {
    height: .2rem;
    text-align: center;
    border: 1px;
    font-size: 14px;
    cursor: pointer;
    background-color: #007ACC;
    color: white;
    border-radius: .03rem
}

.vue-uploader .upload-func {
    display: flex;
    padding: 10px;
    margin: 0px;
    background: #f8f8f8;
    border-top: 1px solid #ececec;
}

.vue-uploader .upload-func .operation-box {
    flex-grow: 0;
    padding-left: 10px;
}

.vue-uploader .upload-func .operation-box button {
    padding: 4px 12px;
    color: #fff;
    background: #007ACC;
    border: none;
    border-radius: 2px;
    cursor: pointer;
}

.vue-uploader>input[type="file"] {
    display: none;
}

.mint-msgbox-wrapper {
    z-index: 8888 !important;
}
</style>
