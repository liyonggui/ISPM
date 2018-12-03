<template>
<van-popup style="height:100%" v-model="show" position="bottom" :overlay="false">
    <tms-page>
        <nav-bar class="navbar" slot="header" ref="head" left-arrow left-text="返回" @click-left="toBack" />
        <div slot="content">
            <van-field :disabled="disabled" :maxlength="64" v-if="showCtrlName" input-align="right" label="组件名称" v-model="compLabel"/>

            <template v-for="(ctrl,index) in paramsForm.compAttrs">
                <van-field  maxlength="ctrl.maxlength||64" v-if="ctrl.type === 'String'||ctrl.type === 'Text'" :required="ctrl.required" :disabled="disabled==true||ctrl.disabled==true" input-align="right" :id="index" v-model="ctrl.value" :label="ctrl.label" @change="compValInputChanged(ctrl)" :type="ctrl.type === 'Text'?'textarea':'text'"
                    :placeholder="ctrl.hint">
                </van-field>
                <van-row class="van-cell" v-else-if="ctrl.type === 'Number' || ctrl.type === 'Int'">
                    <van-col span="12">{{ctrl.label}}</van-col>
                    <van-col span="10" offset="4">
                        <van-stepper v-model="ctrl.value" :disabled="disabled==true||ctrl.disabled==true" @change="compValInputChanged(ctrl)" /></van-col>
                </van-row>
                <van-cell v-else-if="ctrl.type === 'Enum'" :title="ctrl.label" :value="getSelectTranslate(ctrl)" :id="index" :required="ctrl.required" :is-link="!(disabled==true||ctrl.disabled)" @click="pickerCellClick(ctrl,index)">
                    <van-button style="margin-left: .07rem;" v-if="ctrl.value=='danger_status_2'&&showRectifyButton==true" slot="right-icon" type="warning" size="small" plain @click="$emit('toRectify')">发起整改</van-button>
                </van-cell>
                <van-cell v-else-if="ctrl.type === 'DateTime'" :title="ctrl.label" :value="ctrl.value" :id="index" :required="ctrl.required" :is-link="!(disabled==true||ctrl.disabled)" @click="datePickerCellClick(ctrl,index)">
                </van-cell>
                <van-cell v-else-if="ctrl.type === 'Color'" :title="ctrl.label" :value="ctrl.value" :id="index" :required="ctrl.required" :is-link="!(disabled==true||ctrl.disabled)" @click="colorPickerCellClick(ctrl,index)">
                    <van-row slot="right-icon" style="margin-left: 4px;">
                        <van-col span="12">
                            <div :style="'background-color: '+ctrl.value+';width:30px;height:30px;border:1px solid #454545;'"></div>
                        </van-col>
                        <van-col span="12">
                            <van-icon name="arrow" class="van-cell__right-icon" />
                        </van-col>
                    </van-row>
                </van-cell>
            </template>

            <van-popup v-model="showPopupPicker" lock-scroll position="bottom">
                <van-picker v-if="!showToolbar" ref="popupPicker" :value-key="popupValueKey" :columns="popupPickerColumns" @change="onPickerConfirm" />
                <van-picker v-if="showToolbar" ref="popupPicker" show-toolbar :value-key="popupValueKey" :columns="popupPickerColumns" @cancel="showPopupPicker=false" @confirm="onToolbarPickerConfirm" />
            </van-popup>
 
            <van-popup v-model="showDatetimePicker" lock-scroll position="bottom">
                <van-datetime-picker v-model="currentDate" type="datetime" @confirm="onDatePickerConfirm" @cancel="showDatetimePicker = false" />
            </van-popup>

            <van-popup :style="colorStyle" v-model="showColorPicker" lock-scroll position="bottom">
                <tms-page>
                    <swatches-picker slot="content" :style="colorStyle" v-model="colors"></swatches-picker>
                    <van-row slot="footer" style="width:100%">
                        <van-col span="12">
                            <van-button size="large" @click="showColorPicker=false">取消</van-button>
                        </van-col>
                        <van-col span="12">
                            <van-button size="large" @click="onColorPickerConfirm(colors)">确定</van-button>
                        </van-col>

                    </van-row>
                </tms-page>
            </van-popup>
        </div>
        <slot name="footer" slot="footer"></slot>
    </tms-page>
</van-popup>
</template>

<script>
import {
    Swatches
} from 'vue-color'
import moment from 'moment'
export default {
    components: {
        'swatches-picker': Swatches
    },
    props: {
        compAttrs: null,
        compRule: null,
        label: '',
        showCtrlName: true,
        disabled: false,
        showRectifyButton: false
    },
    data() {
        return {
            stringType: [],
            popupPickerColumns: [],
            popupValueKey: '',
            showPopupPicker: false,
            currentIndex: 0,
            showDatetimePicker: false,
            currentDate: new Date(),
            showColorPicker: false,
            colors: '',
            colorStyle: '',
            colorSetStyle: [],
            show: false,
            popupPicker: [],
            showToolbar:false
        }
    },
    computed: {
        compLabel: {
            get() {
                return this.label.trim()
            },
            set(val) {
                
                this.$emit('update:label', val.trim())
            }
        },
        paramsForm: {
            get() {
                return {
                    compAttrs: this.compAttrs
                }
            },
        },

    },
    watch: {
        show(value) {
            if (value) {
                this.addEventBackButtonBack()
            } else {
                this.showPopupPicker = false
                this.showDatetimePicker = false
                this.showColorPicker = false
            }

        },
    },
    methods: {
        toBack() {
            if (this.showPopupPicker == true || this.showDatetimePicker == true || this.showColorPicker == true) {
                this.showPopupPicker = false
                this.showDatetimePicker = false
                this.showColorPicker = false
            } else {
                this.$emit('callback')
                this.show = false
            }

        },
        //监听返回按钮_按返回键后返回
        addEventBackButtonBack() {
            //监听返回按钮
            if (sessionStorage.plusready === "done") {
                plus.key.removeEventListener("backbutton", () => {
                    plus.runtime.quit();
                });
                plus.key.addEventListener("backbutton", () => {
                    this.toBack();
                });
            }
        },
        compValInputChanged(ctrl) {  
            this.$nextTick(() => {
               if  (ctrl.value.trim()) ctrl.value =   ctrl.value.trim()
                this.$emit('compValInputChanged', ctrl)
            })
        },
 
        pickerCellClick(ctrl, index) {
            if (ctrl.disabled||this.disabled) { 
                return
            }
            if(ctrl.name=="deviceId")
            {
                this.showToolbar = true
            }
            else
            {
                this.showToolbar = false  
            }
            this.popupPickerColumns = [{
                values: ctrl.opts
            }]
            this.popupValueKey = 'label';
            this.showPopupPicker = true
            this.currentIndex = index
            let flag = false;
            this.popupPickerColumns[0].values.forEach((item, eindex) => {
                if (item.value === ctrl.value) {
                    flag = true;
                    this.$nextTick(() => {
                        this.$refs.popupPicker.setIndexes([eindex]);
                    })
                    console.log(eindex)
                }
            })
            if (!flag) {
                this.$refs.popupPicker.setIndexes([0])
            }

        },
        onPickerConfirm(picker, item, index) {
            let comp = this.compAttrs
            comp[this.currentIndex].value = item[0].value
            this.$set(this.compAttrs, comp)
            // let setValue ={target:{value:''}}
            // setValue['target']['value']= e.value
            this.compValInputChanged(comp[this.currentIndex])
            if(this.showToolbar)
            {
                 this.showPopupPicker = false
            }
        },
        onToolbarPickerConfirm(e)
        {
            this.showPopupPicker = false
            let comp = this.compAttrs
            comp[this.currentIndex].value = e[0].value
            this.$set(this.compAttrs, comp)
            this.compValInputChanged(comp[this.currentIndex])
        },
        datePickerCellClick(ctrl, index) {
            if (ctrl.disabled||this.disabled) { 
                return
            }
       
            this.currentDate =ctrl.value? moment(ctrl.value)._d:new Date()
            this.showDatetimePicker = true
            this.currentIndex = index
        },
        onDatePickerConfirm(e) {
            this.showDatetimePicker = false
            let comp = this.compAttrs
            comp[this.currentIndex].value = moment(e).format('YYYY-MM-DD HH:mm:ss')
            this.$set(this.compAttrs, comp)
            this.compValInputChanged(comp[this.currentIndex])
        },

        colorPickerCellClick(ctrl, index) {
            if (ctrl.disabled||this.disabled) { 
                return
            }
            this.showColorPicker = true
            this.currentIndex = index
        },
        onColorPickerConfirm(e) {
            this.showColorPicker = false
            let comp = this.compAttrs
            comp[this.currentIndex].value = e.hex
            this.$set(this.compAttrs, comp)
            this.compValInputChanged(comp[this.currentIndex])

        },
        //翻译字典
        getSelectTranslate(ctrl) {
                if (ctrl.opts) {
                    let param = ctrl.opts.filter(item => {
                        return item.value === ctrl.value
                    })
                    if (0 === param.length) {
                        return ''
                    } else {
                        return param[0].label
                    }
                }   
        }
    },
    mounted() {
        this.colorStyle = "height:" + document.documentElement.clientHeight + "px;max-height: unset"
    }
}
</script>

<style lang="less">
.vc-swatches {
    width: unset !important;
    overflow-y: unset !important;
    .vc-swatches-box {
        padding: 16px 0 6px 36px !important;
    }
}
</style>
