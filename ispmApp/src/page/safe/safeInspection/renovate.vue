<template>
<tms-page>
    <nav-bar slot="header" left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$t('safeInspection.rectifyTitle')">
    </nav-bar>

    <div class="content c_flex_1" ref="content" slot="content">
        <custom-form :data="formModel" :config="formConfig" ref="form"></custom-form>

      <van-cell-group v-if="!$store.state.offLine">
        <van-panel :title="$t('safeInspection.inspectionPhotos')" style="margin-bottom: .1rem">
                <image-preview :data="inspectionAttachmentIds"></image-preview>
        </van-panel>
            <van-cell  :value="$t('safeRectify.view')" :title="$t('safeRectify.rectifyPhotos')" is-link @click="scenePopup"></van-cell>
            <image-upload watermark-type="datetime" :data="attachmentIds" @callback="imageUploadCallback" :maxNumber=10 ref="imageUpload"></image-upload>
        </van-cell-group>
    </div>
    <div slot="footer">
        <van-button size="large" @click="submit">{{$t('public_button.save')}}</van-button>
    </div>
</tms-page>
</template>

<script>
import cloneDeep from 'lodash/cloneDeep'
import customForm from 'src/components/custom-form.vue'

import {
    Toast
} from 'vant'
import imagePreview from 'src/components/imagePreview.vue'
import imageUpload from '../../../components/imageUpload.vue'
import moment from 'moment'

const uri = {
    save: "/safe/safeRectify/saveRectifyFromPoint",
    start: "/activiti/safeRectify/start",
    get: "/safe/safeInspection/get",
    getCode: "/safe/safeRectify/getCode"
};
export default {
    components: {
        customForm,
        imageUpload,
        imagePreview
    },
    data() {
        return {
            formModel: {
                rectifyMan: {}
            },

            attachmentIds: [],
            inspectionAttachmentIds:[],
        };
    },

    methods: {
        toBack() {
            this.$router.push('/safe/safeInspection')
        },
        startRectify(data) {
            this.$axios
                .post(uri.start, data)
                .then(res => {
                    Toast.success(this.$t('safe_drawing_point.rectifySubmitSuccess'));
                    
                })
                .catch(err => {
                    console.log("catch")
                    console.log(err)
                })
                .finally(res => {
                    Toast.clear()
                    this.toBack()
                })
        },
        submit() {
            this.$refs.form.validate((valid) => {
                if (valid) {
                    let submitModel = cloneDeep(this.formModel);
                    submitModel.rectifyDate = moment(submitModel.rectifyDate.slice(0, 10)).format('YYYY-MM-DD HH:mm:ss')
                    submitModel.rectifyLaunchDate = moment(submitModel.rectifyLaunchDate.slice(0, 10)).format('YYYY-MM-DD HH:mm:ss')
                    let items = this.attachmentIds.map(item => {
                        return {
                            attachment: {
                                id: item
                            }
                        }
                    });
                    submitModel.items=submitModel.items.concat(items);
                    submitModel.status = 'rectify_status_0';
                    let userInfo = this.$store.state.accountInfo;

                    submitModel.checkMan = {
                        id: userInfo.id,
                        loginName: userInfo.loginName
                    };
                    submitModel.office = {
                        id: userInfo.company.id
                    };
                    submitModel.reviewMan = {
                        id: userInfo.id
                    };
                    submitModel.region = submitModel.safeDrawingPoint.drawing.region
                    submitModel.building = submitModel.safeDrawingPoint.drawing.building
                    submitModel.subdivision = submitModel.safeDrawingPoint.drawing.subdivision
                    submitModel.layer = submitModel.safeDrawingPoint.drawing.layer
                    submitModel.issuePosition =submitModel.safeDrawingPoint.name
                    delete submitModel.safeDrawingPoint
                    Toast.loading({
                        mask: true,
                        duration: 0,
                        loadingType: 'spinner'
                    });
                    this.$axios.post(uri.save, submitModel)
                        .then(resp => {
                            this.startRectify(resp)

                        })
                        .catch(() => {
                            Toast.clear();
                        })
                }
            });
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
                    this.formModel.type = resp.safeDrawingPoint.type=='point_type_1'?'rectify_type_3':'rectify_type_2'
 
                    this.formModel.drawingPointId = resp.safeDrawingPoint.id
                    this.inspectionAttachmentIds = resp.items.map(item => {
                                return item.attachment.id
                            })
                    this.formModel.objectId = resp.id
                    delete this.formModel.id
                })
                .finally(() => {
                    Toast.clear();
                })
        },
        //获取整改单编号
        getCode() {
            let params = {}
            this.$axios.post(uri.getCode, params).then((response) => {
                    if (response) {
                  this.formModel=    Object.assign({},this.formModel, {
                            rectifyListCode: response
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
        formConfig() {
            return [ 
 
                {
                    componentType: 'bizDictPicker',
                    prop: 'safeDrawingPoint.drawing.region',
                    label: this.$t('drawing.region'), //区域
                    dictName: 'region',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'safeDrawingPoint.drawing.building',
                    label: this.$t('drawing.building'), //楼宇
                    dictName: 'building',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'dictPicker',
                    prop: 'safeDrawingPoint.drawing.subdivision',
                    label: this.$t('drawing.subdivision'), //分部分项
                    dictName: 'subdivision',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: 'bizDictPicker',
                    prop: 'safeDrawingPoint.drawing.layer',
                    label: this.$t('drawing.layer'), //楼层
                    dictName: 'layer',
                    selectCode: 'id',
                    displayCode: 'name',
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: "dictPicker",
                    prop: "safeDrawingPoint.signType",
                    dictName: 'sign_type',
                    label: this.$t("safeInspection.items.drawingPointType"), // 标记点分类
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
                },
                {
                    componentType: "label",
                    prop: "safeDrawingPoint.code",
                    label: this.$t("safeInspection.items.drawingPointCode"), // 标记点编号
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
                },
                {
                    componentType: "label",
                    prop: "safeDrawingPoint.name",
                    label: this.$t("safeInspection.items.drawingPointName"), // 标记点名称
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
                },
                {
                    componentType: "label",
                    prop: "inspectionNo",
                    label: this.$t("safeInspection.inspectionNo"), // 巡查单号
                },

                {
                    componentType: "dictPicker",
                    prop: "type",
                    dictName: 'rectify_type',
                    label: this.$t("safeRectify.rectifyType"), // 整改单分类
                    componentProp: {
                        disabled: true
                    }
                },
                {
                    componentType: "input",
                    prop: "issuePositionRemarks",
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    label: this.$t("safeRectify.issuePositionRemarks"), // 问题位置描述
                    required: true,
                },
                {
                    componentType: "input",
                    prop: "issueRemarks",
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    label: this.$t("safeRectify.issueRemarks"), // 存在问题
                    required: true,
                },

                {
                    componentType: 'dictPicker',
                    prop: 'seriousLevel',
                    label: this.$t('safeRectify.seriousLevel'), //严重程度
                    dictName: 'serious_level',
                    required: true,
                },
                {
                    componentType: 'userList',
                    prop: 'rectifyMan',
                    label: this.$t('safeRectify.rectifyMan'), //整改责任人
                    componentProp: {
                        url: "/project/projectUserRole/list",
                        title: this.$t('safeRectify.rectifyMan'),
                    },
                    required: true,
                    events: {
                        'callback': (data) => {
                            //值修改后的回调函数，返回新的选中Object
                            this.formModel = Object.assign({}, this.formModel, {
                                rectifyMan: data.user
                            })
                            this.addEventBackButtonBack()
                        }
                    }
                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'rectifyLaunchDate',
                    viewFormat: (data) => {
                        return data.rectifyLaunchDate ? data.rectifyLaunchDate.slice(0, 10) : null
                    },
                    label: this.$t('safeRectify.rectifyLaunchDate'), //整改发起日期
                    componentProp: {
                        type: 'date'
                    },
                    required: true
                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'rectifyDate',
                    viewFormat: (data) => {
                        return data.rectifyDate ? data.rectifyDate.slice(0, 10) : null
                    },
                    label: this.$t('safeRectify.rectifyDate'), //要求完成整改时限
                    componentProp: {
                        type: 'date'
                    },
                    required: true
                },

                {
                    componentType: "input",
                    prop: "rectifyListName",
                    label: this.$t("safeRectify.rectifyListName"), // 整改单名称
                    required: true,
                    componentProp: {
                        maxlength: 64
                    },
                },
                {
                    componentType: "input",
                    prop: "rectifyListCode",
                    label: this.$t("safeRectify.rectifyListCode"), // 整改单编号
                    required: true,
                    componentProp: {
                        maxlength: 64,
                        disabled: true
                    },
                },
                {
                    componentType: "input",
                    prop: "rectifyOpinions",
                    label: this.$t("safeRectify.rectifyOpinions"), // 整改意见
                    componentProp: {
                        type: "textarea",
                        maxlength: 1000
                    },
                    required: true
                }
            ]
        }
    },

    beforeDestroy() {
        Toast.clear()
        sessionStorage.removeItem("safeInspectionAttach")
    },
    mounted() {
        this.getData();
        this.getCode();
        this.addEventBackButtonBack();
    }
}
</script>

<style lang="less" scoped>
.safeRectify_detail {
    height: 100%;
    width: 100%;
    background-color: whitesmoke;

    .content {
        overflow: auto;
        -webkit-overflow-scrolling: touch;
    }
}
</style>
