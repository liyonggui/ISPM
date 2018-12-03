<template>
    <van-popup class="signaturePopup" v-model="currentShow" lock-scroll position="bottom" :close-on-click-overlay="false">
        <div class="signatureBox c_flex c_direction_v">
            <div class="btnBox c_flex c_j_between">
                <van-button class="confirmButton" size="small" plain @click="cancel" v-text="$t('public_button.cancel')"></van-button>
                <div class="c_flex">
                    <van-button class="confirmButton" size="small" plain @click="overwrite" v-text="$t('public_button.overwrite')"></van-button>
                    <van-button class="confirmButton" size="small" plain @click="submit">
                        {{$t('public_button.confirm')}}
                    </van-button>
                </div>
            </div>
            <div class="canvasContainer c_flex_1">
                <div class="canvasBox" ref="canvasHW">
                    <canvas @touchstart='touchStart' @touchmove='touchMove' @touchend='touchEnd' ref="canvasF" @mousedown="mouseDown" @mousemove="mouseMove" @mouseup="mouseUp"></canvas>
                </div>
            </div>
        </div>
    </van-popup>
</template>

<script>
import moment from 'moment'
import { Toast } from 'vant'

export default {
    name: "signature",
    props: {
        show: { type: Boolean, required: true }
    },
    data() {
        return {
            isRender: false,
            canvasY: 0,

            points: [],
            canvasTxt: null,
            startX: 0,
            startY: 0,
            moveY: 0,
            moveX: 0,
            endY: 0,
            endX: 0,
            w: null,
            h: null,
            isDown: false
        }
    },
    mounted() {

    },

    methods: {

        //电脑设备事件
        mouseDown(ev) {
            ev = ev || event;
            ev.preventDefault();
            if (1) {
                let obj = {
                    x: ev.offsetX,
                    y: ev.offsetY
                };
                this.startX = obj.x;
                this.startY = obj.y;
                this.canvasTxt.beginPath();
                this.canvasTxt.moveTo(this.startX, this.startY);
                this.canvasTxt.lineTo(obj.x, obj.y);
                this.canvasTxt.stroke();
                this.canvasTxt.closePath();
                this.points.push(obj);
                this.isDown = true;
            }
        },
        //移动设备事件
        touchStart(ev) {
            ev = ev || event;
            ev.preventDefault();
            if (ev.touches.length == 1) {
                window.test = this.$refs.canvasF;
                let obj = {
                    x: ev.targetTouches[0].clientX - 10,
                    y: ev.targetTouches[0].clientY - this.canvasY
                };
                this.startX = obj.x;
                this.startY = obj.y;
                this.canvasTxt.beginPath();
                this.canvasTxt.moveTo(this.startX, this.startY);
                this.canvasTxt.lineTo(obj.x, obj.y);
                this.canvasTxt.stroke();
                this.canvasTxt.closePath();
                this.points.push(obj);
            }
        },
        //电脑设备事件
        mouseMove(ev) {
            ev = ev || event;
            ev.preventDefault();
            if (this.isDown) {
                let obj = {
                    x: ev.offsetX,
                    y: ev.offsetY
                };
                this.moveY = obj.y;
                this.moveX = obj.x;
                this.canvasTxt.beginPath();
                this.canvasTxt.moveTo(this.startX, this.startY);
                this.canvasTxt.lineTo(obj.x, obj.y);
                this.canvasTxt.stroke();
                this.canvasTxt.closePath();
                this.startY = obj.y;
                this.startX = obj.x;
                this.points.push(obj);
            }
        },
        //移动设备事件
        touchMove(ev) {
            ev = ev || event;
            ev.preventDefault();
            if (ev.touches.length == 1) {
                let obj = {
                    x: ev.targetTouches[0].clientX - 10,
                    y: ev.targetTouches[0].clientY - this.canvasY
                };
                this.moveY = obj.y;
                this.moveX = obj.x;
                this.canvasTxt.beginPath();
                this.canvasTxt.moveTo(this.startX, this.startY);
                this.canvasTxt.lineTo(obj.x, obj.y);
                this.canvasTxt.stroke();
                this.canvasTxt.closePath();
                this.startY = obj.y;
                this.startX = obj.x;
                this.points.push(obj);
            }
        },
        //电脑设备事件
        mouseUp(ev) {
            ev = ev || event;
            ev.preventDefault();
            if (1) {
                let obj = {
                    x: ev.offsetX,
                    y: ev.offsetY
                };
                this.canvasTxt.beginPath();
                this.canvasTxt.moveTo(this.startX, this.startY);
                this.canvasTxt.lineTo(obj.x, obj.y);
                this.canvasTxt.stroke();
                this.canvasTxt.closePath();
                this.points.push(obj);
                this.points.push({ x: -1, y: -1 });
                this.isDown = false;
            }
        },
        //移动设备事件
        touchEnd(ev) {
            ev = ev || event;
            ev.preventDefault();
            if (ev.touches.length == 1) {
                let obj = {
                    x: ev.targetTouches[0].clientX - 10,
                    y: ev.targetTouches[0].clientY - this.canvasY
                };
                this.canvasTxt.beginPath();
                this.canvasTxt.moveTo(this.startX, this.startY);
                this.canvasTxt.lineTo(obj.x, obj.y);
                this.canvasTxt.stroke();
                this.canvasTxt.closePath();
                this.points.push(obj);
                this.points.push({ x: -1, y: -1 });
            }
        },
        //重写
        overwrite() {
            let canvas = this.$refs.canvasF;
            this.canvasTxt.clearRect(0, 0, canvas.width, canvas.height);

            this.canvasTxt.fillStyle = '#ffffff';
            this.canvasTxt.fillRect(0, 0, canvas.width, canvas.height);
            this.points = [];
        },
        dataURLtoFile(dataurl, filename) {
            var arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1],
                bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
            while (n--) {
                u8arr[n] = bstr.charCodeAt(n);
            }
            return new File([u8arr], filename, { type: mime });
        },
        //提交签名
        cancel() {
            this.overwrite();
            this.currentShow = false
        },
        submit() {

            Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' });
            let canvas = this.$refs.canvasF;
            let dataURI = canvas.toDataURL('image/jpeg');
            let filetype = '.jpeg';
            const file = this.dataURLtoFile(dataURI, 'sign_' + moment().format('YYYY-MM-DD_HH-mm-ss') + filetype);
            let formData = new FormData();
            formData.append("file", file);
            formData.append("type", "sign");
            const config = {
                headers: {
                    "Content-Type": "multipart/form-data"
                }
            };
            const url = "/sys/attachment/fastdfs/upload";
            this.$axios.post(url, formData, config)
                .then((response) => {
                    this.$emit('onSubmit', response);
                })
                .finally(res => {
                    Toast.clear();
                    this.overwrite()
                    this.currentShow = false
                })
        },

        //获取触发事件的控件在整个页面的绝对的Y坐标
        findPositionY(oElement) {
            if (typeof (oElement.offsetParent) != 'undefined') {
                for (var posY = 0; oElement; oElement = oElement.offsetParent) {
                    posY += oElement.offsetTop;
                }
            }
            return posY;
        }
    },
    computed: {
        currentShow: {
            get() {
                if (!this.isRender && this.show) {
                    this.$nextTick(() => {
                        this.isRender = true;
                        let canvas = this.$refs.canvasF;
                        canvas.height = this.$refs.canvasHW.offsetHeight;
                        canvas.width = this.$refs.canvasHW.offsetWidth;
                        this.canvasY = this.findPositionY(canvas);
                        this.canvasTxt = canvas.getContext("2d");
                        this.canvasTxt.fillStyle = '#ffffff';
                        this.canvasTxt.fillRect(0, 0, canvas.width, canvas.height);
                    });
                }
                return this.show
            },
            set(val) {
                this.$emit('update:show', val)
            }
        },
    }
}
</script>

<style type="text/less" lang="less" scoped>
.signaturePopup {
  top: 0;
  .signatureBox {
    width: 100%;
    height: 100%;
    .btnBox {
      height: 0.4rem;
      line-height: 0.4rem;
      .confirmButton {
        color: #38f;
        border: none;
        font-size: 16px;
        line-height: 0.4rem;
        height: 0.4rem;
      }
    }
    .canvasContainer {
      padding: 0.1rem;
      .canvasBox {
        height: 100%;
        width: 100%;
        canvas {
          display: block;
          box-sizing: border-box;
          border: 1px solid #71b900;
        }
      }
    }
  }
}
</style>
