<style lang="less">
.content-overlay {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    background: whitesmoke;
    .content {
        overflow: auto;
        .table-container {
            width: 100%;
            border-collapse: collapse;
            .table-col {
                border-width: 1px;
                border-color: #000;
            }
        }
    }
}
</style>
<template>
    <van-popup v-model="value" class="content-overlay" position="right">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="cancel" :title="title">
        </nav-bar>
        <div class="content" ref="formdesignerdetail">
            <tile v-for="(element,index) in widgetList" :key="index" :index="index" 
                :name="element.name" :prop="element.prop || {}" :data="formData" 
                @handleChangeVal="handleChangeVal" :widget-list="widgetList"
                :disabled="true" :config="false">
            </tile>
        </div>
    </van-popup>
</template>
<script>
import { Toast } from 'vant';
import cloneDeep from 'lodash/cloneDeep';

const uri = {
    template: '/formdesigner/table/template/version/biz'
}

export default {
    data() {
        return {
            formData: {},
            widgetList: []
        }
    },
    props: {
        value: { type: Boolean, default: false, required: true },
        item: { type: Object, required: true },
        title: { type: String },
        template: {type: Object, required: true}
    },
    watch: {
        value(val) {
            if (val) {
                this.addEventBackButtonBack();
                this.getTemplate(this.template.id, this.item.id);
            }
        }
    },
    components: {},
    methods: {
        handleChangeVal(val, element) {
            this.$set(this.formData, element.prop.name, val);
        },
        cancel() {
            this.formData = {};
            this.$emit('input', false);
        },
        getTemplate(id, businessId) {
            Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' });
            this.$axios.post(uri.template, {id, businessId}).then(res => {
                // this.template = res;
                this.$set(this.template, 'properties', JSON.parse(res.properties));
                this.$set(this.template, 'structure', JSON.parse(res.structure));
                this.widgetList = cloneDeep(this.template.structure);
                // 获取详情
                this.getDetail(res.businessData);
            }).finally(res => {
                Toast.clear();
            });
        },
        // 获取详情
        getDetail (data) {
            this.formData = data;
            // 正常的数据格式处理都在组件里做了，不过由于form的validator的问题， 日期格式要优先处理一下
            for (let prop in this.template.properties) {
                if (this.template.properties[prop].category === 'datepicker' || this.template.properties[prop].category === 'timepicker') {
                    if (this.formData[prop]) {
                        this.$set(this.formData, prop, new Date(this.formData[prop]));
                    } else if (this.template.properties[prop].value) {
                        this.$set(this.formData, prop, new Date(this.template.properties[prop].value));
                    }
                } else {
                    if (!this.formData[prop] && this.template.properties[prop].value) {
                        // 对象、数组处理一下
                        if (this.template.properties[prop].value instanceof Array) {
                            if (this.template.properties[prop].value.length > 0) {
                                this.$set(this.formData, prop, this.template.properties[prop].value);
                            }    
                        } else if (this.template.properties[prop].value instanceof Object) {
                            if (this.template.properties[prop].value.name) {
                                this.$set(this.formData, prop, JSON.stringify(this.template.properties[prop].value));
                            }
                        } else {
                            this.$set(this.formData, prop, this.template.properties[prop].value);
                        }
                    }
                }
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
                    this.cancel()
                });
            }
        },
        /**calculateContentHeight 计算高度 */
        calculateContentHeight() {
            // 移除 navbar 的高度 和 审核的高度
            this.$nextTick(() => {
                const navbarHeight = 50;
                this.$refs['formdesignerdetail'].style.height = window.innerHeight - 46 - navbarHeight + 'px'
                this.$refs['formdesignerdetail'].style.marginBottom = navbarHeight + 'px'
            })
        }
    }
}
</script>
