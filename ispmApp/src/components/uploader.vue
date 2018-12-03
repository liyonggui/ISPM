<template>
<div class="vue-uploader">
    <div class="file-list">
        <section v-for="(image,index) of imagesPrew" class="file-item draggable-item" :key="index">
            <div @click="show(image,index)">
                <img v-lazy="image" alt="" ondragstart="return false;">
            </div>
        </section>
        <section v-if="isShowAdd" class="file-item">
            <div id="fileSelect" :disabled="true" class="add needsclick" @click="showActionSheet">
                <span class="needsclick">+</span>
            </div>
        </section>
    </div>
    <!--
    <section v-if="images.length != 0" class="upload-func">
        <div class="progress-bar">
            <section v-if="uploading" :width="(percent * 100) + '%'">{{(percent * 100) + '%'}}</section>
        </div>
    </section>
    -->
    <input type="file" v-if="isMultiple" accept="image/jpg,image/jpeg,image/png" capture="video" @change="fileChanged" ref="file" multiple="multiple">
    <input type="file" v-if="!isMultiple" accept="image/jpg,image/jpeg,image/png" capture="video" @change="fileChanged" ref="file">
</div>
</template>

<script>
export default {
    props: {
        imagesList: {
            type: Array
        },
        //是否只读
        readonly: {
            type: Boolean,
            default: false
        },
        //是否可以多选
        isMultiple: {
            type: Boolean,
            default: false
        },
        //照片最大数量:
        max: {
            type: String,
            default: "9999"
        },
        imagesData: { // 根据服务器返回路径回显图片
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
            images: [], //图片上传到服务器之后的返回的路径。
            isShowAdd: true,
        }
    },
    // watch: { // 监听图片信息

    // },
    methods: {
        /**
         ** 将以base64的图片url数据转换为Blob
         * @param dataURI
         **文件名称
         * @param filename
         * 用url方式表示的base64图片数据
         */
        convertBase64UrlToBlob(dataURI, filename) {
            var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
            //获取文件类型如.jpg
            var filetype = '.' + mimeString.split('/')[1];

            if (sessionStorage.plusready === 'done') {
                var bitmap = new plus.nativeObj.Bitmap();
                // 从本地加载Bitmap图片 
                bitmap.loadBase64Data(dataURI, () => {
                    //    console.log('加载图片成功'); 
                    bitmap.save("_doc/" + filename + filetype, {
                        overwrite: true,
                        quality: 100
                    }, (i) => {
                        console.log('保存图片成功：' + JSON.stringify(i));
                        this.images.push(i.target);

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

                this.images.push(new File([ab], filename + filetype, {
                    type: mimeString
                }));

                this.$emit('outside', this.images);
            }
        },
        showActionSheet() {
            this.isShowAdd = false;
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
                            if (this.isMultiple == true) {
                                this.galleryImgs();
                            } else {
                                this.galleryImg();
                            }
                        } else if (e.index == 0) {
                            this.isShowAdd = true;
                        }
                    });
                } else {
                    //web端上传
                    this.$refs.file.click();
                }
            }
        },
        // 拍照上传 
        getImage() {
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
                            this.isShowAdd = true;
                        }, {
                            resolution: res,
                            format: fmt
                        }
                    )
                },
                (e) => {
                    this.isShowAdd = true;
                }

            )
        },
        //选择图片上传-单图
        galleryImg() {
            console.log("单选" + this.isMultiple);
            plus.gallery.pick((e) => {
                //alert(e.files.length);
                console.log(e);
                plus.io.resolveLocalFileSystemURL(e, (entry) => {
                    console.log("path" + entry.toLocalURL());
                    console.log("item.file", entry.toLocalURL());
                    this.compressImageUpload(entry.toLocalURL(), entry.name);
                }, (e) => {
                    plus.nativeUI.toast("读取拍照文件错误：" + e.message);
                    this.isShowAdd = true;
                });

            }, (e) => {
                console.log("取消选择图片");
                this.isShowAdd = true;
            }, {
                filename: "_doc/camera/",
                filter: "image"
            });
        },
        //选择图片上传-多图
        galleryImgs() {
            console.log("多选" + this.isMultiple);
            plus.gallery.pick((e) => {
                //alert(e.files.length);
                if ((e.files.length + this.imagesPrew.length) > this.max) {
                    plus.nativeUI.toast("最多只能选择" + this.max + "张照片");
                    this.isShowAdd = true;
                } else {
                    for (var i in e.files) {
                        console.log(e.files[i]);
                        plus.io.resolveLocalFileSystemURL(e.files[i], (entry) => {
                            console.log("path" + entry.toLocalURL());
                            console.log("item.file", entry.toLocalURL());
                            this.compressImageUpload(entry.toLocalURL(), entry.name);
                        }, (e) => {
                            plus.nativeUI.toast("读取拍照文件错误：" + e.message);
                        });
                    }
                }
            }, (e) => {
                console.log("取消选择图片");
                this.isShowAdd = true;
            }, {
                filename: "_doc/camera/",
                filter: "image",
                multiple: true
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
            let quality = 50;
            let dst = plus.io.convertLocalFileSystemURL(("_doc/camera/" + imageName));
            console.log("path" + path);
            console.log("imageName" + imageName);
            console.log("dst" + dst);
            plus.zip.compressImage({
                    src: path,
                    dst: dst,
                    overwrite: true,
                    quality: quality,
                    format: 'jpg',
                    width: plus.screen.resolutionWidth+"px",
                    height: plus.screen.resolutionHeight+"px",
                },
                (event) => {
                     console.log(plus.screen.resolutionWidth * plus.screen.scale);
                     console.log(plus.screen.resolutionHeight * plus.screen.scale);
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
                        this.imagesPrew.push(e.target.result);
                        console.log("e.target.result" + e.target.result);
                    });
                    this.images.push(path);
                    this.$emit('outside', this.images);
                    this.isShowAdd = true;
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

        show(image, index) {

            _.clone
            this.popupimage = image;
            this.$emit('show', this.popupimage, _.clone(this.imagesPrew), this.readonly ? null : index);
        },

        remove(index) {
            if (!this.readonly) {
                this.$messagebox.confirm('确认删除该图片？').then((action) => {
                    if (action === 'confirm') {
                        this.files.splice(index, 1);
                        this.images.splice(index, 1);
                        this.imagesPrew.splice(index, 1);
                        this.$emit('toBack');
                        this.$emit('outside', this.images);
                    }
                }).catch((action) => {})
            }
        },
        fileChanged() {
            const list = this.$refs.file.files
            if ((list.length + this.imagesPrew.length) > this.max) {
                let msg = "最多只能选择" + this.max + "张照片";
                this.$message({
                    message: msg,
                    type: 'error'
                })
                this.isShowAdd = true;
            } else {
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
                this.imagesPrew.push(e.target.result);
            });
            this.images.push(path);
            this.$emit('outside', this.images);
            this.isShowAdd = true;
        }
    },
    watch: {
        imagesList(val) {
            if (val.length > 0) {
                this.images = this.images.concat(val);
            }
        },
        imagesPrew(val) {
            if ((this.max <= val.length || this.max == 1) && val.length) {
                this.isShowAdd = false
            } else {
                this.isShowAdd = true
            }
        },
        imagesData(val) {
            this.imagesPrew = this.imagesData;
            if (val.length > 0) {
                val.forEach((element, index) => {
                    this.convertBase64UrlToBlob(element, index);
                });
            }
        }
    },
    mounted() {
        if (this.imagesList) {
            if (this.imagesList.length > 0) {
                this.images = this.images.concat(this.imagesList);
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
    padding: 10px 0px;
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
    margin-left: 0.1rem;
}

.vue-uploader .file-list .file-item img {
    width: 80px;
    height: 80px;
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
    width: 80px;
    height: 80px;
    margin-left: 10px;
    float: left;
    text-align: center;
    line-height: 80px;
    border: 1px dashed #ececec;
    font-size: 30px;
    cursor: pointer;
}

.vue-uploader .upload-func {
    display: flex;
    padding: 10px;
    margin: 0px;
    background: #f8f8f8;
    border-top: 1px solid #ececec;
}

.vue-uploader .upload-func .progress-bar {
    flex-grow: 1;
}

.vue-uploader .upload-func .progress-bar section {
    margin-top: 5px;
    background: #00b4aa;
    border-radius: 3px;
    text-align: center;
    color: #fff;
    font-size: 12px;
    transition: all .5s ease;
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

</style><style>.mint-msgbox-wrapper {
    z-index: 8888 !important;
    background-color: whitesmoke
}
</style>
