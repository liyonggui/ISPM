<!--custom-form-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/31-->
<template>
<div class="customForm" ref="test">
    <van-cell-group v-for="(item, index) in config" :key="index" v-if="!item.componentHidden">
        <!--查看页或组件类型为label时-->
        <template v-if="viewFlag || item.componentType === 'label'">
            <!--自定义插槽-->
            <template v-if="item.slotName">
                <slot :name="item.slotName" v-bind="{data: data, config: item}" :id="item.prop"></slot>
            </template>

            <!--需要自定义显示查看页或label组件内容(如：日期截去时分秒，需要在业务代码处理)-->
            <van-cell v-else-if="item.viewFormat" :title="item.label" :value="item.viewFormat(data)" :id="item.prop">
            </van-cell>

            <!--label-->
            <van-cell v-else-if="item.componentType === 'label'" :title="item.label" :value="item.vModel ||getPropsByDot(data,item.prop)" :id="item.prop">
            </van-cell>

            <!--input-->
            <van-field v-else-if="item.componentType === 'input'" disabled input-align="right" :id="item.prop" v-bind="item.componentProp" v-model="item.vModel || data[item.prop]" :label="item.label">
            </van-field>
            <!--switch-->
            <van-cell v-else-if="item.componentType === 'switch'" :title="item.label" :id="item.prop">
                <van-switch slot="right-icon" v-model="item.vModel || data[item.prop]" :disabled="viewFlag || item.componentType === 'label'" />
            </van-cell>
            <!--area-->
            <van-cell v-else-if="item.componentType === 'area'" :title="item.label" :value="getAreaTranslate(item.vModel || data[item.prop])" :id="item.prop">
            </van-cell>
            <!--bizDictPicker-->
            <van-cell v-else-if="item.componentType === 'bizDictPicker'" :title="item.label" :value="getBizSelectTranslate(item)" :id="item.prop">
            </van-cell>
            <!--drawingPointList-->
            <van-cell v-else-if="item.componentType === 'drawingPointList'" :title="item.label" :value="data[item.prop]?data[item.prop].code:''" :id="item.prop">
            </van-cell>
             <!--userList-->
            <van-cell v-else-if="item.componentType === 'userList'" :title="item.label" :value="data[item.prop]?data[item.prop].name:''" :id="item.prop">
            </van-cell>
            <!--dictPicker-->
            <van-cell v-else-if="item.componentType === 'dictPicker'" :title="item.label" :value="getSelectTranslate(item)" :id="item.prop">
            </van-cell>
            <!--masterDataPicker-->
            <van-cell v-else-if="item.componentType === 'masterDataPicker'" :title="item.label" :value="item.vModel || (data[item.prop] && getPropsByDot(data[item.prop], item.componentProp.displayField))" :id="item.prop">
            </van-cell>

            <!--else-->
            <van-cell v-else :title="item.label" :value="item.vModel || data[item.prop]" :id="item.prop">
            </van-cell>
        </template>

        <template v-else>
            <!--自定义插槽-->
            <template v-if="item.slotName">
                <slot :name="item.slotName" v-bind="{data: data, config: item}" :id="item.prop"></slot>
            </template>

            <!--input-->
            <van-field :maxlength="item.componentProp?item.componentProp.maxlength:'64'"  @blur="onBlur(item,item.vModel || data[item.prop])" :disabled="item.componentProp&&item.componentProp.disabled" v-else-if="item.componentType === 'input'" clearable input-align="right" :id="item.prop" v-model="item.vModel || data[item.prop]" :label="item.label" :required="item.required" :placeholder="validating ? $t('validationTips.notInput') : null" :error="validating && !(item.vModel || data[item.prop])&&item.required" v-bind="item.componentProp" v-on="item.events">
            </van-field>
            <!--switch-->
            <van-cell v-else-if="item.componentType === 'switch'" :title="item.label" :required="item.required" :id="item.prop">
                <van-switch :disabled="item.componentProp&&item.componentProp.disabled" slot="right-icon" v-model="item.vModel || data[item.prop]" v-on="item.events" />
            </van-cell>
            <!--area-->
            <van-cell v-else-if="item.componentType === 'area'" :title="item.label" :required="item.required" :is-link="!(item.componentProp && item.componentProp.disabled)" :value="getAreaTranslate(item.vModel || data[item.prop])" :id="item.prop" @click="areaPickerCellClick(item)">
                <span v-if="validating && !getAreaTranslate(item)&&item.required" class="validateFailed"
                          v-text="$t('validationTips.notSelect')"></span>
            </van-cell>
            <!--bizDictPicker-->
            <van-cell v-else-if="item.componentType === 'bizDictPicker'" :value="getBizSelectTranslate(item)" :title="item.label" :required="item.required" :is-link="!(item.componentProp && item.componentProp.disabled)" @click="bizDictPickerCellClick(item)">
                <span v-if="validating && !getBizSelectTranslate(item)&&item.required" class="validateFailed"
                          v-text="$t('validationTips.notSelect')"></span>
            </van-cell>
            <!--userList-->
            <van-cell v-else-if="item.componentType === 'userList'" :value="data[item.prop]?data[item.prop].name:''" :title="item.label" :required="item.required" :is-link="!(item.componentProp && item.componentProp.disabled)" @click="onShowUserListPopup(item)">
                <span v-if="validating&& !data[item.prop].name && item.required" class="validateFailed"
                          v-text="$t('validationTips.notSelect')"></span>
            </van-cell>
            <!--drawingPointList-->
            <van-cell v-else-if="item.componentType === 'drawingPointList'" :value="data[item.prop]?data[item.prop].code:''" :title="item.label" :required="item.required" :is-link="!(item.componentProp && item.componentProp.disabled)" @click="onShowRectifyPointPopup(item)">
                <span v-if="validating && !data[item.prop]&&item.required" class="validateFailed"
                          v-text="$t('validationTips.notSelect')"></span>
            </van-cell>
            <!--dictPicker-->
            <van-cell v-else-if="item.componentType === 'dictPicker'" :value="getSelectTranslate(item)" :title="item.label" :required="item.required" :is-link="!(item.componentProp && item.componentProp.disabled)" @click="dictPickerCellClick(item)">
                <span v-if="validating && !getSelectTranslate(item)&&item.required" class="validateFailed"
                          v-text="$t('validationTips.notSelect')"></span>
            </van-cell>

            <!--masterDataPicker-->
            <van-cell v-else-if="item.componentType === 'masterDataPicker'" :value="item.vModel || (data[item.prop] && data[item.prop][item.componentProp.displayField])" :title="item.label" :required="item.required" :is-link="!(item.componentProp && item.componentProp.disabled)" @click="masterDataPickerCellClick(item)">
                <span
                        v-if="validating && !(item.vModel || (data[item.prop] && data[item.prop][item.componentProp.displayField]))&&item.required"
                        class="validateFailed"
                        v-text="$t('validationTips.notSelect')"></span>
            </van-cell>

            <!--DatetimePicker-->
            <van-cell v-else-if="item.componentType === 'DatetimePicker'" :value="item.viewFormat ? item.viewFormat(data) : (item.vModel || data[item.prop])" :title="item.label" :required="item.required" :is-link="!(item.componentProp && item.componentProp.disabled)" @click="DatetimePickerCellClick(item)">
                <span v-if="validating && !(item.vModel || data[item.prop])&&item.required" class="validateFailed"
                          v-text="$t('validationTips.notSelect')"></span>
            </van-cell>
        </template>
    </van-cell-group>
    <!--areaPicker选择器-->
    <van-popup v-model="areaPickerShowFlag" lock-scroll position="bottom">
        <van-area :area-list="areaList" columns-num="2" :value="currentRegion" @confirm="areaPickerConfirm" @cancel="areaPickerShowFlag = false" />
    </van-popup>
    <!--picker选择器，dictPicker、masterDataPicker共用一个-->
    <popup-picker v-model="currentCellConfig.vModel || data[currentCellConfig.prop]" :columns="popupPickerColumns" :config="currentCellConfig" v-on="currentCellConfig.events" :value-key="popupValueKey" ref="popupPicker"></popup-picker>
    <!--bizDictpicker选择器-->
    <popup-picker v-model="currentCellConfig.vModel || data[currentCellConfig.prop]" :columns="popupPickerColumns" :config="currentCellConfig" v-on="currentCellConfig.events" :value-key="popupValueKey" ref="bizPopupPicker"></popup-picker>
    <!--DatetimePicker选择器，共用一个-->
    <van-popup v-model="datetimePickerShowFlag" lock-scroll position="bottom">
        <van-datetime-picker v-model="currentDate" v-bind="currentCellConfig.componentProp" v-on="currentCellConfig.events" :formatter="datetimePickerFormatter" @confirm="datetimePickerConfirm" @cancel="datetimePickerShowFlag = false" />
    </van-popup>
    <!--drawingPointList选择器-->
    <drawingPointList   ref="drawingPointList" :title="currentCellConfig.componentType === 'drawingPointList'?currentCellConfig.componentProp.title:''" :params="currentCellConfig.componentType === 'drawingPointList'?currentCellConfig.componentProp.params:{}" :url="currentCellConfig.componentType === 'drawingPointList'?currentCellConfig.componentProp.url:''" v-on="currentCellConfig.events"></drawingPointList>
     <!--userList选择器-->
    <userList   ref="userList" :title="currentCellConfig.componentType === 'userList'?currentCellConfig.componentProp.title:''" :params="currentCellConfig.componentType === 'userList'?currentCellConfig.componentProp.params:{}" :url="currentCellConfig.componentType === 'userList'?currentCellConfig.componentProp.url:''" v-on="currentCellConfig.events"></userList>
</div>
</template>

<script>
import moment from 'moment'
import popupPicker from 'src/components/popupPicker.vue'
import pca from 'area-data/pca'
import drawingPointList from 'src/components/drawingPointList.vue'
import userList from 'src/components/userList.vue'
export default {
    props: {
        data: {
            type: Object,
            required: true
        }, //form绑定的数据
        config: {
            type: Array,
            required: true
        }, //formItem的配置项
        viewFlag: {
            type: Boolean,
            default: false
        }, //是否为查看页的标识符，当为true时走label分支，取消所有必填项校验
    },
    data() {
        return {
            validating: false,

            popupPickerColumns: [],
            currentCellConfig: {},
            popupValueKey: 'label',

            datetimePickerShowFlag: false,
            currentDate: null,
            areaPickerShowFlag: false,
            areaList: {},
            currentRegion: ''
        }
    },
    methods: {
        onBlur(config,value)
        {
            if(value) this.$set(this.data, [config.prop], value.trim())
        },
        getAreaTranslate(region) {
            if (region) {
                const splitChar = ','
                const provinceList = pca['86']
                let province = provinceList[region.split(splitChar)[0]]

                const cityList = pca[region.split(splitChar)[0]]
                let city = cityList[region.split(splitChar)[1]]
                return province + splitChar + city
            }

        },
        getSelectTranslate(config) {
            let data = this.getPropsByDot(this.data, config.prop)
            //若字段没有值 返回''
            if (config.vModel || data) {
                let translate = (value) => {
                    let translateValue = this.$translate({
                        key: config.dictName,
                        value: value,
                        code: config.selectCode ? config.selectCode : 'value'
                    });
                    return translateValue ? translateValue : value
                };

                if (typeof config.vModel === 'string' || typeof data === 'string') {
                    return translate(config.vModel || data)
                } else {
                    let result = [];
                    (config.vModel || data).forEach((item) => {
                        result.push(translate(item))
                    });
                    return result.join(',')
                }
            } else {
                return ''
            }
        },
        getPropsByDot(model, modelKey) {
            if (modelKey.indexOf('.') < 0) {
                return model[modelKey]
            }
            let key = modelKey.split('.')
            let current = model
            for (let i = 0; i < key.length; i++) {
                if (!current[key[i]]) {
                    return ''
                }
                current = current[key[i]]
            }
            return current
        },
        getBizSelectTranslate(config) {
            let data = this.getPropsByDot(this.data, config.prop)
            //若字段没有值 返回''
            if (data) {
                let translate = (value) => {
                    let translateValue = this.$bizTranslate({
                        key: config.dictName,
                        value: value,
                        code: config.selectCode ? config.selectCode : 'value'
                    })
                    //                    return translateValue ? (config.hideCode ? translateValue : `(${value})${translateValue}`) : value
                    return translateValue[config.displayCode] ? translateValue[config.displayCode] : value
                }

                if (typeof data === 'string') {
                    return translate(data)
                } else {
                    let result = []
                    data.forEach((item) => {
                        result.push(translate(item))
                    })
                    console.log(result.join(','))
                    return result.join(',')
                }
            } else {
                return ''
            }
        },
        areaPickerCellClick(config) {
            if (this.viewFlag || (config.componentProp && config.componentProp.disabled)) {
                return
            }
            let provinceList = pca['86']
            let cityList = {}
            for (let p in provinceList) {
                cityList = Object.assign({}, cityList, pca[p])
            }

            this.areaList = Object.assign({}, this.areaList, {
                'province_list': provinceList
            })
            this.areaList = Object.assign({}, this.areaList, {
                'city_list': cityList
            })
            if (config.vModel || this.data[config.prop]) {
                this.currentRegion = (config.vModel || this.data[config.prop]).split(',')[1]
            }
            this.currentCellConfig = config;
            this.areaPickerShowFlag = true
        },
        areaPickerConfirm(value) {
            let pStr
            value.forEach(element => {
                if (pStr) {
                    pStr = pStr + ',' + element.code
                } else {
                    pStr = element.code
                }
            });
            this.$set(this.data, this.currentCellConfig.prop, pStr);
            this.areaPickerShowFlag = false
        },
        dictPickerCellClick(config) {
            if (this.viewFlag || (config.componentProp && config.componentProp.disabled)) {
                return
            }
            this.popupPickerColumns = [{
                values: this.$getDictByKey(config.dictName)
            }];
            this.currentCellConfig = config;
            this.popupValueKey = 'label';
            this.$refs.popupPicker.show = true
        },
        bizDictPickerCellClick(config) {
            if (this.viewFlag || (config.componentProp && config.componentProp.disabled)) {
                return
            }
            this.popupPickerColumns = [{
                values: this.$getBizDictByKey(config.dictName)
            }];
            this.currentCellConfig = config;
            this.popupValueKey = config.displayCode;
            this.$refs.bizPopupPicker.show = true
        },
        masterDataPickerCellClick(config) {
            this.$toast.loading({
                mask: true,
                duration: 0,
                loadingType: 'spinner'
            });
            if (this.viewFlag || (config.componentProp && config.componentProp.disabled)) {
                return
            }
            let params = {};
            if (config.componentProp.params) {
                params = config.componentProp.params;
            }
            let cache = {};
            if (config.componentProp._cache) {
                cache._cache = config.componentProp._cache;
            }
            this.$axios.post(config.componentProp.url, params, cache)
                .then((resp) => {
                    let tempResp=[]
                    resp.list.forEach(element => {
                        tempResp.push(this.getPropsByDot(element, config.componentProp.displayObject))
                    });
                    this.popupPickerColumns = [{
                        values: tempResp
                    }];
                    this.currentCellConfig = config;
                    this.popupValueKey = config.componentProp.displayField;
                    this.$refs.popupPicker.show = true
                    this.$toast.clear()
                });

        },
        DatetimePickerCellClick(config) {
            if (this.viewFlag || (config.componentProp && config.componentProp.disabled)) {
                return
            }
            if (config.vModel || this.data[config.prop]) {
                this.currentDate = moment(config.vModel || this.data[config.prop])._d;
            } else {
                this.currentDate = moment()._d;
            }
            this.currentCellConfig = config;
            this.datetimePickerShowFlag = true
        },

        datetimePickerFormatter(type, value) {
            if (type === 'year') {
                return `${value}年`;
            } else if (type === 'month') {
                return `${value}月`
            } else if (type === 'day') {
                return `${value}日`
            }
            return value;
        },
        datetimePickerConfirm(value) {
            this.$set(this.data, this.currentCellConfig.prop, moment(value).format('YYYY-MM-DD HH:mm:ss'));
            this.datetimePickerShowFlag = false
        },

        validate(callback) {
            let flag = true;
            this.validating = true;
            this.config.forEach(config => {
                switch (config.componentType) {
                    case 'input':
                        if (!(config.vModel || this.data[config.prop]) && config.required) {
                            flag = false;
                        }
                        break;
                    case 'dictPicker':
                        if (!this.getSelectTranslate(config) && config.required) {
                            flag = false;
                        }
                        break;
                    case 'bizDictPicker':
                        if (!this.getBizSelectTranslate(config) && config.required) {
                            flag = false;
                        }
                        break;
                    case 'masterDataPicker':
                        if (!(config.vModel || (this.data[config.prop] && this.data[config.prop][config.componentProp.displayField])) && config.required) {
                            flag = false;
                        }
                        break;
                    case 'DatetimePicker':
                        if (!(config.vModel || this.data[config.prop]) && config.required) {
                            flag = false;
                        }
                        break;
                }
            });
            if (callback) callback(flag);
            return flag
        },
        clearValidate() {
            this.validating = false;
        },

        getPropsByDot(model, modelKey) {
            if (modelKey.indexOf('.') < 0) {
                return model[modelKey]
            }
            let key = modelKey.split('.');
            let current = model;
            for (let i = 0; i < key.length; i++) {
                if (!current[key[i]]) {
                    return ''
                }
                current = current[key[i]]
            }
            return current
        },
        getObjByDot(model, modelKey) {
            if (modelKey.indexOf('.') < 0) {
                return {
                    [modelKey]: model
                }
            }
            let key = modelKey.split('.');
            let current = model;
            for (let i = key.length - 1; i >= 0; i--) {
                current = {
                    [key[i]]: current
                }
            }
            return current
        },
 
        //显示选择危险点弹窗
        onShowRectifyPointPopup(config) {
            if (this.viewFlag || (config.componentProp && config.componentProp.disabled)) {
                return
            }
            this.currentCellConfig = config;
            this.$refs.drawingPointList.show = true
        },
 
        //显示选择user弹窗
        onShowUserListPopup(config) {
            if (this.viewFlag || (config.componentProp && config.componentProp.disabled)) {
                return
            }
            this.currentCellConfig = config;
            this.$refs.userList.show = true
        }
    },
    components: {
        popupPicker,
        drawingPointList,
        userList
    }
}
</script>

<style lang="less">
.customForm {
    margin-bottom: 10px;

    .validateFailed {
        color: #f44;
    }
}

.van-picker__frame {
    position: absolute !important;
}
</style>
