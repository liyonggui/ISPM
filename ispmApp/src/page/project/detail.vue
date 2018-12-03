<!-- 工作台 -->
<template>
<tms-page>
    <nav-bar slot="header" :title="$t('project.projectDetailTitle')" left-arrow @click-left="toBack" />
    <custom-form slot="content" :data="formModel" :config="formConfig" ref="form"  viewFlag></custom-form>
</tms-page>
</template>

<script>
import customForm from 'src/components/custom-form.vue'

const uri = {
    getProjectList: '/sys/project/get ',

};
export default {
    components: {
        customForm
    },
    data() {
        return {

            formModel: {
                delFlag: '0'
            }
        };
    },
    methods: {
        toBack() {
            this.$router.push('/index?active=1')
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

        getProjectDetailData(projectID) {
            let rowDataId = projectID
            if (rowDataId) {
                this.$toast.loading({
                    mask: true,
                    duration: 0,
                    loadingType: 'spinner'
                });
                this.formModel = {
                    delFlag: '0'
                }

                /**查看和编辑操作 */
                if (rowDataId) {
                    this.loading = true
                    this.$axios.post(uri.getProjectList, {
                            id: rowDataId
                        })
                        .then(resp => {
                            this.formModel = resp
                           
                            this.formModel.ifReportBiuld = resp.ifReportBiuld=="Y"?true:false
                        })
                        .finally(() => {
                            this.$toast.clear();
                        })
                }
            }
        },
    },
    mounted() {
        this.addEventBackButtonBack()
        this.getProjectDetailData(this.$route.query.id)     
    },
    computed: {

        formConfig() {
            return [
                {
                    componentType: 'input',
                    prop: 'name',
                    label: this.$t('project.name'), //项目名称
                    componentProp: {
                        maxlength: 64,
                    },
                    required: true
                },
                {
                    componentType: 'input',
                    prop: 'code',
                    label: this.$t('project.code'), //项目编号
                    componentProp: {
                        maxlength: 64,
                    },
                    required: true
                },
                {
                    componentType: 'input',
                    prop: 'engineerCode',
                    label: this.$t('project.engineerCode'), //工程编号
                    componentProp: {
                        maxlength: 64,
                    },
                    required: true
                },
                {
                    componentType: 'dictPicker',
                    prop: 'status',
                    label: this.$t('project.status'), //工程状态
                    dictName: 'project_status',
                    required: true
                },
                {
                    componentType: 'input',
                    prop: 'projectInvestment',
                    label: this.$t('project.projectInvestment'), //工程投资
                    componentProp: {
                        maxlength: 15,
                        decimal: 3
                    },
                    required: true
                },
                {
                    componentType: 'dictPicker',
                    prop: 'type',
                    label: this.$t('project.type'), //项目分类
                    dictName: 'project_type',
                    required: true
                },
              
                {
                    componentType: 'area',
                    prop: 'region',
                    label: this.$t('project.region'), //所属区域
                    componentProp: {
                        maxlength: 255
                    },
                    required: true
                },
                {
                    componentType: 'input',
                    prop: 'address',
                    label: this.$t('project.address'), //项目地址
                    componentProp: {
                        maxlength: 512
                    },
                    required: true
                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'checkinDate',
                    label: this.$t('project.checkinDate'), //登记时间
                    required: true,
                    viewFormat: (data) => {
                        return data.checkinDate ? data.checkinDate.slice(0, 10) : null
                    }
                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'startDate',
                    label: this.$t('project.startDate'), //开始日期
                    required: true,
                    viewFormat: (data) => {
                        return data.startDate ? data.startDate.slice(0, 10) : null
                    }
                },
                {
                    componentType: 'DatetimePicker',
                    prop: 'endDate',
                    label: this.$t('project.endDate'), //结束日期
                    required: true,
                    viewFormat: (data) => {
                        return data.endDate ? data.endDate.slice(0, 10) : null
                    }
                },
                {
                    componentType: 'input',
                    prop: 'projectContent',
                    label: this.$t('project.projectContent'), //工程简介
                    componentProp: {
                        type: 'textarea',
                        maxlength: 2048,
                    },
                    required: true
                },
                {
                    componentType: 'input',
                    componentProp: {
                        type: 'textarea',
                        maxlength: 1024
                    },
                    prop: 'remarks',
                    label: this.$t('project.remarks'), //备注
                    Col: {
                        xs: 24,
                        sm: 24,
                        md: 24
                    }
                }
            ]
        }
    }
};
</script>
