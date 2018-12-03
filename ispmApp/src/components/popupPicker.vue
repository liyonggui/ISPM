<!--popupPicker-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/14-->
<template lang="html">
    <van-popup v-model="show" lock-scroll position="bottom">
        <van-picker @change="change" :columns="columns" v-bind="$attrs"/>
    </van-popup>
</template>

<script>
    export default {
        props: {
            value: {type: [String, Object]},
            columns: {type: Array, required: true},
            config: {type: Object}
        },
        data() {
            return {
                show: false,
                currentValue: ''
            }
        },
        methods: {
            change(vNode, value, index) {
                this.currentValue = value[0];
                this.$emit('change', this.currentValue);
            }
        },
        watch: {
            show(val) {
                if (val) {
                    let flag = false;
                    this.columns[0].values.forEach((item, index) => {
                        if (this.config.componentType === 'dictPicker') {
                            if (item.value === this.value) {
                                flag = true;
                                this.currentValue = item;
                                this.columns[0].defaultIndex = index;
                            }
                        } 
                        else if (this.config.componentType === 'bizDictPicker') {   
                           if(this.value)
                           {
                                if (item[this.config.selectCode]=== this.value) {
                                    flag = true;
                                    this.currentValue = item;
                                    this.columns[0].defaultIndex = index;
                                }
                           }
                        } 
                        else {
                            if (item[this.config.componentProp.displayField] === this.value[this.config.componentProp.displayField]) {
                                flag = true;
                                this.currentValue = item;
                                this.columns[0].defaultIndex = index;
                            }
                        }
                    })
                    if (!flag) {
                        this.currentValue = this.columns[0].values[0];
                        this.columns[0].defaultIndex = 0;
                    }

                } else {
                    if (this.config.componentType === 'dictPicker') {
                        this.$emit('input', this.currentValue.value);
                    } 
                    else if (this.config.componentType === 'bizDictPicker') {
                        this.$emit('input', this.currentValue[this.config.selectCode]);
                    } 
                    
                    else {
                        this.$emit('input', this.currentValue);
                    }
                    this.$emit('confirm', this.currentValue);
                }
            }
        },
        mounted() {

        }
    }
</script>
