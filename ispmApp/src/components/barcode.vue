<!--barcode-->
<!--@author LiFanLingJue-->
<!--@date 2017/11/13-->
<template lang="html">
    <van-popup class="barcode c_flex c_direction_v" v-model="show" lock-scroll position="right">
        <nav-bar left-arrow :left-text="$t('public.back')"
                 @click-left="toBack"
                 :right-text="$t('public.gallery')"
                 @click-right="galleryHandler"
                 :title="$t('public.scanTitle')">
        </nav-bar>
        <div class="c_flex_1 barcodeContainer">
            <div id="barcodeId" class="c_flex c_j_center c_a_center">
                <div style="color:#fff;">{{loadingText}}</div>
            </div>
        </div>
    </van-popup>
</template>

<script>
    export default {
        data() {
            return {
                scan: null,
                toggleLight: false,
                loadingText: this.$t('public.loadingText'),
                show: false
            }
        },
        methods: {
            startRecognize() {
                if (sessionStorage.plusready === 'done') {
                    this.scan = new plus.barcode.Barcode('barcodeId', [plus.barcode.QR], {
                        frameColor: '#00FF00',
                        scanbarColor: '#00FF00'
                    });
                    this.scan.onmarked = this.onMarked;
                    this.startScan();
                }
            },
            onMarked(type, code, file) {
                switch (type) {
                    case plus.barcode.QR:
                        type = 'QR';
                        break;
                    default:
                        alert('扫描的不是QR Code！');
                }
                this.toBack();
                this.$nextTick(() => {
                    this.$emit('callback', code);
                })
            },
            startScan() {
                if (sessionStorage.plusready === 'done') {
                    this.loadingText = "";
                    this.scan.start();
                }
            },
            closeScan() {
                if (sessionStorage.plusready === 'done') {
                    this.scan.close();
                }
            },
            setFlash() {
                if (sessionStorage.plusready === 'done') {
                    this.toggleLight = !this.toggleLight;
                    this.scan.setFlash(this.toggleLight);
                }
            },

            gallerySuccessCB(path) {
                plus.barcode.scan(path, this.onMarked, (error) => {
                    plus.nativeUI.alert('无法识别此图片');
                });
            },

            galleryErrorCB(error) {
                console.log('errorCB: ' + JSON.stringify(error))
            },

            toBack(e) {
                this.$emit('callback')
                this.show = false
            },

            galleryHandler() {
                if (sessionStorage.plusready === 'done') {
                    plus.gallery.pick(this.gallerySuccessCB, this.galleryErrorCB, {
                        filter: "image",
                        multiple: false
                    })
                }
            },
            //监听返回按钮
            addEventBackButtonBack() {
                if (sessionStorage.plusready === "done") {
                    plus.key.removeEventListener("backbutton", () => {
                        plus.runtime.quit();
                    });
                    plus.key.addEventListener("backbutton", () => {
                        this.toBack();
                    });
                }
            },
        },
        watch: {
            show(value) {
                if (value) {
                    this.$nextTick(() => {
                        setTimeout(() => {
                            this.startRecognize();
                        }, 500)
                    });
                } else {
                    this.closeScan();
                    this.loadingText = this.$t('public.loadingText');
                }
				this.addEventBackButtonBack()
            }
        } 
    }
</script>

<style scoped lang="less" type="text/less">
    .barcode {
        height: 100%;
        width: 100%;
        background: whitesmoke;
        .barcodeContainer {
            #barcodeId {
                background: #000;
                height: 100%;
                width: 100%;
            }
        }
    }
</style>
