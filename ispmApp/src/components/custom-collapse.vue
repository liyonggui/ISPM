<!--custom-collapse-->
<!--@author LiFanLingJue-->
<!--@date 2018/8/20-->
<template lang="html">
    <div class="customCollapse">
        <div class="content" ref="content">
            <div>
                <slot></slot>
            </div>
        </div>
        <div class="operation">
            <span @click.stop="currentShow = !currentShow">
                {{currentShow ? $t('public.collapseShow') : $t('public.collapseHide')}}
            </span>
        </div>
    </div>
</template>

<script>
    export default {
        data() {
            return {
                currentShow: false
            }
        },
        watch: {
            currentShow(val) {
                let contentEl = this.$refs.content;
                contentEl.style.height = val ? contentEl.children[0].offsetHeight + 'px' : 0;
            }
        },
        mounted() {
        }
    }
</script>

<style scoped lang="less" type="text/less">
    .customCollapse {
        border-top: 1px solid #e5e5e5;
        .content {
            overflow: hidden;
            height: 0;
            transition: height .3s ease-in-out;
        }
        .operation {
            color: #01a5fa;
            font-size: .14rem;
            text-align: center;
            span {
                display: inline-block;
                line-height: .3rem;
                height: .3rem;
            }
        }
    }
</style>
