<template>
<tms-page class="safeCheck_detail">
    <nav-bar slot="header" left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeCheck.detailTitle')">
    </nav-bar>

    <div class="content c_flex_1" ref="content" slot="content">
        <custom-form :viewFlag="viewFlag" :data="formModel" :config="formConfig_1" ref="form1" style="margin-bottom: 0px;"></custom-form>
        <van-cell :title="$t('safeCheck.deductions')" :required="true" :value="$bizTranslate({key: 'safeCheckDictList', value: formModel.deductions}).value" :is-link="!viewFlag" @click="showDeductionsPopup = true">
            <span v-if="unSelectDeductions" class="validateFailed"
                          v-text="$t('validationTips.notSelect')"></span>
        </van-cell>
        <custom-form :viewFlag="viewFlag" :data="formModel" :config="formConfig_2" ref="form2"></custom-form>
        <van-cell-group>
            <van-cell :value="$t('public_button.view')" :title="$t('safeCheck.photoTitle')" is-link @click="scenePopup"></van-cell>
            <image-upload watermark-type="datetime" :data="attachmentIds" @callback="imageUploadCallback" :maxNumber=10 ref="imageUpload"></image-upload>
        </van-cell-group>

        <van-popup style="height:300px" :lazy-render="false" v-model="showDeductionsPopup" position="bottom">
            <van-tabs v-model="active" swipeable>
                <van-tab :title="$t('safeCheck.bigType')">
                    <!--检查大类-->
                    <van-radio-group v-model="bigTypeResult">
                        <van-cell-group>
                            <van-cell v-for="(dict,index) in bigTypeColumns" clickable :key="dict.id" :title="dict.value" @click="toggle(dict,'bigType')">
                                <van-radio :name="dict" ref="bigTypeCheckboxes" />
                            </van-cell>
                        </van-cell-group>
                    </van-radio-group>
                </van-tab>
                <van-tab :title="$t('safeCheck.checkItemType')" :disabled="checkItemTypeDisabled">
                    <!--检查项目类型-->
                    <van-radio-group v-model="checkItemTypeResult">
                        <van-cell-group>
                            <van-cell v-for="(dict,index) in checkItemTypeColumns" clickable :key="dict.id" :title="dict.value" @click="toggle(dict,'checkItemType')">
                                <van-radio :name="dict" ref="checkItemTypeCheckboxes" />
                            </van-cell>
                        </van-cell-group>
                    </van-radio-group>
                </van-tab>
                <van-tab :title="$t('safeCheck.checkItem')" :disabled="checkItemDisabled">
                    <!--检查项目-->
                    <van-radio-group v-model="checkItemResult">
                        <van-cell-group>
                            <van-cell v-for="(dict,index) in checkItemColumns" clickable :key="dict.value" :title="dict.value" @click="toggle(dict,'checkItem')">
                                <van-radio :name="dict" ref="checkItemCheckboxes" />
                            </van-cell>
                        </van-cell-group>
                    </van-radio-group>
                </van-tab>
                <van-tab :title="$t('safeCheck.deductions')" :disabled="deductionsDisabled">
                    <!--扣分项-->
                    <van-radio-group v-model="deductionsResult">
                        <van-cell-group>
                            <van-cell v-for="(dict,index) in deductionsColumns" clickable :key="dict.id" :title="dict.value" @click="toggle(dict,'deductions')">
                                <van-radio :name="dict" ref="deductionsCheckboxes" />
                            </van-cell>
                        </van-cell-group>
                    </van-radio-group>
                </van-tab>
            </van-tabs>
        </van-popup>
    </div>
    <div slot="footer" v-if="!viewFlag">
        <van-col span="12">
            <van-button v-if="formModel.checkResult =='check_result_1'" size="large" @click="submit('rectify')">{{$t('safeCheck.rectify')}}</van-button>
        </van-col>
        <van-col :span="formModel.checkResult !='check_result_1'?24:12">
            <van-button size="large" @click="submit('save')">{{$t('public_button.save')}}</van-button>
        </van-col>
    </div>
</tms-page>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import customForm from 'src/components/custom-form.vue'

import {
    Toast
} from 'vant'
import imageUpload from '../../../components/imageUpload.vue'
import moment from 'moment'

const uri = {
    save: "/safe/safeCheck/save",
    get: "/safe/safeCheck/get",
    getCode: "/safe/safeCheck/getCode",
};
export default {
    components: {
        customForm,
        imageUpload
    },
    data() {
        return {
            formModel: {},
            initFormModel: {},
            attachmentIds: [],
            viewFlag: false,
            showDeductionsPopup: false,
            //选择评分项
            active: 0,
            bigTypeResult: {},
            checkItemTypeResult: {},
            checkItemResult: {},
            deductionsResult: {},
            safeCheckDictTree: [],
            bigTypeColumns: [],
            checkItemTypeColumns: [],
            checkItemColumns: [],
            deductionsColumns: [],
            //校验扣分项是否选择
            unSelectDeductions: false,

            checkItemTypeDisabled: true,
            checkItemDisabled: true,
            deductionsDisabled: true
        };
    },

    methods: {
        toBack() {
            Toast.clear()
            this.$router.go(-1)
        },

        submit(type) {
            if (type == 'rectify' && JSON.stringify(this.formModel) == JSON.stringify(this.initFormModel)) {
                this.$router.push('/safe/safeCheck/renovate?id=' + this.formModel.id)
            }
            let valid1 = false,
                valid2 = false
            this.$refs.form1.validate((valid) => {
                valid1 = valid
            });
            this.$refs.form2.validate((valid) => {
                valid2 = valid
            });
            this.unSelectDeductions = this.formModel.deductions ? false : true
            if (valid1 && valid2 && !this.unSelectDeductions) {
                let submitModel = cloneDeep(this.formModel);
                submitModel.checkTime = moment(submitModel.checkTime.slice(0, 10)).format('YYYY-MM-DD HH:mm:ss')

                submitModel.items = this.attachmentIds.map(item => {
                    return {
                        attachment: {
                            id: item
                        }
                    }
                });

                let userInfo = this.$store.state.accountInfo;

                submitModel.checkMan = {
                    id: userInfo.id,
                    office: {
                        id: userInfo.company.id
                    }
                };

                Toast.loading({
                    mask: true,
                    duration: 0,
                    loadingType: 'spinner'
                });

                this.$axios.post(uri.save, submitModel)
                    .then(resp => {
                        if (type == 'rectify') this.$router.push('/safe/safeCheck/renovate?id=' + resp.id)
                        else this.toBack()
                    })
                    .catch(() => {
                        Toast.clear();
                    })
                    .finally(() => {
                        Toast.clear();
                    })

            }
        },

        scenePopup() {
            this.$refs.imageUpload.show = true;
        },
        imageUploadCallback(attachments) {
            this.attachmentIds = attachments
        },
        getData() {
            let itemDataId = this.$route.query.id;
            Toast.loading({
                mask: true,
                duration: 0,
                loadingType: 'spinner'
            });
            this.$axios.post(uri.get, {
                    id: itemDataId
                })
                .then(resp => {
                    this.formModel = Object.assign({}, this.formModel, resp)
                    this.initFormModel = cloneDeep(this.formModel)
                    if (resp.items && resp.items.length > 0) {
                        this.attachmentIds = resp.items.map(item => {
                            return item.attachment.id
                        })
                    }
                })
                .finally(() => {
                    Toast.clear();
                })
        },
        onClickTab(index, title) {
            if (!this.checkItemResult.id) this.active = 2
            if (!this.checkItemTypeResult.id) this.active = 1
            if (!this.bigTypeResult.id) this.active = 0
        },

        toggle(dict, type) {
            switch (type) {
                case 'bigType':
                    this.bigTypeResult = dict;
                    this.active = 1
                    this.checkItemTypeDisabled = false
                    this.bigTypeColumns.forEach(element => {
                        if (dict.id == element.id) {
                            this.checkItemTypeColumns = element.children
                        }
                    });
                    break;
                case 'checkItemType':
                    let flag = false
                    this.checkItemTypeColumns.forEach(element => {
                        if (dict.id == element.id) {
                            if (element.type == "check_type_2") {
                                this.checkItemColumns = element.children
                                this.checkItemTypeResult = dict;
                                this.active = 2
                                this.checkItemDisabled = false
                            }
                            if (element.type == "check_type_3") {
                                this.deductionsColumns = element.children
                                this.checkItemResult = dict;
                                this.active = 3
                                this.deductionsDisabled = false
                            }
                        }
                    });

                    break;
                case 'checkItem':
                    this.checkItemResult = dict;
                    this.active = 3
                    this.deductionsDisabled = false
                    this.checkItemColumns.forEach(element => {
                        if (dict.id == element.id) {
                            this.deductionsColumns = element.children
                        }
                    });
                    break;
                case 'deductions':
                    this.deductionsResult = dict;
                    this.showDeductionsPopup = false;
                    this.$set(this.formModel, 'bigType', this.bigTypeResult.id)
                    this.$set(this.formModel, 'checkItemType', this.checkItemTypeResult.id)
                    this.$set(this.formModel, 'checkItem', this.checkItemResult.id)
                    this.$set(this.formModel, 'deductions', this.deductionsResult.id)
                    this.reset()
                    break;
            }
        },
        reset() {
            this.bigTypeResult = {}
            this.checkItemTypeResult = {}
            this.checkItemResult = {}
            this.deductionsResult = {}
            this.active = 0
            this.checkItemTypeDisabled = true
            this.checkItemDisabled = true
            this.deductionsDisabled = true
        },
        confirm() {
            let result = {}
            result["bigType"] = this.bigTypeResult ? this.bigTypeResult.id : ''
            result["checkItemType"] = this.checkItemTypeResult ? this.checkItemTypeResult.id : ''
            result["checkItem"] = this.checkItemResult ? this.checkItemResult.value : ''
            result["deductions"] = this.deductionsResult ? this.deductionsResult.id : ''
            this.$emit('callback', result)
            this.show = false
        },
        initDeductions() {
            this.safeCheckDictTree = this.$getBizDictByKey('safeCheckDictTree')
            this.bigTypeColumns = this.safeCheckDictTree['children']
        },
        //获取检查单编号
        getCode() {
            let params = {}
            this.$axios.post(uri.getCode, params).then((response) => {
                    if (response) {
                        this.formModel = Object.assign({}, this.formModel, {
                            code: response
                        })
                    } else {
                        let msg = this.$t('safe_drawing_point.codeErrorMsg')
                        this.$Message.error(msg)
                    }

                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)
                })
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

    computed: {
        formConfig_1() {
            return [{
                    componentType: 'input',
                    prop: 'code',
                    label: this.$t('safeCheck.code'), //巡查单编号
                    required: true,
                    componentProp: {
                        maxlength: 32,
                        disabled: true
                    }
                },
                {
                    componentType: 'input',
                    prop: 'name',
                    label: this.$t('safeCheck.name'), //巡查单名称
                    required: true,
                    componentProp: {
                        maxlength: 32
                    }
                },
                {
                    componentType: "dictPicker",
                    prop: "type",
                    dictName: 'rectify_type',
                    required: true,
                    label: this.$t("safeCheck.type"), // 检查类型
                },
                {
                    componentType: 'bizDictPicker',
                    prop: "region",
                    label: this.$t('safeCheck.region'), //检查区域
                    dictName: 'region',
                    selectCode: 'id',
                    displayCode: 'name',
                    required: true
                },
                {
                    componentType: 'input',
                    prop: 'issuePositionRemarks',
                    label: this.$t('safeCheck.issuePositionRemarks'), //位置描述
                    required: true,
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: "bigType",
                    label: this.$t('safeCheck.bigType'), //检查大类
                    dictName: 'safeCheckDictList',
                    selectCode: 'id',
                    displayCode: 'value',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: "checkItemType",
                    label: this.$t('safeCheck.checkItemType'), //检查项目类型
                    dictName: 'safeCheckDictList',
                    selectCode: 'id',
                    displayCode: 'value',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: "checkItem",
                    label: this.$t('safeCheck.checkItem'), //检查项目
                    dictName: 'safeCheckDictList',
                    selectCode: 'id',
                    displayCode: 'value',
                    componentProp: {
                        disabled: true
                    }
                },
            ]
        },
        formConfig_2() {
            return [{
                    componentType: 'DatetimePicker',
                    prop: 'checkTime',
                    viewFormat: (data) => {
                        return data.checkTime ? data.checkTime.slice(0, 10) : null
                    },
                    label: this.$t('safeCheck.checkTime'), //检查时间
                    componentProp: {
                        type: 'date'
                    },
                    required: true
                },
                {
                    componentType: "dictPicker",
                    prop: "checkResult",
                    dictName: 'check_result',
                    required: true,
                    label: this.$t("safeCheck.checkResult"), // 检查结果
                },
                {
                    componentType: 'input',
                    prop: 'remarks',
                    label: this.$t('safeCheck.remarks'), //备注
                    required: true,
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    }
                }
            ]
        }
    },

    beforeDestroy() {
        Toast.clear()
    },
    mounted() {
        if (this.$route.query.id) {
            this.$route.query.model == "view" ? this.viewFlag = true : this.viewFlag = false
            this.getData()
        } else {
            this.getCode()
        }
        this.addEventBackButtonBack()
        this.initDeductions()

    },

}
</script>

<style lang="less">
.safeCheck_detail {
    height: 100%;
    width: 100%;
    background-color: whitesmoke;

    .content {
        overflow: auto;
        -webkit-overflow-scrolling: touch;
    }

    .van-ellipsis {
        overflow: unset;
    }

    .validateFailed {
        color: #f44;
    }
}
</style>
